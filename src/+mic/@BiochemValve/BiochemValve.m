classdef MIC_BiochemValve < MIC_Abstract
%  MIC_BiochemValve Class 
%
% ## Description
% The `MIC_BiochemValve` class manages BIOCHEM flow selection valves through communication with an Arduino. 
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
% - `MIC_Abstract.m` 
% 
% ## Key Functions
% - **delete()**: Deletes the object and closes connection to Arduino.
% - **exportState()**: Exports the current state of the instrument.
% - **gui()**: Launches a graphical user interface for the valve controller.
% - **powerSwitch12V()**: Toggles power on the 12V line controlling the valves.
% - **powerSwitch24V()**: Toggles power on the 24V line that powers both the syringe pump and the BIOCHEM valves after stepping down to 12V.
% - **openValve(ValveNumber)**: Opens the specified valve.
% - **closeValve(ValveNumber)**: Closes the specified valve.
% - **unitTest(SerialPort)**: Performs a unit test of the valve controller on a specified serial port.
% 
% ## Usage
% ```matlab
% % Creating an instance of the valve controller
% Valves = MIC_BiochemValve();
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
        function obj = MIC_BiochemValve()
            %Constructor for the BIOCHEM valve object.
            
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@MIC_Abstract(~nargout);
            
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
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end