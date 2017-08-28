classdef MIC_SEQ_SRcollect<MIC_Abstract
% MIC_SEQ_SRcollect SuperResolution data collection software.
% Super resolution data collection class for Sequential microscope
% Works with Matlab Instrument Control (MIC) classes since March 2017

%  usage: SRC=MIC_SEQ_SRcollect();
%
% REQUIRES:
%   Matlab 2014b or higher
%   MIC_Abstract
%   MIC_LightSource_Abstract
%   MIC_CrystaLaser405
%   MIC_TcubeLaserDiode
%   MIC_ThorlabsLED
%   MIC_MCLNanoDrive
%   MIC_MPBLaser
%   MIC_IMGSourceCamera
%   MIC_TCubePiezo
%   MIC_StepperMotor
%   MIC_ShutterTTL
%   MIC_FlipMountTTL

% First version: Sheng Liu 
% Second version and MIC compatible version Farzin Farzam
% Lidke Lab 2017
    properties
        %Hardware objects
        SCMOS               %Main Data Collection Camera
        IRCamera;           %Active Stabilization Camera
        Stage_Piezo_X;        %Linear Piezo Stage in X direction
        Stage_Piezo_Y;        %Linear Piezo Stage in Y direction
        Stage_Piezo_Z;        %Linear Piezo Stage in Z direction
        Stage_Stepper;      %Stepper Motor State
        Lamp_850;           %LED Lamp at 850 nm
        Lamp_660;           %LED Lamp at 660 nm
        Laser_647;          %MPB 647 Laser
        Laser_405;          %ThorLabs 405 Diode Laser
        FlipMount;          %FlipMount for Laser Attenuation
        Shutter;            %Shutter for Laser Block
        
        %Static Instrument Settings (never changed during use of this class)
        SCMOS_UseDefectCorrection=0;
        IRCamera_ExposureTime;
        IRCamera_ROI=[384 639 256 511];     %IR Camera ROI Center 256
        Lamp_850_Power=5;
        Lamp_660_Power=3.2;
        SCMOS_PixelSize=.104;   %microns
        
        %Operational
        LampWait=0.1;     %Time to wait for full power to lamp (seconds)
        ExposureTimeLampFocus=.01;
        ExposureTimeLaserFocus=.05;
        ExposureTimeSequence=.001;
        ExposureTimeCapture=.01;
        NumberOfFrames=5000;
        NumberOfIterations=8;
        NumberOfPhotoBleachingIterations=8;
        StabPeriod=2;   %Time between stabilization events (seconds)
        GridCorner=[1 1]    %10x10 Full Frame Grid Corner (mm)
        SCMOS_ROI_Collect=[897 1152 897 1152];
        SCMOS_ROI_Full=[1 2048 1 2048];
        OffsetDZ=5; %Micron
        OffsetSearchZ=25; %Micron
        Use405=0;
        LaserPowerSequence=200;
        LaserPowerFocus=50;
        LaserPower405Activate=3;
        LaserPower405Bleach=5;
        IsBleach=0;
        StepperLargeStep=.05;        %Large Stepper motor step (mm)
        StepperSmallStep=.002;      %Small Stepper motor step (mm)
        PiezoStep=.1;                %Piezo step (micron)
        UseManualFindCell=0;
        
        %Files and Directories and Idx
        TopDir;
        CoverslipName;
        LabelIdx=1;
        CellGridIdx
        CurrentCellIdx=1;
        CurrentGridIdx=[1 1];
        CoverSlipOffset=[0,0,0];  %Remounting error (mm)
        
        %Control Classes
        Active_Reg;         %Active Registration with IR Camera
        Align_Reg;          %Alignment Object
        
        %Transient Properties
        GuiFigureStage
        GuiFigureMain
        
        %Other things
        SaveDir='y:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='mat'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
        
    end
    
    properties (SetAccess=protected)
        InstrumentName='MIC_SEQ_SRcollect'
    end
        
    properties (Hidden)
        StartGUI;       %Defines GUI start mode.  'true' starts GUI on object creation.
    end
    
    methods
       function obj=MIC_SEQ_SRcollect() 
            % MIC_TIRF_SRcollect constructor
            %  Constructs object and initializes all hardware
            if nargout<1
                error('MIC_Seq_SRcollect must be assigned to an output variable')
            end
            
            %Check for sample (will crash objective if mounted during setup)
            proceedstr=questdlg('Is the sample fixed on the stage?','Warning',...
                'Yes','No','No');
            if strcmp('Yes',proceedstr)
                error('Sample is fixed on the stage!  Remove the sample and restart SeqSRcollect.');
            end
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            [p,~]=fileparts(which('MIC_SEQ_SRcollect'));
            f=fullfile(p,'SEQ_PixelSize.mat');
            
            %Setup Instruments (Order well)
            obj.setup_SCMOS();
            obj.setup_Stage_Piezo();
            obj.setup_IRCamera();
            obj.setup_Lamps();
            obj.setup_Lasers();
            obj.setup_Stage_Stepper();
            obj.setup_FlipMountTTL('Dev3','Port0/Line0');
            obj.setup_ShutterTTL('Dev3','Port0/Line1');
%           obj.Align_Reg=SeqReg3DTrans(obj.SCMOS,obj.Stage_Piezo,obj.Stage_Stepper); old
            obj.Align_Reg=MIC_SeqReg3DTrans(obj.SCMOS,obj.Stage_Piezo_X,obj.Stage_Piezo_Y,obj.Stage_Piezo_Z,obj.Stage_Stepper); %new FF
            obj.Align_Reg.PixelSize=0.104;% micron
            obj.unloadSample(); % to take the stage down enought so use can mount the sample
%             obj.gui_Stage(); %Check for Gui stage new name
%             obj.gui();
            %Open GUIs
                       
       end 
       
       function setup_SCMOS(obj)
           obj.SCMOS=MIC_HamamatsuCamera;
           CamSet = obj.SCMOS.CameraSetting;
           CamSet.DefectCorrection.Bit=1;
           obj.SCMOS.setCamProperties(CamSet);
           obj.SCMOS.ReturnType='matlab';
           %FF: Reset, so we don't get the reset error as the SCMOS comes up
%            DcamClose(obj.SCMOS.CameraHandle)  
%            DcamGetCameras;
%            obj.SCMOS.CameraHandle=DcamOpen(obj.SCMOS.CameraIndex);
           obj.SCMOS.setCamProperties(obj.SCMOS.CameraSetting);
       end
       
       function setup_Stage_Piezo(obj)
          % obj.Stage_Piezo=APTPiezoXYZ(); %old
           % PX=MIC_TCubePiezo('TPZserialNo','TSGserialNo','AxisLabel')
          obj.Stage_Piezo_X=MIC_TCubePiezo('81850186','84850145','X'); %new
          obj.Stage_Piezo_Y=MIC_TCubePiezo('81850193','84850146','Y'); %new
          obj.Stage_Piezo_Z=MIC_TCubePiezo('81850176','84850203','Z'); %new
          obj.Stage_Piezo_X.center(); %new
          obj.Stage_Piezo_Y.center(); %new
          obj.Stage_Piezo_Z.center(); %new
       end
        
        function setup_Stage_Stepper(obj)
            % for SEQ microscope Serial No is 70850323
            obj.Stage_Stepper=MIC_StepperMotor('70850323'); %new
           % obj.Stage_Stepper.set_position([2,2,1]); %center the stepper motor in XY
            obj.Stage_Stepper.moveToPosition(1,0) %new %y 
            obj.Stage_Stepper.moveToPosition(2,0) %new %x
        end
        
        function setup_IRCamera(obj)
            obj.IRCamera=MIC_IMGSourceCamera();
            IRCamSet = obj.IRCamera.CameraSetting;
            IRCamSet.ExposureAuto.Bit='On';
            IRCamSet.ExposureAutoReference.Value=128;
            IRCamSet.FrameRate.Bit='30.00';
            IRCamSet.GainAuto.Bit='On';
            IRCamSet.Gamma.Value=100;
            obj.IRCamera.setCamProperties(IRCamSet);
            obj.IRCamera.setup_acquisition;
            obj.IRCamera.ReturnType='matlab';
            obj.IRCamera.DisplayZoom=1;
            obj.IRCamera.ROI=obj.IRCamera_ROI;
            
%             catch ME
%                 ME
%                 error('hardware startup error');
%             end
            
            %Set save directory
            user_name = java.lang.System.getProperty('user.name'); %?
            timenow=clock; %?
            obj.SaveDir=sprintf('Y:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3)); %?
        end
        
        function setup_Lamps(obj)
            obj.Lamp_660=MIC_ThorlabsLED('Dev1','ao1'); %new
            obj.Lamp_850=MIC_ThorlabsLED('Dev1','ao0'); %new
        end
        
        function setup_Lasers(obj)
            obj.Laser_647=MIC_MPBLaser();
            obj.Laser_405=MIC_TCubeLaserDiode('64841724','Power',45,40.93,1) %new 
            % Example: TLD=MIC_TCubeLaserDiode('64841724','Power',40,40.93,1)
            %  RB 405: I_LD=69.99 mA, I_PD=981 uA, P_LD=40.15 mW. WperA=40.93
        end
        
        function setup_FlipMountTTL(obj,Device,Port,Line)
            obj.FlipMount=MIC_FlipMountTTL('Dev3','Port0/Line0'); %new
            obj.FlipMount.FilterIn; %new
        end
        
        function setup_ShutterTTL(obj,Device,Line,Port)
            obj.Shutter=MIC_ShutterTTL('Dev3','Port0/Line1'); %new
            obj.Shutter.close; %new
        end
        
        function unloadSample(obj)
            %obj.Stage_Stepper.set_position([2,2,4]); %old
             obj.Stage_Stepper.moveToPosition(1,0); %new %y
             obj.Stage_Stepper.moveToPosition(2,0); %new %x
             obj.Stage_Stepper.moveToPosition(3,4); %new %z
        end
        
        function loadSample(obj)
            %obj.Stage_Stepper.set_position([2,2,1]); %old
            obj.Stage_Stepper.moveToPosition(1,0); %new %y
            obj.Stage_Stepper.moveToPosition(2,0); %new %x
            obj.Stage_Stepper.moveToPosition(3,1); %new %z
        end
        
%         %FF: bad programming
%         function PSFcollect(obj) % defining Class as a method (acceptable? NO. Change it!)
%             a=PSFcollect(obj.SCMOS,obj.Stage_Piezo,obj.Laser_647)
%         end
       
%             function delete(obj)  % destructor
%                 %Close figures and delete instruments and control classes
%                 delete(obj.SCMOS.GuiDialog);
%                 delete(obj.Stage_Piezo);
%                 delete(obj.Stage_Stepper)
%                 obj.Align_Reg=[];
%                 delete(obj.GuiFigureStage);
%             end

%             function delete(obj)  %new
%                 %delete all objects
%                 delete(obj.GuiFigure); 
%                 close all force;
%                 clear;
%             end
            
        function Success=findCoverSlipOffset_Manual(obj,RefStruct)
            %Allow user to focus and indentify cell
            if nargin<2
                ref=uigetfile('E:\')
                myDir=obj.TopDir;
                myCoverslip=obj.CoverslipName;
                load(fullfile(myDir,myCoverslip,ref))
            end
            
            F_Ref=figure;
            imshow(RefStruct.Image,[],'Border','tight');
            F_Ref.Name='Ref Image';
            obj.Stage_Piezo_X.center();
            obj.Stage_Piezo_Y.center();
            obj.Stage_Piezo_Z.center();
            obj.gui_Stage();
            
            P0=RefStruct.StepperPos;
           % obj.Stage_Stepper.set_position(P0); %old
            obj.Stage_Stepper.moveToPosition(1,P0(1)) %new %y
            obj.Stage_Stepper.moveToPosition(2,P0(2)) %new %x
            obj.Stage_Stepper.moveToPosition(3,P0(3)) %new %z
            
            obj.SCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
            obj.SCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.SCMOS.AcquisitionType = 'focus';
            obj.SCMOS.setup_acquisition();
            obj.Lamp_660.setPower(obj.Lamp_660_Power);
            obj.SCMOS.start_focus();
            obj.Lamp_660.setPower(0);
            
            Data=obj.captureLamp('Full');
            Fig=figure;
            Fig.MenuBar='none';
            imshow(Data,[],'Border','tight');
            Fig.Name='Click To Center and Proceed';
            Fig.NumberTitle='off';
            try
                [X,Y]=ginput(1) 
                close(Fig);
            catch
                Success=0;
                return
            end
            
            ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
            DiffFromCenter_Pixels=ImSize/2-[X,Y];
            DiffFromCenter_Microns=DiffFromCenter_Pixels*obj.SCMOS_PixelSize;
            %FocusPos=obj.Stage_Stepper.Position; %old
            FocusPos=obj.Stage_Stepper.getPosition; %new
            NewPos=[FocusPos(1:2)+[DiffFromCenter_Microns(2) -DiffFromCenter_Microns(1)]/1000 FocusPos(3)];
            obj.CoverSlipOffset=NewPos-P0;
            %Move to position and show cell
            %obj.Stage_Stepper.set_position(P0+obj.CoverSlipOffset) %old
            obj.Stage_Stepper.moveToPosition(1,P0(2)+obj.CoverSlipOffset(2)) %new %y
            obj.Stage_Stepper.moveToPosition(2,P0(1)+obj.CoverSlipOffset(1)) %new %x
            obj.Stage_Stepper.moveToPosition(3,P0(3)+obj.CoverSlipOffset(3)) %new %z
            pause(1);
            Data=captureLamp(obj,'ROI');
            
            obj.CoverSlipOffset=NewPos-P0;
            FF=figure;
            imshow(Data,[],'Border','tight');
            
            proceedstr=questdlg('Does the Cell Match the Reference Image','Warning',...
                'Yes','No','No');
            if strcmp('Yes',proceedstr)
                Success=1;
            else
                Success=0;
            end
            close(FF)
            try
                close(F_Ref)
            catch
            end
            
        end
        
        function findCoverSlipOffset(obj,RefStruct)
            %Registration of first cell to find offset after remounting
            
            obj.Stage_Piezo_X.center();
            obj.Stage_Piezo_Y.center();
            obj.Stage_Piezo_Z.center();
            ROI=RefStruct.Image;
            ROI=ROI(2:end-1,2:end-1);
            ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
            RE=single(extend(ROI,ImSize,'symmetric',mean(ROI(:))));
            RE=RE-mean(RE(:));
            RE=RE/std(RE(:));
            
            P0=RefStruct.StepperPos;
            %obj.Stage_Stepper.set_position(P0); %old
            obj.Stage_Stepper.moveToPosition(1,P0(2)) %new %y
            obj.Stage_Stepper.moveToPosition(2,P0(1)) %new %x
            obj.Stage_Stepper.moveToPosition(3,P0(3)) %new %z
            
            Z=(-obj.OffsetSearchZ:obj.OffsetDZ:obj.OffsetSearchZ)/1000;
            clear CC FullStack
            NP=P0;
            
            LampRadius=1000;
            [X,Y]=meshgrid(1:ImSize,1:ImSize);
            R=sqrt((X-ImSize/2).^2+(Y-ImSize/2).^2);
            Mask=R>LampRadius;
            for zz=1:length(Z)
                NP(3)=P0(3)+Z(zz);
                %obj.Stage_Stepper.set_position(NP); %old
                obj.Stage_Stepper.moveToPosition(1,NP(2)) %new %y
                obj.Stage_Stepper.moveToPosition(2,NP(1)) %new %x
                obj.Stage_Stepper.moveToPosition(3,NP(3)) %new %z
                pause(1);
                FS=single(obj.captureLamp('Full'));
                FS(Mask)=median(FS(:));
                
                FS=FS-mean(FS(:));
                FS=FS/std(FS(:));
                FullStack(:,:,zz)=FS;
                CC(:,:,zz)=ifftshift(ifft2(fft2(RE).*conj(fft2(FS))))/numel(RE);
                
            end
            %obj.Stage_Stepper.set_position(P0); %old
            obj.Stage_Stepper.moveToPosition(1,P0(2)) %new %y
            obj.Stage_Stepper.moveToPosition(2,P0(1)) %new %x
            obj.Stage_Stepper.moveToPosition(3,P0(3)) %new %z
            
            [v,Zid]=max(max(max(CC,[],1),[],2),[],3);
            [R,C]=find(v==CC(:,:,Zid));
            
            obj.CoverSlipOffset=[-(1024-R)*obj.SCMOS_PixelSize/1000 (1024-C)*obj.SCMOS_PixelSize/1000 Z(Zid)];
            
        end
        
        function findCoverSlipFocus(obj)
            obj.Stage_Piezo_X.center();
            obj.Stage_Piezo_Y.center();
            obj.Stage_Piezo_Z.center();
            obj.gui_Stage();
            obj.SCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
            obj.SCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.SCMOS.AcquisitionType = 'focus';
            obj.SCMOS.setup_acquisition();
            obj.Lamp_660.setPower(obj.Lamp_660_Power);
            obj.SCMOS.start_focus();
            obj.Lamp_660.setPower(0);
        end
        
        function exposeGridPoint(obj)
            %Move to a grid point, take full cam lamp image, give figure to
            %click on cell.
            
            obj.Stage_Piezo_X.center();
            obj.Stage_Piezo_Y.center();
            obj.Stage_Piezo_Z.center();
            ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
            %OldPos=obj.Stage_Stepper.Position; %old
            OldPos=obj.Stage_Stepper.getPosition; %new
            
            %Move to Grid Point
            Grid_mm=obj.CurrentGridIdx*ImSize*obj.SCMOS_PixelSize/1000+obj.GridCorner;
            %obj.Stage_Stepper.set_position([Grid_mm,OldPos(3)]); %old %units are mm
            obj.Stage_Stepper.moveToPosition(1,Grid_mm(2)); %new y %units are mm
            obj.Stage_Stepper.moveToPosition(2,Grid_mm(1)); %new x
            obj.Stage_Stepper.moveToPosition(3,OldPos(3)); %new z
            
            pause(4)
            
            Data=obj.captureLamp('Full');
            Fig=figure;
            Fig.MenuBar='none';
            imshow(Data,[],'Border','tight');
            Fig.Name='Click To Center and Proceed';
            Fig.NumberTitle='off';
            try
                [X,Y]=ginput(1)
                close(Fig);
            catch
                return
            end
            
            DiffFromCenter_Pixels=ImSize/2-[X,Y]
            DiffFromCenter_Microns=DiffFromCenter_Pixels*obj.SCMOS_PixelSize
            OldPos=obj.Stage_Stepper.Position;
            NewPos=OldPos(1:2)+[DiffFromCenter_Microns(2) -DiffFromCenter_Microns(1)]/1000;
            %obj.Stage_Stepper.set_position([NewPos,OldPos(3)]); %old %units are mm
            obj.Stage_Stepper.moveToPosition(1,NewPos(2)); %new y %units are mm
            obj.Stage_Stepper.moveToPosition(2,NewPos(1)); %new x
            obj.Stage_Stepper.moveToPosition(3,OldPos(3)); %new z
            pause(1)
            %Move to next step
            obj.exposeCellROI();
        end
        
         function exposeCellROI(obj)
            %Take ROI lamp image, and allow click on cell, start lamp focus
            
            Data=obj.captureLamp('ROI');
            %Data=rand(256,512);
            Fig=figure;
            Fig.MenuBar='none';
            imshow(Data,[],'Border','tight');
            Fig.Name='Click To Center and Proceed';
            Fig.NumberTitle='off';
            try
                [X,Y]=ginput(1)
                close(Fig);
            catch
                return
            end
            
            ImSize=obj.SCMOS_ROI_Collect(2)-obj.SCMOS_ROI_Collect(1)+1;
            DiffFromCenter_Pixels=ImSize/2-[X,Y];
            DiffFromCenter_Microns=DiffFromCenter_Pixels*obj.SCMOS_PixelSize;
            %OldPos=obj.Stage_Stepper.Position; %old
            OldPos=obj.Stage_Stepper.getPosition; %new
            NewPos=OldPos(1:2)+[DiffFromCenter_Microns(2),-DiffFromCenter_Microns(1)]/1000;
            %obj.Stage_Stepper.set_position([NewPos,OldPos(3)]); %old %units are mm
            obj.Stage_Stepper.moveToPosition(1,NewPos(2)); %new y %units are mm
            obj.Stage_Stepper.moveToPosition(2,NewPos(1)); %new x
            obj.Stage_Stepper.moveToPosition(3,OldPos(3)); %new z
            
            %Move to next step
            obj.startROILampFocus();
         end
        
         function Data=captureLamp(obj,ROISelect)
             %Capture an image with Lamp
             obj.Lamp_660.setPower(obj.Lamp_660_Power);
             pause(obj.LampWait);
             switch ROISelect
                 case 'Full'
                     obj.SCMOS.ROI=obj.SCMOS_ROI_Full;
                 case 'ROI'
                     obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
             end
             obj.SCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
             obj.SCMOS.AcquisitionType = 'capture';
             obj.SCMOS.setup_acquisition();
             Data=obj.SCMOS.start_capture();
             obj.Lamp_660.setPower(0);
         end
         
         function startROILampFocus(obj)
             %Run SCMOS in focus mode with lamp to allow user to focus
             
             obj.gui_Stage();
             
             obj.SCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
             obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
             obj.SCMOS.AcquisitionType = 'focus';
             obj.SCMOS.setup_acquisition();
             obj.Lamp_660.setPower(obj.Lamp_660_Power);
             %obj.FlipMount.set_Position(1); %old % prevent high laser power
             obj.FlipMount.FilterIn; %new
             %obj.startROILaserFocusLow(); % turn on Laser focus low before starting SCMOS focus
             obj.SCMOS.start_focus();
             obj.startROILaserFocusLow(); % FF
             obj.Lamp_660.setPower(0);
             
         end
         
         function startROILaserFocusLow(obj)
             %Run SCMOS in focus mode with Low Laser Power to allow user to focus
             %Ask for save as reference. If yes, save reference.
             
             %Run SCMOS in focus mode with High Laser Power to check
             obj.SCMOS.ExpTime_Focus=obj.ExposureTimeLaserFocus;
             obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
             obj.SCMOS.AcquisitionType = 'focus';
             obj.SCMOS.setup_acquisition();
             obj.Laser_647.setPower(obj.LaserPowerFocus);
             obj.Laser_647.WaitForLaser=0;
             %obj.FlipMount.set_Position(1); %old % sets the flip mount (with ND filter inside) in front of the beam
             obj.FlipMount.FilterIn; %new
             obj.Shutter.open; % opens shutter for laser
             obj.Laser_647.on();
             obj.Lamp_660.setPower(0); %FF
             obj.SCMOS.start_focus();
             %obj.Shutter.OpenClose(0); % closes the shutter instead of turning off the laser
             %  obj.Laser_647.on(); %FF
             obj.Laser_647.off();
             obj.Shutter.close; %closes shutter in order to prevent photobleaching
             
             UseCell = questdlg('Use this cell and Save Reference Image?','Save and Use','Yes','No','Yes');
             
             switch UseCell
                 case 'Yes'
                     obj.saveReferenceImage();
                 case 'No'
             end
         end
         
         function saveReferenceImage(obj)
            %Take reference image and save
            
            %Collect ROI Image
            obj.Lamp_660.setPower(obj.Lamp_660_Power);
            pause(obj.LampWait);
            obj.SCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
            obj.SCMOS.AcquisitionType = 'capture';
            obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.SCMOS.setup_acquisition();
            Data=obj.SCMOS.start_capture();
            obj.Lamp_660.setPower(0);
            RefStruct.Image=Data;
            
            %Collect Full Image
            obj.Lamp_660.setPower(obj.Lamp_660_Power);
            pause(obj.LampWait);
            obj.SCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
            obj.SCMOS.AcquisitionType = 'capture';
            obj.SCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.SCMOS.setup_acquisition();
            Data=obj.SCMOS.start_capture();
            obj.Lamp_660.setPower(0);
            RefStruct.Image_Full=Data;
            
            %Center Piezo and add to stepper
            %PP=obj.Stage_Piezo.Position; %old
             PP=obj.Stage_Piezo.getPosition; %new: has error
            obj.Stage_Piezo.center();
            %PPC=obj.Stage_Piezo.Position; %old
             PP=obj.Stage_Piezo.getPosition; %new: has error
            OS=PP-PPC;
            %SP=obj.Stage_Stepper.Position; %old: has error
             SP=obj.Stage_Stepper.getPosition; %new
            SP(3)=SP(3)+OS(3)/1000;
            RefStruct.StepperPos=SP;
            
            %This is now just the center position
            RefStruct.PiezoPos=PPC;
            
            RefStruct.GridIdx=obj.CurrentGridIdx;
            RefStruct.CellIdx=obj.CurrentCellIdx;
            
            [~,~]=mkdir(obj.TopDir);
            [~,~]=mkdir(fullfile(obj.TopDir,obj.CoverslipName));
            
            FN = sprintf('Reference_Cell_%2.2d.mat',obj.CurrentCellIdx);
            FileName=fullfile(obj.TopDir,obj.CoverslipName,FN);
            F=matfile(FileName);
            F.Properties.Writable = true; % so we don't get the error "F.Properties.Writable is False." 
            F.RefStruct=RefStruct;
            
            %Update cell count
            obj.CurrentCellIdx=obj.CurrentCellIdx+1;
         end
         
         function startROILaserFocusHigh(obj)
            %Run SCMOS in focus mode with High Laser Power to check
            obj.SCMOS.ExpTime_Focus=obj.ExposureTimeSequence;
            obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.SCMOS.AcquisitionType = 'focus';
            obj.SCMOS.setup_acquisition();
            %obj.Laser_647.setPower(obj.LaserPowerSequence); %old
            obj.Laser_647.setPower(obj.LaserPowerSequence); %new
            obj.Laser_647.WaitForLaser=0;
            obj.Shutter.open; %open shutter
           % obj.FlipMount.set_Position(0); %old %moves away the ND filter
            obj.FlipMount.FilterOut; %new
            obj.Laser_647.on();
            obj.SCMOS.start_focus();
            obj.Laser_647.off();
         end
        
         function startSequence(obj,RefStruct,LabelID)
            %Collects and saves an SR data Set
            
            %Setup file saving
            
            if ~obj.IsBleach
                [~,~]=mkdir(obj.TopDir);
                [~,~]=mkdir(fullfile(obj.TopDir,obj.CoverslipName));
                DN=fullfile(obj.TopDir,obj.CoverslipName,sprintf('Cell_%2.2d',RefStruct.CellIdx),sprintf('Label_%2.2d',LabelID));
                [~,~]=mkdir(DN);
                TimeNow=clock;
                DateString=[num2str(TimeNow(1)) '-' num2str(TimeNow(2))  '-' num2str(TimeNow(3)) '-' num2str(TimeNow(4)) '-' num2str(TimeNow(5))];
                FN=sprintf('Data_%s.mat',DateString);
                FileName=fullfile(DN,FN);
                F=matfile(FileName);
            end
            
            %Move to Cell
            %obj.Stage_Stepper.set_position(RefStruct.StepperPos+obj.CoverSlipOffset); %old 
            obj.Stage_Stepper.moveToPosition(RefStruct.StepperPos(1)+obj.CoverSlipOffset(1)); %new %y
            obj.Stage_Stepper.moveToPosition(RefStruct.StepperPos(2)+obj.CoverSlipOffset(2)); %new %x
            obj.Stage_Stepper.moveToPosition(RefStruct.StepperPos(3)+obj.CoverSlipOffset(3)); %new %z
            obj.Stage_Piezo.center();
            
            %Align
            obj.Lamp_660.setPower(obj.Lamp_660_Power);
            pause(obj.LampWait);
            obj.SCMOS.ExpTime_Capture=obj.ExposureTimeCapture; %need to update when changing edit box
            obj.SCMOS.AcquisitionType = 'capture';
            obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.SCMOS.setup_acquisition();
            obj.Align_Reg.Image_Reference=RefStruct.Image;
            obj.Align_Reg.MaxIter=50;
            try %So that if alignment fails, we don't stop auto collect for other cells
                obj.Align_Reg.align2imageFit();
            catch
                warning('Problem with Align_Reg.align2imageFit()')
                return
            end
            obj.Lamp_660.setPower(0);
            
            %Setup Stabilization
            obj.Active_Reg=ActiveReg3D(obj.IRCamera,obj.Stage_Piezo);
            obj.Lamp_850.SetPower(obj.Lamp_850_Power);
            obj.Active_Reg.takeRefImageStack();
            obj.Active_Reg.Period=obj.StabPeriod;
            obj.Active_Reg.start();
            
            %Setup sCMOS for Sequence
            obj.SCMOS.ExpTime_Sequence=obj.ExposureTimeSequence;
            obj.SCMOS.SequenceLength=obj.NumberOfFrames;
            obj.SCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.SCMOS.AcquisitionType = 'sequence';
            obj.SCMOS.setup_acquisition();
            
            %Start Laser
            
            %obj.FlipMount.set_Position(0); %old % moves away the ND filter from the beam
            obj.FlipMount.FilterOut; %new
            %obj.Shutter.OpenClose(1); % opens shutter before the Laser turns on
            if obj.Use405
                obj.Laser_405.setPower(obj.LaserPower405Activate);
            end
            if obj.IsBleach
                obj.Laser_405.setPower(obj.LaserPower405Bleach);
            end
            
            %Collect Data
            if obj.IsBleach
                for nn=1:obj.NumberOfPhotoBleachingIterations
                    obj.Shutter.open; % opens shutter before the Laser turns on
                    Data=obj.SCMOS.start_sequence();
                    S=sprintf('F.Data%2.2d=Data;',nn);
                    eval(S);
                    obj.Shutter.close; % closes shutter before the Laser turns on
                end
                
            else
                
                for nn=1:obj.NumberOfIterations
                    obj.Shutter.open; % opens shutter before the Laser turns on
                    Data=obj.SCMOS.start_sequence();
                    if ~obj.IsBleach %Append Data
                        obj.Shutter.close;
                        S=sprintf('F.Data%2.2d=Data;',nn);
                        eval(S);
                        %obj.Shutter.open;
                    end
                    obj.Shutter.close; % closes shutter before the Laser turns on
                end
                
                %End Laser
                %     obj.Laser_647.off();
                obj.Shutter.close; % closes the shutter instead of turning off the Laser
                %obj.FlipMount.set_Position(1); %old % moves back the ND filter in front of the beam
                obj.FlipMount.FilterIn; %new
                obj.Laser_405.setPower(0);
                
                %End Active Stab
                obj.Active_Reg.stop();
                
                %Save Everything
                if ~obj.IsBleach %Append Data
                    Cam=struct(obj.SCMOS);
                    Cam.FigureHandle=[];
                    Cam.ImageHandle=[];
                    F.Camera=Cam;
                    F.Active=obj.Active_Reg.exportState();
                    F.Align=obj.Align_Reg.exportState();
                end
                
                %delete Active_Reg
                obj.Active_Reg.Timer
                delete(obj.Active_Reg);
            end
         end
            
         function autoCollect(obj,StartCell,RefDir)
                %This takes all SR data using saved reference data
                
                if nargin<3 %Ask for directory with Reference files
                    RefDir=uigetdir(obj.TopDir);
                end
                
                if nargin<2 %Ask for directory with Reference files
                    StartCell=1;
                end
                
                %Find number of cells, filenames, etc
                FileList=dir(fullfile(RefDir,'Reference_Cell*'));
                NumCells=length(FileList);
                
                obj.Shutter.close; % close shutter before the Laser turns on
                obj.Laser_647.WaitForLaser=0;
                obj.FlipMount.set_Position(0); %old % moves away the ND filter from the beam
                obj.FlipMount.FilterOut; %new 
                obj.Laser_647.setPower(obj.LaserPowerSequence);
                obj.Laser_647.on();
                
                %Loop over cells
                for nn=StartCell:NumCells 
                    
                    %Create or load RefImageStruct
                    FileName=fullfile(RefDir,FileList(nn).name);
                    F=matfile(FileName);
                    RefStruct=F.RefStruct;
                    if (obj.UseManualFindCell)&&(nn==StartCell)
                        S=obj.findCoverSlipOffset_Manual(RefStruct);
                        obj.CoverSlipOffset
                        if ~S;return;end
                    end
                    
                    obj.startSequence(RefStruct,obj.LabelIdx);
                    
                    if nn==StartCell %update coverslip offset
                        %obj.CoverSlipOffset=obj.Stage_Stepper.Position-RefStruct.StepperPos; %old
                        obj.CoverSlipOffset=obj.Stage_Stepper.getPosition-RefStruct.StepperPos; %new
                    end
                end
                %obj.FlipMount.set_Position(1); %old % moves away the ND filter from the beam
                obj.FlipMount.FilterOut; %new
                obj.Laser_647.off();
         end 
        
            %Stage Controls --------------------------------
            function moveStepperUpLarge(obj)
                %Pos=obj.Stage_Stepper.Position; %old
                Pos=obj.Stage_Stepper.getPosition; %new
                Pos(3)=Pos(3)+obj.StepperLargeStep;
                %obj.Stage_Stepper.set_position(Pos); %old
                obj.Stage_Stepper.moveToPosition(1,Pos(2)); %new %y 
                obj.Stage_Stepper.moveToPosition(2,Pos(1)); %new %x
                obj.Stage_Stepper.moveToPosition(3,Pos(3)); %new %z
            end
            function moveStepperDownLarge(obj)
                %Pos=obj.Stage_Stepper.Position; %old
                Pos=obj.Stage_Stepper.getPosition; %new
                Pos(3)=Pos(3)-obj.StepperLargeStep;
                %obj.Stage_Stepper.set_position(Pos); %old
                obj.Stage_Stepper.moveToPosition(1,Pos(2)); %new %y 
                obj.Stage_Stepper.moveToPosition(2,Pos(1)); %new %x
                obj.Stage_Stepper.moveToPosition(3,Pos(3)); %new %z
            end
            function moveStepperUpSmall(obj)
                %Pos=obj.Stage_Stepper.Position; %old
                Pos=obj.Stage_Stepper.getPosition; %new
                Pos(3)=Pos(3)+obj.StepperSmallStep;
                %obj.Stage_Stepper.set_position(Pos); %old
                obj.Stage_Stepper.moveToPosition(1,Pos(2)); %new %y 
                obj.Stage_Stepper.moveToPosition(2,Pos(1)); %new %x
                obj.Stage_Stepper.moveToPosition(3,Pos(3)); %new %z
            end
            function moveStepperDownSmall(obj)
                %Pos=obj.Stage_Stepper.Position; %old
                Pos=obj.Stage_Stepper.getPosition; %new
                Pos(3)=Pos(3)-obj.StepperSmallStep;
                %obj.Stage_Stepper.set_position(Pos); %old
                obj.Stage_Stepper.moveToPosition(1,Pos(2)); %new %y 
                obj.Stage_Stepper.moveToPosition(2,Pos(1)); %new %x
                obj.Stage_Stepper.moveToPosition(3,Pos(3)); %new %z
            end
            function movePiezoUpSmall(obj)
                %Pos=obj.Stage_Piezo.Position; %old
                Pos=obj.Stage_Piezo.getPosition; %new
                Pos(3)=Pos(3)+obj.PiezoStep;
                %obj.Stage_Piezo.set_position(Pos); %old
                obj.Stage_Piezo.setPosition(Pos); %new
            end
            function movePiezoDownSmall(obj)
               %Pos=obj.Stage_Piezo.Position; %old
                Pos=obj.Stage_Piezo.getPosition; %new
                Pos(3)=Pos(3)-obj.PiezoStep;
               %obj.Stage_Piezo.set_position(Pos); %old
                obj.Stage_Piezo.setPosition(Pos); %new
            end
            % End Stage Controls ____________________________   
           
    end
    
    methods (Static)
        
    function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all hardware objects
            % and SEQ_SRcollect settings
            
            % Children
            [Children.Camera.Attributes,Children.Camera.Data,Children.Camera.Children]=...
                obj.CameraObj.exportState();
            
            [Children.Stage.Attributes,Children.Stage.Data,Children.Stage.Children]=...
                obj.StageObj.exportState();
            
            [Children.Laser405.Attributes,Children.Laser405.Data,Children.Laser405.Children]=...
                obj.Laser405.exportState();
            
            [Children.Laser647.Attributes,Children.Laser647.Data,Children.Laser642.Children]=...
                obj.Laser647.exportState();
            
            [Children.Lamp.Attributes,Children.Lamp.Data,Children.Lamp.Children]=...
                obj.LampObj.exportState();            
            
            % Our Properties
            Attributes.ExpTime_Focus_Set = obj.ExpTime_Focus_Set;
            Attributes.ExpTime_Sequence_Set = obj.ExpTime_Sequence_Set;
            Attributes.NumFrames = obj.NumFrames;
            Attributes.NumSequences = obj.NumSequences;
            Attributes.CameraGain = obj.CameraGain;
            Attributes.CameraEMGainHigh = obj.CameraEMGainHigh;
            Attributes.CameraEMGainLow = obj.CameraEMGainLow;
            Attributes.CameraROI = obj.CameraROI;
            Attributes.CameraPixelSize=obj.PixelSize;
            
            Attributes.SaveDir = obj.SaveDir;
            Attributes.RegType = obj.RegType;
            
            % light source properties
            Attributes.Laser405 = obj.Laser405Low;
            Attributes.Laser647 = obj.Laser642Low;
            Attributes.LampPower = obj.LampPower;
            Attributes.Laser405Aq = obj.Laser405Aq;
            Attributes.Laser642Aq = obj.Laser642Aq;
            Attributes.LampAq = obj.LampAq;
            Data=[];
            end
            
        function State = unitTest()
            State = obj.exportState();
        end

    end
end