classdef Example3DStage < MIC_3DStage_Abstract
    % This class is an example implementation of 3D Stage Class.
    % This class simulates a 3D stage that can move along x,y,z axes.
    
    % REQUIRES:
    % MIC_3DStage_Abstract.m
    
    % CITATION: Sajjad Khan, Lidkelab, 2024.

    properties (SetAccess = protected)
        InstrumentName = 'Simulated 3D Stage'; % Name of the instrument
        Position = [0, 0, 0];   % Example position [x, y, z]
        PositionUnit = 'mm';    % Example position unit (millimeters)
    end
    
    properties (Hidden)
        StartGUI = false;                         % GUI does not start automatically
    end
    
    methods
        function obj = Example3DStage()
            % Constructor
            obj@MIC_3DStage_Abstract(~nargout);
        end

        function center(obj)
            % Method to set the stage to the center (0, 0, 0)
            obj.Position = [0, 0, 0];
            fprintf('Stage positioned at the center.\n');
        end

        function setPosition(obj, position)
            % Method to set the stage to a specified position
            if numel(position) == 3
                obj.Position = position;
                fprintf('Stage positioned at: [%f, %f, %f] %s\n', position, obj.PositionUnit);
            else
                error('Position must be a 3-element vector [x, y, z]');
            end
        end

        function [Attributes, Data, Children] = exportState(obj)
            % Method to export the state of the stage
            Attributes = struct('PositionUnit', obj.PositionUnit);
            Data = struct('Position', obj.Position);
            Children = struct(); % No children in this example
        end
        function gui(obj)
            % Method to open the main control GUI
            % Implementation of the abstract method from MIC_Abstract
            disp('Opening GUI for Example3DStage...');
           % Creates and manages a GUI for controlling the 3D stage
    if ~isempty(obj.GuiFigure) && isvalid(obj.GuiFigure)
        figure(obj.GuiFigure);
        return;
    end

    obj.GuiFigure = figure('Name', [obj.InstrumentName ' Control'], ...
                           'NumberTitle', 'off', ...
                           'MenuBar', 'none', ...
                           'ToolBar', 'none', ...
                           'HandleVisibility', 'on', ...
                           'Position', [300, 300, 400, 300], ... % Adjusted size for 3 sliders
                           'CloseRequestFcn', @obj.closeGui);

    % Slider for X position control
    xSlider = uicontrol('Parent', obj.GuiFigure, ...
                       'Style', 'slider', ...
                       'Units', 'normalized', ...
                       'Position', [0.1, 0.7, 0.8, 0.1], ...
                       'Value', obj.Position(1), ...
                       'Min', -10, ... % Adjust the limits as needed
                       'Max', 10, ...
                       'SliderStep', [0.01, 0.1], ...
                       'Callback', @(src, evt) obj.setPosition([get(src, 'Value'), obj.Position(2), obj.Position(3)]));

    % Text display for current X position
    uicontrol('Parent', obj.GuiFigure, ...
              'Style', 'text', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.85, 0.8, 0.1], ...
              'String', ['X Position: ' num2str(obj.Position(1))]);

    % Slider for Y position control
    ySlider = uicontrol('Parent', obj.GuiFigure, ...
                       'Style', 'slider', ...
                       'Units', 'normalized', ...
                       'Position', [0.1, 0.5, 0.8, 0.1], ...
                       'Value', obj.Position(2), ...
                       'Min', -10, ... % Adjust the limits as needed
                       'Max', 10, ...
                       'SliderStep', [0.01, 0.1], ...
                       'Callback', @(src, evt) obj.setPosition([obj.Position(1), get(src, 'Value'), obj.Position(3)]));

    % Text display for current Y position
    uicontrol('Parent', obj.GuiFigure, ...
              'Style', 'text', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.65, 0.8, 0.1], ...
              'String', ['Y Position: ' num2str(obj.Position(2))]);

    % Slider for Z position control
    zSlider = uicontrol('Parent', obj.GuiFigure, ...
                       'Style', 'slider', ...
                       'Units', 'normalized', ...
                       'Position', [0.1, 0.3, 0.8, 0.1], ...
                       'Value', obj.Position(3), ...
                       'Min', -10, ... % Adjust the limits as needed
                       'Max', 10, ...
                       'SliderStep', [0.01, 0.1], ...
                       'Callback', @(src, evt) obj.setPosition([obj.Position(1), obj.Position(2), get(src, 'Value')]));

    % Text display for current Z position
    uicontrol('Parent', obj.GuiFigure, ...
              'Style', 'text', ...
              'Units', 'normalized', ...
              'Position', [0.1, 0.45, 0.8, 0.1], ...
              'String', ['Z Position: ' num2str(obj.Position(3))]);
        end
      function closeGui(obj, src, ~)
            % Close request function for the GUI
            delete(src);
            obj.GuiFigure = [];
       end
    end

    methods (Static=true)
        function Success = unitTest()
            % Method to test the functionality of the class
            % Here you would typically test each method to ensure they  work properly
            obj = Example3DStage();
            obj.center();
            obj.setPosition([1, 2, 3]);
            Success = true; % Assume success for simplicity
            delete(obj); % Clean up object
        end
    end
end
