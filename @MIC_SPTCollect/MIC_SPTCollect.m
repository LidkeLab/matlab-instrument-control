classdef MIC_SPTCollect < MIC_Abstract
    % MIC_SPTCollect Single Particle Tracking/Superresolution data collection
    % software. Super resolution and Single Particle Tracking data collection
    % class for SPT microscope Works with Matlab Instrument Control (MIC)
    % classes since August 2017
    
    %  usage: SPT=MIC_SPTCollect();
    %
    % REQUIRES:
    %   Matlab 2014b or higher MIC_Abstract MIC_LightSource_Abstract
    %   MIC_AndorCamera MIC_TcubeLaserDiode MIC_CrystaLaser561 MIC_IX71Lamp
    %   MIC_SyringePump MIC_ThorlabsIR MIC_ThorlabLED MIC_MCLNanoDrive
    %   MIC_Reg3DTrans
    %
    % CITATION:
    %   Hanieh Mazloom-Farsibaf   August 2017 (Keith A. Lidke's lab)
    
    properties
        % Hardware objects
        CameraObj;      % Andor Camera
        CameraObj2;     % Second Andor Camera
        IRCameraObj;    % Thorlabs IR Camera
        StageObj;       % MCL Nano Drive
        Laser638Obj;       % TCubeLaserDiode 638
        Laser561Obj;       % Crystal Laser 561
        Lamp850Obj;     % ThorlabLED Lamp for IRCamera
        LampObj;        % IX71 Lamp
        SyringePumpObj; % SyringePump for Tracking+Fixation
        R3DObj;         % Reg3DTrans class
        ActRegObj;      % Active Stabilization Object
        
        % Camera params
        ExpTime_Focus_Set=.01;          % Exposure time during focus Andor Camera
        ExpTime_Sequence_Set=.01;       % Exposure time during sequence Andor Camera
        ExpTime_Sequence_Actual=.002;
        ExpTime_Capture=.05;
        NumFrames=2000;                 % Number of frames per sequence
        NumSequences=20;                % Number of sequences per acquisition
        CameraGain=1;                   % Flag for adjusting camera Gain
        CameraEMGainHigh=200;           % High camera gain value
        CameraEMGainLow=2;              % Low camera gain value
        CameraROI=1;                    % Camera ROI (see gui for specifics)
        PixelSize;                      % Pixel size determined from calibration Andor Camera
        OrientMatrix;                   % unitary matrix to show orientation
        % between Andor Camera and Stage([a b;c d])
        IRExpTime_Focus_Set=0.01;       % Exposure time during focus IR Camera
        IRExpTime_Sequence_Set=0.01;    % Exposure time during sequence IR Camera
        IRCameraROI=2;                  % IRCamera ROI (see gui for specifics)
        IRPixelSize;                    % PixelSize for IR Camera
        IROrientMatrix;                 % unitary matrix to show orientation
        % between IR Camera and Stage([a b;c d])
        % Light source params
        Laser638Low;          % Low power 638 laser
        Laser561Low;          % Low power 561 laser
        Laser638High;         % High power 638 laser
        Laser561High;         % High power 561 laser
        LampPower;            % Power of lamp IX71
        Lamp850Power;         % Power of lamp 850
        Laser638Aq;           % Flag for using 638 laser during acquisition
        Laser561Aq;           % Flag for using 561 laser during acquisition
        LampAq;               % Flag for using lamp during acquisition
        Lamp850Aq;            % Flag for using lamp 850 during acquisition
        LampWait=1;           % Time (s) to wait after turning on lamp before Reg3DTrans functions
        focus638Flag=0;       % Flag for using 638 laser during focus
        focus561Flag=0;       % Flag for using 561 laser during focus
        focusLampFlag=0;      % Flag for using Lamp IX71 during focus
        focusLamp850Flag=0;   % Flag for using Lamp 850 during focus
        
        % Other things
        SaveDir='Y:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='mat'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
        
        
        TimerAndor;
        TimerSyringe;
        TimerIRCamera;
        tSyring_start
        tIR_start
        tIR_end
        tAndor_start
        tAndor_end
        SyringeWaitTime
        SyringeWaitTime_offset=-2; % in the unit of frame for IRCamera
        IRSequenceLength
        IRsequenceLength_offset=50;%in the unit of frame for IRCamera
        sequenceType='SRCollect';  % Type of acquisition data 'Tracking+SRCollect'
        ActiveRegCheck=0;
        RegCamType='IRCamera'   % Type of Camera Bright Field Registration
        %'Andor Camera', 'IRCamera'
        CalFilePath
        zPosition
        MaxCC
    end
    
    properties (SetAccess = protected)
        InstrumentName = 'SPTCollect'; % Descriptive name of "instrument"
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  Set to false to prevent gui opening before hardware is initialized.
    end
    
    methods
        function obj=MIC_SPTCollect()
            % MIC_SPT_Collect constructor
            %   Constructs object and initializes all hardware
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            [p,~]=fileparts(which('MIC_SPTCollect'));
            obj.CalFilePath=p;
            
            if exist(fullfile(p,'SPT_AndorCalibrate.mat'),'file')
                a=load(fullfile(p,'SPT_AndorCalibrate.mat'));
                obj.PixelSize=a.PixelSize;
                obj.OrientMatrix=a.OrientMatrix;
                clear a
            end
            
            if exist(fullfile(p,'SPT_IRCalibrate.mat'),'file')
                a=load(fullfile(p,'SPT_IRCalibrate.mat'));
                obj.IRPixelSize=a.PixelSize;
                obj.IROrientMatrix=a.OrientMatrix;
                clear a
            end
            
            % Initialize hardware objects
            try
                % Camera
                fprintf('Initializing Camera\n')
                obj.CameraObj=MIC_AndorCamera();
                CamSet = obj.CameraObj.CameraSetting;
                CamSet.FrameTransferMode.Bit=1;
                CamSet.FrameTransferMode.Ind=2;
                CamSet.FrameTransferMode.Desc=obj.CameraObj.GuiDialog.FrameTransferMode.Desc{2};
                CamSet.BaselineClamp.Bit=1;
                CamSet.VSSpeed.Bit=4;
                CamSet.HSSpeed.Bit=0;
                CamSet.VSAmplitude.Bit=2;
                CamSet.PreAmpGain.Bit=2;
                CamSet.EMGain.Value = obj.CameraEMGainHigh;
                obj.CameraObj.setCamProperties(CamSet);
                obj.CameraObj.setup_acquisition();
                obj.CameraObj.ReturnType='matlab';
                obj.CameraObj.DisplayZoom=4;
                fprintf('Initializing IRCamera\n')
                obj.IRCameraObj=MIC_ThorlabsIR();
                obj.IRCameraObj.DisplayZoom=1;
                % Stage
                fprintf('Initializing Stage\n')
                obj.StageObj=MIC_MCLNanoDrive();
                % Lasers
                fprintf('Initializing 638 laser\n')
                obj.Laser638Obj=MIC_TCubeLaserDiode('64844789','Current',195,0,0)
                obj.Laser638Low =0;
                obj.Laser638High =195;
                fprintf('Initializing 561 laser\n')
                %                obj.Laser561Obj = MIC_CrystaLaser561('Dev1','Port0/Line0:1');
                %                 obj.Laser561Low= ; obj.Laser561High= ;
                % Lamp 850
                fprintf('Initializing lamp 850\n')
                obj.Lamp850Obj=MIC_ThorlabsLED('Dev1','ao1');
                obj.Lamp850Power = 30;
                % Lamp IX71
                fprintf('Initializing lamp\n')
                obj.LampObj=MIC_IX71Lamp('Dev1','ao0','Port0/Line0');
                obj.LampPower = 50;
                
                %                 Registration object
                fprintf('Initializing Registration object\n')
                if strcmp(obj.RegCamType,'Andor Camera')
                    f=fullfile(obj.CalFilePath,'SPT_AndorCalibrate.mat')
                    obj.R3DObj=MIC_Reg3DTrans(obj.CameraObj,obj.StageObj,f);
                elseif strcmp(obj.RegCamType,'IRCamera')
                    f=fullfile(obj.CalFilePath,'SPT_IRCalibrate.mat')
                    obj.R3DObj=MIC_Reg3DTrans(obj.IRCameraObj,obj.StageObj,f);
                end
                
                if ~exist(f,'file')
                    if strcmp(obj.RegCamType,'Andor Camera')
                        %set the Andor Camera
                        CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
                        CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
                        EMGTemp = CamSet.EMGain.Value;
                        CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                        obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                        obj.R3DObj.CameraObj.setShutter(1);
                        
                        %set the lamp
                        if isempty(obj.LampPower) || obj.LampPower==0
                            obj.LampPower=obj.LampObj.MaxPower/2;
                        end
                        obj.LampObj.setPower(obj.LampPower);
                        obj.LampObj.on();
                        fprintf('Calibrating camera and stage ...\n')
                        pause(obj.LampWait);
                        obj.R3DObj.calibrate();
                        % change back camera setting to the values before using the R3DTrans class
                        obj.R3DObj.CameraObj.setShutter(0);
                        CamSet.EMGain.Value = EMGTemp;
                        CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                        obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                        obj.LampObj.off();
                        obj.PixelSize=obj.R3DObj.PixelSize;
                    else strcmp(obj.RegCamType,'IRCamera');
                        %set the lamp
                        if isempty(obj.Lamp850Power) || obj.Lamp850Power==0
                            obj.Lamp850Power=obj.Lamp850Obj.MaxPower/3;
                        end
                        obj.Lamp850Obj.setPower(obj.Lamp850Power);
                        obj.Lamp850Obj.on();
                        obj.R3DObj.CameraObj.ROI=[515 770 467 722];
                        fprintf('Calibrating camera and stage ...\n')
                        pause(obj.LampWait);
                        obj.R3DObj.calibrate();
                        obj.Lamp850Obj.off();
                        obj.IRPixelSize=obj.R3DObj.PixelSize;
                    end
                    clear a;
                end
                
            catch ME
                ME
                error('hardware startup error');
                
            end
            
            %Set save directory
            user_name = java.lang.System.getProperty('user.name');
            timenow=clock;
            %             obj.SaveDir=sprintf('Y:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3));
            
            % Start gui (not using StartGUI property because GUI shouldn't
            % be started before hardware initialization)
            obj.gui();
        end
        
        function delete(obj)
            %delete all objects
            if ishandle(obj.GuiFigure)
                disp('Closing GUI...');
                delete(obj.GuiFigure)
            end
            disp('Deleting Lamp...');
            delete(obj.Lamp850Obj);
            disp('Deleting Laser 638...');
            delete(obj.Laser638Obj);
            disp('Deleting Stage...');
            delete(obj.StageObj);
            disp('Deleting Camera...');
            delete(obj.CameraObj);
            disp('Deleting IR Camera');
            delete(obj.IRCameraObj);
            disp('Deleting Syringe Pump')
            delete(obj.SyringePumpObj)
            disp('Turn off MCl Nanodriver and Lasers 638/561 manually!')
            close all force;
            clear;
        end
        
        %registration channel function loadref(obj)
        function loadref(obj)
            % Load reference image file
            [a,b]=uigetfile('*.mat','Select Reference File',obj.SaveDir);
            if ~a
                return
            end
            obj.R3DObj.RefImageFile = fullfile(b,a);
            tmp=load(obj.R3DObj.RefImageFile,'Image_Reference');
            obj.R3DObj.Image_Reference=tmp.Image_Reference;
        end
        
        function takecurrent(obj)
            % captures and displays current image
            if strcmp(obj.RegCamType,'Andor Camera');
                %set the Andor Camera
                CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
                CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.R3DObj.CameraObj.setShutter(1);
                
                %set the lamp
                if isempty(obj.LampPower) || obj.LampPower==0
                    obj.LampPower=obj.LampObj.MaxPower/2;
                end
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on();
                pause(obj.LampWait);
                obj.R3DObj.getcurrentimage();
                % change back camera setting to the values before using the R3DTrans class
                obj.R3DObj.CameraObj.setShutter(0);
                CamSet.EMGain.Value = EMGTemp;
                CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
            else strcmp(obj.RegCamType,'IRCamera');
                %set the lamp
                if isempty(obj.Lamp850Power) || obj.Lamp850Power==0
                    obj.Lamp850Power=obj.Lamp850Obj.MaxPower/2;
                end
                obj.Lamp850Obj.setPower(obj.Lamp850Power);
                obj.Lamp850Obj.on();
                pause(obj.LampWait);
                obj.R3DObj.getcurrentimage();
                obj.Lamp850Obj.off();
            end
        end
        
        function align(obj)
            % Align to current reference image
            switch obj.RegType
%                 case 'Self'
% %                     obj.takeref();
                case 'Ref'
                    if isempty(obj.R3DObj.Image_Reference)
                        obj.loadref();
                    end
            end
            if strcmp(obj.RegCamType,'Andor Camera');
                %set the Andor Camera
                CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
                CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.R3DObj.CameraObj.setShutter(1);
                
                %set the lamp
                if isempty(obj.LampPower) || obj.LampPower==0
                    obj.LampPower=obj.LampObj.MaxPower/2;
                end
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on();
                pause(obj.LampWait);
                obj.R3DObj.ZStackMaxDevInitialReg=.5;
                obj.R3DObj.UseStackCorrelation=1; %for 3D Reg correlation
                obj.R3DObj.align2imageFit();
                % change back camera setting to the values before using the R3DTrans class
                obj.R3DObj.CameraObj.setShutter(0);
                CamSet.EMGain.Value = EMGTemp;
                CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
            else strcmp(obj.RegCamType,'IRCamera');
                %set the lamp
                if isempty(obj.Lamp850Power) || obj.Lamp850Power==0
                    obj.Lamp850Power=obj.Lamp850Obj.MaxPower/2;
                end
                obj.Lamp850Obj.setPower(obj.Lamp850Power);
                obj.Lamp850Obj.on();
                pause(obj.LampWait);
                obj.R3DObj.ZStackMaxDevInitialReg=.5;
                obj.R3DObj.UseStackCorrelation=1; %for 3D Reg correlation
                 obj.R3DObj.align2imageFit();
                obj.Lamp850Obj.off();
            end
        end
        
        function showref(obj)
            % Displays current reference image
            dipshow(obj.R3DObj.Image_Reference);
        end
        
        function takeref(obj)
            % Captures reference image obj.setLampPower();
            if strcmp(obj.RegCamType,'Andor Camera');
                %set the Andor Camera
                CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
                CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.R3DObj.CameraObj.setShutter(1);
                %set the lamp
                if isempty(obj.LampPower) || obj.LampPower==0
                    obj.LampPower=obj.LampObj.MaxPower/2;
                end
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on();
                pause(obj.LampWait);
                %%update this lines after new version of Reg3DTrans till
                %%line 390
                obj.R3DObj.ZStackMaxDevInitialReg=.5;
                if ~obj.R3DObj.UseStackCorrelation
                obj.R3DObj.takerefimage();
                else
                    obj.R3DObj.takeRefStack();
                end
                
                % change back camera setting to the values before using the R3DTrans class
                obj.R3DObj.CameraObj.setShutter(0);
                CamSet.EMGain.Value = EMGTemp;
                CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
            else strcmp(obj.RegCamType,'IRCamera');
                if isempty(obj.IRCameraObj)
                    obj.IRCameraObj=MIC_ThorlabsIR();
                end
                %set the lamp
                if isempty(obj.Lamp850Power) || obj.Lamp850Power==0
                    obj.Lamp850Power=obj.Lamp850Obj.MaxPower/2;
                end
                obj.Lamp850Obj.setPower(obj.Lamp850Power);
                obj.Lamp850Obj.on();
                pause(obj.LampWait);
                 %%update this lines after new version of Reg3DTrans till
                %%line 415
                                obj.R3DObj.ZStackMaxDevInitialReg=.5;

if ~obj.R3DObj.UseStackCorrelation
                obj.R3DObj.takerefimage();
                else
                    obj.R3DObj.takeRefStack();
end
obj.Lamp850Obj.off();
            end
            
        end
        
        function saveref(obj)
            % Saves current reference image
            obj.R3DObj.saverefimage();
        end
        
        function focusLow(obj)
            % Focus function using the low laser settings
            CamSet=obj.CameraObj.CameraSetting;
            CamSet.EMGain.Value = obj.CameraEMGainHigh;
            obj.CameraObj.setCamProperties(CamSet);
            %        Lasers set up to 'low' power setting
            if obj.focus638Flag
                obj.Laser638Obj.setPower(obj.Laser638Low);
                obj.Laser638Obj.on();
            else
                obj.Laser638Obj.off();
            end
            %                 if obj.focus561Flag
            %                     obj.Laser561Obj.setPower(obj.Laser561Low);
            %                     obj.Laser561Obj.on;
            %                 else
            %                     obj.Laser561Obj.off;
            %                 end
            %
            % Aquiring and displaying images
            obj.CameraObj.ROI=obj.getROI('Andor');
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            out=obj.CameraObj.start_focus();
            % Turning lasers off
            obj.Laser638Obj.off();
            %             obj.Laser561.off();
            obj.LampObj.off();
            obj.Lamp850Obj.off();
        end
        
        function focusHigh(obj)
            % Focus function using the high laser settings
            CamSet=obj.CameraObj.CameraSetting;
            CamSet.EMGain.Value = obj.CameraEMGainHigh;
            obj.CameraObj.setCamProperties(CamSet);
            %        Lasers set up to 'high' power setting
            if obj.focus638Flag
                obj.Laser638Obj.setPower(obj.Laser638High);
                obj.Laser638Obj.on();
            else
                obj.Laser638Obj.off();
            end
            %     if obj.focus561Flag
            %         obj.Laser561Obj.setPower(obj.Laser561High);
            %         obj.Laser561Obj.on();
            %     else
            %         obj.Laser561Obj.off();
            %     end
            
            % Aquiring and displaying images
            obj.CameraObj.ROI=obj.getROI('Andor');
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            out=obj.CameraObj.start_focus();
            % Turning lasers off
            obj.Laser638Obj.off();
            %     obj.Laser561Obj.off();
        end
        
        function setLampPower(obj,LampPower_in)
            % sets Lamp power to input value
            if nargin<2
                obj.LampObj.setPower(obj.LampPower);
            else
                obj.LampObj.setPower(LampPower_in);
            end
            obj.LampPower=obj.LampObj.Power;
        end
        
        function focusLamp(obj)
            % Continuous display of image with lamp on. Useful for focusing
            % of the microscope.
            CamSet = obj.CameraObj.CameraSetting;
            %put Shutter back to auto
            CamSet.ManualShutter.Bit=0;
            %obj.CameraObj.setCamProperties(CamSet);
            CamSet.EMGain.Value = obj.CameraEMGainLow;
            obj.CameraObj.setCamProperties(CamSet);
            obj.LampObj.setPower(obj.LampPower);
            obj.LampObj.on();
            obj.CameraObj.ROI=obj.getROI('Andor');
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            obj.CameraObj.start_focus();
            %dipshow(out);
            CamSet.EMGain.Value = obj.CameraEMGainHigh;
            obj.CameraObj.setCamProperties(CamSet);
            obj.LampObj.off();
            %           pause(obj.obj.LampWait);
        end
        
        % this is for Lamp 850 and IRCamera
        function focusLamp850(obj)
            % Continuous display of image with lamp on. Useful for focusing
            % of the microscopeon IRCamera
            obj.Lamp850Obj.setPower(obj.Lamp850Power);
            obj.Lamp850Obj.on();
            obj.IRCameraObj.ROI=obj.getROI('IRThorlabs');
            obj.IRCameraObj.ExpTime_Focus=obj.IRExpTime_Focus_Set;
            %             obj.IRCameraObj.AcquisitionType = 'focus';
            obj.IRCameraObj.start_focus();
            %dipshow(out);
            obj.Lamp850Obj.off();
            %           pause(obj.obj.LampWait);
        end
        
        function set_RegCamType(obj)
            if strcmp(obj.RegCamType,'Andor Camera');
                CalFileName=fullfile(obj.CalFilePath,'SPT_AndorCalibrate.mat');
                if exist(CalFileName,'file')
                    obj.R3DObj=MIC_Reg3DTrans(obj.CameraObj,obj.StageObj,CalFileName);
                else
                    obj.R3DObj=MIC_Reg3DTrans(obj.CameraObj,obj.StageObj,CalFileName);
                    warning('Put nanogris as a sample to do the calibration for Reg3dTrans class')
                    %set the Andor Camera
                    CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
                    CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
                    EMGTemp = CamSet.EMGain.Value;
                    CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                    obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                    obj.R3DObj.CameraObj.setShutter(1);
                    
                    %set the lamp
                    if isempty(obj.LampPower) || obj.LampPower==0
                        obj.LampPower=obj.LampObj.MaxPower/2;
                    end
                    obj.LampObj.setPower(obj.LampPower);
                    obj.LampObj.on();
                    fprintf('Calibrating camera and stage ...\n')
                    pause(obj.LampWait);
                    obj.R3DObj.calibrate();
                    % change back camera setting to the values before using the R3DTrans class
                    obj.R3DObj.CameraObj.setShutter(0);
                    CamSet.EMGain.Value = EMGTemp;
                    CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                    obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                    obj.LampObj.off();
                    obj.PixelSize=obj.R3DObj.PixelSize;
                end
                
            elseif strcmp(obj.RegCamType,'IRCamera')
                if isempty(obj.IRCameraObj)
                    obj.IRCameraObj=MIC_ThorlabsIR();
                end
                CalFileName=fullfile(obj.CalFilePath,'SPT_IRCalibrate.mat');
                if exist(CalFileName,'file')
                    obj.R3DObj=MIC_Reg3DTrans(obj.IRCameraObj,obj.StageObj,CalFileName);
                else
                    obj.R3DObj=MIC_Reg3DTrans(obj.IRCameraObj,obj.StageObj,CalFileName);
                    warning('Put nanogris as a sample to do the calibration for Reg3dTrans class')
                    obj.R3DObj.ChangeExpTime=true;
                    obj.R3DObj.ExposureTime=0.01;
                    obj.R3DObj.CameraObj.ROI=[515 770 467 722];
                    %set the lamp
                    if isempty(obj.Lamp850Power) || obj.Lamp850Power==0
                        obj.Lamp850Power=obj.Lamp850Obj.MaxPower/2;
                    end
                    obj.Lamp850Obj.setPower(obj.Lamp850Power);
                    obj.Lamp850Obj.on();
                    pause(obj.LampWait);
                    obj.R3DObj.calibrate();
                    obj.Lamp850Obj.off();
                    obj.IRPixelSize=obj.R3DObj.PixelSize;
                end
                
            end
            
        end
        function StartSequence(obj,guihandles)
            
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            
            delete(timerfindall)
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            
            obj.LampObj.setPower(obj.LampPower);
            %make sure IR camera exists
            if ~isvalid(obj.IRCameraObj)
                obj.IRCameraObj=MIC_ThorlabsIR();
            end
            
            switch obj.RegType
                case 'Self' %take and save the reference image
                    obj.takeref();
                    f=fullfile(obj.SaveDir,[obj.BaseFileName s '_ReferenceImage']);
                    Image_Reference=obj.R3DObj.Image_Reference; %#ok<NASGU>
                    save(f,'Image_Reference');
                case 'Ref'
                    if isempty(obj.R3DObj.Image_Reference)
                        error ('Load a reference image!')
                    end
            end
            %define IRCameraObj from different classes if SPT+SR is running
            if strcmp(obj.sequenceType,'Tracking+SRCollect');
                if isvalid(obj.IRCameraObj)
                    obj.IRCameraObj.delete();
                end
                obj.IRCameraObj=MIC_IRSyringPump();
                obj.IRCameraObj.DisplayZoom=1;
                obj.ActiveRegCheck=0;
            end
            %set Active Stabilization
            if obj.ActiveRegCheck==1
                %setup Lamp850
                %Active Stabilization
                obj.ActRegObj=MIC_ActiveReg3D_SPT(obj.IRCameraObj,obj.StageObj);
                obj.ActRegObj.PixelSize=obj.IRPixelSize;
                obj.Lamp850Obj.setPower(obj.Lamp850Power);
                obj.Lamp850Obj.on()
                obj.IRCameraObj.ROI=obj.getROI('IRThorlabs');
                obj.ActRegObj.takeRefImageStack();
                obj.ActRegObj.X_Current=[];
                obj.ActRegObj.Y_Current=[];
                obj.ActRegObj.Z_Current=[];
            end
            
            switch obj.SaveFileType
                case 'mat'
                case 'h5'
                    FileH5=fullfile(obj.SaveDir,[obj.BaseFileName s '.h5']);
                    MIC_H5.createFile(FileH5);
                    MIC_H5.createGroup(FileH5,'Data');
                    MIC_H5.createGroup(FileH5,'Data/Channel01');
                otherwise
                    error('StartSequence:: unknown file save type')
            end
            
            MaxCC=[];
            Image_BF=[];
            %loop over sequences
            for nn=1:obj.NumSequences
                if obj.AbortNow; obj.AbortNow=0; break; end
                
                nstring=strcat('Acquiring','...',num2str(nn),'/',num2str(obj.NumSequences));
                %set(guihandles.Button_ControlStart, 'String',nstring,'Enable','off');
                
                %align to image
                switch obj.RegType
                    case 'None'
                    otherwise
                        obj.align();
                        Image_BF{nn}=obj.R3DObj.Image_Current;
                        %                         MaxCC(nn)=obj.R3DObj.maxACmodel;
                end
                
                
                %Setup laser for aquisition
                if obj.Laser638Aq
                    obj.Laser638Obj.setPower(obj.Laser638High);
                    obj.Laser638Obj.on();
                end
                if obj.Laser561Aq
                    obj.Laser561Obj.setPower(obj.Laser561High);
                    obj.Laser561Obj.on();
                end
                
                if obj.LampAq
                    obj.LampObj.setPower(obj.LampPower);
                    obj.LampObj.on();
                end
                
                if obj.Lamp850Aq
                    obj.Lamp850Obj.setPower(obj.LampPower);
                    obj.Lamp850Obj.on();
                end
                
                %Setup Camera
                CamSet = obj.CameraObj.CameraSetting;
                CamSet.EMGain.Value = obj.CameraEMGainHigh;
                switch obj.CameraGain %??
                    case 1 %Low pre-amp gain
                        CamSet.PreAmpGain.Bit=2;
                    case 2 %high pre-amp gain
                        
                end
                obj.CameraObj.setCamProperties(CamSet);
                obj.CameraObj.ExpTime_Sequence=obj.ExpTime_Sequence_Set;
                obj.CameraObj.SequenceLength=obj.NumFrames;
                                obj.CameraObj.AcquisitionTimeOutOffset=10000;
                obj.CameraObj.ROI=obj.getROI('Andor');
                %                 fprintf('EM Gain\n')
                obj.CameraObj.CameraSetting.EMGain
                CamSet.FrameTransferMode.Ind=2;
                obj.CameraObj.setCamProperties(CamSet);
                %                 fprintf('Frame mode\n')
                obj.CameraObj.CameraSetting.FrameTransferMode
                %Collect
                % For SPT microscope there are three options for imaging:
                % 1)'SRCollect'=normal SRCollect: for supperresolution and tracking
                % 2)'Tracking+SRCollect'= for tracking+superresolution in consecutive order
                % using SyringePump
                % 3)'TwoColorTracking'= Use two EMCCD cameras and two
                % lasers (638 nm, 561 nm) for tracking or superresolution
                
                %obj.sequenceType='SRCollect'
                if  strcmp(obj.sequenceType,'SRCollect')
                    
                    %------------------------------------------IR capture version 2---------------------------------
                    if obj.ActiveRegCheck==1
                        IRWaitTime=1;
                        numf=floor(obj.ExpTime_Sequence_Set*obj.NumFrames)./IRWaitTime;
                        TimerIR=timer('StartDelay',0,'period',IRWaitTime,'TasksToExecute',numf,'ExecutionMode','fixedRate');
                        
                        if numf>1
                            IRsaveDir=[obj.SaveDir,obj.BaseFileName,s,'\'];
                            if ~exist(IRsaveDir,'dir');mkdir(IRsaveDir);end
                            TimerIR.TimerFcn={@IRCaptureTimerFcnV1,obj.ActRegObj,IRsaveDir,'IRImage-'};
                            obj.tIR_start=clock;
                            start(TimerIR);
                        else
                            if nn==1
                                proceedstr=questdlg('Sequence duration is less than 1 s, do you want to continue without active stabilization?','Warning',...
                                    'Yes','No','No');
                                if strcmp('No',proceedstr)
                                    return;
                                end
                            end
                        end
                        obj.tIR_end=clock;
                        
                    end
                    
                    
                    % collect
                    obj.tAndor_start=clock;
                    zPosition(nn)=obj.StageObj.Position(3);
                    sequence=obj.CameraObj.start_sequence();
                    obj.tAndor_end=clock;
                    %-----------------------------------------wait IR camera version 2------------
                    if obj.ActiveRegCheck==1
                        st=TimerIR.Running;
                        while(strcmp(st,'on'))
                            st=TimerIR.Running;
                            pause(0.1);
                        end
                        delete(TimerIR);
                    end
                    
                elseif strcmp(obj.sequenceType,'TwoTracking');
                    obj.CameraObj2=MIC_AndorCamera();
                    
                elseif strcmp(obj.sequenceType,'Tracking+SRCollect');
                    
                    
                    %Setup IRCamera
                    obj.IRCameraObj.ROI=obj.getROI('IRThorlabs')
                    obj.IRCameraObj.ExpTime_Sequence=obj.IRExpTime_Sequence_Set;
                    % time should be long to cover all process after
                    % syringe pump for 5min=0.01*30000
                    obj.IRCameraObj.SequenceLength=obj.ExpTime_Sequence_Set*obj.NumFrames+obj.IRsequenceLength_offset
                    obj.IRCameraObj.KeepData=1; % image is saved in IRCamera.Data
                    
                    %set timer for IRcamera
                    obj.TimerIRCamera=timer('StartDelay',0.9);
                    obj.TimerIRCamera.TimerFcn={@IRCamerasequenceTimerFcn,obj.IRCameraObj}
                    
                    %set timer for SyringePump
                    obj.SyringeWaitTime=obj.ExpTime_Sequence_Set*obj.NumFrames+obj.SyringeWaitTime_offset;
                    obj.IRCameraObj.SPwaitTime=obj.SyringeWaitTime
                    obj.tIR_start=clock;
                    start(obj.TimerIRCamera);
                    obj.tAndor_start=clock;
                    sequence=obj.CameraObj.start_sequence();
                    obj.tAndor_end=clock;
                    fprintf('IRCamera is finished...\n')
                    
                    %Turn off Syringe Pump
                    obj.TimerSyringe=clock;
                    obj.IRCameraObj.SP.stop() %(?)
                    fprintf('Syringe Pump is stopped\n')
                    
                    %                                         %clear IRCamera
                    %                                         obj.IRCameraObj.delete();
                    %                                         obj.IRCameraObj=[];
                end
                
                %Turn off Laser
                obj.Laser638Obj.off();
                %         obj.Laser561Obj.off();
                obj.LampObj.off();
                obj.Lamp850Obj.off();
                
                if isempty(sequence)
                    errordlg('Window was closed before capture complete.  No Data Saved.','Capture Failed');
                    return;
                end
                
                %Save
                switch obj.SaveFileType
                    case 'mat'
                        fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                        if strcmp(obj.sequenceType,'Tracking+SRCollect')
                            [Params IRData]=exportState(obj); %#ok<NASGU>
                            save(fn,'sequence','Params','IRData');
                        else
                            [Params]=exportState(obj); %#ok<NASGU>
                            save(fn,'sequence','Params','zPosition','MaxCC','Image_BF');
                        end
                    case 'h5' %This will become default
                        S=sprintf('Data%04d',nn)
                        MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01',S,sequence);
                    otherwise
                        error('StartSequence:: unknown SaveFileType')
                end
            end
            
            switch obj.SaveFileType
                case 'mat'
                    %Nothing to do
                case 'h5' %This will become default
                    S='MIC_TIRF_SRcollect';
                    MIC_H5.createGroup(FileH5,S);
                    obj.save2hdf5(FileH5,S);  %Not working yet
                otherwise
                    error('StartSequence:: unknown SaveFileType')
            end
            
        end
        
        
        function ROI=getROI(obj,CameraIndex)
            %these could be set from camera size;
            if nargin <2
                error('Choose type of Camera')
            end
            %             switch CameraIndex
            %                 case 'IRThorlabs'
            %                     DimX=obj.IRCameraObj.XPixels;
            %                     DimY=obj.IRCameraObj.YPixels;
            %                     cameraROI=obj.IRCameraROI;
            %                 case 'Andor'
            %                     DimX=obj.CameraObj.XPixels;
            %                     DimY=obj.CameraObj.YPixels;
            %                     cameraROI=obj.CameraROI;
            %             end
            if strcmp(CameraIndex,'Andor')
                DimX=obj.CameraObj.XPixels;
                DimY=obj.CameraObj.YPixels;
                cameraROI=obj.CameraROI;
                switch cameraROI
                    
                    case 1
                        ROI=[1 DimX 1 DimY]; %full
                    case 2
                        ROI=[1 round(DimX/2) 1 DimY];%left
                    case 3
                        ROI=[round(DimX/2)+1 DimX 1 DimY];%right
                    case 4  %Center Left
                        ROI=[1 round(DimX/2) round(DimX/4)+1 round(DimX*3/4)];
                    case 5
                        ROI=[round(DimX/2)+1 DimX round(DimX/4)+1 round(DimX*3/4)];% right center
                    case 6
                        ROI=[1 DimX round(DimX/4)+1 round(DimX*3/4)];% center horizontally
                    case 7
                        ROI=[1 DimX round(DimX*3/8)+1 round(DimX*5/8)];% center horizontally half
                    case 8
                        ROI=[1 DimX round(DimX*7/16)+1 round(DimX*9/16)];% 128*16 center
                    case 9
                        ROI=[DimX/2 DimX round(DimX*6/8) DimX];% 64*32 low right
                    case 10
                        ROI=[1 DimX/2 round(DimX*6/8) DimX];% 64*32 low left
                    case 11
                        ROI=[DimX/2 DimX round(DimX*14/16) DimX];% 64*32 low left
                        
                    otherwise
                        error('SRcollect: ROI not found')
                end
            elseif strcmp(CameraIndex,'IRThorlabs')
                DimX=obj.IRCameraObj.XPixels;
                DimY=obj.IRCameraObj.YPixels;
                cameraROI=obj.IRCameraROI;
                
                switch cameraROI
                    case 1
                        ROI=[1 DimX 1 DimY]; %full
                    case 2   %Center for SPT setup 350*350
                        ROI=[468 817 420 769];
                    case 3   %Center for SPT setup 256*256
                        % This was chosen manually
                        ROI=[515 770 467 722];
                    case 4   %Center for SPT setup 128*128
                        % This was chosen manually
                        ROI=[579 706 532 659];
                end
                
            end
        end
        
        function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all hardware objects and
            % SRcollect settings
            
            % Children
            [Children.Camera.Attributes,Children.Camera.Data,Children.Camera.Children]=...
                obj.CameraObj.exportState();
            
            [Children.IRCameraObj.Attributes,Children.IRCameraObj.Data,Children.IRCameraObj.Children]=...
                obj.IRCameraObj.exportState();
            
            [Children.Stage.Attributes,Children.Stage.Data,Children.Stage.Children]=...
                obj.StageObj.exportState();
            
            [Children.Laser638Obj.Attributes,Children.Laser638Obj.Data,Children.Laser638Obj.Children]=...
                obj.Laser638Obj.exportState();
            
            %     [Children.Laser561Obj.Attributes,Children.Laser561Obj.Data,Children.Laser561Obj.Children]=...
            %         obj.Laser561Obj.exportState();
            %
            [Children.Lamp.Attributes,Children.Lamp.Data,Children.Lamp.Children]=...
                obj.LampObj.exportState();
            
            [Children.Lamp850.Attributes,Children.Lamp850.Data,Children.Lamp850.Children]=...
                obj.Lamp850Obj.exportState();
            if isfield(obj,'Reg3D')
                [Children.Reg3D.Attributes,Children.Reg3D.Data,Children.Reg3D.Children]=...
                    obj.R3DObj.exportState();
            end
            
            
            % Our Properties
            Attributes.ExpTime_Focus_Set = obj.ExpTime_Focus_Set;
            Attributes.ExpTime_Sequence_Set = obj.ExpTime_Sequence_Set;
            Attributes.NumFrames = obj.NumFrames;
            Attributes.NumSequences = obj.NumSequences;
            Attributes.CameraGain = obj.CameraGain;
            Attributes.CameraEMGainHigh = obj.CameraEMGainHigh;
            Attributes.CameraEMGainLow = obj.CameraEMGainLow;
            Attributes.CameraROI = obj.getROI('Andor');
            Attributes.CameraPixelSize=obj.PixelSize;
            Attributes.IRExpTime_Focus_Set=obj.IRExpTime_Focus_Set;
            Attributes.IRExpTime_Sequence_Set=obj.IRExpTime_Sequence_Set;
            Attributes.IRCameraROI=obj.getROI('IRThorlabs');
            
            Attributes.SaveDir = obj.SaveDir;
            Attributes.RegType = obj.RegType;
            
            % light source properties
            Attributes.Laser638Low = obj.Laser638Low;
            %     Attributes.Laser561Low = obj.Laser561Low;
            Attributes.Laser638High = obj.Laser638High;
            %     Attributes.Laser561High = obj.Laser561High;
            Attributes.LampPower = obj.LampPower;
            Attributes.Lamp850Power = obj.Lamp850Power;
            %     Attributes.Laser561Aq = obj.Laser561Aq;
            Attributes.Laser638Aq = obj.Laser638Aq;
            Attributes.LampAq = obj.LampAq;
            Attributes.Lam850pAq = obj.Lamp850Aq;
            
            Data=obj.IRCameraObj.Data;
        end
    end
    
    methods (Static)
        
        function State = unitTest()
            State = obj.exportState();
        end
        
    end
end
