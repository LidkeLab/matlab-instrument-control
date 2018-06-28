classdef MIC_BiochemValve < MIC_Abstract
    % Testing class for control of the Cavro syringe pump PN 20740556 -D. 
    % Eventually needs to be modified to adhere to standards in the
    % matlab-instrument-control (MIC) superclass. 
    %
    % REQUIREMENTS: 
    %   MATLAB R2014b or newer recommended. 
    %   MATLAB Support Package for Arduino Hardware installed
    %       NOTE: You may need to setup the Arduino you are using
    %       specifically even if this package was installed previously.
    %       Matlab needs to upload software onto the Arduino before
    %       creation of an instance of this class. 
    % 
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'BiochemValve';
        Arduino; % serial object for the connected syringe pump
    end
    
    
    properties (Hidden)
        StartGUI = false;
    end
    
    
    properties
        CurrentState = 1; % 1 if 12V connected to valves, 0 otherwise
        DeviceSearchTimeout = 10; % timeout(s) to search for USB device
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        IN1Pin = 2; % Arduino digital pin number connected to relay IN1
        SerialPort; % serial port for the Arduino (if needed)
        Board = 'Uno'; % name of Arduino board (if needed)
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
        
        function valvePowerSwitch(obj)
            %Power switch for the BIOCHEM flow selection valves.
            %
            % This function will check the most recently known state of the 
            % relay controlling the 12V line powering the BIOCHEM flow 
            % selection valves and then send the opposite signal.
            
            % Switch the 12V control relay from it's currently known state.
            % NOTES: 
            %   1) The relay controlling the 12V line is wired active HIGH
            %      in the sense that the 12V line is accesible to the valve
            %      control relays when the Arduino sends a 1 (5V) to the 
            %      12V line control relay. 
            %   2) This assumes that the 12V line is controlled by the 2nd
            %      relay, i.e. the relay controlled by IN2 on the relay
            %      module.  If this changes, modify definition of PinName.
            PinName = sprintf('D%i', obj.IN1Pin + 1); 
            writeDigitalPin(obj.Arduino, PinName, ~obj.CurrentState); 
            
            % Update the CurrentState to reflect our switch.
            obj.CurrentState = ~obj.CurrentState; 
        end

        openValve(obj, ValveNumber); 
        closeValve(obj, ValveNumber); 
    end
    
    
    methods (Static)
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end