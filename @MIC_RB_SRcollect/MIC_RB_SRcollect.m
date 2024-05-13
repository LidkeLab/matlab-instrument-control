classdef MIC_RB_SRcollect < MIC_Abstract
%  MIC_RB_SRcollect
% 
% ## Overview
% The `MIC_RB_SRcollect` class is designed for super-resolution data collection on the Reflected Beam (RB) microscope. This software integrates with various hardware components through Matlab Instrument Control (MIC) classes to manage and control super-resolution microscopy experiments effectively.
% 
% ## Features
% - Control and synchronize multiple light sources including lasers and LEDs.
% - Interface with cameras for image acquisition.
% - Manage piezo stages for precise positioning.
% - Utilize galvanometers for scanning applications.
% - Integrate with Spatial Light Modulators (SLMs) for advanced optical manipulation.
% 
% ## Requirements
% - MATLAB 2014b or higher.
% - Dependencies on several MIC classes:
%   - `MIC_Abstract`
%   - `MIC_LightSource_Abstract`
%   - `MIC_TCubeLaserDiode`
%   - `MIC_VortranLaser488`
%   - `MIC_CrystaLaser561`
%   - `MIC_HamamatsuCamera`
%   - `MIC_RebelStarLED`
%   - `MIC_OptotuneLens`
%   - `MIC_GalvoAnalog`
% 
% ## Installation
% 1. Ensure all dependent classes are available in your MATLAB path.
% 2. Clone or download this repository into your MATLAB environment.
% 3. Instantiate an object using the command: `SRC = MIC_RB_SRcollect();`
% ## Methods Overview
% - `setupPiezo()`: Configures and initializes the piezo stages.
% - `loadref()`: Loads a reference image for alignment.
% - `takecurrent()`: Captures the current image from the camera.
% - `align()`: Aligns the current image to a reference.
% - `showref()`: Displays the reference image.
% - `takeref()`: Captures and sets a new reference image.
% - `saveref()`: Saves the current reference image.
% - `focusLow()`, `focusHigh()`: Methods to focus the microscope using low or high laser power settings.
% - `focusLamp()`: Uses the LED for continuous image display, useful for manual focusing.
% - `StartSequence()`: Begins the data acquisition sequence.
% 
% ## Usage
% Here is a simple example on how to start a session with the `MIC_RB_SRcollect` class:
% ```matlab
% % Create the SRcollect object
% SRC = MIC_RB_SRcollect();
% 
% % Setup camera and laser parameters
% SRC.Camera.ExpTime = 0.1;  % Set exposure time
% SRC.Laser642.setPower(10); % Set laser power
% 
% % Start acquisition
% SRC.StartSequence();
% ```   
% Citation: Marjolein Meddens, Lidke Lab 2017
    properties
        % Hardware objects
        Camera;         % Hamamatsu Camera
        StageObj;       % 3D Piezo Stage
        Laser405;       % TCubeLaserDiode 405
        Laser488;       % Vortran 488
        Laser561;       % CrystaLaser 561
        Laser642;       % TCubeLaserDiode 642
        LED;            % RebelStar LED
        Galvo;          % Analog Galvo
        TunableLens;    % Optotune Lens
        SLM;            % Hamamatsu LCOS
        
        % Control Classes
        R3DObj;         %Registration object
        
        % Camera params
        ExpTime                         % Camera exposure time (s)
        NumFrames                       % Number of frames per sequence
        NumSequences                    % Number of sequences per acquisition
        CameraReadoutMode               % 'Slow' or 'Fast'
        CameraROI                       % Absolute Pixel ROI
        CameraROISelect                % Camera ROI (see gui for specifics)
        CameraDefectCorrection          % Camera defect correction 'OFF' or 'ON'
        PixelSizeX=[];                  % Pixel size X determined from calibration (um)
        PixelSizeY=[];                  % Pixel size Y determined from calibration (um)
        
        % Light source params
        Laser405Low;    % Low power 405 laser
        Laser488Low;    % Low power 488 laser
        Laser642Low;    % Low power 642 laser
        Laser405High;   % High power 405 laser
        Laser488High;   % High power 488 laser
        Laser642High;   % High power 642 laser
        LEDPower=50;    % Power of LED
        Laser405Focus   % Flag for using 405 laser during focus
        Laser488Focus   % Flag for using 488 laser during focus
        Laser561Focus   % Flag for using 561 laser during focus
        Laser642Focus   % Flag for using 642 laser during focus
        LEDFocus;       % Flag for using LED during focus
        Laser405Aq      % Flag for using 405 laser during acquisition
        Laser488Aq      % Flag for using 488 laser during acquisition
        Laser561Aq      % Flag for using 561 laser during acquisition
        Laser642Aq      % Flag for using 642 laser during acquisition
        LEDAq;          % Flag for using LED during acquisition
        LEDWait=0.5;    % LED wait time
        
        % Microscope
        NA=1.3;             % NA of objective
        RefrIdx=1.406;      % Refractive index of immersion medium
        Fobjective=180/60;  % Focal lenght of objective (mm)
        SLMangle = 7.4;     % Angle of SLM with respect to the X-axis of 
                                % the incoming beam (degrees)
        % PSF
        ZCoefOptimized      % Optimized zernike coefficient for no abberations
        DefocusCoeff2Micron=-0.2882; % um defocus for a defocus coefficient of 1
        
        % Tunable lens
        FP2Shift = 26;      % TL shift in waist position per focal power (um/dpt)
        
        % Registration
        RegType='Self';     % Registration type, can be 'None', 'Self'
        ExpTimeReg = 0.1;  % Camera exposure time during registration (s)
        ZStart;             %zstack absolute start position
        % Piezo
        PiezoStepSize = 0.25; % Piezo step size (um)
        StartZStack;        % Start position of Z-stack
        EndZStack;          % End position of Z-stack
        Zstack;             % Flag for acquiring Z-stack
        NumZRepeats=1;        % Number of Z stack repeats
        
        % Galvo
        PosToV=-0.0086;     % Conversion factor from shift of light-sheet to voltage (V/um)
        GalvoStepSize       % Step size of Galvo (um)
        MirrorPosition='left';  % Position of mirror can be 'left' or 'right'
        
        % Other things
        SaveDir='y:\Marjolein';  % Save Directory
        BaseFileName='Cell01';   % Base File Name
        AbortNow=0;     % Flag for aborting acquisition
        SaveType='h5'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
    end
    
    properties (SetAccess = protected)
        InstrumentName = 'RB_SRcollect'; % Descriptive name of "instrument"
        GuiFigurePSF        % handle of PSF gui
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  Set to false to prevent gui opening before hardware is initialized.
    end
    
    methods
        function obj=MIC_RB_SRcollect()
            % MIC_RB_SRcollect constructor
            %   Constructs object and initializes all hardware
            
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            
            % Get calibrated pixel size
            [p,~]=fileparts(which('MIC_RB_SRcollect'));
            PixelCalFile=fullfile(p,'RB_PixelSize.mat');
      
            % Initialize hardware objects
            try
                % Camera
                fprintf('Initializing Camera\n')
                obj.Camera=MIC_HamamatsuCamera();
                obj.Camera.ReturnType='matlab';
                % Stage
                obj.setupPiezo();
    
                %Reg3D
                fprintf('Initializing Registration object\n')
                obj.R3DObj=MIC_Reg3DTrans(obj.Camera,obj.StageObj,PixelCalFile);
                obj.R3DObj.ExposureTime=obj.ExpTimeReg;
                if ~exist(PixelCalFile,'file')
                    obj.CameraObj.ROI=[1 256 1 256];
                    obj.R3DObj.calibratePixelSize();
                else
                    F=load(PixelCalFile);
                    PixelSize=F.PixelSize;
                    clear F;
                end
                  
                % Lasers
                fprintf('Initializing 405 laser\n')
                obj.Laser405 = MIC_TCubeLaserDiode('64864827','Power',40.15,40.93,1);
                obj.Laser405Low = 1;
                obj.Laser405High = obj.Laser405.MaxPower;
                fprintf('Initializing 488 laser\n')
                obj.Laser488=MIC_VortranLaser488('Dev1','ao2');
                obj.Laser488Low = 1;
                obj.Laser488High = obj.Laser488.MaxPower;
                fprintf('Initializing 561 laser\n')
                obj.Laser561 = MIC_CrystaLaser561('Dev1','Port0/Line0:1');
                fprintf('Initializing 642 laser\n')
                obj.Laser642 = MIC_TCubeLaserDiode('64844464','Power',71,181.3,1);
                obj.Laser642Low = 1;
                obj.Laser642High = obj.Laser642.MaxPower;
                % LED
                fprintf('Initializing LED\n')
                obj.LED=MIC_RebelStarLED('Dev1','ao0');
                
                % Galvo
                fprintf('Initializing Galvo\n')
                obj.Galvo=MIC_GalvoAnalog('Dev1','ao1');
                % SLM
                fprintf('Initializing SLM\n')
                obj.SLM = MIC_HamamatsuLCOS();
                % Tunable lens
                fprintf('Initializing Tunable lens\n');
                obj.TunableLens = MIC_OptotuneLens('COM3');
            catch ME
                disp(ME);
                error('hardware startup error');      
            end
            
            % Start gui (not using StartGUI property because GUI shouldn't
            % be started before hardware initialization)
            obj.gui();
        end
        
        function setupPiezo(obj)
            fprintf('Initializing 3D Piezo Stage\n')
            
            ControllerXSerialNum='29501305';
            ControllerYSerialNum='29501307';
            ControllerZSerialNum='81843229';
            StrainGaugeXSerialNum='59000121';
            StrainGaugeYSerialNum='59000140';
            StrainGaugeZSerialNum='84842506';
            MaxPiezoConnectAttempts=1;
            
            obj.StageObj = MIC_NanoMaxPiezos(...
                ControllerXSerialNum, StrainGaugeXSerialNum, ...
                ControllerYSerialNum, StrainGaugeYSerialNum, ...
                ControllerZSerialNum, StrainGaugeZSerialNum, ...
                MaxPiezoConnectAttempts);
        end
        
        function delete(obj)
            %delete all objects
            if ~isempty(obj.GuiFigure) && ishandle(obj.GuiFigure)
                close(obj.GuiFigure)
            end
            if ~isempty(obj.GuiFigurePSF) && ishandle(obj.GuiFigurePSF)
                close(obj.GuiFigurePSF)
            end
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
            obj.LED.setPower(obj.LEDPower);
            LEDState=obj.LED.IsOn;
            obj.LED.on();
            pause(.1);
            obj.R3DObj.getcurrentimage();
            if ~LEDState %turn off if off before. 
                obj.LED.off();
            end
        end
        
        function align(obj)
            % Align to current reference image
            obj.LED.setPower(obj.LEDPower);
            LEDState=obj.LED.IsOn;
            obj.LED.on();
            obj.R3DObj.align2imageFit();
            if ~LEDState %turn off if off before. 
                obj.LED.off();
            end
        end
        
        function showref(obj)
            % Displays current reference image
            dipshow(obj.R3DObj.Image_Reference);
        end
        
        function takeref(obj)
            % Captures reference image
            obj.LED.setPower(obj.LEDPower);
            LEDState=obj.LED.IsOn;
            obj.LED.on();
            obj.R3DObj.takerefimage();
             if ~LEDState %turn off if off before. 
                obj.LED.off();
            end
        end
        
        function saveref(obj)
            % Saves current reference image
            obj.R3DObj.saverefimage();
        end
        
        function focusLow(obj)
            % Focus function using the low laser settings
            
            %        Lasers set up to 'low' power setting
            if obj.Laser405Focus
                obj.Laser405.setPower(obj.Laser405Low);
                obj.Laser405.on;
            else
                obj.Laser405.off;
            end
            if obj.Laser488Focus
                obj.Laser488.setPower(obj.Laser488Low);
                obj.Laser488.on;
            else
                obj.Laser488.off;
            end
            if obj.Laser561Focus
                obj.Laser561.setPower(obj.Laser561Low);
                obj.Laser561.on;
            else
                obj.Laser561.off;
            end
            if obj.Laser642Focus
                obj.Laser642.setPower(obj.Laser642Low);
                obj.Laser642.on;
            else
                obj.Laser642.off;
            end
            if obj.LEDFocus
                obj.LED.setPower(obj.LEDPower);
                obj.LED.on;
            else
                obj.LED.off;
            end
            obj.Camera.start_focus();
            % Turning lasers off
            obj.Laser405.off;
            obj.Laser488.off;
            obj.Laser561.off;
            obj.Laser642.off;
            obj.LED.off;
        end
        
        function focusHigh(obj)
            % Focus function using the high laser settings
            
            %        Lasers set up to 'high' power setting
            if obj.Laser405Focus
                obj.Laser405.setPower(obj.Laser405High);
                obj.Laser405.on;
            else
                obj.Laser405.off;
            end
            if obj.Laser488Focus
                obj.Laser488.setPower(obj.Laser488High);
                obj.Laser488.on;
            else
                obj.Laser488.off;
            end
            if obj.Laser561Focus
                obj.Laser561.setPower(obj.Laser561High);
                obj.Laser561.on;
            else
                obj.Laser561.off;
            end
            if obj.Laser642Focus
                obj.Laser642.setPower(obj.Laser642High);
                obj.Laser642.on;
            else
                obj.Laser642.off;
            end
            if obj.LEDFocus
                obj.LED.setPower(obj.LEDPower);
                obj.LED.on;
            else
                obj.LED.off;
            end
            % Aquiring and displaying images
            obj.Camera.start_focus();
            % Turning lasers off
            obj.Laser405.off;
            obj.Laser488.off;
            obj.Laser561.off;
            obj.Laser642.off;
            obj.LED.off;
        end
        
        function focusLamp(obj)
            % Continuous display of image with lamp on. Useful for focusing of
            % the microscope.
            obj.LED.setPower(obj.LEDPower);
            obj.LED.on();
            obj.Camera.start_focus;
            obj.LED.off();
        end
        
        function StartSequence(obj,guihandles)
            
            %create save folder and filenames
            if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            
            %Setup camera and lamp for reg stack
            
            obj.LED.setPower(obj.LEDPower);
            obj.LED.on();
            pause(obj.LEDWait);
            
            switch obj.RegType
                case 'Self' %take and save the reference stack
                    Pos=obj.StageObj.Position;
                    z0=Pos(3); %z position
                    obj.ZStart=z0;
                    obj.R3DObj.takerefimage();
                    f=fullfile(obj.SaveDir,[obj.BaseFileName s '_ReferenceImage']);
                    Image_Reference=obj.R3DObj.Image_Reference; 
                    save(f,'Image_Reference');
            end
            obj.LED.off();
            
            switch obj.SaveType
                case 'mat'
                case 'h5'
                    FileH5=fullfile(obj.SaveDir,[obj.BaseFileName s '.h5']);
                    MIC_H5.createFile(FileH5);
                    MIC_H5.createGroup(FileH5,'Channel01');
                    MIC_H5.createGroup(FileH5,'Channel01/Zposition001');
                otherwise
                    error('StartSequence:: unknown file save type')
            end
            
            % calc Zrange
            Pos=obj.StageObj.Position;
            z0=Pos(3); %z position
            if obj.Zstack
                ZRange = z0-(obj.StartZStack : obj.PiezoStepSize : obj.EndZStack);
            else
                ZRange = 0;
            end
            
            % calc Grange for Galvo- FIX based on relative z0
            g0 = obj.Galvo.Voltage;
            if obj.Zstack
                switch obj.MirrorPosition
                    case 'left'
                        GalvoConversion = obj.PosToV;
                    case 'right'
                        GalvoConversion = -obj.PosToV;
                end
                GStep = obj.PiezoStepSize * GalvoConversion;
                GStart = g0 - ((z0-obj.StartZStack) * GalvoConversion);
                GEnd = g0 + ((z0-obj.StartZStack) * GalvoConversion);
                GRange = GStart : GStep : GEnd;
            else
                GRange = g0;
            end

            % acquire data
            for nn=1:obj.NumSequences
                if obj.AbortNow; obj.AbortNow=0; break; end
                
                % move piezo
                obj.StageObj.StagePiezoZ.setPosition(obj.ZStart);
                % move galvo
                obj.Galvo.setVoltage(GRange(1));
                pause(0.1) % wait for piezo and galvo to finish move
                
                %align to image
                switch obj.RegType
                    case 'None'
                    otherwise
                        obj.LED.setPower(obj.LEDPower);
                        obj.LED.on();
                        obj.R3DObj.align2imageFit();
                        obj.LED.off();
                end

                for kk = 1 : numel(ZRange)
                    if obj.AbortNow; break; end
 
                    % move piezo
                    Pos=obj.StageObj.Position;
                    z0=Pos(3); %z position
                    
                    obj.StageObj.StagePiezoZ.setPosition(z0+ ZRange(kk));
                    % move galvo
                    obj.Galvo.setVoltage(GRange(kk));
                    pause(0.1) % wait for piezo and galvo to finish move
                    
                    if obj.AbortNow; obj.AbortNow=0; break; end
                
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
                        obj.Laser561.on;
                    end
                    if obj.Laser642Aq
                        obj.Laser642.setPower(obj.Laser642High);
                        obj.Laser642.on;
                    end
                    if obj.LEDAq
                        obj.LED.setPower(obj.LEDPower);
                        obj.LED.on;
                    end
                    
                    %Collect
                    sequence=obj.Camera.start_sequence();
                    
                    %Turn off Laser
                    obj.Laser405.off;
                    obj.Laser488.off;
                    obj.Laser561.off;
                    obj.Laser642.off;
                    obj.LED.off;
                    
                    %Save
                    switch obj.SaveType
                        case 'mat'
                            fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                            Params=exportState(obj); 
                            save(fn,'sequence','Params');
                        case 'h5' %This will become default
                            if nn==1 %create the z position group
                                S=sprintf('Channel01/Zposition%03d',kk);
                                MIC_H5.createGroup(FileH5,S);
                            end
                            S=sprintf('Data%04d',nn);
                            S2=sprintf('Channel01/Zposition%03d/Data%04d',kk,nn);
                            MIC_H5.createGroup(FileH5,S2);
                            obj.save2hdf5(FileH5,S2);  
                            MIC_H5.writeAsync_uint16(FileH5,S2,S,sequence);
                        otherwise
                            error('StartSequence:: unknown SaveFileType')
                    end
                end
            end
        end
        
        function dispOptimalPupil(obj)
            obj.SLM.ZernikeCoef = obj.ZCoefOptimized;
            obj.SLM.calcZernikeImage();
        end
        
        function [Attributes,Data,Children] = exportState(obj)
            % exportState Exports current state of all hardware objects
            % and SRcollect settings
            
            % Children
            [Children.Camera.Attributes,Children.Camera.Data,Children.Camera.Children]=...
                obj.Camera.exportState();
            [Children.StageObj.Attributes,Children.StageObj.Data,Children.StageObj.Children]=...
                obj.StageObj.exportState();
            [Children.Galvo.Attributes,Children.Galvo.Data,Children.Galvo.Children]=...
                obj.Galvo.exportState();
            [Children.Laser405.Attributes,Children.Laser405.Data,Children.Laser405.Children]=...
                obj.Laser405.exportState();
            [Children.Laser488.Attributes,Children.Laser488.Data,Children.Laser488.Children]=...
                obj.Laser488.exportState();
            [Children.Laser561.Attributes,Children.Laser561.Data,Children.Laser561.Children]=...
                obj.Laser561.exportState();
            [Children.Laser642.Attributes,Children.Laser642.Data,Children.Laser642.Children]=...
                obj.Laser642.exportState();
            [Children.LED.Attributes,Children.LED.Data,Children.LED.Children]=...
                obj.LED.exportState();
            [Children.TunableLens.Attributes,Children.TunableLens.Data,Children.TunableLens.Children]=...
                obj.TunableLens.exportState();
            [Children.SLM.Attributes,Children.SLM.Data,Children.SLM.Children]=...
                obj.SLM.exportState();
            [Children.R3DObj.Attributes,Children.R3DObj.Data,Children.R3DObj.Children]=...
                obj.R3DObj.exportState();
            
            % Camera params
            Attributes.ExpTime = obj.ExpTime;
            Attributes.NumFrames = obj.NumFrames;
            Attributes.NumSequences = obj.NumSequences;
            Attributes.CameraReadoutMode = obj.CameraReadoutMode;
            Attributes.CameraROISelect = obj.CameraROISelect;
            Attributes.CameraROI = obj.Camera.ROI;
            Attributes.CameraDefectCorrection = obj.CameraDefectCorrection;
            Attributes.PixelSizeX = obj.PixelSizeX;
            Attributes.PixelSizeY = obj.PixelSizeY;
            
            % light source params
            Attributes.Laser405Low = obj.Laser405Low;
            Attributes.Laser488Low = obj.Laser488Low;
            Attributes.Laser642Low = obj.Laser642Low;
            Attributes.Laser405High = obj.Laser405High;
            Attributes.Laser488High = obj.Laser488High;
            Attributes.Laser642High = obj.Laser642High;
            Attributes.LEDPower = obj.LEDPower;
            Attributes.Laser405Aq = obj.Laser405Aq;
            Attributes.Laser488Aq = obj.Laser488Aq;
            Attributes.Laser561Aq = obj.Laser561Aq;
            Attributes.Laser642Aq = obj.Laser642Aq;
            Attributes.LEDAq = obj.LEDAq;
            
            % Registration
            Attributes.RegType = obj.RegType;
            Attributes.ExpTimeReg = obj.ExpTimeReg;
            
            % Piezo
            Attributes.PiezoStepSize = obj.PiezoStepSize;
            Attributes.StartZStack = obj.StartZStack;
            Attributes.EndZStack = obj.EndZStack;
            Attributes.Zstack = obj.Zstack;
            
            % Galvo
            Attributes.PosToV = obj.PosToV;
            Attributes.GalvoStepSize = obj.GalvoStepSize;
            Attributes.MirrorPosition = obj.MirrorPosition;
            
            % Microscope
            Attributes.NA = obj.NA; 
            Attributes.RefrIdx = obj.RefrIdx;  
            Attributes.Fobjective = obj.Fobjective;
            Attributes.SLMangle = obj.SLMangle;
            
            % PSF
            Attributes.ZCoefOptimized = obj.ZCoefOptimized;
            Attributes.DefocusCoeff2Micron = obj.DefocusCoeff2Micron;
        
            % Tunable lens
            Attributes.FP2Shift = obj.FP2Shift;
            
            Data=[];
        end
        
        %Get and Set methods
        
        function set.ExpTimeReg(obj,In)
            obj.ExpTimeReg=In;
            obj.R3DObj.ExposureTime=obj.ExpTimeReg;
        end
        
        
    end
    
    
    methods (Static)
        
        [f] = blazeScanObjFcn(X,I,BlazeWidth);
        [I] = blazeScanIntensity(BlazeWidth,Ibead,Ibg,PupilPos,Rpupil);
        
        function State = unitTest()
            State = 1;
        end
        
    end
end


