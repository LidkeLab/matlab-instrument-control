classdef MIC_BiochemValve < MIC_Abstract
    % Class used for control of the BIOCHEM flow selection valves.
    %
    % This class controls (indirectly) the BIOCHEM flow selection valves
    % via communication with an Arduino.  It can open and close specific
    % valves as well as cut power to both the valves and the syringe pump
    % (this functionality is given here as an emergency shutoff, the
    % shutting down of the syringe pump is just a side effect of the
    % emergency shutdown to the valves). 
    %
    % Example: Valves = MIC_BiochemValve();
    % Functions: delete, exportState, gui, powerSwitch12V, powerSwitch24V, 
    %            openValve, closeValve, unitTest
    %
    % REQUIREMENTS: 
    %   MATLAB R2014b or later.
    %   MATLAB Support Package for Arduino Hardware installed
    %       NOTE: You may need to setup the Arduino you are using
    %       specifically even if this package was installed previously.
    %       Matlab needs to upload software onto the Arduino before
    %       creation of an instance of this class. 
    %   MIC_Abstract.m
    % 
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
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