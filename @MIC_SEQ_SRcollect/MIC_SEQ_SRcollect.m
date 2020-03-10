classdef MIC_SEQ_SRcollect < MIC_Abstract
% MIC_SEQ_SRcollect SuperResolution data collection software.
% Super resolution data collection class for Sequential microscope
% Works with Matlab Instrument Control (MIC) classes since March 2017

%  usage: SEQ=MIC_SEQ_SRcollect();
%
% REQUIRES:
%   Matlab 2014b or higher
%   matlab-instrument-control
%   sma-core-alpha (if using PublishResults flag)

% First version: Sheng Liu 
% Second version: Farzin Farzam  
% MIC compatible version: Farzin Farzam
% Lidke Lab 2017
% old version of this code is named SeqAutoCollect.m and can be found at
% documents>MATLAB>Instrumentation>development>SeqAutoCollect
    properties
        % Hardware objects
        CameraSCMOS; % Main Data Collection Camera
        XPiezoSerialNums = {'81850186', '84850145'}; % controller, gauge
        YPiezoSerialNums = {'81850193', '84850146'}; % controller, gauge
        ZPiezoSerialNums = {'81850176', '84850203'}; % controller, gauge
        StagePiezo; % piezo stage
        StageStepper; % Stepper Motor Stage
        Lamp660; % LED Lamp at 660 nm
        Laser647; % MPB 647 Laser
        Laser405; % ThorLabs 405 Diode Laser
        FlipMount; % FlipMount for Laser Attenuation
        Shutter; % Shutter for Laser Block
 
        % Static Instrument Settings
        SCMOS_UseDefectCorrection = 0;
        Lamp660Power = 15;
        SCMOS_PixelSize = .0973; % microns
        SCMOSCalFilePath; % needed if using PublishResults flag
        
        % Operational properties.
        LampWait = 0.1; % Time to wait for full power to lamp (seconds)
        ExposureTimeLampFocus = 0.02;
        ExposureTimeLaserFocusLow = 0.2;
        ExposureTimeLaserFocusHigh = 0.01;
        ExposureTimeSequence = 0.01;
        ExposureTimeCapture = 0.02;
        NumberOfFrames = 6000;
        NumberOfSequences = 10;
        NAcquisitionCycles = 1; % number of acquisition cycles per cell
        PostSeqPause = 0; % seconds to pause after each sequence
        UsePreActivation = 1; % excite fluors. before acquiring data
        DurationPreActivation = 10; % (seconds) time of pre-activation
        StabPeriod = 5; % Time between stabilization events (seconds)
        GridCorner = [1, 1] % 10x10 Full Frame Grid Corner (mm)
        SCMOS_ROI_Collect = [897, 1152, 897, 1152];
        SCMOS_ROI_Full = [1, 2048, 1, 2048];
        OffsetDZ = 5; % Micron
        OffsetSearchZ = 25; % Micron
        CoverslipZPosition = 1; % relative pos. of coverslip to stage
        OnDuringFocus647 = 0; % flag indicates 647nm laser on for focusing
        OnDuringSequence647 = 0; % flag indicates 647nm on for sequence
        OnDuringFocus405 = 0; % flag indicates 405nm laser on for focusing
        OnDuringSequence405 = 0; % flag indicates 405nm on for sequence
        LaserPowerFocus647 = 50;
        LaserPowerSequence647 = 150;
        LaserPowerFocus405 = 2;
        LaserPowerSequence405 = 2;
        IsBleach = 0; % boolean: 1 for a photobleach round, 0 otherwise
        StepperWaitTime = 5; % max time (s) to wait for stepper to move
        MaxPiezoConnectAttempts = 2; % max # of attempts to connect piezo
        PiezoSettlingTime = 0.2; % settling time of piezos (s)
        StepperLargeStep = 0.05; % Large Stepper motor step (mm)
        StepperSmallStep = 0.002; % Small Stepper motor step (mm)
        PiezoStep = 0.1; % Piezo step (micron)
        UseManualFindCell = 0;
        
        % Misc. file directories, directories, and indices.
        TopDir = '';
        CoverslipName = '';
        LabelIdx = 1;
        FilenameTag = ''; % tag appended to filename of saved results
        CellGridIdx;
        CurrentCellIdx = 1;
        CurrentGridIdx = [1, 1];
        CoverSlipOffset = [0, 0, 0]; % Remounting error (mm)
        
        % Registration classes.
        AlignReg; % brightfield alignment object
        UseBrightfieldReg = 1; % boolean: 1 uses registration, 0 doesn't
        UseStackCorrelation = 1; % boolean: 1 uses full stack registration
        NSeqBeforePeriodicReg = 1; % seq. collected before periodic reg.
        Reg3DStepSize = 0.1; % (um) step size along z during cell reg. default=0.1
        Reg3DMaxDev = 1; % (um) max deviation along z during cell reg. default=1
        Reg3DMaxDevInit = 1; % (um) max dev. along z for initial cell reg.
        Reg3DXTol = 0.005; % (um) correction along x to claim convergence
        Reg3DYTol = 0.005; % (um) correction along y to claim convergence
        Reg3DZTol = 0.05; % (um) correction along z to claim convergence
        
        % Misc. other properties.
        SaveDir = 'Y:\'; % Save Directory
        AbortNow = 0; % Flag for aborting acquisition
        SaveFileType = 'h5DataGroups'; % 'h5' or 'h5DataGroups'
        PublishResults = 0; % if 1, call PublishSeqSRResults after imaging
    end
    
    properties (SetAccess = protected)
        InstrumentName = 'MIC_SEQ_SRcollect';
    end
        
    properties (Hidden)
        % StartGUI == 1 will start the GUI on creation of a class instance.
        % StartGUI == 0 will not start the GUI on creation.
        StartGUI = 1;
    end
    
    properties (SetObservable)
        StatusString = ''; % string for status of the acquisition
    end
    
    methods
        function obj = MIC_SEQ_SRcollect(RunTestingMode)
            % Enable the autonaming feature of MIC_Abstract.
            obj = obj@MIC_Abstract(~nargout);
            
            % Set a property listener for the StatusString property.
            addlistener(obj, 'StatusString', 'PostSet', @obj.updateStatus);
            
            % Check if the input RunTestingMode was passed, and if so
            % proceed to create the class without setup of the instruments.
            if exist('RunTestingMode', 'var') && RunTestingMode
                return
            end
            
            % Ask the user to confirm sample is not fixed to the stage,
            % throw an error as a reminder if they answer Yes.
            proceedstr = questdlg('Is the sample fixed on the stage?', ...
                'Warning', 'Yes', 'No', 'Yes'); % default selection 'Yes'
            if strcmp('Yes', proceedstr)
                error(['Sample is fixed on the stage!  ', ...
                    'Remove the sample and restart SeqSRcollect.']);
            end

            % Setup instruments, ensuring proper order is maintained.
            obj.setupSCMOS();
            obj.setupLamps();
            obj.setupLasers();
            obj.setupFlipMountTTL();
            obj.setupShutterTTL();
            obj.setupStageStepper();
            obj.setupStagePiezo();
            obj.setupAlignReg();
            if obj.StageStepper.isvalid
                obj.unloadSample(); % move stage up for sample mounting
            end
            obj.StatusString = '';
        end
        
        function delete(obj)
            % Class destructor.
            delete(obj.GuiFigure);
            close all force;
            obj.Laser647.off(); % ensure the 647 laser is turned off
            obj.Laser405.off(); % ensure the 405 laser is turned off
            obj.FlipMount.FilterIn(); % place ND filter in optical path
            obj.Shutter.close(); % ensure shutter is blocking 647 laser
            clear();
        end
        
        function [Attributes, Data, Children] = exportState(obj)
            % exportState Exports current state of all hardware objects
            % and SEQ_SRcollect settings
                        
            % First, call exportState() method for the Children of obj.
            [Children.CameraSCMOS.Attributes, ...
                Children.CameraSCMOS.Data, ...
                Children.CameraSCMOS.Children] = ...
                    obj.CameraSCMOS.exportState();
            [Children.StageStepper.Attributes, ...
                Children.StageStepper.Data, ...
                Children.StageStepper.Children] = ...
                    obj.StageStepper.exportState();
            [Children.Laser405.Attributes, ...
                Children.Laser405.Data, ...
                Children.Laser405.Children] = ...
                    obj.Laser405.exportState();
            [Children.Laser647.Attributes, ...
                Children.Laser647.Data, ...
                Children.Laser647.Children] = ...
                    obj.Laser647.exportState();
            [Children.Lamp660.Attributes, ...
                Children.Lamp660.Data, ...
                Children.Lamp660.Children] = ...
                    obj.Lamp660.exportState();
            if obj.UseBrightfieldReg
                [Children.AlignReg.Attributes, ...
                    Children.AlignReg.Data, ...
                    Children.AlignReg.Children] = ...
                        obj.AlignReg.exportState();
            end
            
            % Store the desired obj properties to be exported.
            Attributes.ExposureTimeLampFocus = obj.ExposureTimeLampFocus;
            Attributes.ExposureTimeLaserFocusLow = ...
                obj.ExposureTimeLaserFocusLow;
            Attributes.ExposureTimeLaserFocusHigh = ...
                obj.ExposureTimeLaserFocusHigh;
            Attributes.ExposureTimeSequence = obj.ExposureTimeSequence;
            Attributes.ExposureTimeCapture = obj.ExposureTimeCapture;
            Attributes.NumberOfFrames = obj.NumberOfFrames;
            Attributes.NumberOfSequences = obj.NumberOfSequences;
            Attributes.CameraROI = obj.SCMOS_ROI_Collect;
            Attributes.SCMOS_ROI_Full = obj.SCMOS_ROI_Full;
            Attributes.SaveDir = obj.SaveDir;
            Attributes.LaserPowerFocus647 = obj.LaserPowerFocus647;
            Attributes.LaserPowerSequence647 = obj.LaserPowerSequence647;
            Attributes.LaserPowerFocus405 = obj.LaserPowerFocus405;
            Attributes.LaserPowerSequence405 = obj.LaserPowerSequence405;
            Attributes.UsePreActivation = obj.UsePreActivation;
            Attributes.DurationPreActivation = obj.DurationPreActivation;
            
            % Store the Data to be exported.
            Data = [];
        end
        
        GuiFig = gui(obj);
        GuiFig = guiPiezoReconnection(obj);
        
        function updateStatus(obj, ~, ~)
            % Listener callback for a change of the object property
            % StatusString. 
            
            % Find the status box object within the GUI.
            StatusObject = findall(obj.GuiFigure, 'Tag', 'StatusText');
            
            % Modify the text within the status box to show the current
            % status.
            StatusObject.String = obj.StatusString;
        end
        
        autoCollect(obj, StartCell, RefDir);
        exposeCellROI(obj); 
        exposeGridPoint(obj);
        findCoverSlipOffset(obj, RefStruct);
        Success=findCoverSlipOffset_Manual(obj, RefStruct);
        saveReferenceImage(obj);
        startSequence(obj, RefStruct, LabelID);
        
        function setupSCMOS(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up main sCMOS...';
            
            % Setup the sCMOS and set properties as needed.
            obj.CameraSCMOS = MIC_HamamatsuCamera();
            CamSet = obj.CameraSCMOS.CameraSetting;
            CamSet.DefectCorrection.Bit = 1;
            obj.CameraSCMOS.setCamProperties(CamSet);
            obj.CameraSCMOS.ReturnType = 'matlab';
            obj.CameraSCMOS.setCamProperties( ...
                obj.CameraSCMOS.CameraSetting);
            obj.CameraSCMOS.ExpTime_Capture = 0.2;
            obj.CameraSCMOS.ExpTime_Sequence = 0.01;
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupStagePiezo(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up sample stage piezos...';
            
            % Connect to the piezos and create the piezo stage object.
            obj.StagePiezo = MIC_NanoMaxPiezos(...
                obj.XPiezoSerialNums{1}, obj.XPiezoSerialNums{2}, ...
                obj.YPiezoSerialNums{1}, obj.YPiezoSerialNums{2}, ...
                obj.ZPiezoSerialNums{1}, obj.ZPiezoSerialNums{2}, ...
                obj.MaxPiezoConnectAttempts);
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupStageStepper(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up sample stage stepper motors...';
            
            % Setup the stepper motors for the NanoMax stage and move the
            % stage to a safe position so as to avoid hitting the
            % objective.
            obj.StageStepper = MIC_StepperMotor('70850323');
            obj.StageStepper.moveToPosition(3, 4); % z stepper
            obj.StageStepper.moveToPosition(1, 2.0650); % y stepper
            obj.StageStepper.moveToPosition(2, 2.2780); % x stepper
            
            % Check to make sure the steppers were setup properly.
            pause(obj.StepperWaitTime); % let stage settle down first
            XPosition = obj.StageStepper.getPosition(2);
            YPosition = obj.StageStepper.getPosition(1);
            ZPosition = obj.StageStepper.getPosition(3);
            SmallStepSize = obj.StepperSmallStep;
            if (abs(XPosition - 2.2780) > SmallStepSize) ...
                    || (abs(YPosition - 2.0650) > SmallStepSize) ...
                    || (abs(ZPosition - 4) > SmallStepSize)
                % If any of these conditions are true, something has
                % probably gone wrong with the stepper motor...
                warning(['There is a problem with the stepper motors.', ...
                    ' Please power cycle the stepper motor ', ...
                    'controller and run SEQ.setupStageStepper()']);
                obj.StageStepper.delete(); % delete so it can't be used
            end
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupLamps(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up sample illumination LED...';
            
            % Setup the LED lamp object.
            obj.Lamp660 = MIC_ThorlabsLED('Dev2', 'ao0');
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupLasers(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up lasers...';
            
            % Setup the needed laser(s).
            obj.Laser647 = MIC_MPBLaser();
            obj.Laser405 = MIC_TCubeLaserDiode('64841724', ...
                'Power', 32.25, 20.05, 10);
            % Usage: 
            % TLD = MIC_TCubeLaserDiode(SerialNo, Mode, ...
            %                           MaxPower, WperA, TIARange)
            % Max power was set to 32.25 mW (~80% of max), corresponding
            % to a current of 32.25 mA.  WperA was found by measuring the 
            % output power for input currents of 34 mA to 64 mA in 10 mA 
            % steps, fitting a line to the plot of PD current vs. power, 
            % and taking the slope. The TIARange was set to the photodiode
            % setting as set  by the dip switches on the laser driver 
            % controller.  
            % See DS lab notes 3/8/19.
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupFlipMountTTL(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = ...
                'Setting up neutral density filter flipmount...';
            
            % Setup the flip mount object to control the neutral density
            % filter.
            obj.FlipMount = MIC_FlipMountTTL('Dev1', 'Port0/Line0');
            obj.FlipMount.FilterIn(); % place ND filter in 647 laser path
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupShutterTTL(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Setting up the shutter...';
            
            % Setup the shutter for control of the 647nm laser.
            obj.Shutter = MIC_ShutterTTL('Dev1', 'Port0/Line1');
            obj.Shutter.close(); % close the shutter by default
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function setupAlignReg(obj)
            % Create the registration object.
            CalibrationFilePath = ['C:\Users\lidkelab\Documents\', ...
                'MATLAB\matlab-instrument-control\Reg3DCalFile.mat'];
            obj.AlignReg = MIC_Reg3DTrans(obj.CameraSCMOS, ...
                obj.StagePiezo, CalibrationFilePath);
            
            % Modify properties of the registration object as needed.
            obj.AlignReg.ChangeExpTime = 1;
            obj.AlignReg.ExposureTime = obj.ExposureTimeCapture;
            obj.AlignReg.ZStackMaxDevInitialReg = obj.Reg3DMaxDevInit;
            obj.AlignReg.ZStack_MaxDev = obj.Reg3DMaxDev;
            obj.AlignReg.ZStack_Step = obj.Reg3DStepSize;
            obj.AlignReg.StageSettlingTime = obj.PiezoSettlingTime;
            obj.AlignReg.UseStackCorrelation = obj.UseStackCorrelation;
            obj.AlignReg.CameraTriggerMode = 'software'; 
            obj.AlignReg.Tol_X = obj.Reg3DXTol;
            obj.AlignReg.Tol_Y = obj.Reg3DZTol;
            obj.AlignReg.Tol_Z = obj.Reg3DZTol;
        end
        
        function unloadSample(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Unloading the sample...';
            
            % Raise the sample stage away from the objective.
            obj.StageStepper.moveToPosition(1, 2.0650); % y stepper
            obj.StageStepper.moveToPosition(2, 2.2780); % x stepper
            obj.StageStepper.moveToPosition(3, 4); % z stepper
            
            % Clear the coverslip offset (this will no longer be a valid
            % offset, but might cause other problems if not reset).
            obj.CoverSlipOffset = [0, 0, 0];
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function loadSample(obj)
            % Update the status indicator for the GUI.
            obj.StatusString = 'Loading the sample...';
            
            % Lower the sample stage towards the objective
            obj.StageStepper.moveToPosition(1, 2.0650); % y stepper
            obj.StageStepper.moveToPosition(2, 2.2780); % x stepper
            obj.StageStepper.moveToPosition(3, obj.CoverslipZPosition); % z stepper
            
            % Update the status indicator for the GUI.
            obj.StatusString = '';
        end
        
        function findCoverslipFocus(obj)
            % Displays the entire ROI of the main sCMOS camera while
            % illuminating the sample with the 660nm lamp.  This can be
            % used, e.g., to help find the coverslip when the sample is
            % initially placed on the sample stage.
            
            % Center the piezos before proceeding.
            obj.StagePiezo.center();
            
            % Set some camera parameters and begin a focus acquisition.
            obj.CameraSCMOS.ExpTime_Focus = obj.ExposureTimeLampFocus;
            obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Full;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Lamp660.setPower(obj.Lamp660Power);
            obj.Lamp660.on();
            obj.CameraSCMOS.start_focus();
            obj.Lamp660.setPower(0);
        end
        
        function Data = captureLamp(obj, ROISelect)
            % Capture an image with 660nm lamp.
            obj.Lamp660.on(); 
            obj.Lamp660.setPower(obj.Lamp660Power);
            pause(obj.LampWait);
            switch ROISelect
                case 'Full'
                    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
                case 'ROI'
                    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
            end
            obj.CameraSCMOS.ExpTime_Capture = obj.ExposureTimeCapture;
            obj.CameraSCMOS.AcquisitionType = 'capture';
            obj.CameraSCMOS.setup_acquisition();
            Data = obj.CameraSCMOS.start_capture();
            obj.Lamp660.setPower(0);
        end
        
        function startROILampFocus(obj)
            % Run the SCMOS in focus mode with the 660nm lamp to allow the 
            % user to focus.
            obj.CameraSCMOS.ExpTime_Focus = obj.ExposureTimeLampFocus;
            obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Lamp660.setPower(obj.Lamp660Power);
            obj.FlipMount.FilterIn(); 
            obj.CameraSCMOS.start_focus();
            obj.Lamp660.off();
            obj.startROILaserFocusLow();
        end
        
        function startROILaserFocusLow(obj)
            % Run the SCMOS in focus mode with Low Laser Power to allow the
            % user to focus.  
            
            % Run SCMOS in focus mode with Low Laser Power to check
            % fluorescence. 
            % NOTE: Once the laser is turned on once through this function,
            % it will stay on until an acquisition is complete (this is
            % done to avoid the laser power up delay at each cell
            % selection).
            obj.CameraSCMOS.ExpTime_Focus = obj.ExposureTimeLaserFocusLow;
            obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Laser647.setPower(obj.LaserPowerFocus647);
            obj.Laser405.setPower(obj.LaserPowerFocus405);
            obj.FlipMount.FilterIn();
            obj.Laser647.on();
            if obj.OnDuringFocus647
                % Only open the shutter if requested by the set flag.
                obj.Shutter.open();
            end
            if obj.OnDuringFocus405
                % Only turn on the 405nm laser if requested by the set
                % flag.
                obj.Laser405.on();
            end
            obj.CameraSCMOS.start_focus();
            obj.Shutter.close(); % closes shutter to prevent photobleaching
            obj.Laser405.off(); % turn of the 405nm laser
            
            % Ask the user if they would like to proceed to high power
            % focus mode.  If not, ask if they would like to save the
            % reference at the current focus. 
            UseHighPowerFocus = questdlg('Proceed to high power focus?', ...
                'Use High Power Focus', 'Yes', 'No', 'No'); % default No
            if strcmpi(UseHighPowerFocus, 'Yes')
                % The user would like to re-adjust the focus in High Power
                % Focus Mode.
                obj.startROILaserFocusHigh();
            else
                % Ask user if they would like to save the current cell and
                % focus as a reference (question dialog will appear once 
                % the figure window for the CameraSCMOS object is closed).
                UseCell = ...
                    questdlg('Use this cell and Save Reference Image?', ...
                    'Save and Use', 'Yes', 'No', 'Yes'); % default Yes
                if strcmpi(UseCell, 'Yes')
                    obj.saveReferenceImage();
                end
            end
        end

        function startROILaserFocusHigh(obj)
            % Run SCMOS in focus mode with High Laser Power.
            obj.CameraSCMOS.ExpTime_Focus = obj.ExposureTimeLaserFocusHigh;
            obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
            obj.CameraSCMOS.AcquisitionType = 'focus';
            obj.CameraSCMOS.setup_acquisition();
            obj.Laser647.setPower(obj.LaserPowerFocus647);
            obj.Laser405.setPower(obj.LaserPowerFocus405);
            obj.Laser647.on();
            if obj.OnDuringFocus647
                % Only open the shutter if requested by the set flag.
                obj.Shutter.open();
            end
            if obj.OnDuringFocus405
                % Only turn on the 405nm laser if requested by the set
                % flag.
                obj.Laser405.on();
            end
            obj.FlipMount.FilterOut(); 
            obj.CameraSCMOS.start_focus();
            obj.Shutter.close(); % closes shutter to prevent photobleaching
            obj.Laser405.off(); % turn of the 405nm laser
            
            % Ask user if they would like to save the current cell and
            % focus as a reference (question dialog will appear once
            % the figure window for the CameraSCMOS object is closed).
            UseCell = ...
                questdlg('Use this cell and Save Reference Image?', ...
                'Save and Use', 'Yes', 'No', 'Yes'); % default Yes
            if strcmpi(UseCell, 'Yes')
                obj.saveReferenceImage();
            end
        end
        
        function collectPSFStack(obj, ExposureTime, MaxOffsetZ, ...
                StepSize, SaveDir)
            % This method will collect a z-stack of images centered around
            % the current piezo position.  The purpose of this method is to
            % collect a stack of images of a low density bead sample to
            % observe the PSF.  The input ExposureTime is optional with 
            % a default value of obj.ExposureTimeLaserFocusLow.
            % The input MaxOffsetZ is optional with a default value of 2.5
            % microns.  The input StepSize is optional with a default value
            % of obj.PiezoStep.  The input SaveDir is optional with a
            % default value of obj.TopDir.
            
            % Set defaults if needed.
            if ~exist('ExposureTime', 'var') || isempty(ExposureTime)
                ExposureTime = obj.ExposureTimeLaserFocusLow;
            end
            if ~exist('MaxOffsetZ', 'var') || isempty(MaxOffsetZ)
                MaxOffsetZ = 2.5; % microns
            end 
            if ~exist('StepSize', 'var') || isempty(StepSize)
                StepSize = obj.PiezoStep; % microns
            end 
            if ~exist('SaveDir', 'var') || isempty(SaveDir)
                SaveDir = obj.TopDir;
            end 
            
            % Set instrument properties as needed. 
            PreviousExposureTime = obj.CameraSCMOS.ExpTime_Capture;
            obj.CameraSCMOS.ExpTime_Capture = ExposureTime;
            
            % Collect the z-stack. 
            CurrentPosition = obj.StagePiezo.Position;
            ZPositions = CurrentPosition(3) - MaxOffsetZ...
                :StepSize...
                :CurrentPosition(3) + MaxOffsetZ;
            ImageSize = [obj.SCMOS_ROI_Collect(2) ...
                - obj.SCMOS_ROI_Collect(1) + 1, ...
                obj.SCMOS_ROI_Collect(4) ...
                - obj.SCMOS_ROI_Collect(3) + 1];
            ZStack = zeros([ImageSize, numel(ZPositions)], 'single');
            for ii = 1:numel(ZPositions)
                % Move to the specified position.
                obj.StagePiezo.setPosition([CurrentPosition(1), ...
                    CurrentPosition(2), ZPositions(ii)]);
                
                % Allow the stage to settle.
                pause(obj.PiezoSettlingTime);
                
                % Capture an image at the current position.
                ZStack(:, :, ii) = single(obj.CameraSCMOS.start_capture());
            end
            
            % Save the ZStack as a .mat file.
            save(fullfile(SaveDir, 'PSFStack.mat'), 'ZStack');         
            
            % Move the stage back to the original position.
            obj.StagePiezo.setPosition(CurrentPosition);
            
            % Change the camera exposure time back to it's original value.
            obj.CameraSCMOS.ExpTime_Capture = PreviousExposureTime;
        end
        
        function moveStepperUpLarge(obj)
            % Large stage step up in the z dimension with stepper motor.
            PosStepZ = obj.StageStepper.getPosition(3); % get z position
            PosStepZ = PosStepZ + obj.StepperLargeStep; % proposed z pos.
            obj.StageStepper.moveToPosition(3, PosStepZ); % set new z pos.
        end
        
        function moveStepperDownLarge(obj)
            % Large stage step down in the z dimension with stepper motor.
            PosStepZ = obj.StageStepper.getPosition(3); % get z position
            PosStepZ = PosStepZ - obj.StepperLargeStep; % proposed z pos.
            obj.StageStepper.moveToPosition(3, PosStepZ); % set new z pos.
        end
        
        function moveStepperUpSmall(obj)
            % Small stage step up in the z dimension with stepper motor.
            PosStepZ = obj.StageStepper.getPosition(3); % get z position
            PosStepZ = PosStepZ + obj.StepperSmallStep; % proposed z pos.
            obj.StageStepper.moveToPosition(3, PosStepZ); % set new z pos.
        end
        
        function moveStepperDownSmall(obj)
            % Small stage step down in the z dimension with stepper motor.
            PosStepZ = obj.StageStepper.getPosition(3); % get z position
            PosStepZ = PosStepZ - obj.StepperSmallStep; % proposed z pos.
            obj.StageStepper.moveToPosition(3, PosStepZ); % set new z pos.
        end
        
        function movePiezoUpSmall(obj)
            % Small stage step up in the z dimension with piezo.
            OldPosPiezo = obj.StagePiezo.Position;
            NewPosPiezo = OldPosPiezo + [0, 0, obj.PiezoStep];
            if NewPosPiezo(3) < (10 + obj.StepperSmallStep * 1e3)
                obj.StagePiezo.setPosition(NewPosPiezo); 
            else
                warning(['Recommended Z piezo range exceeded: please ', ...
                    'use small stepper movements before using piezo.'])
            end
        end
        
        function movePiezoDownSmall(obj)
            % Small stage step down in the z dimension with piezo.
            OldPosPiezo = obj.StagePiezo.Position;
            NewPosPiezo = OldPosPiezo - [0, 0, obj.PiezoStep];
            if NewPosPiezo(3) > (10 - obj.StepperSmallStep * 1e3)
                obj.StagePiezo.setPosition(NewPosPiezo); 
            else
                warning(['Recommended Z piezo range exceeded: please ', ...
                    'use small stepper movements before using piezo.'])
            end
        end
    end
    
    methods (Static)
        function State = unitTest()
            % unitTest for the sequential microscope.. not yet written!
        end

    end
end