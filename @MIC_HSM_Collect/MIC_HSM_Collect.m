classdef MIC_HSM_Collect < MIC_Abstract
% MIC_HSM_Collect: Matlab instrument class for controlling HSM
%
% Example: HSM=MIC_HSM_Collect();
%
% REQUIRES:
%
%   Matlab 2014b or higher
%
% CITATION:
% 
% Lidke Lab 2017

% Created by Keith Lidke, Elton Jhamba, Hanieh Mazloom-Farsibaf 2019
    
    properties
        % objardware objects
        CameraZyla;      % Andor Camera
        CameraLuca;     % Luca
        LaserObj;       % NewPort Laser 488
        GalvoObj;       % Galvo Obj
        LampObj;        % IX71 Lamp
        StageObj;       % MCL Nano Drive
        FlipMount;      % flipmount mirror
        R3DObj;         % Reg3DTrans class
        
        % Light source params
        LampPower;      % Power of lamp 
        LampAq;         % Flag for using lamp during acquisition
        LampWait=2.5;   % Lamp wait time
        % Other things
        SaveDir='h:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='mat'  %Save to *.mat or *.H5.  Options are 'mat' or 'H5'
%          HSMMaxROI=[852 1335 890 1400];%for Atto 488
%         HSMMaxROI=[1000 1300 900 1500];%for Atto 520
%         ROI =[1000 1300 900 1500];%for Atto 520
           HSMMaxROI=[785 1150 930 1400];%for tetraspek beads
        ROI =[900 1080 730 1200];
        % Camera params
        Exp_Focus = 0.1;
        PixelSizeLuca;                   % Pixel size determined from calibration
        OrientMatrix;                   % unitary matrix to show orientation 
                                        % between Camera and Stage([a b;c d])
       
        % Scan params
        NSteps = 400;
        StepAngle = 0.00186; % Step angle in degrees
        Exp_Scan = 0.01;

        % Background 
        BackgroundScanN = 500;
        Background;
        
    end
    
    properties (SetAccess = protected)
        InstrumentName = 'MIC_HSM_Collect'; % Descriptive name of "instrument"
    end
    
     properties (Hidden)
         StartGUI;       %Defines GUI start mode.  Set to false to prevent gui opening before objardware is initialized.
     end
    
    methods
        function obj=MIC_HSM_Collect()
            % MIC_TIRF_SRcollect constructor
            %   Constructs object and initializes all objardware
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
%                  [p,~]=fileparts(which('MIC_HSM_Collect'));
 [p,~]=fileparts(which('MIC_HSM_Collect'));
 f=fullfile(p,'HSM_Calibrate.mat');
          
            % Initialize objardware objects
       try    
            %camera
            fprintf('Initializing Cameras\n')
            obj.CameraLuca=MIC_AndorCamera();
            obj.CameraZyla=MIC_AndorCameraZyla();
            %LUCA Camera settings
            CamSet = obj.CameraLuca.CameraSetting;
            CamSet.FrameTransferMode.Bit=1;
            CamSet.BaselineClamp.Bit=1;
%             CamSet.VSSpeed.Bit=4;
            CamSet.HSSpeed.Bit=0;
%             CamSet.PreAmpGain.Bit=2;
            CamSet.EMGain.Value = 2;
            obj.CameraLuca.setCamProperties(CamSet);
            obj.CameraLuca.setup_acquisition();
            obj.CameraLuca.ReturnType='matlab';
            obj.CameraLuca.DisplayZoom=4;
            obj.CameraLuca.ROI= [200 800 200 800];
           
            % Stage
            fprintf('Initializing Stage\n')
            obj.StageObj=MIC_MCLNanoDrive();
            
            % Laser
            obj.LaserObj = MIC_HSMLaser488();
           
            % Lamp
            obj.LampObj=MIC_IX71Lamp('Dev3','ao0','Port1/Line3');
            obj.LampPower = 45;
            
            % Galvo
            obj.GalvoObj = MIC_GalvoDigital('Dev1','Port0/Line0:31');
            obj.GalvoObj.enable();
            obj.GalvoObj.angle2word(0);
            obj.GalvoObj.setAngle();
            %FlipMount Mirror
        
          obj.FlipMount = MIC_FlipMountTTL('Dev1','Port1/Line2');

        % Registration object
        fprintf('Initializing Registration object\n')
        
        obj.R3DObj=MIC_Reg3DTrans(obj.CameraLuca,obj.StageObj,f);
        if ~exist(f,'file')
                CamSet = obj.R3DObj.CameraObj.CameraSetting;
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                 EMGTemp = CamSet.EMGain.Value;
                 CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                %set the lamp
                if isempty(obj.LampPower) || obj.LampPower==0
                    obj.LampPower=obj.LampObj.MaxPower/2;
                end
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on();
                fprintf('Calibrating camera and stage ...\n')
                pause(obj.LampWait);
%                 obj.R3DObj.align2imageFit();
                obj.R3DObj.CameraObj.ROI=[100 900 100 900];
                obj.R3DObj.calibrate();
                obj.LampObj.off();
%             obj.CameraLuca.ROI=[100 900 100 900];
%             obj.R3DObj.calibrate();
        end  
        if exist(f,'file')
            a=load(f);
            obj.PixelSizeLuca=a.PixelSize;
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
            user_name = 'Data'; %java.lang.System.getProperty('user.name');
            timenow=clock;
            obj.SaveDir=sprintf('H:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3));
            
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
             fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
             pause(1)
             obj.FlipMount.FilterOut;
             pause(1)
             CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
             EMGTemp = CamSet.EMGain.Value;
             CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
             obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
             
             %set the lamp
             if isempty(obj.LampPower) || obj.LampPower==0
                 obj.LampPower=obj.LampObj.MaxPower/2;
             end
             obj.LampObj.setPower(obj.LampPower);
             obj.LampObj.on();
             pause(obj.LampWait);
             obj.R3DObj.getcurrentimage();
             % change back camera setting to the values before using the R3DTrans class
             CamSet.EMGain.Value = EMGTemp;
             obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
             obj.LampObj.off();
             
             
         end
         
        
       % Align to current reference image
    %set the Andor Camera
        function align(obj)
           
        
            CamSet = obj.R3DObj.CameraObj.CameraSetting; %take the saved setting
            EMGTemp = CamSet.EMGain.Value;
            CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
            obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties

            %set the lamp
            if isempty(obj.LampPower) || obj.LampPower==0
                obj.LampPower=obj.LampObj.MaxPower/2;
            end
            obj.LampObj.setPower(obj.LampPower);
            obj.LampObj.on();
            pause(obj.LampWait);
            obj.R3DObj.align2imageFit();
            % change back camera setting to the values before using the R3DTrans class
            CamSet.EMGain.Value = EMGTemp;
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
                 %set the mannualShutter be one
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                
                %set the lamp
                if isempty(obj.LampPower) || obj.LampPower==0
                    obj.LampPower=obj.LampObj.MaxPower/2;
                end
                obj.LampObj.setPower(obj.LampPower);
                obj.LampObj.on();
                pause(obj.LampWait);
                obj.R3DObj.takerefimage();
                % change back camera setting to the values before using the R3DTrans class
                CamSet.EMGain.Value = EMGTemp;
                obj.R3DObj.CameraObj.setCamProperties(CamSet); %set the camera properties
                obj.LampObj.off();
                
                
        end
        
        function saveref(obj)
            % Saves current reference image
            obj.R3DObj.saverefimage();
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
        
        function focus_raw(obj)
            obj.CameraZyla.ROI = obj.ROI;
            obj.CameraZyla.ExpTime_Focus= obj.Exp_Focus; 
            obj.CameraZyla.start_focus();
        end
        
        function collect_background(obj)
            obj.CameraZyla.ROI = obj.ROI;
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.BackgroundScanN;
            obj.CameraZyla.start_sequence();
            obj.Background = single(mean(obj.CameraZyla.Data,3));
        end
        
        function Data=single_scan(obj)
            % Setup camera
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.NSteps;
            obj.CameraZyla.ROI = obj.ROI;
            
            % Setup Galvo
            obj.GalvoObj.N_Step =obj.NSteps;       
            obj.GalvoObj.StepSize = obj.StepAngle; 
            obj.GalvoObj.N_Scan=1; % number of scans 
            obj.GalvoObj.Offset = 0;     
            obj.GalvoObj.enable();       %enable first
            obj.GalvoObj.setSequence();

            %This is main data collection
            obj.CameraZyla.start_sequence();
            %--------------------------
            
            %Get data and finish 
            Data=single(obj.CameraZyla.Data)-repmat(obj.Background,[1 1 obj.NSteps]);
            
            Data=permute(Data,[1 3 2]); % to check the raw data in (x,y) instead of (x,Lambda)
            
            %disable and clear sessions in galvo
            obj.GalvoObj.disable();
            obj.GalvoObj.clearSession();
            
        end
        
        
        function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all objardware objects
            % and SRcollect settings
            
            % Children
            [Children.CameraZyla.Attributes,Children.CameraZyla.Data,Children.CameraZyla.Children]=...
                obj.CameraZyla.exportState();
            
            [Children.CameraLuca.Attributes,Children.CameraLuca.Data,Children.CameraLuca.Children]=...
                obj.CameraLuca.exportState();
            
            [Children.Stage.Attributes,Children.Stage.Data,Children.Stage.Children]=...
                obj.StageObj.exportState();
            
            [Children.Lamp.Attributes,Children.Lamp.Data,Children.Lamp.Children]=...
                obj.LampObj.exportState();
            
            [Children.Reg3D.Attributes,Children.Reg3D.Data,Children.Reg3D.Children]=...
                obj.R3DObj.exportState();
            
            [Children.FlipMount.Attributes,Children.FlipMount.Data,Children.FlipMount.Children]=...
                obj.FlipMount.exportState();
            % Our Properties
         
            Attributes=[];
            Data=[];
        end
    end
    
    methods (Static)
        
        function State = unitTest()
            State = obj.exportState();
        end
        
    end
end


