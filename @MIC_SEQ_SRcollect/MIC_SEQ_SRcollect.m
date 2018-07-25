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
        end
        
        function delete(obj)
            delete(obj.CameraIR);
        end
        
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
            Children = [];
            
            % Our Properties
            Attributes.ExposureTimeLampFocus = obj.ExposureTimeLampFocus;
            Attributes.ExposureTimeLaserFocus = obj.ExposureTimeLaserFocus;
            Attributes.ExposureTimeSequence = obj.ExposureTimeSequence;
            Attributes.ExposureTimeCapture = obj.ExposureTimeCapture;
            Attributes.NumberOfFrames = obj.NumberOfFrames;
            Attributes.NumberOfSequences = obj.NumberOfSequences;
            Attributes.NumberOfPhotoBleachingIterations = ...
                obj.NumberOfPhotoBleachingIterations;
            Attributes.SCMOS_ROI_Collect = obj.SCMOS_ROI_Collect;
            Attributes.SCMOS_ROI_Full = obj.SCMOS_ROI_Full;
            Attributes.IRCamera_ROI = obj.IRCamera_ROI;
            Attributes.SCMOS_PixelSize=obj.SCMOS_PixelSize;
            
            Attributes.SaveDir = obj.SaveDir;
            Attributes.RegType = obj.RegType;
            
            % light source properties
            Attributes.LaserPower405Activate = obj.LaserPower405Activate;
            Attributes.LaserPower405Bleach = obj.LaserPower405Bleach;
            Attributes.LaserPowerSequence = obj.LaserPowerSequence;
            Attributes.LaserPowerFocus = obj.LaserPowerFocus;
            Data=[];
        end
        
        autoCollect(obj,StartCell,RefDir);
        exposeCellROI(obj); 
        exposeGridPoint(obj);
        findCoverSlipOffset(obj,RefStruct);
        Success=findCoverSlipOffset_Manual(obj,RefStruct);
        saveReferenceImage(obj);
        startSequence(obj,RefStruct,LabelID);
        
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
    end
    
    methods (Static)
        function State = unitTest()
            State = obj.exportState();
        end

    end
end