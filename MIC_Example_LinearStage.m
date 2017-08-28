classdef MIC_Example_LinearStage < MIC_LinearStage_Abstract 
    %MIC_Example_LinearStage Creates a dummy stage to test MIC_LinearStage_Abstract
    %   The virtual stage will display all moves on the command line
    
    % Marjolein Meddens, Lidke Lab 2017
    
    properties (SetAccess=protected)  
        InstrumentName = 'ExampleLinearStage' % Descriptive name 
    end
    
    properties (SetAccess=protected)
        PositionUnit='um';     % Units of position parameter (eg. um/mm)
        CurrentPosition;       % Current position of device
        MinPosition=0;         % Lower limit position 
        MaxPosition=20;        % Upper limit position
        Axis='X';              % Stage axis (X, Y or Z)
    end
    
    properties (Hidden)
        StartGUI = true();
    end
    
    methods        
        function obj = MIC_Example_LinearStage() 
            %MIC_Example_LinearStage() creates example linear stage object
            % The virtual stage will display all moves on the command line
            % No input required
            
            % AutoName
            obj = obj@MIC_LinearStage_Abstract(~nargout); 
            obj.center();
        end
        
        function setPosition(obj,Position)
            % check input
            if Position < obj.MinPosition || Position > obj.MaxPosition
                error('MIC_Example_LinearState:posInput','Invalid Position, must be between %i and %i',obj.MinPosition, obj.MaxPosition);
            end
            % move stage
            fprintf('Stage moves to %i %s\n',Position,obj.PositionUnit);
            obj.CurrentPosition = Position;
            obj.updateGui;
        end
        
        function Position = getPosition(obj)
            % get position by querying the stage
            if isempty(obj.CurrentPosition)
                obj.CurrentPosition = (obj.MaxPosition-obj.MinPosition)/2;
            end
            Position = obj.CurrentPosition;
        end

        function State=exportState(obj) %here you can add whatever you want to save along with the data
            State.InstrumentName=obj.InstrumentName;
            State.PositionUnit=obj.PositionUnit;
            State.CurrentPosition=obj.CurrentPosition;
            State.MinPosition=obj.MinPosition;
            State.MaxPosition=obj.MaxPosition;
            State.Axis=obj.Axis;
        end        
               
    end
    
    methods (Static)
        function state=unitTest()  
            % tests all functionality of MIC_Example_LinearStage
            
            fprintf('Testing MIC_Example_LinearStage class...\n');
            % create and delete object
            ELS = MIC_Example_LinearStage();
            ELS.delete()
            clear ELS
            ELS = MIC_Example_LinearStage();
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

