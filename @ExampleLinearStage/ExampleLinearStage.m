classdef ExampleLinearStage < MIC_LinearStage_Abstract
    % This class is an example implementation of MIC_LinearStage_Abstract.
    % This class simulates a linear stage that can move along one axis.
    
    % REQUIRES: 
    % MIC_LinearStage_Abstract.m
    %
    % CITATION: Sajjad Khan, Lidkelab, 2024.

    properties (SetAccess = protected)
        InstrumentName = 'Simulated Linear Stage'; % Name of the instrument
        PositionUnit = 'mm';                      % Units of position parameter (e.g., mm)
        CurrentPosition = 0;                      % Current position of the device
        MinPosition = 0;                          % Lower limit position 
        MaxPosition = 100;                        % Upper limit position
        Axis = 'X';                               % Stage axis (X, Y, or Z)
    end
    
    properties (Hidden)
        StartGUI = false;                         % GUI does not start automatically
    end
    
    methods
        function obj = ExampleLinearStage()
            % Call superclass constructor
            obj = obj@MIC_LinearStage_Abstract(~nargout);
        end
        
        function setPosition(obj, position)
            % Sets the position of the stage to the specified position
            % position must be within the bounds [MinPosition, MaxPosition]
            if position < obj.MinPosition || position > obj.MaxPosition
                error('Position out of bounds');
            end
            obj.CurrentPosition = position;
            disp(['Position set to ', num2str(obj.CurrentPosition), ' ', obj.PositionUnit]);
            obj.updateGui();
        end
        
        function pos = getPosition(obj)
            % Returns the current position of the stage
            pos = obj.CurrentPosition;
            disp(['Current Position: ', num2str(pos), ' ', obj.PositionUnit]);
        end

        function gui(obj)
            % Creates and manages a GUI for controlling the linear stage
            if ~isempty(obj.GuiFigure) && isvalid(obj.GuiFigure)
                figure(obj.GuiFigure);
                return;
            end
            
            obj.GuiFigure = figure('Name', [obj.InstrumentName ' Control'], ...
                                   'NumberTitle', 'off', ...
                                   'MenuBar', 'none', ...
                                   'ToolBar', 'none', ...
                                   'HandleVisibility', 'on', ...
                                   'Position', [300, 300, 400, 200], ...
                                   'CloseRequestFcn', @obj.closeGui);

            % Slider for position control
            slider = uicontrol('Parent', obj.GuiFigure, ...
                               'Style', 'slider', ...
                               'Units', 'normalized', ...
                               'Position', [0.1, 0.5, 0.8, 0.1], ...
                               'Value', obj.CurrentPosition, ...
                               'Min', obj.MinPosition, ...
                               'Max', obj.MaxPosition, ...
                               'SliderStep', [0.01, 0.1], ...
                               'Callback', @(src, evt) obj.sliderCallback(src, evt));
            
            % Text display for current position
            uicontrol('Parent', obj.GuiFigure, ...
                      'Style', 'text', ...
                      'Units', 'normalized', ...
                      'Position', [0.1, 0.7, 0.8, 0.1], ...
                      'String', ['Position: ' num2str(obj.CurrentPosition) ' ' obj.PositionUnit]);
        end
        
        function sliderCallback(obj, src, ~)
            % Callback function for the slider
            newPosition = get(src, 'Value');
            obj.setPosition(newPosition);
        end
        
        function updateGui(obj)
            % Update GUI with the current position
            if ~isempty(obj.GuiFigure) && isvalid(obj.GuiFigure)
                sliderHandle = findobj(obj.GuiFigure, 'Style', 'slider');
                textHandle = findobj(obj.GuiFigure, 'Style', 'text');
                set(sliderHandle, 'Value', obj.CurrentPosition);
                set(textHandle, 'String', ['Position: ' num2str(obj.CurrentPosition) ' ' obj.PositionUnit]);
            end
        end
        
        function closeGui(obj, src, ~)
            % Close request function for the GUI
            delete(src);
            obj.GuiFigure = [];
        end

        function [Attributes, Data, Children] = exportState(obj)
            % Exports relevant properties for saving state
            Attributes = struct('PositionUnit', obj.PositionUnit, ...
                                'CurrentPosition', obj.CurrentPosition, ...
                                'MinPosition', obj.MinPosition, ...
                                'MaxPosition', obj.MaxPosition, ...
                                'Axis', obj.Axis);
            Data = struct();
            Children = struct();
        end
    end
    
        methods (Static=true)
        function Success = unitTest()
            % Method to test the functionality of the class
            % Here you would typically test each method to ensure they
            % work properly
            obj = ExampleLinearStage();
            obj.center();
            obj.setPosition([15]);
            Success = true; % Assume success for simplicity
            delete(obj); % Clean up object
        end
    end

  
end
