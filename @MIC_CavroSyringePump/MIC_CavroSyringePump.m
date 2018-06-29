classdef MIC_CavroSyringePump < MIC_Abstract
    % MIC class for control of the Cavro syringe pump PN 20740556 -D. 
    %
    % MATLAB 2014b or later required.
    % MATLAB R2017a or later recommended. 
    %
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'CavroSyringePump';
        StatusByte = 64; % see XP3000 manual p. 3-46, default busy no error
        SyringePump; % serial object for the connected syringe pump
    end
    
    
    properties (Hidden)
        StartGUI = false;
    end
    
    
    properties (Dependent) % determined on demand
        ReadableStatus; % user readable status of the syringe pump
    end
    
    
    properties
        DeviceAddress = 1; % ASCII address for device
        DeviceSearchTimeout = 10; % timeout(s) to search for a pump
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        SerialPort = 'COM3'; % default COM port
    end
    
  
    methods
        function obj = MIC_CavroSyringePump()
            %Constructor for the Cavro syringe pump object.
                       
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@MIC_Abstract(~nargout);
        end
        
        function delete(obj)
            %Defines a class destructor for the syringe pump.
            
            % If the serial object obj.SyringePump exists (i.e. a syringe
            % pump had been connected to), close the connection to it and
            % clean up.
            if ~isempty(obj.SyringePump)
                fclose(obj.SyringePump); % close serial connection
                delete(obj.SyringePump); % delete from memory
                clear obj.SyringePump % remove from workspace
            end
        end
        
        function [Attributes, Data, Children] = exportState(obj) 
            % Exports the current state of the insrtument.
            Attributes.InstrumentName = obj.InstrumentName;
            Data=[];
            Children=[];
        end
        
        function updateGui(obj)
            % Update the GUI with the current parameters (if one exists).
            
            % Check to see if a GUI exists.
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            
            % Search for GUI objects to be updated and update them.
            for ii = 1:numel(obj.GuiFigure.Children)
                % Loop through each object within the GUI.
                if strcmpi(obj.GuiFigure.Children(ii).Tag, 'StatusText')
                    % This is the textbox displaying the pumps status,
                    % update the status.
                    obj.GuiFigure.Children(ii).String = obj.ReadableStatus;
                    drawnow % ensure the text updates immediately
                end
            end
         end
        
        gui(obj); 
        
        [ASCIIMessage, ReadableMessage] = connectSyringePump(obj);
        [ASCIIMessage, DataBlock] = readAnswerBlock(obj);
        executeCommand(obj, Command); 
        querySyringePump(obj);
        [DataBlock] = reportCommand(obj, Command);
        
        function ReadableStatus = get.ReadableStatus(obj)
            %Produces a readable status of the syringe pump upon request.
            %NOTE: obj.ReadableStatus is a Dependent property.
            
            % Decode the StatusByte returned by the syringe pump.
            [PumpStatus, ErrorString] = ...
                obj.decodeStatusByte(obj.StatusByte);
            
            % Store a message summaring PumpStatus and ErrorString.
            ReadableStatus = sprintf('Syringe Pump Status: %s, %s \n', ...
                PumpStatus, ErrorString);
        end
        
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
            % Window.  If a GUI exists, update the GUI instead.
            if isprop(obj, 'GuiFigure')
                % A GUI exists for the current instance of the class.
                obj.updateGui; % updates the GUI
            else
                fprintf('Syringe Pump Status: %s, %s \n', PumpStatus, ...
                    ErrorString);
            end
        end
    end
    
    
    methods (Static)
        [ASCIIMessage, IsValid] = cleanAnswerBlock(RawASCIIMessage);
        [PumpStatus, ErrorString] = decodeStatusByte(StatusByte);
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end