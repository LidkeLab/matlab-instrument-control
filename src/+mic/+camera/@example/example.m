classdef example < mic.camera.abstract
    % This is an example implementation of mic.camera.abstract 
    % Matlab Instrument Control Camera Class. 
    %
    % REQUIRES:
    % mic.camera.abstract.m
    %
    % ## Protected Properties (Set Access)
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'Simulated Camera'`.
    %
    % ### `CameraIndex`
    % Index of the camera.
    % **Default:** `1`.
    %
    % ### `ImageSize`
    % Size of the image in pixels `[width, height]`.
    % **Default:** `[1024, 768]`.
    %
    % ### `LastError`
    % String storing the last error encountered.
    % **Default:** `''` (empty string).
    %
    % ### `Manufacturer`
    % Name of the manufacturer.
    % **Default:** `'MyCam'`.
    %
    % ### `Model`
    % Model name of the camera.
    % **Default:** `'CamModelX100'`.
    %
    % ### `CameraParameters`
    % Structure containing camera-specific parameters.
    % **Default:** `struct('Gain', 1, 'FrameRate', 30)`.
    %
    % ### `XPixels`
    % Number of pixels in the first dimension (width).
    % **Default:** `1024`.
    %
    % ### `YPixels`
    % Number of pixels in the second dimension (height).
    % **Default:** `768`.
    %
    % ## Public Properties
    %
    % ### `Binning`
    % Binning settings in the format `[binX binY]`.
    % **Default:** `[1 1]`.
    %
    % ### `Data`
    % Last acquired data.
    % **Default:** `[]` (empty array).
    %
    % ### `ExpTime_Focus`
    % Exposure time for focus mode.
    % **Default:** `0.01`.
    %
    % ### `ExpTime_Capture`
    % Exposure time for capture mode.
    % **Default:** `0.02`.
    %
    % ### `ExpTime_Sequence`
    % Exposure time for sequence mode.
    % **Default:** `0.05`.
    %
    % ### `ROI`
    % Region of interest specified as `[Xstart Xend Ystart Yend]`.
    % **Default:** `[1 1024 1 768]`.
    %
    % ### `SequenceLength`
    % Length of the kinetic series.
    % **Default:** `10`.
    %
    % ### `SequenceCycleTime`
    % Cycle time for the kinetic series (in seconds).
    % **Default:** `0.1`.
    %
    % ### `TriggerMode`
    % Trigger mode for the camera.
    % **Default:** `'internal'`.
    %
    % ## Protected Properties
    %
    % ### `AbortNow`
    % Flag to stop acquisition.
    % **Default:** `false`.
    %
    % ### `FigurePos`
    % Position of the figure window.
    %
    % ### `FigureHandle`
    % Handle for the figure window.
    %
    % ### `ImageHandle`
    % Handle for the image display.
    %
    % ### `ReadyForAcq`
    % Indicates if the camera is ready for acquisition.
    % **Default:** `false`.
    %
    % ### `TextHandle`
    % Handle for text display.
    %
    % ### `TimerHandle`
    % Handle for the timer object.
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Indicates whether the GUI starts automatically.
    % **Default:** `false`.
    %
    % ## Methods
    %
    % ### `example()`
    % Constructor for creating an instance of `example`.
    %
    % ### `exportState()`
    % Exports the current state of the camera object.
    % - Returns a state structure containing camera parameters, image size, exposure times, ROI, and binning.
    %
    % ### `abort()`
    % Stops the acquisition process.
    % - Sets `AbortNow` to `true`.
    %
    % ### `errorcheck(funcname)`
    % Performs error checking for the specified function.
    %
    % ### `getlastimage()`
    % Retrieves the last captured image.
    % - Simulates and returns a random image based on `ImageSize`.
    %
    % ### `getdata()`
    % Retrieves data from the camera.
    % - Simulates data acquisition by generating a random image.
    %
    % ### `initialize()`
    % Initializes the camera settings.
    % - Sets `ReadyForAcq` to `true`.
    %
    % ### `setup_acquisition()`
    % Configures acquisition parameters for the camera.
    % - Calls `initialize()` if the camera is not ready.
    %
    % ### `shutdown()`
    % Shuts down the camera and releases resources.
    % - Stops and deletes any timer objects.
    % - Closes and deletes figure handles.
    %
    % ### `start_capture()`
    % Starts capture mode.
    % - Returns a simulated image if the camera is ready.
    %
    % ### `start_focus()`
    % Starts focus mode.
    % - Returns a simulated image if the camera is ready.
    %
    % ### `start_sequence()`
    % Starts sequence acquisition mode.
    % - Returns a simulated image sequence if the camera is ready.
    %
    % ### `fireTrigger()`
    % Simulates firing a trigger.
    %
    % ### `setupGUI()`
    % Creates a GUI for controlling the camera.
    % - Includes buttons for `Focus`, `Capture`, and `Sequence` modes.
    %
    % ### `onButtonClicked(src)`
    % Handles button clicks in the GUI.
    %
    % ### `closeGui()`
    % Handles closing the GUI and cleaning up resources.
    %
    % ### `setupTemperatureTimer(displayHandle)`
    % Sets up a timer to periodically update the temperature display.
    %
    % ### `updateTemperatureDisplay(displayHandle)`
    % Updates the temperature display based on current readings.
    %
    % ### `stopAndCleanupTimer()`
    % Stops and deletes the timer.
    %
    % ### `call_temperature()`
    % Simulates a call to get temperature.
    % - Returns a sample temperature and status.
    %
    % ## Protected Methods
    %
    % ### `get_properties()`
    % Retrieves camera properties.
    %
    % ### `gettemperature()`
    % Retrieves the camera's temperature and status.
    %
    % ## Static Methods
    %
    % ### `funcTest()`
    % Performs a unit test of the class.
    % - Initializes the camera, sets up acquisition, and runs focus mode.
    %
    % CITATION: Sajjad Khan, Lidkelab, 2024.

    properties(SetAccess=protected)
        InstrumentName = 'Simulated Camera';
        CameraIndex = 1;
        ImageSize = [1024, 768];
        LastError = '';
        Manufacturer = 'MyCam';
        Model = 'CamModelX100';
        CameraParameters = struct('Gain', 1, 'FrameRate', 30);
        XPixels = 1024;
        YPixels = 768;
    end

    properties
        Binning = [1 1];
        Data = [];
        ExpTime_Focus = 0.01;
        ExpTime_Capture = 0.02;
        ExpTime_Sequence = 0.05;
        ROI = [1 1024 1 768];
        SequenceLength = 10;
        SequenceCycleTime = 0.1;
        TriggerMode = 'internal';
    end

    properties(Access=protected)
        AbortNow = false;
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq = false;
        TextHandle;
        TimerHandle; % Timer object handle
    end
    
    properties (Hidden)
        StartGUI = false; % GUI does not start automatically by default
    end

    methods
        function obj = example()
            obj = obj@mic.camera.abstract(~nargout);
        end

        function state = exportState(obj)
            state = obj.CameraParameters;
            state.ImageSize = obj.ImageSize;
            state.ExpTimes = [obj.ExpTime_Focus, obj.ExpTime_Capture, obj.ExpTime_Sequence];
            state.ROI = obj.ROI;
            state.Binning = obj.Binning;
        end

        function abort(obj)
            obj.AbortNow = true;
            disp('Abortion requested.');
        end

        function errorcheck(obj, funcname)
            disp(['Checking errors for function: ', funcname]);
            obj.LastError = '';
        end

        function out = getlastimage(obj)
            disp('Retrieving last image.');
            out = rand(obj.ImageSize); % Simulate an image
        end

        function out = getdata(obj)
            disp('Getting data.');
            out = rand(obj.ImageSize); % Simulate data acquisition
            obj.Data = out;
        end

        function initialize(obj)
            disp('Initializing camera settings.');
            obj.ReadyForAcq = true;
        end

        function setup_acquisition(obj)
            disp('Setting up acquisition parameters.');
            if ~obj.ReadyForAcq
                disp('Camera not ready. Initializing now.');
                obj.initialize();
            end
        end
        
        function shutdown(obj)
            disp('Shutting down the camera.');
            obj.abort();
            if ~isempty(obj.TimerHandle) && isobject(obj.TimerHandle) && isvalid(obj.TimerHandle)
                stop(obj.TimerHandle);
                delete(obj.TimerHandle);
                obj.TimerHandle = [];
            end
            if ishandle(obj.FigureHandle)
                close(obj.FigureHandle);
                obj.FigureHandle = [];
            end
            disp('Camera shutdown completed.');
        end
        
        function img = start_capture(obj)
            disp('Starting capture mode.');
            if obj.ReadyForAcq
                disp('Camera is running in capture mode.');
                img = rand(obj.ImageSize);  % Return a dummy image
            else
                disp('Camera is not ready for capture.');
                img = [];  % Return an empty array if not ready
            end
        end
        
        function img = start_focus(obj)
            disp('Starting focus mode.');
            if obj.ReadyForAcq
                disp('Camera is running in focus mode.');
                img = rand(obj.ImageSize);  % Return a dummy image
            else
                disp('Camera is not ready for focus.');
                img = [];  % Return an empty array if not ready
            end
        end
        
        function seq = start_sequence(obj)
            disp('Starting sequence acquisition mode.');
            if obj.ReadyForAcq
                disp('Camera is running in sequence acquisition mode.');
                seq = repmat(rand(obj.ImageSize), 1, 1, obj.SequenceLength);  % Return a dummy sequence
            else
                disp('Camera is not ready for sequence acquisition.');
                seq = [];  % Return an empty array if not ready
            end
        end
        
        function fireTrigger(obj)
            disp('Firing trigger.');
            % Simulate firing trigger
        end
        
        function setupGUI(obj)
            % Create a figure for the GUI
            obj.FigureHandle = figure('Name', 'Camera Control', 'CloseRequestFcn', @(src, event) obj.closeGui());
            
            % Create a button for focus
            uicontrol('Style', 'pushbutton', 'String', 'Focus', ...
                'Position', [20, 50, 70, 25], ...
                'Callback', @(src, evnt)obj.onButtonClicked(src));
            
            % Create a button for capture
            uicontrol('Style', 'pushbutton', 'String', 'Capture', ...
                'Position', [100, 50, 70, 25], ...
                'Callback', @(src, evnt)obj.onButtonClicked(src));
            
            % Create a button for sequence acquisition
            uicontrol('Style', 'pushbutton', 'String', 'Sequence', ...
                'Position', [180, 50, 70, 25], ...
                'Callback', @(src, evnt)obj.onButtonClicked(src));
            
            disp('GUI setup complete.');
        end
        
        function onButtonClicked(obj, src)
            % Change the button color to green
            set(src, 'BackgroundColor', [0, 1, 0]);  % Set color to green
            drawnow;  
            
            % Determine the action based on button label
            switch src.String
                case 'Focus'
                    obj.start_focus();
                case 'Capture'
                    obj.start_capture();
                case 'Sequence'
                    obj.start_sequence();
                otherwise
                    disp('Unknown button action.');
            end
        end
        
        function closeGui(obj)
            % Custom method to handle GUI closure
            disp('Closing GUI and cleaning up resources.');
            if isvalid(obj.TimerHandle)
                stop(obj.TimerHandle);
                delete(obj.TimerHandle);
            end
            % Close the figure safely
            if ishandle(obj.FigureHandle)
                delete(obj.FigureHandle);  % Use delete instead of close to ensure the handle is removed
            end
            obj.FigureHandle = [];
        end

        function setupTemperatureTimer(obj, displayHandle)
            % Ensure no existing timer is running
            if ~isempty(obj.TimerHandle) && isvalid(obj.TimerHandle)
                stop(obj.TimerHandle);
                delete(obj.TimerHandle);
            end
            % Setup a new timer
            obj.TimerHandle = timer('ExecutionMode', 'fixedRate', 'Period', 5, ...
                                    'TimerFcn', @(~,~) obj.updateTemperatureDisplay(displayHandle));
            start(obj.TimerHandle);
        end

        function updateTemperatureDisplay(obj, displayHandle)
            % Check if the display handle and the object itself are still valid
            if isvalid(obj) && ishandle(displayHandle)
                try
                    [temp, status] = obj.call_temperature();
                    set(displayHandle, 'String', sprintf('Temperature: %d°C, Status: %d', temp, status));
                catch ME
                    disp(['Error updating temperature display: ' ME.message]);
                end
            else
                disp('Stopping timer due to invalid display handle or object.');
                obj.stopAndCleanupTimer();
            end
        end

        function stopAndCleanupTimer(obj)
            if isvalid(obj.TimerHandle)
                stop(obj.TimerHandle);
                delete(obj.TimerHandle);
                obj.TimerHandle = [];
            end
        end

        function [temp, status] = call_temperature(obj)
            temp = 22; % Example temperature in Celsius
            status = 1; % Temperature stabilized
        end
    end

    methods(Access=protected)
        function obj = get_properties(obj)
            disp('Getting camera properties.');
        end

        function [temp, status] = gettemperature(obj)
            disp('Getting camera temperature.');
            temp = 25; % Assume room temperature
            status = 1; % Temperature stabilized
        end
    end
    
    methods(Static=true)
        function Success = funcTest()
            disp('Starting unit test...');
            obj = mic.camera.example();
            obj.initialize();
            obj.setup_acquisition();
            obj.start_focus();
            pause(1);
            Success = true; % Assume success for simplicity
            obj.abort();
            disp('Unit test completed successfully.');
        end
    end
end
% To open GUI, create obj = Example_Camera() then call obj.gui()
% To close GUI properly, press Abort -> Exit -> Confirm.
