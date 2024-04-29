classdef ExampleLightSource < MIC_LightSource_Abstract
    % ExampleLightSource: Concrete implementation of MIC_LightSource_Abstract
    % This class provides full functionalities for a simulated light source.
    
    properties (SetAccess = protected)
        InstrumentName = 'ExampleLightSource'; % Name of the instrument
        PowerUnit = 'Watts';
        Power = 0;  % Initialize Power to a valid scalar within the range
        IsOn = 0;
        MinPower = 0;
        MaxPower = 100;
    end
    
    
    properties (Hidden)
        StartGUI = false; % GUI does not start automatically by default
    end
    
    methods
        function obj = ExampleLightSource()
            obj = obj@MIC_LightSource_Abstract(~nargout);
        end
        
        function setPower(obj, power)
            if power < obj.MinPower || power > obj.MaxPower
                error('Power value must be between %d and %d %s.', obj.MinPower, obj.MaxPower, obj.PowerUnit);
            end
            obj.Power = power;
            fprintf('Power set to %g %s\n', obj.Power, obj.PowerUnit);
        end
        
        function on(obj)
            if obj.Power <= obj.MinPower
                error('Power must be set above minimum power to turn on.');
            end
            obj.IsOn = 1;
            fprintf('Light source turned on.\n');
        end
        
        function off(obj)
            obj.IsOn = 0;
            fprintf('Light source turned off.\n');
        end
        
        function shutdown(obj)
            obj.off();
            fprintf('Light source is shutting down.\n');
        end
        
        function gui(obj)
            % Modifications only in the gui method
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                guiWidth = 300;
                guiHeight = 250;
                screen = get(0, 'ScreenSize');
                posX = (screen(3) - guiWidth) / 2;
                posY = (screen(4) - guiHeight) / 2;
                
                obj.GuiFigure = figure('Name', obj.InstrumentName, 'NumberTitle', 'off', 'Resize', 'off', 'Position', [posX, posY, guiWidth, guiHeight]);
                
                btnOn = uicontrol('Parent', obj.GuiFigure, 'Style', 'pushbutton', 'String', 'Turn On', 'Position', [50, 150, 200, 40], 'Callback', @(src, evt) obj.onButtonClicked(src));
                btnOff = uicontrol('Parent', obj.GuiFigure, 'Style', 'pushbutton', 'String', 'Turn Off', 'Position', [50, 100, 200, 40], 'Callback', @(src, evt) obj.offButtonClicked(src));
                
                slider = uicontrol('Parent', obj.GuiFigure, 'Style', 'slider', 'Min', obj.MinPower, 'Max', obj.MaxPower, 'Value', obj.Power, 'Position', [50, 50, 200, 40], 'Callback', @(src, evt) obj.sliderMoved(src));
                
                lblSlider = uicontrol('Parent', obj.GuiFigure, 'Style', 'text', 'String', ['Power: ', num2str(obj.Power), ' ', obj.PowerUnit], 'Position', [50, 20, 200, 20], 'HorizontalAlignment', 'center');
            else
                figure(obj.GuiFigure);
            end
        end
        
        function onButtonClicked(obj, src)
            % Turn the light source on and change button color
            obj.on();
            set(src, 'BackgroundColor', 'green');
        end
        
        function offButtonClicked(obj, src)
            % Turn the light source off and change button color
            obj.off();
            set(src, 'BackgroundColor', 'red');
        end
        
        function sliderMoved(obj, src)
            % Update the power based on the slider's position
            newPower = round(get(src, 'Value'));  % Round to nearest integer
            obj.setPower(newPower);  % Set the power on the light source
            % Update slider label
            lblSlider = findobj(obj.GuiFigure, 'Type', 'uicontrol', 'Style', 'text');
            set(lblSlider, 'String', ['Power: ', num2str(obj.Power), ' ', obj.PowerUnit]);
        end
        
        
        function [Attributes, Data, Children] = exportState(obj)
            % Export the current state of the object
            Attributes = struct('PowerUnit', obj.PowerUnit, 'IsOn', obj.IsOn);
            Data = struct('Power', obj.Power, 'MinPower', obj.MinPower, 'MaxPower', obj.MaxPower);
            Children = {}; % No children objects in this simple example
        end
    end
    
    methods (Static=true)
        function Success = unitTest()
            obj = ExampleLightSource();
            fprintf('Starting unit test for %s\n', class(obj));
            obj.setPower(50);
            obj.on();
            obj.off();
            Success = true; % Assume success for simplicity
            delete(obj); % Clean up object
        end
        
    end
end