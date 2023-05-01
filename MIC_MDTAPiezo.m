classdef MIC_MDTAPiezo < MIC_LinearStage_Abstract
    % MIC_MDTAPiezo Matlab Instrument Control Class for ThorLabs MDT69XA Piezo

    properties(SetAccess=protected)
        CurrentPosition; % unit is voltage
        MinPosition = 0;
        MaxPosition = 75;
        OffsetPosition = 0;
        PositionUnit = 'Voltage';
        Axis = 'X';
        DevInfo;
        SerialObj;
       
        InstrumentName = 'MDT69XA_Piezo'
    end
    
    properties
         WaitTime = 0.1; % unit is second
    end

    properties (Hidden)
        StartGUI;
    end

    methods
        function obj = MIC_MDTAPiezo(PortName)
            obj = obj@MIC_LinearStage_Abstract(~nargout);
            obj.SerialObj = serialport(PortName,115200);
            obj.SerialObj.configureTerminator("CR/LF")
            obj.DevInfo = obj.writeread("I");
            disp(obj.DevInfo)
%             resp = obj.writeread('XV0');
%             resp = obj.writeread("XR?");
%             st = strfind(resp,'[')+1;
%             ed = strfind(resp,']')-1;
%            obj.OffsetPosition = str2double(resp(st:ed));

        end

        function Position = getPosition(obj)
            waitTime = obj.WaitTime;
            obj.WaitTime = 0.1;
            resp = obj.writeread("XR?");
            st = strfind(resp,'[')+1;
            ed = strfind(resp,']')-1;
            Position = str2double(resp(st:ed));
            obj.CurrentPosition = Position;
            obj.WaitTime = waitTime;
        end
        

        function setPosition(obj,Position)
            Position = Position-obj.OffsetPosition;
            if Position < obj.MinPosition || Position > obj.MaxPosition
                disp(['MIC_MDTAPiezo:posInput','Invalid Position, must be between ',num2str(obj.MinPosition),' and ',num2str(obj.MaxPosition)])
                %error('MIC_MDTAPiezo:posInput','Invalid Position, must be between %i and %i',obj.MinPosition, obj.MaxPosition);
            else
                
                % move stage
                resp = obj.writeread(['XV',num2str(Position)]);
                if strcmp(resp,'! ')
                    disp(['MIC_MDTAPiezo:stageMove','stage move error'])
                end
                obj.updateGui
            end

        end
        
        
        function State=exportState(obj) %here you can add whatever you want to save along with the data
            State.InstrumentName=obj.InstrumentName;
            State.PositionUnit=obj.PositionUnit;
            State.CurrentPosition=obj.CurrentPosition;
            State.MinPosition=obj.MinPosition;
            State.MaxPosition=obj.MaxPosition;
            State.Axis=obj.Axis;
        end   
        
        function delete(obj)
            
            obj.SerialObj.delete();
            obj.SerialObj = [];
        end

        function resp = writeread(obj, command)
            obj.SerialObj.writeline(command)
            pause(obj.WaitTime)
            if obj.WaitTime>=0.1
                resp = obj.SerialObj.read(obj.SerialObj.NumBytesAvailable,"char"); 
            else
                resp = '* ';
            end
        end
    end

    methods (Static)
        function state=unitTest(PortName)  
            % tests all functionality of MIC_Example_LinearStage
            
            fprintf('Testing MIC_MDTAPiezo class...\n');
            % create and delete object
            ELS = MIC_MDTAPiezo(PortName);
            ELS.delete()
            clear ELS
            ELS = MIC_MDTAPiezo(PortName);
            fprintf('Creating and deleting of object successful\n');
            % move stage
            ELS.setPosition(ELS.MinPosition);
            ELS.setPosition(ELS.MaxPosition);
            fprintf('Moving stage to min and max positions successful\n');
            % export state
            state = ELS.exportState();
            disp(state);
            fprintf('Test of MIC_Example_LinearStage successful\n');
        end
        
    end

end