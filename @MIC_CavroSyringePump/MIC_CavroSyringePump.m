classdef MIC_CavroSyringePump < MIC_Abstract
    % MIC class for control of the Cavro syringe pump PN 20740556 -D. 
    %
    % MATLAB R2017a or newer recommended. 
    %
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'CavroSyringePump';
        StatusByte = 64; % see XP3000 manual p. 3-46, default busy no error
        SyringePump; % serial object for the connected syringe pump
    end
    
    
    properties % (Access = protected) % would I want this???
        StartGUI;
    end
    
    
    properties
        DeviceAddress = 1; % ASCII address for device
        DeviceSearchTimeout = 10; % timeout(s) to search for a pump
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        SerialPort = 'COM3'; % default COM port for syringe pump
    end
    
    
    methods
        function delete(obj)
            %Defines a class destructor
            fclose(obj.SyringePump); % close serial connection
            delete(obj.SyringePump); % delete from memory
            clear obj.SyringePump % remove from workspace
        end
        
        exportState(obj); 
        gui(obj); 
        
        [ASCIIMessage, ReadableMessage] = connectSyringePump(obj);
        [ASCIIMessage, DataBlock] = readAnswerBlock(obj);
        executeCommand(obj, Command); 
        querySyringePump(obj);
        [DataBlock] = reportCommand(obj, Command);
        
        function obj = set.StatusByte(obj, StatusByte)
            %Displays a message to the MATLAB Command Window whenever the 
            %StatusByte is changed. 
            
            % If the StatusByte has not changed, we don't need to do
            % anything here so return to the calling function/method.
            % NOTE: obj.StatusByte is the previously set value, StatusByte
            % is what the calling function/method was trying to set
            % obj.StatusByte to.
            if StatusByte == obj.StatusByte
                return
            end
            
            % Update obj.StatusByte to the new value.
            obj.StatusByte = StatusByte;
            
            % Decode the StatusByte returned by the syringe pump.
            [PumpStatus, ErrorString] = obj.decodeStatusByte(StatusByte);
            
            % Display a message to summarize StatusByte in the Command
            % Window.
            fprintf('Syringe Pump Status: %s, %s \n', PumpStatus, ...
                ErrorString);
        end
    end
    
    
    methods (Static)
        [ASCIIMessage, IsValid] = cleanAnswerBlock(RawASCIIMessage);
        [PumpStatus, ErrorString] = decodeStatusByte(StatusByte);
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end