classdef MIC_RB_SRcollect < MIC_Abstract
    % MIC_RB_SRcollect SuperResolution data collection software.
    % Super resolution data collection class for RB microscope
    % Works with Matlab Instrument Control (MIC) classes
    %
    %  usage: SRC=MIC_RB_SRcollect();
    %
    % REQUIRES:
    %   Matlab 2014b or higher
    %   MIC_Abstract
    %   MIC_LightSource_Abstract
    %   MIC_TCubeLaserDiode
    %   MIC_VortranLaser488
    %   MIC_CrystaLaser561
    %   MIC_CameraAbstract
    %   MIC_HamamatsuCamera
    %   MIC_RebelStarLED
    %   MIC_OptotuneLens
    %   MIC_GalvoAnalog
    %
    % Marjolein Meddens, Lidke Lab 2017
    
    properties
        % Hardware objects
        Camera;         % Hamamatsu Camera
        Piezo;          % TCubePiezo
        Laser405;       % TCubeLaserDiode 405
        Laser488;       % Vortran 488
        Laser561;       % CrystaLaser 561
        Laser642;       % TCubeLaserDiode 642
        LED;            % RebelStar LED
        Galvo;          % Analog Galvo
        TunableLens;    % Optotune Lens
        SLM;            % Hamamatsu LCOS
        
        % Camera params
        ExpTime                         % Camera exposure time (s)
        NumFrames                       % Number of frames per sequence
        NumSequences                    % Number of sequences per acquisition
        CameraReadoutMode               % 'Slow' or 'Fast'
        CameraROI                       % Camera ROI (see gui for specifics)
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
        LEDPower;       % Power of LED
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
        LEDWait=0.1;    % LED wait time
        
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
        RegType='None';     % Registration type, can be 'None', 'Passive'
        ExpTimeReg = 0.01;  % Camera exposure time during registration (s)
        
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
        SaveType='mat'  %Save to *.mat or *.h5.  Options are 'mat' or 'h5'
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
            pix = load(fullfile(p,'RB_PixelSize.mat'));
            obj.PixelSizeX = pix.PixelSizeX;
            obj.PixelSizeY = pix.PixelSizeY;
            
            % Initialize hardware objects
            try
                % Camera
                fprintf('Initializing Camera\n')
                obj.Camera=MIC_HamamatsuCamera();
                obj.Camera.ReturnType='matlab';
                % Stage
                fprintf('Initializing Piezo\n')
                obj.Piezo=MIC_TCubePiezo('81843229','84842506','Z');
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
                obj.LEDPower = 10;
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
        
        function delete(obj)
            %delete all objects
            if ~isempty(obj.GuiFigure) && ishandle(obj.GuiFigure)
                close(obj.GuiFigure)
            end
            if ~isempty(obj.GuiFigurePSF) && ishandle(obj.GuiFigurePSF)
                close(obj.GuiFigurePSF)
            end
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
            
            %create save folder and time stamp
            if ~exist(obj.SaveDir,'dir')
                mkdir(obj.SaveDir);
            end
            TimeStamp = datestr(clock,'yyyy-mm-dd-HH-MM-SS');
            
            % calc Zrange
            z0=obj.Piezo.CurrentPosition;
            if obj.Zstack
                ZRange = obj.StartZStack : obj.PiezoStepSize : obj.EndZStack;
            else
                ZRange = z0;
            end
            
            % calc Grange for Galvo
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
            
            % acquire registration reference image
            switch obj.RegType
                case 'None' % do nothing
                case 'Passive' %take and save the reference stack
                    %calculate z-range
                    z0=obj.Piezo.CurrentPosition;
                    if obj.Zstack
                        RefZRange = obj.StartZStack-1 : 0.05 : obj.EndZStack+1;
                    else
                        RefZRange = z0-1 : 0.05 : z0+1;
                    end
                    %Setup Camera
                    obj.Camera.ExpTime_Sequence = obj.ExpTimeReg;
                    obj.Camera.setup_fast_acquisition(numel(RefZRange));
                    %Collect
                    obj.LED.setPower(obj.LEDPower);
                    obj.LED.on();
                    pause(obj.LEDWait);
                    for ii=1:length(RefZRange)
                        obj.Piezo.setPosition(RefZRange(ii))
                        pause(.1);
                        obj.Camera.TriggeredCapture();
                    end
                    Data=obj.Camera.FinishTriggeredCapture(numel(RefZRange)); 
                    %Turn off LED and reset Piezo and Camera
                    obj.LED.off();
                    obj.Piezo.setPosition(z0);
                    obj.Camera.ExpTime_Sequence = obj.ExpTime;
                    % save reference stack
                    refName = [obj.BaseFileName '_' TimeStamp '_RefStack.mat'];
                    save(fullfile(obj.SaveDir,refName),'Data','RefZRange');
                    % setup for registration images
                    regName = [obj.BaseFileName '_' TimeStamp '_RegImages.mat'];
                    RegImages = zeros(size(Data,1),size(Data,2),numel(ZRange),obj.NumSequences);
                    
            end
            
            % create h5 file
            switch obj.SaveType
                case 'mat'
                case 'h5'
                    FileH5=fullfile(obj.SaveDir,[obj.BaseFileName '_' TimeStamp '.h5']);
                    MIC_H5.createFile(FileH5);
                    MIC_H5.createGroup(FileH5,'Data');
                    MIC_H5.createGroup(FileH5,'Data/Channel01');
                otherwise
                    error('MIC_RB_SRcollect:StartSequence','Unknown Save Type, must be h5 or mat')
            end
            
            % acquire data
            for nn=1:obj.NumSequences
                if obj.AbortNow; obj.AbortNow=0; break; end
                
                nstring=strcat('Acquiring','...',num2str(nn),'/',num2str(obj.NumSequences));
                set(guihandles.Button_ControlStart, 'String',nstring,'Enable','off');
                
                for zz = 1 : numel(ZRange)
                    if obj.AbortNow; break; end
                    
                    % move piezo
                    obj.Piezo.setPosition(ZRange(zz));
                    % move galvo
                    obj.Galvo.setVoltage(GRange(zz));
                    pause(0.1) % wait for piezo and galvo to finish move
                    
                    %align to image
                    switch obj.RegType
                        case 'None'
                        case 'Passive'
                            % set up camera and LED
                            obj.Camera.ExpTime_Capture = obj.ExpTimeReg;
                            obj.LED.setPower(obj.LEDPower);
                            obj.LED.on();
                            pause(obj.LEDWait);
                            % capture image
                            RegImages(:,:,zz,nn) = obj.Camera.start_capture();
                            % turn off LED and reset camera
                            obj.LED.off();
                            obj.Camera.ExpTime_Capture = obj.ExpTime;
                            % save image
                            save(fullfile(obj.SaveDir,regName),'RegImages','ZRange');
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
                            fn=[obj.BaseFileName '#' num2str(nn,'%03d') '-' num2str(zz,'%03d') '_' TimeStamp];
                            Params=exportState(obj); %#ok<NASGU>
                            save(fullfile(obj.SaveDir,fn),'sequence','Params');
                        case 'h5' %This will become default, not working yet...
                            S=sprintf('Data%04d',nn);
                            MIC_H5.writeAsync_uint16(FileH5,'Data/Channel01',S,sequence);
                        otherwise
                            error('StartSequence:: unknown SaveFileType')
                    end
                end
            end
            
            
            switch obj.SaveType
                case 'mat'
                    %Nothing to do
                case 'h5' %This will become default
                    S='MIC_TIRF_SRcollect';
                    MIC_H5.createGroup(FileH5,S);
                    obj.save2hdf5(FileH5,S);  %Not working yet
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
            [Children.Piezo.Attributes,Children.Piezo.Data,Children.Piezo.Children]=...
                obj.Piezo.exportState();
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
            
            % instrument object properties
            Attributes.Camera = Children.Camera.Attributes;
            Attributes.Piezo = Children.Piezo.Attributes;
            Attributes.Galvo = Children.Galvo.Attributes;
            Attributes.Laser405 = Children.Laser405.Attributes;
            Attributes.Laser488 = Children.Laser488.Attributes;
            Attributes.Laser561 = Children.Laser561.Attributes;
            Attributes.Laser642 = Children.Laser642.Attributes;
            Attributes.LED = Children.LED.Attributes;
            Attributes.SLM = Children.SLM.Attributes;
            Attributes.TunableLens = Children.TunableLens.Attributes;
            
            % Camera params
            Attributes.ExpTime = obj.ExpTime;
            Attributes.NumFrames = obj.NumFrames;
            Attributes.NumSequences = obj.NumSequences;
            Attributes.CameraReadoutMode = obj.CameraReadoutMode;
            Attributes.CameraROI = obj.CameraROI;
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
        
    end
    
    
    
    methods (Static)
        
        [f] = blazeScanObjFcn(X,I,BlazeWidth);
        [I] = blazeScanIntensity(BlazeWidth,Ibead,Ibg,PupilPos,Rpupil);
        
        function State = unitTest()
            State = 1;
        end
        
    end
end


