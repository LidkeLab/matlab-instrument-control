classdef CavroSyringePump < mic.abstract
% mic.CavroSyringePump Class 
% 
% ## Description
% The `MIC_CavroSyringePump` class controls a Cavro syringe pump via USB, specifically designed for 
% pump PN 20740556 -D. This class may work with other Cavro brand syringe pumps but has only been tested with the 
% specified model. It can perform any operation described in the Cavro XP3000 operators manual (e.g. in Appendix G - Command Quick Reference). 
% 
% ## Installation Requirements
% - MATLAB R2014b or later (R2017a or later recommended)
% - Operating System: Windows (modifications required for UNIX systems, particularly in serial port behaviors)
% - Dependency: `mic.abstract.m`
% 
% ##  Functions: 
% delete, exportState, updateGui, gui, connectSyringePump,
% readAnswerBlock, executeCommand, reportCommand,
% querySyringePump, cleanAnswerBlock, decodeStatusByte, unitTest
% 
% ## Usage
% ```matlab
% % Create an instance of the Cavro syringe pump controller
% Pump = mic.CavroSyringePump();
% % Connect to the pump
% [Message, Status] = Pump.connectSyringePump();
% % Execute a command to move the plunger
% Pump.executeCommand('Move Plunger to 1000');
% % Check the pump's status
% Pump.querySyringePump();
% % Disconnect and cleanup
% delete(Pump);
% ```   
% ### CITATION: David Schodt, Lidke Lab, 2018

    properties
        DeviceAddress = 1; % ASCII address for device
        DeviceSearchTimeout = 10; % timeout(s) to search for a pump
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        SerialPort = 'COM3'; % default COM port
    end
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'CavroSyringePump'; % name of the instrument
        SyringePump; % serial object for the connected syringe pump
        PlungerPosition; % absolute plunger position (0-3000)
        ReadableAction; % activity of the pump/pump response to a report
        VelocitySlope; % ramping slope of plunger from StartVelocity->Top
        StartVelocity; % plunger starting velocity (half-steps/sec)
        TopVelocity; % max plunger velocity (half-steps/sec)
        CutoffVelocity; % plunger stop velocity (half-steps/sec)
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
        function obj = CavroSyringePump()
            %Constructor for the Cavro syringe pump object.
                       
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@mic.abstract(~nargout);
            
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
