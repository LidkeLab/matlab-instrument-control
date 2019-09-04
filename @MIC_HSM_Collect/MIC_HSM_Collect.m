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
        % Zyla ROI
        
        CameraROI=1; %Camera ROI (see gui for specifics)
        
        % Camera params
        Exp_Focus = 0.01;
        PixelSizeLuca;                   % Pixel size determined from calibration
        OrientMatrix;                   % unitary matrix to show orientation
        % between Camera and Stage([a b;c d])
        
        % Scan params
        NSteps = 200;
        StepAngle = 0.00186; % Step angle in degrees 0.00186
        Exp_Scan = 0.01;
        Nsequences =20;
        %         NSeqBeforeRegistration = 5;
        DataCube = 5;% data cubes
        sequence_1;
        sequence_2;
        sequence_3;
        % Background
        BackgroundScanN = 500;
        Background;
        clibImage;
 
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
            
            % Enable autonaming feature of MIC_AbstractC
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
                obj.CameraLuca.ROI= [300 700 300 700];
                obj.CameraLuca.ExpTime_Capture = 0.01;
                % Stage
                fprintf('Initializing Stage\n')
                obj.StageObj=MIC_MCLNanoDrive();
                
                % Laser
                obj.LaserObj = MIC_HSMLaser488();
                
                % Lamp
                obj.LampObj=MIC_IX71Lamp('Dev3','ao0','Port1/Line3');
                obj.LampPower = 40;%40;
                
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
                    fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
                    pause(1)
                    obj.FlipMount.FilterOut;
                    pause(1)
                    pause(obj.LampWait);
                    %                 obj.R3DObj.align2imageFit();
                    obj.R3DObj.CameraObj.ROI=[350 650 350 650]; %luca
                    obj.R3DObj.calibrate();
                    obj.LampObj.off();
                    obj.FlipMount.FilterIn;
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
            obj.CameraZyla.ROI=obj.getROI();
            
            obj.CameraZyla.ExpTime_Focus= obj.Exp_Focus;
            obj.CameraZyla.start_focus();
        end
        
        function collect_background(obj)
            
            obj.CameraZyla.ROI=obj.getROI();
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.BackgroundScanN;
            obj.CameraZyla.start_sequence();
            obj.Background = single(mean(obj.CameraZyla.Data,3));
        end

        function collect_backgroundROI(obj)
            
%             obj.CameraZyla.ROI=obj.getROI();
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.BackgroundScanN;
            obj.CameraZyla.start_sequence();
            obj.Background = single(mean(obj.CameraZyla.Data,3));
        end
        function collect_clibImage(obj)
            
            obj.CameraZyla.ROI=obj.getROI();
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = 50;
            obj.CameraZyla.ExpTime_Sequence = 0.5;
            obj.CameraZyla.start_sequence();
            obj.clibImage = single(mean(obj.CameraZyla.Data,3));
        end
        
        
        function Calibration(obj)
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            obj.DataDir = obj.SaveDir;
            
            obj.collect_clibImage();
            out = obj.clibImage;
            [~, idx1(1)] = max(obj.clibImage(200,505:544));
            idx1(1)=idx1(1)+505;
            [~, idx1(2)] = max(obj.clibImage(200,347:434));
            idx1(2)=idx1(2)+347;
            [~, idx1(3)] = max(obj.clibImage(200,282:335));
            idx1(3)=idx1(3)+282;
            [~, idx1(4)] = max(obj.clibImage(200,212:270));
            idx1(4)=idx1(4)+212;
            [~, idx1(5)] = max(obj.clibImage(200,138:150));
            idx1(5)=idx1(5)+138;
            [~, idx1(6)] = max(obj.clibImage(200,120:136));
            idx1(6)=idx1(6)+120;
            [~, idx1(7)] = max(obj.clibImage(200,66:84));
            idx1(7)=idx1(7)+66;
            idx1
             
            peakWv = [485 544 586 611.5 696.5 706.7 763.5];

            pfit = polyfit(idx1,peakWv,3);
            wv = polyval(pfit,1:length(out));
            figure;plot(idx1,peakWv,'*')

            title('Spectral Clibration');
            xlabel('Lateral shift (pixels)');
            ylabel('Wavelength (pixels)');
            
            SaveDate=datestr(timenow, 'yyyy-mm-dd-HH-MM-SS');
            save([obj.SaveDir 'Wavelength_Calibration_Data-' SaveDate],'out','timenow','wv','idx1','peakWv','pfit');
        end
        
        function Data=single_scanROI(obj)
            % Setup camera
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.NSteps;
%             obj.CameraZyla.ROI=obj.getROI();
            
            
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
        
        function Data=single_scan(obj)
            % Setup camera
            obj.CameraZyla.ExpTime_Sequence=obj.Exp_Scan;
            obj.CameraZyla.SequenceLength = obj.NSteps;
            obj.CameraZyla.ROI=obj.getROI();
            
            
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
            obj.CameraZyla.ROI=obj.getROI();
            %Take background scan
            obj.BackgroundScanN=100;
            obj.collect_background();
            dipshow(obj.Background)
            
            % H.LaserObj.setPower();
           
            obj.LaserObj.on();
%             Y=figure
            P=figure
%             F=figure
            while 1
                Data=obj.single_scan();
%                 dipshow(F,sum(Data(:,:,250:300),3))
%                 diptruesize(50)
                dipshow(P,sum(Data(:,:,1:100),3))
                diptruesize(200)
%                 dipshow(Y,sum(Data(:,:,350:380),3))
%                 diptruesize(100)
            end
            
            obj.LaserObj.off();
        end
        function single_scan_sequence(obj)
            
            
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            obj.DataDir = obj.SaveDir;
            switch obj.SaveFileType
                case 'mat'
                case 'h5'
                    FileH5=fullfile(obj.SaveDir,[obj.BaseFileName s '.h5']);
                    MIC_H5.createFile(FileH5);
                    MIC_H5.createGroup(FileH5,'Data');
                    MIC_H5.createGroup(FileH5,'Calibration');
                otherwise
                    error('StartSequence:: unknown file save type')
            end
            %first take a reference image or align to image
            
            obj.FlipMount.FilterOut;
            fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
            obj.LampObj.setPower(obj.LampPower);
            
            obj.RegType='Self';
            switch obj.RegType
                case 'Self' %take and save the reference image
                    obj.takeref();
                    f=fullfile(obj.SaveDir,[obj.BaseFileName s '_ReferenceImage']);
                    Image_Reference=obj.R3DObj.Image_Reference; %#ok<NASGU>
                    save(f,'Image_Reference');
            end
            
          
            
            obj.FlipMount.FilterIn;
            fprintf('IsOpen == %d\n', obj.FlipMount.IsOpen);
            
            %Take background scan
            obj.CameraZyla.abort()% Clear buffer
            
            obj.LaserObj.off()
            obj.BackgroundScanN=100;
            obj.collect_background();
            dipshow(obj.Background)
            P=figure
            ROISZ = obj.CameraZyla.ROI;
            %loop over sequences
            for nn=1:obj.DataCube
                nn
                %Turn on Laser for aquisition
                obj.LaserObj.on();
                Data = ones(ROISZ(2)-ROISZ(1)+1,obj.NSteps,ROISZ(4)-ROISZ(3)+1,obj.Nsequences);
                for ii = 1:obj.Nsequences
                    ii
                    %Collect Data
                    Data(:,:,:,ii)=obj.single_scan();
                    im =sum(Data(:,:,1:100),3);
                    dipshow(P,im)
                    diptruesize(200)  
                end
                 %Turn off Laser
                obj.LaserObj.off();
                Data = uint16(Data);
                %Save
                switch obj.SaveFileType
                    case 'mat'
                        fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                        Params=exportState(obj); %#ok<NASGU>
                        save(fn,'Data','Params');
                    case 'h5' %This will become default
                        S=sprintf('Data_C%04d',nn);
                        MIC_H5.writeAsync_uint16(FileH5,'Data',S,Data);
                    otherwise
                        error('StartSequence:: unknown SaveFileType')
                end
                
                
                switch obj.SaveFileType
                    case 'mat'
                        %Nothing to do
                    case 'h5' %This will become default
                        % S='MIC_TIRF_SRcollect'; % -modified SP
                        S='Data'; % -modified EJ
                        MIC_H5.createGroup(FileH5,S);
                        obj.save2hdf5(FileH5,S);  %Working
                    otherwise
                        error('StartSequence:: unknown SaveFileType')
                end
                
                % align
                if nn~=obj.DataCube
                    obj.FlipMount.FilterOut;
                    
                    fprintf('Start aliging...\n')
                    obj.align();% Align
                    fprintf('Alignment is done...\n')
                    
                    obj.FlipMount.FilterIn;
                    pause(1)
                else
                end
            end
        end
        
        function singleScan(obj)
            obj.CameraZyla.ROI=obj.getROI();
            obj.LaserObj.off()
            obj.BackgroundScanN=100;
            obj.collect_background();
            obj.LaserObj.on()
            Data=obj.single_scan();
            obj.LaserObj.off()
            dipshow(sum(Data(:,:,:),3))
            diptruesize(200)
        end
        %Set ROI for zylaCamera
        function ROI=getROI(obj)
            %these could be set from camera size;
            switch obj.CameraROI
                case 1
                    ROI=[580 1030 880  980]; %256pixels 
                case 2
                    ROI=[708  964  800  1250];%256pixels
                case 3
                    ROI=[772 900 800  1250];%128pixels 
                case 4
                    ROI=[804 868 800  1250];%64pixels
                case 5
                    ROI=[820 852 800  1250];%32pixels
                case 6
                    ROI=[794 1306 750 1300]; % Custom from Sandeep
                    
                otherwise
                    error('HSM_collect: ROI not found')
            end
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


