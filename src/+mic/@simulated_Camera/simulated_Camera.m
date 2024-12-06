classdef simulated_Camera < mic.camera.abstract
    % This is an example implementation of mic.camera.abstract 
    % Matlab Instrument Control Camera Class. 
    
    % REQUIRES:
    % mic.abstract.m
    
    % ## Properties
    %
    % ### Protected Properties
    %
    % #### `InstrumentName`
    % - **Description:** Name of the instrument.
    %   - **Default Value:** `'SimulatedCamera'`
    %
    % #### `CameraIndex`
    % - **Description:** Index to identify the camera instance.
    %   - **Default Value:** `1`
    %
    % #### `ImageSize`
    % - **Description:** Resolution of the camera's images in pixels `[XPixels, YPixels]`.
    %   - **Default Value:** `[1024, 768]`
    %
    % #### `LastError`
    % - **Description:** Stores the last error message encountered.
    %
    % #### `Manufacturer`
    % - **Description:** Manufacturer name of the camera.
    %   - **Default Value:** `'MyCam'`
    %
    % #### `Model`
    % - **Description:** Model name of the camera.
    %   - **Default Value:** `'CamModelX100'`
    %
    % #### `CameraParameters`
    % - **Description:** Structure defining camera parameters such as `Gain` and `FrameRate`.
    %   - **Default Value:** `struct('Gain', 1, 'FrameRate', 30)`
    %
    % #### `XPixels`
    % - **Description:** Horizontal resolution of the camera image.
    %   - **Default Value:** `1024`
    %
    % #### `YPixels`
    % - **Description:** Vertical resolution of the camera image.
    %   - **Default Value:** `768`
    %
    % ### Public Properties
    %
    % #### `Binning`
    % - **Description:** Binning factor `[horizontal, vertical]` to reduce image resolution.
    %   - **Default Value:** `[1, 1]`
    %
    % #### `Data`
    % - **Description:** Data acquired from the camera.
    %
    % #### `ExpTime_Focus`
    % - **Description:** Exposure time for focus mode in seconds.
    %   - **Default Value:** `0.01`
    %
    % #### `ExpTime_Capture`
    % - **Description:** Exposure time for capture mode in seconds.
    %   - **Default Value:** `0.02`
    %
    % #### `ExpTime_Sequence`
    % - **Description:** Exposure time for sequence acquisition in seconds.
    %   - **Default Value:** `0.05`
    %
    % #### `ROI`
    % - **Description:** Region of interest for image acquisition `[xStart, xEnd, yStart, yEnd]`.
    %   - **Default Value:** `[1, 1024, 1, 768]`
    %
    % #### `SequenceLength`
    % - **Description:** Number of images in a sequence acquisition.
    %   - **Default Value:** `10`
    %
    % #### `SequenceCycleTime`
    % - **Description:** Time between consecutive images in a sequence in seconds.
    %   - **Default Value:** `0.1`
    %
    % #### `TriggerMode`
    % - **Description:** Specifies the trigger mode used by the camera.
    %   - **Default Value:** `'internal'`
    %
    % ### Hidden Properties
    %
    % #### `StartGUI`
    % - **Description:** Indicates whether the GUI starts automatically.
    %   - **Default Value:** `false`
    %
    % ### Protected Properties
    %
    % #### `AbortNow`
    % - **Description:** Flag to indicate if an ongoing process should be aborted.
    %   - **Default Value:** `false`
    %
    % #### `FigurePos`
    % - **Description:** Stores the position of the GUI figure.
    %
    % #### `FigureHandle`
    % - **Description:** Handle for the main GUI figure.
    %
    % #### `ImageHandle`
    % - **Description:** Handle for image display in GUI.
    %
    % #### `ReadyForAcq`
    % - **Description:** Indicates if the camera is ready for acquisition.
    %   - **Default Value:** `false`
    %
    % #### `TextHandle`
    % - **Description:** Handle for text display in GUI.
    %
    % #### `TimerHandle`
    % - **Description:** Handle for a timer object used in GUI operations.
    %
    % ## Methods
    %
    % ### `simulated_Camera()`
    % - **Description:** Constructor method for the `simulated_Camera` class. Initializes the object.
    %
    % ### `exportState()`
    % - **Description:** Exports the state of the camera, including parameters and settings.
    %
    % ### `abort()`
    % - **Description:** Aborts an ongoing acquisition or operation.
    %
    % ### `errorcheck(funcname)`
    % - **Description:** Checks and displays any errors for the given function.
    %
    % ### `getlastimage()`
    % - **Description:** Retrieves the last acquired image.
    %   - **Returns:** Simulated random image data.
    %
    % ### `getdata()`
    % - **Description:** Acquires and returns image data.
    %
    % ### `initialize()`
    % - **Description:** Initializes camera settings.
    %
    % ### `setup_acquisition()`
    % - **Description:** Sets up acquisition parameters.
    %
    % ### `shutdown()`
    % - **Description:** Shuts down the camera and releases resources.
    %
    % ### `start_capture()`
    % - **Description:** Starts capture mode.
    %   - **Returns:** Simulated random image data.
    %
    % ### `start_focus()`
    % - **Description:** Starts focus mode.
    %   - **Returns:** Simulated random image data.
    %
    % ### `start_sequence()`
    % - **Description:** Starts sequence acquisition mode.
    %   - **Returns:** Simulated random sequence data.
    %
    % ### `fireTrigger()`
    % - **Description:** Fires a trigger for acquisition.
    %
    % ### `setupGUI()`
    % - **Description:** Sets up a GUI for controlling the camera.
    %
    % ### `onButtonClicked(src)`
    % - **Description:** Handles button clicks in the GUI.
    %
    % ### `closeGui()`
    % - **Description:** Closes the GUI and releases associated resources.
    %
    % ### `setupTemperatureTimer(displayHandle)`
    % - **Description:** Sets up a timer to periodically update temperature display.
    %
    % ### `updateTemperatureDisplay(displayHandle)`
    % - **Description:** Updates temperature displayed in GUI.
    %
    % ### `stopAndCleanupTimer()`
    % - **Description:** Stops and cleans up the timer.
    %
    % ### `call_temperature()`
    % - **Description:** Retrieves simulated temperature values.
    %
    % ### Protected Methods
    %
    % #### `get_properties()`
    % - **Description:** Retrieves camera properties.
    %
    % #### `gettemperature()`
    % - **Description:** Retrieves the current camera temperature.
    %   - **Returns:** Simulated temperature value and status.
    %
    % ### Static Method: `funcTest()`
    % - **Description:** Tests the functionality of the `simulated_Camera` class.
    %
    % CITATION: Sajjad Khan, Lidkelab, 2024.

    properties(SetAccess=protected)
        InstrumentName = 'SimulatedCamera';
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
        function obj = simulated_Camera()
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
            disp('Starting funcTest ...');
            Success = true;
            try
                obj = mic.simulated_Camera();
                obj.initialize();
                obj.setup_acquisition();
                obj.start_focus();
                pause(1);
                obj.abort();
                disp('funcTest completed successfully.');
            catch ME
                fprintf('Caught following error during mic.simulated_Camera.funcTest')
                disp(ME.identifier);
                disp(ME.message);
                Success = false;
            end
        end
    end

end
% To open GUI, create obj = simulated_Camera() then call obj.gui()
% To close GUI properly, press Abort -> Exit -> Confirm.
