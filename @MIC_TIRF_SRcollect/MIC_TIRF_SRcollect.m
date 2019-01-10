classdef MIC_TIRF_SRcollect < MIC_Abstract
% MIC_TIRF_SRcollect: Matlab instrument class for controlling TIRF
% microscope in room 118.
%
% Super resolution data collection software for TIRF microscope. Creates
% object calling MIC classes for Andor EMCCD camera, MCL NanoDrive stage,
% 405 nm CrystaLaser, 488 nm SpectaPhysics Laser, 561 nm Coherent Laser,
% 642 nm Thorlabs TCube Laser Diode, halogen lamp attached to microscope
% and the registration class Reg3DTrans.
% Works with Matlab Instrument Control (MIC) classes since March 2017
%
% Example: TIRF=MIC_TIRF_SRcollect();
%
% REQUIRES:
%   MIC_Abstract
%   MIC_LightSource_Abstract
%   MIC_AndorCamera
%   MIC_NewportLaser488
%   MIC_CrystaLaser405
%   MIC_CoherentLaser561
%   MIC_TcubeLaserDiode
%   MIC_IX71Lamp
%   MIC_MCLNanoDrive
%   MIC_Reg3DTrans  
%   Matlab 2014b or higher
%
% CITATION:
% First version: Sheng Liu 
% MIC compatible version Sandeep Pallikuth & Marjolein Meddens
% Lidke Lab 2017

    properties
        % Hardware objects
        CameraObj;      % Andor Camera
        StageObj;       % MCL Nano Drive
        Laser405;       % CrystaLaser 405
        Laser488;       % NewPort Laser 488
        Laser561;       % CoherentLaser 561 
        Laser642;       % TCubeLaserDiode 642
        LampObj;        % IX71 Lamp
        R3DObj;         % Reg3DTrans class
        
        % Camera params
        ExpTime_Focus_Set=.01;          % Exposure time during focus
        ExpTime_Sequence_Set=.01;       % Exposure time during sequence
        ExpTime_Sequence_Actual=.02;
        ExpTime_Capture=.05;
        NumFrames=2000;                 % Number of frames per sequence
        NumSequences=20;                % Number of sequences per acquisition
        CameraGain=1;                   % Flag for adjusting camera Gain
        CameraEMGainHigh=100;           % High camera gain value 
        CameraEMGainLow=2;              % Low camera gain value 
        CameraROI=8;                    % Camera ROI (see gui for specifics)
        PixelSize;                      % Pixel size determined from calibration
        OrientMatrix;                   % unitary matrix to show orientation 
                                        % between Camera and Stage([a b;c d])

        % Light source params
        Laser405Low;    % Low power 405 laser
        Laser488Low;    % Low power 488 laser
        Laser561Low;    % Low power 561 laser
        Laser642Low;    % Low power 642 laser
        Laser405High;   % High power 405 laser
        Laser488High;   % High power 488 laser
        Laser561High;   % High power 561 laser
        Laser642High;   % High power 642 laser
        LampPower;      % Power of lamp
        Laser405Aq;     % Flag for using 405 laser during acquisition
        Laser488Aq;     % Flag for using 488 laser during acquisition
        Laser561Aq;     % Flag for using 561 laser during acquisition
        Laser642Aq;     % Flag for using 642 laser during acquisition
        LampAq;         % Flag for using lamp during acquisition
        LampWait=2.5;   % Lamp wait time
        focus405Flag=0;       % Flag for using 405 laser during focus
        focus488Flag=0;       % Flag for using 488 laser during focus
        focus561Flag=0;       % Flag for using 561 laser during focus
        focus642Flag=0;       % Flag for using 642 laser during focus
        focusLampFlag=0;  % Flag for using Lamp during focus
        
        % Other things
        SaveDir='y:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='mat'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
    end
    
    properties (SetAccess = protected)
        InstrumentName = 'TIRF_SRcollect'; % Descriptive name of "instrument"
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  Set to false to prevent gui opening before hardware is initialized.
    end
    
    methods
        function obj=MIC_TIRF_SRcollect()
            % MIC_TIRF_SRcollect constructor
            %   Constructs object and initializes all hardware
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
                [p,~]=fileparts(which('MIC_TIRF_SRcollect'));
                f=fullfile(p,'TIRF_Calibrate.mat');
            
            % Initialize hardware objects
            try
                % Camera
                fprintf('Initializing Camera\n')
                obj.CameraObj=MIC_AndorCamera();
                CamSet = obj.CameraObj.CameraSetting;
                CamSet.FrameTransferMode.Bit=1;
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
                % Stage
                fprintf('Initializing Stage\n')
                obj.StageObj=MIC_MCLNanoDrive();
                % Lasers
                fprintf('Initializing 405 laser\n')
                obj.Laser405 = MIC_CrystaLaser405('Dev1','ao1','Port0/Line3');
                obj.Laser405Low = 1;
                obj.Laser405High = 4;
                fprintf('Initializing 488 laser\n')
                obj.Laser488=MIC_TIRFLaser488();
                obj.Laser488Low = 1;
                obj.Laser488High = 10;
                fprintf('Initializing 561 laser\n')
                obj.Laser561 = MIC_CoherentLaser561('COM4');
                obj.Laser561Low = 1;
                obj.Laser561High = 10;
                fprintf('Initializing 642 laser\n')
                obj.Laser642 = MIC_TCubeLaserDiode('64838719','Power',80,182.5,1);
                obj.Laser642Low = 1;
                obj.Laser642High = obj.Laser642.MaxPower;
                % Lamp
                fprintf('Initializing lamp\n')
                obj.LampObj=MIC_IX71Lamp('Dev1','ao3','Port0/Line12');
                obj.LampPower = 50;
                % Registration object
                fprintf('Initializing Registration object\n')
                obj.R3DObj=MIC_Reg3DTrans(obj.CameraObj,obj.StageObj,f);
                if ~exist(f,'file')
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
                        obj.R3DObj.CameraObj.ROI=[1 256 257 512];
                        obj.R3DObj.calibrate();
                        obj.LampObj.off();
                    obj.CameraObj.ROI=[1 256 1 256];
                    obj.R3DObj.calibrate();
                end  
                if exist(f,'file')
                    a=load(f);
                    obj.PixelSize=a.PixelSize;
                    obj.OrientMatrix=a.OrientMatrix;
                    clear a;
                end
                obj.R3DObj.ChangeExpTime=true;
                obj.R3DObj.ExposureTime=0.01;
           catch ME
               ME
                error('hardware startup error');
                
            end
            
            %Set save directory
            user_name = java.lang.System.getProperty('user.name');
            timenow=clock;
            obj.SaveDir=sprintf('Y:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3));
            
            % Start gui (not using StartGUI property because GUI shouldn't
            % be started before hardware initialization)
            obj.gui();
        end
        
        function delete(obj)
            %delete all objects
            delete(obj.GuiFigure);
            close all force;
            clear;
        end
        
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
        end
        
        function align(obj)
            % Align to current reference image
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
                obj.R3DObj.align2imageFit();
                % change back camera setting to the values before using the R3DTrans class
                obj.R3DObj.CameraObj.setShutter(0);
                CamSet.EMGain.Value = EMGTemp;
                CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
        end
        
        function showref(obj)
            % Displays current reference image
            dipshow(obj.R3DObj.Image_Reference);
        end
        
        function takeref(obj)
            % Captures reference image
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
                obj.R3DObj.takerefimage();
                % change back camera setting to the values before using the R3DTrans class
                obj.R3DObj.CameraObj.setShutter(0);
                CamSet.EMGain.Value = EMGTemp;
                CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
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
            if obj.focus405Flag
                obj.Laser405.setPower(obj.Laser405Low);
                obj.Laser405.on();
            else
                obj.Laser405.off();
            end
            if obj.focus488Flag
                obj.Laser488.setPower(obj.Laser488Low);
                obj.Laser488.on();
            else
                obj.Laser488.off();
            end
            if obj.focus561Flag
                obj.Laser561.setPower(obj.Laser561Low);
                obj.Laser561.on;
            else
                obj.Laser561.off;
            end
            if obj.focus642Flag
                obj.Laser642.setPower(obj.Laser642Low);
                obj.Laser642.on;
            else
                obj.Laser642.off;
            end
            if obj.focusLampFlag
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on;
            else
                obj.LampObj.off;
            end
            % Aquiring and diplaying images
            obj.CameraObj.ROI=obj.getROI();
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            out=obj.CameraObj.start_focus();
            % Turning lasers off
            obj.Laser405.off;
            obj.Laser488.off;
            obj.Laser561.off;
            obj.Laser642.off;
            obj.LampObj.off;
        end

        function focusHigh(obj)
            % Focus function using the high laser settings
            CamSet=obj.CameraObj.CameraSetting;
            CamSet.EMGain.Value = obj.CameraEMGainHigh;
            obj.CameraObj.setCamProperties(CamSet);
    %        Lasers set up to 'high' power setting
            if obj.focus405Flag
                obj.Laser405.setPower(obj.Laser405High);
                obj.Laser405.on;
            else
                obj.Laser405.off;
            end
            if obj.focus488Flag
                obj.Laser488.setPower(obj.Laser488High);
                obj.Laser488.on;
            else
                obj.Laser488.off;
            end
            if obj.focus561Flag
                obj.Laser561.setPower(obj.Laser561High);
                obj.Laser561.on;
            else
                obj.Laser561.off;
            end
            if obj.focus642Flag
                obj.Laser642.setPower(obj.Laser642High);
                obj.Laser642.on;
            else
                obj.Laser642.off;
            end
            if obj.focusLampFlag
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on;
            else
                obj.LampObj.off;
            end
            % Aquiring and displaying images
            obj.CameraObj.ROI=obj.getROI();
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            out=obj.CameraObj.start_focus();
            % Turning lasers off
            obj.Laser405.off;
            obj.Laser488.off;
            obj.Laser561.off;
            obj.Laser642.off;
            obj.LampObj.off;
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
            % Continuous display of image with lamp on. Useful for focusing of
            % the microscope.
            CamSet = obj.CameraObj.CameraSetting;
            %put Shutter back to auto
            CamSet.ManualShutter.Bit=0;
            %obj.CameraObj.setCamProperties(CamSet);        
            CamSet.EMGain.Value = obj.CameraEMGainLow;
            obj.CameraObj.setCamProperties(CamSet);
            obj.LampObj.setPower(obj.LampPower);
            obj.LampObj.on;
            obj.CameraObj.ROI=obj.getROI();
            obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
            obj.CameraObj.AcquisitionType = 'focus';
            obj.CameraObj.setup_acquisition();
            obj.CameraObj.start_focus();
            %dipshow(out);
            CamSet.EMGain.Value = obj.CameraEMGainHigh;
            obj.CameraObj.setCamProperties(CamSet);
            obj.LampObj.off;
 %           pause(obj.LampWait);
        end
        
        function StartSequence(obj,guihandles)
            
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            
            %first take a reference image or align to image
           
           obj.LampObj.setPower(obj.LampPower);
           
           
           switch obj.RegType
                case 'Self' %take and save the reference image
                    obj.takeref();
                    f=fullfile(obj.SaveDir,[obj.BaseFileName s '_ReferenceImage']);
                    Image_Reference=obj.R3DObj.Image_Reference; %#ok<NASGU>
                    save(f,'Image_Reference');
           end
            
           switch obj.SaveFileType
               case 'mat'
               case 'h5'
                   FileH5=fullfile(obj.SaveDir,[obj.BaseFileName s '.h5']);
                   MIC_H5.createFile(FileH5);
%                    Previously used group structure
%                    MIC_H5.createGroup(FileH5,'Data');
%                    MIC_H5.createGroup(FileH5,'Data/Channel01');
                   MIC_H5.createGroup(FileH5,'Channel01');
                   MIC_H5.createGroup(FileH5,'Channel01/Zposition001');
               otherwise
                   error('StartSequence:: unknown file save type')
           end
           
            %loop over sequences
            for nn=1:obj.NumSequences
                if obj.AbortNow; obj.AbortNow=0; break; end
                
                nstring=strcat('Acquiring','...',num2str(nn),'/',num2str(obj.NumSequences));
                set(guihandles.Button_ControlStart, 'String',nstring,'Enable','off');
                
                %align to image
                switch obj.RegType
                    case 'None'
                    otherwise
                        obj.align();
                end
                
                %Setup laser for aquisition
                if obj.Laser405Aq
                    obj.Laser405.setPower(obj.Laser405High);
                    obj.Laser405.on;
                end
                if obj.Laser488Aq
                    obj.Laser488.setPower(obj.Laser488High);
                    obj.Laser488.on;
                end
                if obj.Laser561Aq
                    obj.Laser561.setPower(obj.Laser561High);
                    obj.Laser561.on;
                end
                if obj.Laser642Aq
                    obj.Laser642.setPower(obj.Laser642High);
                    obj.Laser642.on;
                end
                if obj.LampAq
                    obj.LampObj.setPower(obj.LampPower);
                    obj.LampObj.on;
                end
                
                %Setup Camera
                CamSet = obj.CameraObj.CameraSetting;
                CamSet.EMGain.Value = obj.CameraEMGainHigh;
                switch obj.CameraGain
                    case 1 %Low pre-amp gain
                        CamSet.PreAmpGain.Bit=2;
                    case 2 %high pre-amp gain
                end
                obj.CameraObj.setCamProperties(CamSet);
                obj.CameraObj.ExpTime_Sequence=obj.ExpTime_Sequence_Set;
                obj.CameraObj.SequenceLength=obj.NumFrames;
                obj.CameraObj.ROI=obj.getROI();
                
                %Collect
                sequence=obj.CameraObj.start_sequence(); 
                
                %Turn off Laser
                obj.Laser405.off;
                obj.Laser488.off;
                obj.Laser561.off;
                obj.Laser642.off;
                obj.LampObj.off;
                
                %Save
                switch obj.SaveFileType
                    case 'mat'
                        fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                        Params=exportState(obj); %#ok<NASGU>
                        save(fn,'sequence','Params');
                    case 'h5' %This will become default
                        S=sprintf('Data%04d',nn)
                        MIC_H5.writeAsync_uint16(FileH5,'Channel01/Zposition001',S,sequence);
                    otherwise
                        error('StartSequence:: unknown SaveFileType')
                end
            end
            
            switch obj.SaveFileType
                case 'mat'
                    %Nothing to do
                case 'h5' %This will become default
                    % S='MIC_TIRF_SRcollect'; % -modified SP
                    S='Channel01/Zposition001'; % -modified SP
                    MIC_H5.createGroup(FileH5,S);
                    obj.save2hdf5(FileH5,S);  %Working
                otherwise
                    error('StartSequence:: unknown SaveFileType')
            end
  
        end
        
        function ROI=getROI(obj)
            %these could be set from camera size;
            switch obj.CameraROI
                case 1
                    ROI=[1 512 1 512]; %full
                case 2
                    ROI=[1 256 1 512];%left
                case 3
                    ROI=[257 512 1 512];%right
                case 4  
                    ROI=[1 256 129 384];%Center Left
                case 5
                    ROI=[257 512 129 384];% Center right
                case 6
                    ROI=[1 512 129 384];% center horizontal
                case 7
                    ROI=[1 256 1 256];% Left Top quadrant
                case 8
                    ROI=[1 256 257 512];% Left Bottom quadrant
                case 9
                    ROI=[257 512 1 256];% Right Top quadrant
                case 10
                    ROI=[257 512 257 512];% Right Bottom quadrant
                case 11
                    ROI=[1 512 1 256];% Top half
                    
                case 12
                    ROI=[1 512 257 512];% Bottom half
                case 13
                    ROI=[129 384 129 384];% center256
                    
                otherwise
                    error('SRcollect: ROI not found')
            end
        end
        
        function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all hardware objects
            % and SRcollect settings
            
            % Children
            [Children.Camera.Attributes,Children.Camera.Data,Children.Camera.Children]=...
                obj.CameraObj.exportState();
            
            [Children.Stage.Attributes,Children.Stage.Data,Children.Stage.Children]=...
                obj.StageObj.exportState();
            
            [Children.Laser405.Attributes,Children.Laser405.Data,Children.Laser405.Children]=...
                obj.Laser405.exportState();
            
            [Children.Laser488.Attributes,Children.Laser488.Data,Children.Laser488.Children]=...
                obj.Laser488.exportState();
            
            [Children.Laser561.Attributes,Children.Laser561.Data,Children.Laser561.Children]=...
                obj.Laser561.exportState();
            
            [Children.Laser642.Attributes,Children.Laser642.Data,Children.Laser642.Children]=...
                obj.Laser642.exportState();
            
            [Children.Lamp.Attributes,Children.Lamp.Data,Children.Lamp.Children]=...
                obj.LampObj.exportState();
            
            [Children.Reg3D.Attributes,Children.Reg3D.Data,Children.Reg3D.Children]=...
                obj.R3DObj.exportState();
            
            
            
            % Our Properties
            Attributes.ExpTime_Focus_Set = obj.ExpTime_Focus_Set;
            Attributes.ExpTime_Sequence_Set = obj.ExpTime_Sequence_Set;
            Attributes.NumFrames = obj.NumFrames;
            Attributes.NumSequences = obj.NumSequences;
            Attributes.CameraGain = obj.CameraGain;
            Attributes.CameraEMGainHigh = obj.CameraEMGainHigh;
            Attributes.CameraEMGainLow = obj.CameraEMGainLow;
            Attributes.CameraROI = obj.getROI;
            Attributes.CameraPixelSize=obj.PixelSize;
            
            
            Attributes.SaveDir = obj.SaveDir;
            Attributes.RegType = obj.RegType;
            
            % light source properties
            Attributes.Laser405Low = obj.Laser405Low;
            Attributes.Laser488Low = obj.Laser488Low;
            Attributes.Laser561Low = obj.Laser561Low;
            Attributes.Laser642Low = obj.Laser642Low;
            Attributes.Laser405High = obj.Laser405High;
            Attributes.Laser488High = obj.Laser488High;
            Attributes.Laser561High = obj.Laser561High;
            Attributes.Laser642High = obj.Laser642High;
            Attributes.LampPower = obj.LampPower;
            Attributes.Laser405Aq = obj.Laser405Aq;
            Attributes.Laser488Aq = obj.Laser488Aq;
            Attributes.Laser561Aq = obj.Laser561Aq;
            Attributes.Laser642Aq = obj.Laser642Aq;
            Attributes.LampAq = obj.LampAq;
            Data=[];
        end
    end
    
    methods (Static)
        
        function State = unitTest()
            State = obj.exportState();
        end
        
    end
end


