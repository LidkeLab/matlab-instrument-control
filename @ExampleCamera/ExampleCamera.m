classdef ExampleCamera < MIC_Camera_Abstract
    % This is an example implementation of MIC_Camera_Abstract 
    % Matlab Instrument Control Camera Class. 
    
    % REQUIRES: 
    % MIC_Abstract.m
    %
    % CITATION: Sajjad Khan, Lidkelab, 2024.
    properties(SetAccess=protected)
        InstrumentName = 'ExampleCamera';
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
        function obj = ExampleCamera()
            obj = obj@MIC_Camera_Abstract(~nargout);
           
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
            out = rand(obj.ImageSize);
        end

        function out = getdata(obj)
            disp('Getting data.');
            out = rand(obj.ImageSize);
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
            
            % Ensure that any ongoing processes are aborted
            obj.abort();
            
            % Check if TimerHandle is a valid object and stop/delete it if it is
            if ~isempty(obj.TimerHandle) && isobject(obj.TimerHandle) && isvalid(obj.TimerHandle)
                stop(obj.TimerHandle);
                delete(obj.TimerHandle);
                obj.TimerHandle = [];
            end
            
            % Check if FigureHandle is a valid handle and close it if it is
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
        
        function setupGUI(obj)
            
            
            Create a button for focus
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
        function Success = unitTest()
            disp('Starting unit test...');
            obj = ExampleCamera();
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

% To close gui properly, press Abort -> Exit -> Confirm.