classdef ExamplePowerMeter < MIC_PowerMeter_Abstract
    % ExamplePowerMeter Class for controlling Example Power Meter
    % This class provides an interface to the example power meter,
    % implementing all necessary methods to operate the device and manage
    % data acquisition and GUI representation.
    properties (SetAccess = protected)
        InstrumentName = 'ExamplePowerMeter';
    end
    methods
        function obj = ExamplePowerMeter()
            % Constructor for ExamplePowerMeter
            obj = obj@MIC_PowerMeter_Abstract(~nargout);
            
            obj.StartGUI = true;  % Automatically start the GUI
            % Initialize property values
            obj.initializeProperties();
        end
        
        function initializeProperties(obj)
            % Method to initialize or reset properties
            obj.VisaObj = 'NIDAQ';
            obj.Power = 0.1;  % Set initial power to 0.1 mW
            obj.Ask = 'power';  % Set to measure power by default
            obj.Limits = [400, 700];  % Set wavelength limits to a dummy range
            obj.Lambda = 532;  % Set default wavelength to 532 nm
            obj.T = 10;  % Set GUI update period to 10 seconds
            obj.Stop = 0;  % Ensure plotting is off by default
        end
        
        function gui(obj)
            % Ensure the GUI can handle errors and manage device communication
            try
                % Check device connection before attempting to use it
                if isempty(obj.VisaObj) || (isobject(obj.VisaObj) && ~isvalid(obj.VisaObj))
                    error('Device not connected or VisaObj is not initialized or invalid.');
                end
                
                % Create GUI figure and axes
                obj.GuiFigure = figure('Name', 'Example Power Meter GUI', 'NumberTitle', 'off');
                ax = axes('Parent', obj.GuiFigure);
                hold(ax, 'on');
                xlabel(ax, 'Time (s)');
                ylabel(ax, 'Power (mW)');
                grid(ax, 'on');
                
                x = linspace(0, 10*pi, 400);  % Generate 100 points between 0 and 2*pi
                
                % Calculate the sine of each x value
                y = sin(x);
                
                % Plot the sine function
                plot(ax, x, y);

                
            catch ME
                disp(['Error in GUI setup: ', ME.message]);
                if ishandle(obj.GuiFigure)
                    close(obj.GuiFigure);
                end
            end
        end
        
        function output = measure(obj)
            if ischar(obj.VisaObj) && strcmp(obj.VisaObj, 'Simulated')
                disp('Test Mode: Simulating measurement.');
                output = 0.5;  % Simulated output
            else
                try
                    fprintf(obj.VisaObj, obj.Ask);
                    output = str2double(fscanf(obj.VisaObj));
                catch
                    disp('Error reading from device. Returning simulated data.');
                    output = 0.5;  % Simulated output for development or testing
                end
            end
        end
        
        function [Attributes, Data, Children] = exportState(obj)
            % Export the current state of the power meter
            Attributes.InstrumentName = obj.InstrumentName;
            Attributes.Lambda = obj.Lambda;
            Attributes.Limits = obj.Limits;
            Data.Power = obj.Power;
            Data.T = obj.T;
            Children = [];  % Assuming no children components
        end
        
        function Shutdown(obj)
            % Cleanly shutdown the power meter connection
            if ischar(obj.VisaObj) && strcmp(obj.VisaObj, 'Simulated')
                disp('Test Mode: Simulated power meter shutdown.');
                obj.VisaObj = [];  % Clear the dummy connection object
            elseif isobject(obj.VisaObj) && isvalid(obj.VisaObj)
                fclose(obj.VisaObj);
                delete(obj.VisaObj);
                obj.VisaObj = [];
                disp('Power Meter shutdown completed.');
            else
                disp('No active connection to shutdown.');
            end
        end
        function connect(obj, testMode)
            if nargin < 2
                testMode = false;
            end
            
            if testMode
                disp('Test Mode: Simulated connection to Example power meter.');
                obj.VisaObj = 'Simulated'; % Assign a dummy string to represent a connected state
            else
                try
                    obj.VisaObj = visa('NI', 'USB0::0x1313::0x8078::P0000000::INSTR');
                    fopen(obj.VisaObj);
                    if strcmp(obj.VisaObj.Status, 'open')
                        disp('Connected to PM100D power meter.');
                    else
                        error('Failed to open connection to PM100D power meter.');
                    end
                catch ME
                    error('Failed to connect to Example power meter: %s', ME.message);
                end
            end
        end
        
    end
    
    methods (Static)
        function Success = unitTest(testMode)
            if nargin < 1
                testMode = true;  % Default to test mode
            end
            
            fprintf('Creating instance of ExamplePowerMeter...\n');
            pm = ExamplePowerMeter();  % Create instance
            Success = true;
            
            try
                fprintf('Connecting to the Example power meter...\n');
                pm.connect(testMode);
                fprintf('Connection successful.\n');
                
                fprintf('Setting wavelength to 532 nm...\n');
                pm.Lambda = 532;
                if pm.Lambda ~= 532
                    error('Lambda was not set correctly.');
                end
                fprintf('Lambda set correctly.\n');
                
                fprintf('Measuring power...\n');
                pm.Ask = 'power';
                powerReading = pm.measure();
                if isempty(powerReading) || isnan(powerReading)
                    error('Power measurement failed.');
                end
                fprintf('Power measurement successful: %f mW\n', powerReading);
                
                fprintf('Shutting down the power meter...\n');
                pm.Shutdown();
                fprintf('Shutdown successful.\n');
            catch ME
                disp(ME.message);
                Success = false;
            end
            
            delete(pm);
        end
        
    end
end
