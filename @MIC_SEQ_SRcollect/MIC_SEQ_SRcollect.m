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
% Second version: Farzin Farzam  
% MIC compatible version: Farzin Farzam
% Lidke Lab 2017
% old version of this code is named SeqAutoColletc.m and can be found at
% documents>MATLAB>Instrumentation>development>SeqAutoCollect
    properties
        %Hardware objects
        CameraSCMOS               %Main Data Collection Camera
        CameraIR;           %Active Stabilization Camera
        StagePiezoX;        %Linear Piezo Stage in X direction
        StagePiezoY;        %Linear Piezo Stage in Y direction
        StagePiezoZ;        %Linear Piezo Stage in Z direction
        StageStepper;      %Stepper Motor State
        Lamp850;           %LED Lamp at 850 nm
        Lamp660;           %LED Lamp at 660 nm
        Laser647;          %MPB 647 Laser
        Laser405;          %ThorLabs 405 Diode Laser
        FlipMount;          %FlipMount for Laser Attenuation
        Shutter;            %Shutter for Laser Block
 
        %Static Instrument Settings (never changed during use of this class)
        SCMOS_UseDefectCorrection=0;
        IRCamera_ExposureTime;
        IRCamera_ROI=[513 769 385 641];     %IR Camera ROI Center 256
        Lamp850Power=7;
        Lamp660Power=12;
        SCMOS_PixelSize=.104;   %microns
        
        %Operational
        LampWait=0.1;     %Time to wait for full power to lamp (seconds)
        ExposureTimeLampFocus=.01;
        ExposureTimeLaserFocus=.2;
        ExposureTimeSequence=.01;
        ExposureTimeCapture=.2;
        NumberOfFrames=2000;
        NumberOfSequences=20; 
        NumberOfPhotoBleachingIterations=8;
        StabPeriod=5;   %Time between stabilization events (seconds)
        GridCorner=[1 1]    %10x10 Full Frame Grid Corner (mm)
        SCMOS_ROI_Collect=[897 1152 897 1152];
        SCMOS_ROI_Full=[1 2048 1 2048];
        OffsetDZ=5; %Micron
        OffsetSearchZ=25; %Micron
        Use405=0;
        LaserPowerSequence=185;
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
        ActiveReg;         %Active Registration with IR Camera
        AlignReg;          %Alignment Object
        
        %Transient Properties
        GuiFigureStage
        GuiFigureMain
        
        %Other things
        SaveDir='y:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='h5'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
        
    end
    
    properties (SetAccess=protected)
        InstrumentName='MIC_SEQ_SRcollect'
    end
        
    properties (Hidden)
        StartGUI=1;       %Defines GUI start mode.  'true' starts GUI on object creation.
    end
    
    methods
       function obj=MIC_SEQ_SRcollect()
            %Check for sample (will crash objective if mounted during setup)
            proceedstr=questdlg('Is the sample fixed on the stage?', ...
                'Warning', 'Yes', 'No', 'Yes'); % default selection 'Yes'
            if strcmp('Yes', proceedstr)
                error('Sample is fixed on the stage!  Remove the sample and restart SeqSRcollect.');
            end
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            [p,~]=fileparts(which('MIC_SEQ_SRcollect'));
            f=fullfile(p,'SEQ_PixelSize.mat');
            
            %Setup Instruments (Order well)
            obj.setup_SCMOS();
            obj.setup_IRCamera();
            obj.setup_Stage_Piezo();
            obj.setup_Lamps();
            obj.setup_Lasers();
            obj.setup_Stage_Stepper();
            obj.setup_FlipMountTTL('Dev3','Port0/Line0');
            obj.setup_ShutterTTL('Dev3','Port0/Line1');
            obj.AlignReg=MIC_SeqReg3DTrans(obj.CameraSCMOS,obj.StagePiezoX,obj.StagePiezoY,obj.StagePiezoZ,obj.StageStepper); %new FF
            obj.AlignReg.PixelSize=0.104;% micron (SCMOS camera)
            obj.unloadSample(); % to take the stage down enought so use can mount the sample
            %Open GUIs
                       
       end 
       
       function delete(obj)
          delete(obj.CameraIR); 
           
       end
       
       function setup_SCMOS(obj)
           obj.CameraSCMOS=MIC_HamamatsuCamera();
           CamSet = obj.CameraSCMOS.CameraSetting;
           CamSet.DefectCorrection.Bit=1;
           obj.CameraSCMOS.setCamProperties(CamSet);
           obj.CameraSCMOS.ReturnType='matlab';
           obj.CameraSCMOS.setCamProperties(obj.CameraSCMOS.CameraSetting);
           obj.CameraSCMOS.ExpTime_Capture=0.2;
           obj.CameraSCMOS.ExpTime_Sequence=0.01;
       end
       
       function setup_Stage_Piezo(obj)
          obj.StagePiezoX=MIC_TCubePiezo('81850186','84850145','X'); %new
          obj.StagePiezoY=MIC_TCubePiezo('81850193','84850146','Y'); %new
          obj.StagePiezoZ=MIC_TCubePiezo('81850176','84850203','Z'); %new
          obj.StagePiezoX.center(); %new
          obj.StagePiezoY.center(); %new
          obj.StagePiezoZ.center(); %new
       end
        
        function setup_Stage_Stepper(obj)
            % for SEQ microscope Serial No is 70850323
            obj.StageStepper=MIC_StepperMotor('70850323'); %new
            obj.StageStepper.moveToPosition(1,2.0650); %new %y 
            obj.StageStepper.moveToPosition(2,2.2780); %new %x
            obj.StageStepper.moveToPosition(3,2); %new %z
            %NOTE: numbers provided so the center of GUI is the initial
            %position of the objective under and at the center of the
            %sample holder.
        end
        
        function setup_IRCamera(obj)
            obj.CameraIR=MIC_ThorlabsIR(); %FFtest
            obj.CameraIR.ROI=obj.IRCamera_ROI;
            obj.CameraIR.ExpTime_Capture=0.5;
            
            %             catch ME
            %                 ME
            %                 error('hardware startup error');
            %             end
            
            %Set save directory
            user_name = java.lang.System.getProperty('user.name'); %?
            timenow=clock; %? FF
            obj.SaveDir=sprintf('Y:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3)); %?
        end
        
        function setup_Lamps(obj)
            obj.Lamp660=MIC_ThorlabsLED('Dev1','ao1'); %new
            obj.Lamp850=MIC_ThorlabsLED('Dev1','ao0'); %new
        end
        
        function setup_Lasers(obj)
            obj.Laser647=MIC_MPBLaser();
            obj.Laser405=MIC_TCubeLaserDiode('64841724','Power',45,40.93,1) %new 
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
            %obj.StageStepper.set_position([2,2,4]); %old
             obj.StageStepper.moveToPosition(1,2.0650); %new %y
             obj.StageStepper.moveToPosition(2,2.2780); %new %x
             obj.StageStepper.moveToPosition(3,4); %new %z
        end
        
        function loadSample(obj)
            %obj.StageStepper.set_position([2,2,1]); %old
            obj.StageStepper.moveToPosition(1,2.0650); %new %y
            obj.StageStepper.moveToPosition(2,2.2780); %new %x
            obj.StageStepper.moveToPosition(3,1.4); %new %z
        end
            
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
            obj.StagePiezoX.center();
            obj.StagePiezoY.center();
            obj.StagePiezoZ.center();
%             obj.gui_Stage();
            
            P0=RefStruct.StepperPos; %[P0x, P0y, P0z] where P0y=obj.StageStepper.getPosition(1)
            obj.StageStepper.moveToPosition(1,P0(2)) %y
            obj.StageStepper.moveToPosition(2,P0(1)) %x
            obj.StageStepper.moveToPosition(3,P0(3)) %z
            
            obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Lamp660.setPower(obj.Lamp660Power);
            obj.CameraSCMOS.start_focus();
            obj.Lamp660.setPower(0);
            
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
%             DiffFromCenter_Pixels=ImSize/2-[X,Y];
%             DiffFromCenter_Microns=DiffFromCenter_Pixels*obj.SCMOS_PixelSize;
            FocusPosY=obj.StageStepper.getPosition(1); %y
            FocusPosX=obj.StageStepper.getPosition(2); %x
            FocusPosZ=obj.StageStepper.getPosition(3); %z
            FocusPos=[FocusPosX,FocusPosY,FocusPosZ];
%             NewPos=[FocusPos(1:2)+[-DiffFromCenter_Microns(2) DiffFromCenter_Microns(1)]/1000 FocusPos(3)];
deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm
deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
if X>1024 & Y<1024
    NewPos_X=FocusPosX-deltaX; %mm
    NewPos_Y=FocusPosY-deltaY; %mm
elseif X>1024 & Y>1024
    NewPos_X=FocusPosX-deltaX; %mm
    NewPos_Y=FocusPosY+deltaY; %mm
elseif X<1024 & Y<1024
    NewPos_X=FocusPosX+deltaX; %mm
    NewPos_Y=FocusPosY-deltaY; %mm
else
    NewPos_X=FocusPosX+deltaX; %mm
    NewPos_Y=FocusPosY+deltaY; %mm
end
NewPos=[NewPos_X,NewPos_Y,FocusPosZ]; %new
             obj.CoverSlipOffset=NewPos-P0;
            %Move to position and show cell
%             obj.StageStepper.moveToPosition(1,P0(2)+obj.CoverSlipOffset(2)) %y
%             obj.StageStepper.moveToPosition(2,P0(1)+obj.CoverSlipOffset(1)) %x
%             obj.StageStepper.moveToPosition(3,P0(3)+obj.CoverSlipOffset(3)) %z
                        obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
                        obj.StageStepper.moveToPosition(2,NewPos(1)); %new x
                        obj.StageStepper.moveToPosition(3,FocusPosZ); %new z
            
            % check with expose grid
%             OldPos_X=obj.StageStepper.getPosition(2); %new x
%             OldPos_Y=obj.StageStepper.getPosition(1); %new y
%             OldPos_Z=obj.StageStepper.getPosition(3); %new z
%             OldPos=[OldPos_X,OldPos_Y,OldPos_Z]; %new
%             deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm 
%             deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
%             if X>1024 & Y<1024
%                 NewPos_X=OldPos_X-deltaX; %mm
%                 NewPos_Y=OldPos_Y-deltaY; %mm
%             elseif X>1024 & Y>1024
%                 NewPos_X=OldPos_X-deltaX; %mm
%                 NewPos_Y=OldPos_Y+deltaY; %mm
%             elseif X<1024 & Y<1024
%                 NewPos_X=OldPos_X+deltaX; %mm
%                 NewPos_Y=OldPos_Y-deltaY; %mm
%             else
%                 NewPos_X=OldPos_X+deltaX; %mm
%                 NewPos_Y=OldPos_Y+deltaY; %mm
%             end
%             NewPos=[NewPos_X,NewPos_Y]; %new
%             obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
%             obj.StageStepper.moveToPosition(2,NewPos(1)); %new x
%             obj.StageStepper.moveToPosition(3,OldPos(3)); %new z
            %end of check
            
            pause(1);
            Data=captureLamp(obj,'ROI');
            
%             obj.CoverSlipOffset=NewPos-P0;
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
            
            obj.StagePiezoX.center();
            obj.StagePiezoY.center();
            obj.StagePiezoZ.center();
            ROI=RefStruct.Image;
            ROI=ROI(2:end-1,2:end-1);
            ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
            RE=single(extend(ROI,ImSize,'symmetric',mean(ROI(:))));
            RE=RE-mean(RE(:));
            RE=RE/std(RE(:));
            
            P0=RefStruct.StepperPos;
            obj.StageStepper.moveToPosition(1,P0(2)) %new %y
            obj.StageStepper.moveToPosition(2,P0(1)) %new %x
            obj.StageStepper.moveToPosition(3,P0(3)) %new %z
            
            Z=(-obj.OffsetSearchZ:obj.OffsetDZ:obj.OffsetSearchZ)/1000;
            clear CC FullStack
            NP=P0;
            
            LampRadius=1000;
            [X,Y]=meshgrid(1:ImSize,1:ImSize);
            R=sqrt((X-ImSize/2).^2+(Y-ImSize/2).^2);
            Mask=R>LampRadius;
            for zz=1:length(Z)
                NP(3)=P0(3)+Z(zz);
                obj.StageStepper.moveToPosition(1,NP(2)) %new %y
                obj.StageStepper.moveToPosition(2,NP(1)) %new %x
                obj.StageStepper.moveToPosition(3,NP(3)) %new %z
                pause(1);
                FS=single(obj.captureLamp('Full'));
                FS(Mask)=median(FS(:));
                
                FS=FS-mean(FS(:));
                FS=FS/std(FS(:));
                FullStack(:,:,zz)=FS;
                CC(:,:,zz)=ifftshift(ifft2(fft2(RE).*conj(fft2(FS))))/numel(RE);
                
            end
            obj.StageStepper.moveToPosition(1,P0(2)) %new %y
            obj.StageStepper.moveToPosition(2,P0(1)) %new %x
            obj.StageStepper.moveToPosition(3,P0(3)) %new %z
            
            [v,Zid]=max(max(max(CC,[],1),[],2),[],3);
            [R,C]=find(v==CC(:,:,Zid));
            
            obj.CoverSlipOffset=[-(1024-R)*obj.SCMOS_PixelSize/1000 (1024-C)*obj.SCMOS_PixelSize/1000 Z(Zid)];
            
        end
        
        function findCoverSlipFocus(obj)
            obj.StagePiezoX.center();
            obj.StagePiezoY.center();
            obj.StagePiezoZ.center();
            obj.gui_Stage();
            obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Lamp660.setPower(obj.Lamp660Power);
            obj.Lamp660.on;
            obj.CameraSCMOS.start_focus();
            obj.Lamp660.setPower(0);
        end
        
        function exposeGridPoint(obj)
            %Move to a grid point, take full cam lamp image, give figure to
            %click on cell.

            obj.StagePiezoX.center();
            obj.StagePiezoY.center();
            obj.StagePiezoZ.center();
            ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
            OldPos_X=obj.StageStepper.getPosition(2); %new
            OldPos_Y=obj.StageStepper.getPosition(1); %new
            OldPos_Z=obj.StageStepper.getPosition(3); %new
            %Move to Grid Point
            Grid_mm=obj.CurrentGridIdx*ImSize*obj.SCMOS_PixelSize/1000+obj.GridCorner;
            obj.StageStepper.moveToPosition(1,Grid_mm(2)); %new y %units are mm
            obj.StageStepper.moveToPosition(2,Grid_mm(1)); %new x
            obj.StageStepper.moveToPosition(3,OldPos_Z); %new z
            
            pause(4)
            
            Data=obj.captureLamp('Full');
            Fig=figure;
            Fig.MenuBar='none';
            imshow(Data,[],'Border','tight');
            Fig.Name='Click To Center and Proceed';
            Fig.NumberTitle='off';
            try
                [X,Y]=ginput(1)% [X,Y] goes from 1 to 2048 for each of the 
                % ROIs of each of 100 buttons on the GUI. 
                % NOTE ON ROTATION: this [X,Y] are coordinates calculated on a rotated
                % and mirror imaged of the live SCMOS 
                close(Fig);
            catch
                return
            end
            
            OldPos_X=obj.StageStepper.getPosition(2); %new x
            OldPos_Y=obj.StageStepper.getPosition(1); %new y
            OldPos_Z=obj.StageStepper.getPosition(3); %new z
            OldPos=[OldPos_X,OldPos_Y,OldPos_Z]; %new
            %find new position with respect to Motor's (0,0):
            deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm 
            deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
            if X>1024 & Y<1024
                NewPos_X=OldPos_X-deltaX; %mm
                NewPos_Y=OldPos_Y-deltaY; %mm
            elseif X>1024 & Y>1024
                NewPos_X=OldPos_X-deltaX; %mm
                NewPos_Y=OldPos_Y+deltaY; %mm
            elseif X<1024 & Y<1024
                NewPos_X=OldPos_X+deltaX; %mm
                NewPos_Y=OldPos_Y-deltaY; %mm
            else
                NewPos_X=OldPos_X+deltaX; %mm
                NewPos_Y=OldPos_Y+deltaY; %mm
            end
            
            NewPos=[NewPos_X,NewPos_Y]; %new
            obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
            obj.StageStepper.moveToPosition(2,NewPos(1)); %new x
            obj.StageStepper.moveToPosition(3,OldPos(3)); %new z
            pause(1)
            %Move to next step
            obj.exposeCellROI();
        end
        
         function exposeCellROI(obj)
            %Take ROI lamp image, and allow click on cell, start lamp focus    
            Data=obj.captureLamp('ROI');
            Fig=figure;
            Fig.MenuBar='none';
            imshow(Data,[],'Border','tight');
            Fig.Name='Click To Center and Proceed';
            Fig.NumberTitle='off';
            try
                [X,Y]=ginput(1)%coordinates with respect to top left corner of the 256by256 image
                close(Fig);
            catch
                return
            end
            
            ImSize=obj.SCMOS_ROI_Collect(2)-obj.SCMOS_ROI_Collect(1)+1;%256by256ROI
            OldPos_X=obj.StageStepper.getPosition(2); %new x
            OldPos_Y=obj.StageStepper.getPosition(1); %new y
            OldPos_Z=obj.StageStepper.getPosition(3); %new z
            OldPos=[OldPos_X,OldPos_Y,OldPos_Z]; %new
            deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm 
            deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
            if X>ImSize/2 & Y<ImSize/2
                NewPos_X=OldPos_X-deltaX; %mm
                NewPos_Y=OldPos_Y-deltaY; %mm
            elseif X>ImSize/2 & Y>ImSize/2
                NewPos_X=OldPos_X-deltaX; %mm
                NewPos_Y=OldPos_Y+deltaY; %mm
            elseif X<ImSize/2 & Y<ImSize/2
                NewPos_X=OldPos_X+deltaX; %mm
                NewPos_Y=OldPos_Y-deltaY; %mm
            else
                NewPos_X=OldPos_X+deltaX; %mm
                NewPos_Y=OldPos_Y+deltaY; %mm
            end
            NewPos=[NewPos_X,NewPos_Y]; %new
            
            obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
            obj.StageStepper.moveToPosition(2,NewPos(1)); %new x FF
            obj.StageStepper.moveToPosition(3,OldPos(3)); %new z FF 
            %Move to next step
            obj.startROILampFocus();
         end
        
         function Data=captureLamp(obj,ROISelect)
             %Capture an image with Lamp
             obj.Lamp660.setPower(obj.Lamp660Power);
             pause(obj.LampWait);
             switch ROISelect
                 case 'Full'
                     obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
                 case 'ROI'
                     obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
             end
             obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
             obj.CameraSCMOS.AcquisitionType = 'capture';
             obj.CameraSCMOS.setup_acquisition();
             Data=obj.CameraSCMOS.start_capture();
             obj.Lamp660.setPower(0);
         end
         
         function startROILampFocus(obj)
             %Run SCMOS in focus mode with lamp to allow user to focus             
             obj.gui_Stage();
             obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
             obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
             obj.CameraSCMOS.AcquisitionType = 'focus';
             obj.CameraSCMOS.setup_acquisition();
             obj.Lamp660.setPower(obj.Lamp660Power);
             obj.FlipMount.FilterIn; %new
             %obj.startROILaserFocusLow(); % turn on Laser focus low before starting SCMOS focus
             obj.CameraSCMOS.start_focus();
             obj.startROILaserFocusLow(); % FF
             obj.Lamp660.setPower(0);             
         end
         
         function startROILaserFocusLow(obj)
             %Run SCMOS in focus mode with Low Laser Power to allow user to focus
             %Ask for save as reference. If yes, save reference.
             
             %Run SCMOS in focus mode with High Laser Power to check
             obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeLaserFocus;
             obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
             obj.CameraSCMOS.AcquisitionType = 'focus';
             obj.CameraSCMOS.setup_acquisition();
             obj.Laser647.setPower(obj.LaserPowerFocus);
             obj.FlipMount.FilterIn; %new
             obj.Shutter.open; % opens shutter for laser
             obj.Laser647.on();
             obj.Lamp660.setPower(0); %FF
             obj.CameraSCMOS.start_focus();
             obj.Laser647.off();
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
            obj.Lamp660.setPower(obj.Lamp660Power);
            pause(obj.LampWait);
            obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
            obj.CameraSCMOS.AcquisitionType = 'capture';
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.setup_acquisition();
            Data=obj.CameraSCMOS.start_capture();
            obj.Lamp660.setPower(0);
            RefStruct.Image=Data;
            %Collect Full Image
            obj.Lamp660.setPower(obj.Lamp660Power);
            pause(obj.LampWait);
            obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
            obj.CameraSCMOS.AcquisitionType = 'capture';
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
            obj.CameraSCMOS.setup_acquisition();
            Data=obj.CameraSCMOS.start_capture();
            obj.Lamp660.setPower(0);
            RefStruct.Image_Full=Data;            
            %Center Piezo and add to stepper
            PPx=obj.StagePiezoX.getPosition; %new
            PPy=obj.StagePiezoY.getPosition; %new
            PPz=obj.StagePiezoZ.getPosition; %new
            PP=[PPx, PPy, PPz];
            obj.StagePiezoX.center(); %new 
            obj.StagePiezoY.center(); %new
            obj.StagePiezoZ.center(); %new
            PPCx=obj.StagePiezoX.getPosition; %new
            PPCy=obj.StagePiezoY.getPosition; %new
            PPCz=obj.StagePiezoZ.getPosition; %new
            PPC=[PPCx, PPCy, PPCz];
            OS=PP-PPC; %difference between piezo at center and at current
            % position of each cell  
            SPx=Kinesis_SBC_GetPosition('70850323',2); %new
            SPy=Kinesis_SBC_GetPosition('70850323',1); %new
            SPz=Kinesis_SBC_GetPosition('70850323',3); %new
            SP=[SPx,SPy,SPz];
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
            obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeSequence;
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Laser647.setPower(obj.LaserPowerSequence); %new
            obj.Laser647.WaitForLaser=0;
            obj.Shutter.open; %open shutter
            obj.FlipMount.FilterOut; %new
            obj.Laser647.on();
            obj.CameraSCMOS.start_focus();
            obj.Laser647.off();
         end
        
         function startSequence(obj,RefStruct,LabelID)
            %Collects and saves an SR data Set
            
            %create save folder and filenames
%             if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
%             timenow=clock;
%             s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
%             
                   %.........................    
            %Setup file saving
            if ~obj.IsBleach
                [~,~]=mkdir(obj.TopDir);
                [~,~]=mkdir(fullfile(obj.TopDir,obj.CoverslipName));
                DN=fullfile(obj.TopDir,obj.CoverslipName,sprintf('Cell_%2.2d',RefStruct.CellIdx),sprintf('Label_%2.2d',LabelID));
                [~,~]=mkdir(DN);
                TimeNow=clock;
                DateString=[num2str(TimeNow(1)) '-' num2str(TimeNow(2))  '-' num2str(TimeNow(3)) '-' num2str(TimeNow(4)) '-' num2str(TimeNow(5)) '-' num2str(round(TimeNow(6)))];
%                 FN=sprintf('Data_%s.mat',DateString); %FF
                FN=sprintf('Data_%s.h5',DateString);
                FileName=fullfile(DN,FN);
%                 F=matfile(FileName); %FF
            end
       %.........................     
            % FF test for save h.file
            switch obj.SaveFileType
                case 'mat'
                case 'h5'
                    FileH5=FileName; %FF
%                     FileH5=fullfile(obj.SaveDir,[obj.BaseFileName DateString '.h5']); 
                    MIC_H5.createFile(FileH5);
                    MIC_H5.createGroup(FileH5,'Data');
                    MIC_H5.createGroup(FileH5,'Data/Channel01');
                otherwise
                    error('StartSequence:: unknown file save type')
            end
            
            %Move to Cell
            obj.StageStepper.moveToPosition(1,RefStruct.StepperPos(2)+obj.CoverSlipOffset(2)); %new %y
            obj.StageStepper.moveToPosition(2,RefStruct.StepperPos(1)+obj.CoverSlipOffset(1)); %new %x
            obj.StageStepper.moveToPosition(3,RefStruct.StepperPos(3)+obj.CoverSlipOffset(3)); %new %z
            obj.StagePiezoX.center(); %new 
            obj.StagePiezoY.center(); %new
            obj.StagePiezoZ.center(); %new 
            %Align
            obj.Lamp660.setPower(obj.Lamp660Power+2);
            pause(obj.LampWait);
            obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture; %need to update when changing edit box
            obj.CameraSCMOS.AcquisitionType = 'capture';
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.setup_acquisition();
            obj.AlignReg.Image_Reference=RefStruct.Image;
            obj.AlignReg.MaxIter=20; %new
            try %So that if alignment fails, we don't stop auto collect for other cells
                obj.AlignReg.align2imageFit(RefStruct); %FF
            catch 
                warning('Problem with AlignReg.align2imageFit()')
                return
            end
            
            obj.Lamp660.setPower(0);
            
            %Setup Stabilization
            obj.ActiveReg=MIC_ActiveReg3D_Seq(obj.CameraIR,obj.StagePiezoX,obj.StagePiezoY,obj.StagePiezoZ); %new
            obj.Lamp850.on; 
            obj.Lamp850.setPower(obj.Lamp850Power);
            obj.IRCamera_ExposureTime=obj.CameraIR.ExpTime_Capture;
            obj.ActiveReg.takeRefImageStack(); %takes 21 reference images
            obj.ActiveReg.Period=obj.StabPeriod;
            obj.ActiveReg.start(); 
            
            %Setup sCMOS for Sequence
            obj.CameraSCMOS.ExpTime_Sequence=obj.ExposureTimeSequence;
            obj.CameraSCMOS.SequenceLength=obj.NumberOfFrames;
            obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.AcquisitionType = 'sequence';
            obj.CameraSCMOS.setup_acquisition();
            
            %Start Laser
            obj.FlipMount.FilterOut; % moves away the ND filter from the beam
            if obj.Use405
                obj.Laser405.setPower(obj.LaserPower405Activate);
            end
            if obj.IsBleach
                obj.Laser405.setPower(obj.LaserPower405Bleach);
            end
            
            %Collect Data
            if obj.IsBleach
                for nn=1:obj.NumberOfPhotoBleachingIterations
                    obj.Shutter.open; % opens shutter before the Laser turns on
                    Data=obj.CameraSCMOS.start_sequence();
                    S=sprintf('F.Data%2.2d=Data;',nn);
                    eval(S);
                    obj.Shutter.close; % closes shutter before the Laser turns on
                end
                
            else
                
                for nn=1:obj.NumberOfSequences
                    obj.Shutter.open; % opens shutter before the Laser turns on
                    
                    %Collect 
                    sequence=obj.CameraSCMOS.start_sequence();
                    if ~obj.IsBleach %Append Data
                        obj.Shutter.close;
                        switch obj.SaveFileType
                            case 'mat'
                                fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                                Params=exportState(obj); %#ok<NASGU>
                                save(fn,'sequence','Params');
                            case 'h5' %This will become default
                                S=sprintf('Data%04d',nn)
                                MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01',S,sequence);
                            otherwise
                                error('StartSequence:: unknown SaveFileType')
                        end
                        %obj.Shutter.open;
                    end
                    obj.Shutter.close; % closes shutter before the Laser turns on
                end
                
                %End Laser
                %     obj.Laser647.off();
                obj.Shutter.close; % closes the shutter instead of turning off the Laser
                obj.FlipMount.FilterIn; %new
                obj.Laser405.setPower(0);
                
                %End Active Stabilization:
                obj.ActiveReg.stop();
                
                %Save Everything
                if ~obj.IsBleach %Append Data
                    Cam=struct(obj.CameraSCMOS);
                    Cam.FigureHandle=[];
                    Cam.ImageHandle=[];
                    F.Camera=Cam;
                    F.Active=obj.ActiveReg.exportState(); %FF
                    F.Align=obj.AlignReg.exportState();
%                     Camera=Cam;
%                     Active=obj.ActiveReg.exportState(); %FF
%                     Align=obj.AlignReg.exportState();
%                     MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01','Camera',Camera);
%                     MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01','Active',Active);
%                     MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01','Align',Align);
                end
                
                %delete ActiveReg
                delete(obj.ActiveReg);
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
%                 obj.FlipMount.FilterIn; 
                obj.Laser647.setPower(obj.LaserPowerSequence);
                obj.Laser647.on();
                
                %Loop over cells

                for nn=StartCell:NumCells 
                    
                    %Create or load RefImageStruct
                    FileName=fullfile(RefDir,FileList(nn).name);
                    F=matfile(FileName);
                    RefStruct=F.RefStruct;
                    if (obj.UseManualFindCell)&&(nn==StartCell)
                        S=obj.findCoverSlipOffset_Manual(RefStruct);
                        obj.CoverSlipOffset;
                        if ~S;return;end
                    end
                    
                    obj.startSequence(RefStruct,obj.LabelIdx);
%                     obj.FlipMount.FilterOut; %FF
                    
                    if nn==StartCell %update coverslip offset
                        %obj.CoverSlipOffset=obj.StageStepper.Position-RefStruct.StepperPos; %old
                        SPx=Kinesis_SBC_GetPosition('70850323',2); %new
                        SPy=Kinesis_SBC_GetPosition('70850323',1); %new
                        SPz=Kinesis_SBC_GetPosition('70850323',3); %new
                        SP=[SPx,SPy,SPz];
                        obj.CoverSlipOffset=SP-RefStruct.StepperPos; %new
                    end
%                     obj.FlipMount.FilterOut;

                end
                
                obj.FlipMount.FilterIn; %moves in the ND filter toward the beam
                obj.Shutter.close;
                obj.Laser647.off();
         end 
        
            %Stage Controls --------------------------------
            function moveStepperUpLarge(obj)
                Pos_Step_Z=obj.StageStepper.getPosition(3);%get pos
                Pos_Step_Z=Pos_Step_Z+obj.StepperLargeStep;%update pos
                obj.StageStepper.moveToPosition(3,Pos_Step_Z);%set pos
            end
            function moveStepperDownLarge(obj)
                Pos_Step_Z=obj.StageStepper.getPosition(3);%get pos
                Pos_Step_Z=Pos_Step_Z-obj.StepperLargeStep;%update pos
                obj.StageStepper.moveToPosition(3,Pos_Step_Z);%set pos
            end
            function moveStepperUpSmall(obj)
                Pos_Step_Z=obj.StageStepper.getPosition(3);%get pos
                Pos_Step_Z=Pos_Step_Z+obj.StepperSmallStep;%update pos
                obj.StageStepper.moveToPosition(3,Pos_Step_Z);%set pos
            end
            function moveStepperDownSmall(obj)
                Pos_Step_Z=obj.StageStepper.getPosition(3);%get pos
                Pos_Step_Z=Pos_Step_Z-obj.StepperSmallStep;%update pos
                obj.StageStepper.moveToPosition(3,Pos_Step_Z);%set pos
            end
            function movePiezoUpSmall(obj)
                Pos_Piezo_Z=obj.StagePiezoZ.getPosition;%get pos
                Pos_Piezo_Z=Pos_Piezo_Z+obj.PiezoStep;%update pos
                obj.StagePiezoZ.setPosition(Pos_Piezo_Z);%set pos
            end
            function movePiezoDownSmall(obj)
                Pos_Piezo_Z=obj.StagePiezoZ.getPosition;%get pos
                Pos_Piezo_Z=Pos_Piezo_Z-obj.PiezoStep;%update pos
                obj.StagePiezoZ.setPosition(Pos_Piezo_Z);%set pos
            end
            % End Stage Controls ____________________________   
           
    end
    
    methods (Static)
        
    function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all hardware objects
            % and SEQ_SRcollect settings
            % Children:
            [Children.CameraSCMOS.Attributes,Children.CameraSCMOS.Data,Children.CameraSCMOS.Children]=...
                obj.CameraSCMOS.exportState();
            [Children.CameraIR.Attributes,Children.CameraIR.Data,Children.CameraIR.Children]=...
                obj.CameraIR.exportState();
            [Children.StageStepper.Attributes,Children.StageStepper.Data,Children.StageStepper.Children]=...
                obj.StageStepper.exportState();
            [Children.Laser405.Attributes,Children.Laser405.Data,Children.Laser405.Children]=...
                obj.Laser405.exportState();
            [Children.Laser647.Attributes,Children.Laser647.Data,Children.Laser642.Children]=...
                obj.Laser647.exportState();
            [Children.Lamp850.Attributes,Children.Lamp850.Data,Children.Lamp850.Children]=...
                obj.Lamp850.exportState();
            [Children.Lamp660.Attributes,Children.Lamp660.Data,Children.Lamp660.Children]=...
                obj.Lamp660.exportState();  
            
            % Our Properties
            Attributes.ExposureTimeLampFocus = obj.ExposureTimeLampFocus;
            Attributes.ExposureTimeLaserFocus = obj.ExposureTimeLaserFocus;
            Attributes.ExposureTimeSequence = obj.ExposureTimeSequence;
            Attributes.ExposureTimeCapture = obj.ExposureTimeCapture;
            Attributes.NumberOfFrames = obj.NumberOfFrames;
            Attributes.NumberOfSequences = obj.NumberOfSequences;
            Attributes.NumberOfPhotoBleachingIterations = ...
                obj.NumberOfPhotoBleachingIterations; 
            Attributes.CameraGain = obj.CameraGain;
            Attributes.CameraEMGainHigh = obj.CameraEMGainHigh;
            Attributes.CameraEMGainLow = obj.CameraEMGainLow;
            Attributes.CameraROI = obj.CameraROI;
            Attributes.CameraPixelSize=obj.PixelSize;
            
            Attributes.SaveDir = obj.SaveDir;
            Attributes.RegType = obj.RegType;
            
            % light source properties
            Attributes.LaserPower405Activate = obj.LaserPower405Activate;
            Attributes.LaserPower405Bleach = obj.LaserPower405Bleach; 
            Attributes.LaserPowerSequence = obj.LaserPowerSequence;
            Attributes.LaserPowerFocus = obj.LaserPowerFocus;
            Data=[];
            end
            
        function State = unitTest()
            State = obj.exportState();
        end

    end
end