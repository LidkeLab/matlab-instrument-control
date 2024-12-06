classdef NDFilterWheel < mic.abstract
    %  mic.NDFilterWheel: Matlab Instrument Control for servo operated Filter wheel containing Neutral Density filters
    %
    %  ## Description
    % Filter wheel should be controlled by Dynamixel Servos. See "Z:\Lab 
    %  General Info and Documents\TIRF Microscope\Build Instructions for 
    %  Filter Wheel Setup.doc"
    %  This class works with an arbitrary number of filters
    %  To create a mic.NDFilterWheel object the position and transmittance
    %  of each filter must be specified. The position must be given in
    %  degrees rotation corresponding to the input of the servo. This
    %  can be calibrated by setting the servo rotation such that the
    %  specific filter is in the optical path. The Rotation property of the
    %  servo gives the right position value for that filter.
    %
    % ## Class Properties
    %
    % ### Protected Properties
    % - **`InstrumentName`**:
    %   - **Description**: Descriptive name of the instrument.
    %   - **Type**: String
    %   - **Default**: `'NDFilterWheel'`
    %
    % - **`Servo`**:
    %   - **Description**: Servo object responsible for rotating the filter wheel.
    %   - **Type**: Object
    %
    % - **`FilterPos`**:
    %   - **Description**: Array representing the rotation angles (in degrees) of the servo corresponding to filter positions.
    %   - **Type**: Numeric Array
    %
    % - **`TransmissionValues`**:
    %   - **Description**: Array containing fractional transmission values (0 to 1) for each filter position.
    %   - **Type**: Numeric Array
    %
    % ### Dependent Properties
    % - **`CurrentFilter`**:
    %   - **Description**: Represents the current filter number in use.
    %   - **Type**: Numeric
    %   - **Access**: Dependent (computed based on other properties)
    %
    % - **`CurrentTransmittance`**:
    %   - **Description**: Fractional transmittance value (0 to 1) of the currently selected filter.
    %   - **Type**: Numeric
    %   - **Access**: Dependent (computed based on `CurrentFilter` and `TransmissionValues`)
    %
    % ### Hidden Properties
    % - **`StartGUI`**:
    %   - **Description**: Flag indicating whether the GUI should start when an object of the class is created.
    %   - **Type**: Boolean
    %   - **Default**: `0`
    %
    % ## Usage Example
    %  Example: obj=mic.NDFilterWheel(ServoId,FracTransmVals,FilterPos);
    %          ServoId: Id of servo, is written on servo
    %          FracTransmVals: N-element array of Fractional Transmittance
    %                   Values for N filters in wheel, order (linear index)
    %                    should correspond to order in FilterPos input
    %          FilterPos: N-element array of Rotation (degrees) of servo 
    %                   corresponding to filter positions, order (linear
    %                   index should correspond to order in FracTransmVals
    %  Example for 6 filters:
    %  FWobj = mic.NDFilterWheel(1, [1 0.8 0.6 0.4 0.2 0], [0 60 120 180 240 300])
    %
    %  ## Key Functions: 
    % setFilter, exportState, setTransmittance get.CurrentFilter, get.CurrentTransmittance
    %
    %  ## REQUIRES
    %   Matlab 2014b or higer
    %   mic.abstract.m
    %   mic.DynamixelServo.m
    %
    % ### CITATION: Marjolein Meddens, Lidke Lab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName = 'NDFilterWheel';
        Servo;
        FilterPos; % Rotation (degrees) of servo corresponding to filter positions
        TransmissionValues; % Fractional transmissions of filters
    end
    
    properties (SetAccess=protected, Dependent)
        CurrentFilter; % Current filter number
        CurrentTransmittance; % Transmittance (0-1) of current filter
    end
    
    properties (Hidden)
        StartGUI = 0; % Flag for starting GUI when object of class is created
    end
    
    methods
        function obj=NDFilterWheel(ServoId, FracTransmVals, FilterPos)
            % Object constructor
            
            % pass AutoName input into base classes
            obj = obj@mic.abstract(~nargout);
            
            % check input
            if nargin <3
                error('mic.NDFilterWheel:narginlow','Not enough input arguments, 3 inputs required');
            elseif nargin >3
                error('mic.NDFilterWheel:narginhigh','Too many input arguments, 3 inputs required');
            end
            if ServoId < 1 || ServoId > 255
                error('mic.NDFilterWheel:id','Invalid servo id');
            end
            if numel(FracTransmVals) ~= numel(FilterPos)
                error('mic.NDFilterWheel:InputSizes','FracTransmVals and FilterPos inputs should have the same number of elements');
            elseif ~isnumeric(FracTransmVals)
                error('mic.NDFilterWheel:FracTransmValsType','Invalid type of FracTransmVals input, must be numeric');
            elseif any(FracTransmVals<0) || any(FracTransmVals>1)
                error('mic.NDFilterWheel:FracTransmValsVal','Invalid value(s) in FracTransmVals input, must be between 0 and 1');
            end
            
            % Initialize Servo
            obj.Servo = mic.DynamixelServo(ServoId);
            obj.Servo.MovingSpeed = 1023;
            
            % check input
            if any(FilterPos<0) || any(FilterPos>obj.Servo.MAX_ROTATION)
                error('mic.NDFilterWheel:FilterPosInput','Invalid FilterPos input, values must be between 0 and %i',obj.Servo.MAX_ROTATION);
            end
            
            % initialize properties
            obj.TransmissionValues = FracTransmVals(:);
            obj.FilterPos = FilterPos(:);
            
            % move to first position
            obj.setFilter(1);
        end
        
        function setFilter(obj,FNum)
            % Sets filter to FNum
            % INPUT
            %   FNum - number of filter to switch to
            
            % check input
            if ~round(FNum)==(FNum) || FNum>numel(obj.FilterPos)
                error('mic.NDFilterWheel:FilterNumInput',...
                    'Invalid input, FilterNum should be an integer between 1 and %i, corresponding to a filter position',numel(obj.FilterPos));
            end
            % move filter
            obj.Servo.Rotation = obj.FilterPos(FNum);
            while obj.Servo.Moving
            end
            obj.updateGui();
        end
        
        function setTransmittance(obj,Transm)
            % Sets filter based on transmittance
            % INPUT
            %   Transm - transmittance of filter to switch to
            
            % check input
            if ~any(obj.TransmissionValues==Transm)
                transValStringArray = string(obj.TransmissionValues);
                for ii = 1 : numel(transValStringArray)-1
                    transValStringArray(ii) = [transValStringArray{ii} ','];
                end
                transValString = strcat(transValStringArray{:});
                error('mic.NDFilterWheel:TransmittanceInput',...
                    ['Invalid input, Transmittance should be the same as one of the installed filters, ',...
                'currently these filters are intstalled: %s'],transValString);
            end
            % move filter
            obj.Servo.Rotation = obj.FilterPos(obj.TransmissionValues==Transm);
            while obj.Servo.Moving
            end
            obj.updateGui();
        end        
        
        function updateGui(obj)
            % find button group
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            for ii = 1 : numel(obj.GuiFigure.Children)
                if strcmp(obj.GuiFigure.Children(ii).Tag,'buttonGroup')
                    % set the selected filter to the current filter
                    tagCellStr = {obj.GuiFigure.Children(ii).Children.Tag};
                    tagCellNum = cellfun(@(x) str2double(x),tagCellStr,'UniformOutput',false);
                    tagNum = cell2mat(tagCellNum);
                    obj.GuiFigure.Children(ii).SelectedObject = obj.GuiFigure.Children(ii).Children(tagNum == obj.CurrentFilter);
                end
            end
        end
        
        function value = get.CurrentFilter(obj)
            % Gets current filter information
            value = find(obj.FilterPos==round(obj.Servo.Rotation));
        end
        
        function value = get.CurrentTransmittance(obj)
            % Gets current transmittance information
            value = obj.TransmissionValues(obj.FilterPos==round(obj.Servo.Rotation));
        end
        
        function [Attributes,Data,Children] = exportState(obj)
            % Exports current state of mic.NDFilterWheel object
            Attributes.InstrumentName = obj.InstrumentName;
            Attributes.CurrentFilter = obj.CurrentFilter;
            Attributes.CurrentTransmittance = obj.CurrentTransmittance;
            Attributes.FilterPos = obj.FilterPos;
            Attributes.TransmissionValues = obj.TransmissionValues;
            Attributes.ServoState = obj.Servo.exportState;
            Data=[];
            Children = [];            
        end
    end
    
    methods(Static)
        function State = funcTest(ServoId,FracTransmVals,FilterPos)
            % mic.NDFilterWheel.funcTest(ServoId,FracTransmVals,FilterPos)
            % performs test of all mic.NDFilterWheel functionality
            %
            % INPUT (required)
            %  ServoId - Id of servo, is written on servo 
            % INPUT (optional)
            %  FracTransmVals - N-element array of Fractional Transmittance
            %                   Values for N filters in wheel, order (linear index) should
            %                   correspond to order in FilterPos input 
            %                   if empty, 6 random ND filters are assumed
            %  FilterPos - N-element array of Rotation (degrees) of servo 
            %              corresponding to filter positions, order (linear
            %              index should correspond to order in
            %              FracTransmVals
            %              if empty, 6 filter positions are assumed
            
            fprintf('\nTesting mic.NDFilterWheel class...\n')
            % Check input
            if ~exist('FracTransmVals','var') || isempty(FracTransmVals)
                FracTransmVals = [1 0.9 0.6 0.3 0.1 0];
            end
            if ~exist('FilterPos','var') || isempty(FilterPos)
                FilterPos = [0 60 120 180 240 300];
            end
            % constructing and deleting instances of the class
            FWobj = mic.NDFilterWheel(ServoId,FracTransmVals,FilterPos);
            delete(FWobj);
            clear FWobj;
            FWobj = mic.NDFilterWheel(ServoId,FracTransmVals,FilterPos);
            fprintf('* Construction and Destruction of object works\n')
            % loading and closing gui
            GUIfig = FWobj.gui;
            close(GUIfig);
            FWobj.gui;
            fprintf('* Opening and closing of GUI works, please test GUI manually\n');
            % Change filter
            fprintf('* Do you hear/see the filter wheel move?\n')
            FWobj.setFilter(6);
            FWobj.setFilter(1);
            fprintf('  If you saw/heard that, changing the filter works works\n');
            % export state
            State = FWobj.exportState;
            fprintf('* Export of current state works, please check workspace for it\n')
            fprintf('Finished testing mic.NDFilterWheel class\n');
        end
    end
end
