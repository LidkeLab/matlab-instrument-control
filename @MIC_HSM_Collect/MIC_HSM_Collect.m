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
    
    %TODO
    
    
    
    
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
        DataDir='h:\'; 
        SaveDir='h:\';  % Save Directory
        BaseFileName='Cell1';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        RegType='None'; % Registration type, can be 'None', 'Self' or 'Ref'
        SaveFileType='mat'  %Save to *.mat or *.H5.  Options are 'mat' or 'H5'
        %          HSMMaxROI=[852 1335 890 1400];%for Atto 488
        %         HSMMaxROI=[1000 1300 900 1500];%for Atto 520
        %         ROI =[1000 1300 900 1500];%for Atto 520
        HSMMaxROI=[785 1150 930 1400];%for tetraspek beads
        ROI=[800 1050 900 1500]; % Camera ROI [LeftTop ...]
        % Camera params
        Exp_Focus = 0.1;
        PixelSizeLuca;                   % Pixel size determined from calibration
        OrientMatrix;                   % unitary matrix to show orientation
        % between Camera and Stage([a b;c d])
        
        % Scan params
        NSteps = 200;
        StepAngle = 0.00186; % Step angle in degrees 0.00186
        Exp_Scan = 0.02;
        Nsequences =20;
        NSeqBeforeRegistration = 5;
        sequence_1;
        sequence_2;
        sequence_3;
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
                obj.CameraLuca.ROI= [300 800 300 800];
                
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
        function scanFocus(obj)
            
            %Take background scan
            obj.BackgroundScanN=100;
            obj.collect_background();
            dipshow(obj.Background)
            
            % H.LaserObj.setPower();
            obj.LaserObj.on();
            Y=figure
            P=figure
            F=figure
            while 1
                Data=obj.single_scan();
                dipshow(F,sum(Data(:,:,250:300),3))
                diptruesize(100)
                dipshow(P,sum(Data(:,:,330:370),3))
                diptruesize(300)
                dipshow(Y,sum(Data(:,:,370:400),3))
                diptruesize(100)
            end
            
            obj.LaserObj.off();
        end
        function single_scan_sequence(obj)
            
           
            obj.FlipMount.FilterOut;
            fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            obj.DataDir = obj.SaveDir;
            %first take a reference image or align to image
            
            obj.LampObj.setPower(obj.LampPower);
            
            obj.RegType='Self';
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
                    MIC_H5.createGroup(FileH5,'Channel01');
                    MIC_H5.createGroup(FileH5,'Channel01/Zposition001');
                otherwise
                    error('StartSequence:: unknown file save type')
            end
            
            
            
            
            obj.FlipMount.FilterIn;
            fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
            
            
            
            obj.CameraZyla.abort()
            %Take background scan
            obj.LaserObj.off()
            obj.BackgroundScanN=100;
            obj.collect_background();
            dipshow(obj.Background)
            
            obj.sequence_1 = zeros(obj.ROI(2)-obj.ROI(1)+1,obj.NSteps,obj.Nsequences);
            obj.sequence_2 = zeros(obj.ROI(2)-obj.ROI(1)+1,obj.NSteps,obj.Nsequences);
%             obj.sequence_3 = zeros(obj.ROI(2)-obj.ROI(1)+1,obj.NSteps,obj.Nsequences);
%             F=figure
%             Y=figure
%             P=figure
            for ii=1:obj.Nsequences
                ii
                if ~mod(ii, obj.NSeqBeforeRegistration)
                    pause(1)
                    obj.FlipMount.FilterOut;
                    
                    fprintf('Start aliging...\n')
                    obj.align();% Align
                    fprintf('Alignment is done...\n')
                    
                    
                    obj.FlipMount.FilterIn;
                    pause(1)
                    
                end
                obj.LaserObj.on();
                Data=obj.single_scan();
                DataXY_1=sum(Data(:,:,330:370),3);% 530nm spectra selection
                DataXY_2=sum(Data(:,:,370:400),3);% 488nm spectra selection
%                 DataXY_3=sum(Data(:,:,200:470),3);
                obj.sequence_1(:,:,ii)=DataXY_1;
                obj.sequence_2(:,:,ii)=DataXY_2;
%                 obj.sequence_3(:,:,ii)=DataXY_3;
%                 dipshow(F,DataXY_1)
%                 diptruesize(200)
%                 dipshow(Y,DataXY_2)
%                 diptruesize(200)
%                 dipshow(P,DataXY_2)
%                 diptruesize(200)
                obj.LaserObj.off();
                
                
                
            end
            
            
         
            
        end
        function singleScan(obj)
           
            obj.LaserObj.off()
            obj.BackgroundScanN=100;
            obj.collect_background();
            obj.LaserObj.on()
            Data=obj.single_scan();
            obj.LaserObj.off()
            dipshow(sum(Data(:,:,:),3))
            diptruesize(100)
        end
        function atLiveMode(obj)
            % Used for checking pinhole alignment
            disp('Andor SDK3 Live Mode Example');
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
            [rc,hndl] = AT_Open(0);
            AT_CheckError(rc);
            disp('Camera initialized');
            [rc] = AT_SetFloat(hndl,'ExposureTime',0.1);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'CycleMode','Continuous');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'TriggerMode','Software');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');
            AT_CheckWarning(rc);
            [rc] = AT_SetInt(hndl,'AOIWidth',1400);
            [rc] = AT_SetInt(hndl,'AOILeft',250);
            [rc] = AT_SetInt(hndl,'AOIHeight',1400);
            [rc] = AT_SetInt(hndl,'AOITop',300);
            [rc,imagesize] = AT_GetInt(hndl,'ImageSizeBytes');
            % AT_CheckWarning(rc);
            [rc,height] = AT_GetInt(hndl,'AOIHeight');
            % AT_CheckWarning(rc);
            [rc,width] = AT_GetInt(hndl,'AOIWidth');
            % AT_CheckWarning(rc);
            [rc,stride] = AT_GetInt(hndl,'AOIStride');
            % AT_CheckWarning(rc);
            warndlg('To Abort the acquisition close the image display.','Starting Acquisition')
            disp('Starting acquisition...');
            [rc] = AT_Command(hndl,'AcquisitionStart');
            AT_CheckWarning(rc);
            buf2 = zeros(width,height);
            h=imagesc(buf2);
            while(ishandle(h))
                [rc] = AT_QueueBuffer(hndl,imagesize);
                AT_CheckWarning(rc);
                [rc] = AT_Command(hndl,'SoftwareTrigger');
                AT_CheckWarning(rc);
                [rc,buf] = AT_WaitBuffer(hndl,1000);
                AT_CheckWarning(rc);
                [rc,buf2] = AT_ConvertMono16ToMatrix(buf,height,width,stride);
                AT_CheckWarning(rc);
                set(h,'CData',buf2);
                drawnow;
                
            end
            
            P=prctile(buf2(buf2>0),99.9);
            buf2(buf2>P)=P;
            h=imagesc(buf2);
            set(h,'CData',buf2);
            
            disp('Acquisition complete');
            [rc] = AT_Command(hndl,'AcquisitionStop');
            AT_CheckWarning(rc);
            [rc] = AT_Flush(hndl);
            AT_CheckWarning(rc);
            [rc] = AT_Close(hndl);
            AT_CheckWarning(rc);
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            disp('Camera shutdown');

        end
        function atKineticSeries(obj)
            %Used to take images for calibration
            disp('Andor SDK3 Kinetic Series Example');
            [rc] = AT_InitialiseLibrary();
            AT_CheckError(rc);
            [rc,hndl] = AT_Open(0);
            AT_CheckError(rc);
            disp('Camera initialized');
            [rc] = AT_SetFloat(hndl,'ExposureTime',0.05);
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'CycleMode','Fixed');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'TriggerMode','Internal');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'SimplePreAmpGainControl','16-bit (low noise & high well capacity)');
            AT_CheckWarning(rc);
            [rc] = AT_SetEnumString(hndl,'PixelEncoding','Mono16');
            AT_CheckWarning(rc);
            prompt = {'Enter Acquisition name','Enter number of images'};
            dlg_title = 'Configure acquisition';
            num_lines = 1;
            def = {'acquisition','10'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            filename = cell2mat(answer(1));
            frameCount = str2double(cell2mat(answer(2)));
            [rc] = AT_SetInt(hndl,'FrameCount',frameCount);
            AT_CheckWarning(rc); 
            [rc] = AT_SetInt(hndl,'AOIWidth',1400);
            [rc] = AT_SetInt(hndl,'AOILeft',250);
            [rc] = AT_SetInt(hndl,'AOIHeight',1400);
            [rc] = AT_SetInt(hndl,'AOITop',300);
            [rc,imagesize] = AT_GetInt(hndl,'ImageSizeBytes');
            AT_CheckWarning(rc);
            [rc,height] = AT_GetInt(hndl,'AOIHeight');
            AT_CheckWarning(rc);
            [rc,width] = AT_GetInt(hndl,'AOIWidth');
            AT_CheckWarning(rc);
            [rc,stride] = AT_GetInt(hndl,'AOIStride');
            AT_CheckWarning(rc);
            for X = 1:10
                [rc] = AT_QueueBuffer(hndl,imagesize);
                AT_CheckWarning(rc);
            end
            disp('Starting acquisition...');
            [rc] = AT_Command(hndl,'AcquisitionStart');
            AT_CheckWarning(rc);
            i=0;
            while(i<frameCount)
                [rc,buf] = AT_WaitBuffer(hndl,1000);
                AT_CheckWarning(rc);
                [rc] = AT_QueueBuffer(hndl,imagesize);
                AT_CheckWarning(rc);
                [rc,buf2] = AT_ConvertMono16ToMatrix(buf,height,width,stride);
                AT_CheckWarning(rc);
                P=prctile(buf2(buf2>0),99.9);
                buf2(buf2>P)=P;
                h=imagesc(buf2);
                set(h,'CData',buf2);
                
                thisFilename = strcat(filename, num2str(i+1), '.tiff');
                disp(['Writing Image ', num2str(i+1), '/',num2str(frameCount),' to disk']);
                imwrite(buf2,thisFilename) %saves to current directory
                
                i = i+1;
            end
            disp('Acquisition complete');
            [rc] = AT_Command(hndl,'AcquisitionStop');
            AT_CheckWarning(rc);
            [rc] = AT_Flush(hndl);
            AT_CheckWarning(rc);
            [rc] = AT_Close(hndl);
            AT_CheckWarning(rc);
            [rc] = AT_FinaliseLibrary();
            AT_CheckWarning(rc);
            disp('Camera shutdown');

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


