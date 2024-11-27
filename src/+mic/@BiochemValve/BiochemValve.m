classdef BiochemValve < mic.abstract
%  mic.BiochemValve Class 
%
% ## Description
% The `mic.BiochemValve` class manages BIOCHEM flow selection valves through communication with an Arduino. 
% It provides functionality to open and close valves, and includes an emergency shutoff to cut power to both the valves
% and a syringe pump.
% 
% ## Installation Requirements
% - MATLAB R2014b or later
% - MATLAB Support Package for Arduino Hardware:     
% 
% ##NOTE
% You may need to setup the Arduino you are using
% specifically even if this package was installed previously.
% Matlab needs to upload software onto the Arduino before
% creation of an instance of this class. 
% 
% **Note:** Ensure the Arduino is properly set up as MATLAB needs to upload software onto it before using this class.
% 
% ## Dependencies
% - `mic.abstract.m` 
% 
%## Class Properties
% 
% ### Protected Properties
% - **`InstrumentName`**:
%   - **Description**: Descriptive name of the instrument.
%   - **Type**: String
%   - **Default**: `'BiochemValve'`
% - **`Arduino`**:
%   - **Description**: Serial object for communicating with the connected Arduino.
% 
% ### Hidden Properties
% - **`StartGUI`**:
%   - **Description**: Boolean flag indicating whether a graphical user interface (GUI) should be started for the instrument.
%   - **Type**: Boolean
%   - **Default**: `false`
% 
% ### Public Properties
% - **`PowerState12V`**:
%   - **Description**: Indicates the state of the 12V power line. A value of `1` indicates the line is active, and `0` indicates it is inactive.
%   - **Type**: Integer (0 or 1)
%   - **Default**: `0`
% - **`PowerState24V`**:
%   - **Description**: Indicates the state of the 24V power line. A value of `1` indicates the line is active, and `0` indicates it is inactive.
%   - **Type**: Integer (0 or 1)
%   - **Default**: `0`
% - **`DeviceSearchTimeout`**:
%   - **Description**: Timeout duration (in seconds) for searching for the USB device (Arduino).
%   - **Type**: Integer
%   - **Default**: `10` seconds
% - **`DeviceResponseTimeout`**:
%   - **Description**: Timeout duration (in seconds) for awaiting a response from the device (Arduino).
%   - **Type**: Integer
%   - **Default**: `10` seconds
% - **`IN1Pin`**:
%   - **Description**: The digital pin on the Arduino that is connected to relay IN1.
%   - **Type**: Integer
%   - **Default**: `2`
% - **`SerialPort`**:
%   - **Description**: The serial port used to communicate with the Arduino. This should match the connected port.
%   - **Type**: String
% - **`Board`**:
%   - **Description**: Name of the Arduino board being used (e.g., 'Uno', 'Mega').
%   - **Type**: String
%   - **Default**: `'Uno'`
% - **`ValveState`**:
%   - **Description**: Array representing the states of six valves, where `0` indicates closed and `1` indicates open.
%   - **Type**: Array of six integers (each 0 or 1)
%   - **Default**: `[0, 0, 0, 0, 0, 0]`
%
% ## Key Functions
% - **delete()**: Deletes the object and closes connection to Arduino.
% - **exportState()**: Exports the current state of the instrument.
% - **gui()**: Launches a graphical user interface for the valve controller.
% - **powerSwitch12V()**: Toggles power on the 12V line controlling the valves.
% - **powerSwitch24V()**: Toggles power on the 24V line that powers both the syringe pump and the BIOCHEM valves after stepping down to 12V.
% - **openValve(ValveNumber)**: Opens the specified valve.
% - **closeValve(ValveNumber)**: Closes the specified valve.
% - **funcTest(SerialPort)**: Performs a unit test of the valve controller on a specified serial port.
% 
% ## Usage
% ```matlab
% % Creating an instance of the valve controller
% Valves = mic.BiochemValve();
% 
% % Opening and closing a valve
% Valves.openValve(3);  % Open valve number 3
% Valves.closeValve(3); % Close valve number 3
% 
% % Managing power
% Valves.powerSwitch12V();  % Toggle the 12V power line
% ```
% ### CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'BiochemValve'; % name of instrument
        Arduino; % serial object for the connected syringe pump
    end
    
    
    properties (Hidden)
        StartGUI = false;
    end
    
    
    properties
        PowerState12V = 0; % 1 if 12V line is active, 0 otherwise
        PowerState24V = 0; % 1 if 24V line is active, 0 otherwise
        DeviceSearchTimeout = 10; % timeout(s) to search for USB device
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        IN1Pin = 2; % Arduino digital pin number connected to relay IN1
        SerialPort; % serial port for the Arduino (if needed)
        Board = 'Uno'; % name of Arduino board (if needed)
        ValveState = [0, 0, 0, 0, 0, 0]; % 6 valves, 0 (closed) or 1 (open)
    end
    
    
    methods
        function obj = BiochemValve()
            %Constructor for the BIOCHEM valve object.
            
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@mic.abstract(~nargout);
            
            % Search for/connect to an Arduino connected via USB.
            if isempty(obj.SerialPort) 
                % The user did not specify which port to connect to. 
                obj.Arduino = arduino();
            else 
                % The user has specified which port the Arduino is on. 
                clear obj.SerialPort
                obj.Arduino = arduino(obj.SerialPort, obj.Board); 
            end
        end
        
        function delete(obj)
            %Defines a class destructor for the BIOCHEM valve.
            clear obj.Arduino % remove from workspace, close connection
        end
        
        function [Attributes, Data, Children] = exportState(obj) 
            % Exports the current state of the insrtument.
            Attributes.InstrumentName = obj.InstrumentName;
            Data=[];
            Children=[];
        end     
        
        gui(obj); 
        
        function powerSwitch12V(obj)
            %Power switch for the BIOCHEM flow selection valves (12V line)
            %
            % This function will check the most recently known state of the 
            % relay controlling the 12V line powering the BIOCHEM flow 
            % selection valves and then send the opposite signal.
            
            % Switch the 12V control relay from it's currently known state.
            % NOTES: 
            %   1) The relay controlling the 12V line is wired active LOW
            %      in the sense that the 12V line is accesible to the valve
            %      control relays when the Arduino sends a 0 to the 12V 
            %      line control relay. 
            %   2) This assumes that the 12V line is controlled by the 2nd
            %      relay, i.e. the relay controlled by IN2 on the relay
            %      module.  If this changes, modify definition of PowerPin.
            PowerPin = sprintf('D%i', obj.IN1Pin + 1); 
            writeDigitalPin(obj.Arduino, PowerPin, obj.PowerState12V); 
            
            % Update the CurrentState to reflect our switch.
            obj.PowerState12V = ~obj.PowerState12V; 
        end
        
        function powerSwitch24V(obj)
            %Power switch for the 24V line (this powers both the syringe
            %pump and the BIOCHEM valves after stepping down to 12V).
            %
            % This function will check the most recently known state of the 
            % relay controlling the 24V line and then send the opposite
            % signal.
            
            % Switch the 24V control relay from it's currently known state.
            % NOTES: 
            %   1) The relay controlling the 24V line is wired active LOW
            %      in the sense that the 24V line is live when the Arduino
            %      sends a 0 to the pin controlling the 24V line relay.
            PowerPin = sprintf('D%i', obj.IN1Pin); 
            writeDigitalPin(obj.Arduino, PowerPin, obj.PowerState24V); 
            
            % Update the CurrentState to reflect our switch.
            obj.PowerState24V = ~obj.PowerState24V; 
        end

        openValve(obj, ValveNumber);
        closeValve(obj, ValveNumber);
    end
    
    
    methods (Static)
        function funcTest(SerialPort)
            
            % funcTest - Performs a func test of the BiochemValve controller using the specified SerialPort.
            % INPUT: SerialPort (string) - The serial port to connect to the Arduino (e.g., 'COM3' on Windows).
            % This function will:
            % - Create a connection to the specified Arduino port
            % - Test opening and closing a sample valve
            % - Toggle power states as part of a functional check
            % - Output test results to the MATLAB Command Window
            % - Error handling is provided to catch any issues during execution, and the connection is properly closed by 
            %  clearing the Arduino object. You should replace 'D3' and 'D4' with the appropriate pins based on your hardware configuration.
            
            try
                % Establish connection to the Arduino
                disp(['Connecting to Arduino on port: ' SerialPort]);
                a = arduino(SerialPort, 'Uno'); % Change 'Uno' to your specific board model if needed
                disp('Connection established.'); 
                
                % Test toggling power states
                disp('Toggling 12V power state...');
                writeDigitalPin(a, 'D3', 1); % Example digital pin for demonstration
                pause(1);
                writeDigitalPin(a, 'D3', 0);
                disp('12V power state toggled successfully.');
                
                % Test valve control (open and close a valve)
                ValvePin = 'D4'; % Example valve control pin
                disp('Opening valve...');
                writeDigitalPin(a, ValvePin, 1); % Open valve
                pause(2); % Keep the valve open for 2 seconds
                disp('Closing valve...');
                writeDigitalPin(a, ValvePin, 0); % Close valve
                
                % Clean up and close connection
                clear a; % Clear the Arduino object to close the connection
                disp('Functional test completed successfully.');
                
            catch ME
                % Handle errors gracefully
                warning('An error occurred during the function test.');
                disp(['Error Message: ', ME.message]);
                if exist('a', 'var') % If Arduino object exists, clear it
                    clear a;
                end
            end
        end
        
    end
end
