classdef MIC_CavroSyringePump < MIC_Abstract
    % MIC class for control of the Cavro syringe pump PN 20740556 -D. 
    %
    % This class is used to control a Cavro syringe pump via USB.  This
    % class may work for a wide range of Cavro brand syringe pumps, however
    % it has only been tested for pump PN 20740556 -D .  It can perform any
    % syringe pump operation described in the Cavro XP3000 operators manual
    % (e.g. in Appendix G - Command Quick Reference). 
    %
    % Example: Pump = MIC_CavroSyringePump();
    % Functions: delete, exportState, updateGui, gui, connectSyringePump,
    %            readAnswerBlock, executeCommand, reportCommand,
    %            querySyringePump, cleanAnswerBlock, decodeStatusByte,
    %            unitTest
    %
    % REQUIREMENTS:
    %   Windows operating system (should work with unix systems with
    %       modifications only to serial port behaviors)
    %   MATLAB 2014b or later required.
    %   MATLAB R2017a or later recommended. 
    %   MIC_Abstract.m
    %
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties
        DeviceAddress = 1; % ASCII address for device
        DeviceSearchTimeout = 10; % timeout(s) to search for a pump
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        SerialPort = 'COM3'; % default COM port
        VelocitySlope; % ramping slope of plunger from StartVelocity->Top
        StartVelocity; % plunger starting velocity (half-steps/sec)
        TopVelocity; % max plunger velocity (half-steps/sec)
        CutoffVelocity; % plunger stop velocity (half-steps/sec)
    end
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'CavroSyringePump'; % name of the instrument
        SyringePump; % serial object for the connected syringe pump
        PlungerPosition; % absolute plunger position (0-3000)
        ReadableAction; % activity of the pump/pump response to a report
    end
    
    
    properties (SetObservable)
        StatusByte = 0; % status of the pump, 0 if not connected
    end
    
    
    properties (Hidden)
        MatlabRelease; % version of MATLAB that is using this class
        StartGUI = false;
    end
    
    
    properties (Dependent) % determined on demand
        ReadableStatus; % user readable status of the syringe pump
    end
       
    
    methods
        function obj = MIC_CavroSyringePump()
            %Constructor for the Cavro syringe pump object.
                       
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@MIC_Abstract(~nargout);
            
            % Set property listener(s). 
            addlistener(obj, 'StatusByte', 'PostSet', ...
                @obj.statusByteChange);
            
            % Determine the current version of MATLAB in use.
            obj.MatlabRelease = version('-release');
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
        
        gui(obj);
        updateGui(obj);
        
        [ASCIIMessage, ReadableMessage] = connectSyringePump(obj);
        [ASCIIMessage, DataBlock] = readAnswerBlock(obj);
        executeCommand(obj, Command); 
        querySyringePump(obj);
        [DataBlock] = reportCommand(obj, Command);
        [DataBlock] = generalCommand(obj, Command); 

        function ReadableStatus = get.ReadableStatus(obj)
            %Produces a readable status of the syringe pump upon request.
            %NOTE: obj.ReadableStatus is a Dependent property.
            
            % Decode the StatusByte returned by the syringe pump.
            [PumpStatus, ErrorString] = ...
                obj.decodeStatusByte(obj.StatusByte);
            
            % Store a message summarizing PumpStatus and ErrorString.
            ReadableStatus = sprintf('Syringe Pump Status: %s, %s', ...
                PumpStatus, ErrorString);
        end
        
        function waitForReadyStatus(obj)
            %Does not return control to calling function until the syringe
            %pump is ready to accept new commands.

            % Query the syringe pump until it returns the 'Ready' status.
            QueryNumber = 1; 
            while (obj.StatusByte < 96) || (QueryNumber == 1)
                % If obj.StatusByte < 96, the syringe pump is busy and we 
                % should query the device.  The OR condition ensures that 
                % at least one query is performed before exiting this 
                % method call. 
                obj.querySyringePump; % updates obj.PumpStatus internally
                QueryNumber = QueryNumber + 1; 
            end
        end
        
        function statusByteChange(obj, ~, ~)
            % Callback function to execute upon a post-set event of the
            % obj.StatusByte property

            % Decode the new value of obj.StatusByte
            [PumpStatus, ErrorString] = ...
                obj.decodeStatusByte(obj.StatusByte);
            
            % If the pump is ready to accept commands, clear
            % obj.ReadableAction to indicate the pump is no longer active.
            if obj.StatusByte >= 96
                obj.ReadableAction = ''; 
            end
            
            % Display a message to summarize StatusByte in the Command
            % Window.  If a GUI exists, update the GUI instead.
            if isprop(obj, 'GuiFigure')
                % A GUI exists for the current instance of the class.
                obj.updateGui; % updates the GUI
            else
                fprintf('Syringe Pump Status: %s, %s \n', PumpStatus, ...
                    ErrorString);
                disp(obj.ReadableAction)
                fprintf('_______________________________________________');
            end
        end
    end
    
    
    methods (Static)
        [ASCIIMessage, IsValid] = cleanAnswerBlock(RawASCIIMessage);
        [PumpStatus, ErrorString] = decodeStatusByte(StatusByte);
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end