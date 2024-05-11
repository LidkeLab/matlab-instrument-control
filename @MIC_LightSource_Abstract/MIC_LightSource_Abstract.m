classdef MIC_LightSource_Abstract < MIC_Abstract
    % # MIC_LightSource_Abstract: Matlab Instrument Abstact Class for all light source Matlab Instrument Class 
    % ## Description
    % This class defines a set of abstract properties and methods that must
    % implemented in inheritting classes for all light source devices.  
    % This also provides a simple and intuitive GUI interface.   
    % ## Key Abstract Properties
% - **PowerUnit:** Unit of power measurement, specific to each device (e.g., mW, %).
% - **Power:** Currently set power level, constrained by the minimum and maximum power limits.
% - **IsOn:** Indicates whether the light source is on (1) or off (0).
% - **MinPower:** Minimum allowable power setting.
% - **MaxPower:** Maximum allowable power setting.
% 
% ## Key Methods
% - **Constructor (`MIC_LightSource_Abstract(AutoName)`):** Initializes the auto-naming functionality from `MIC_Abstract` class. This constructor must be called from the constructor of all inheriting classes.
% - **`setPower(obj, power)`:** Abstract method to set the power of the light source. Must be implemented by subclasses.
% - **`on(obj)`:** Abstract method to turn on the light source. Must be implemented by subclasses.
% - **`off(obj)`:** Abstract method to turn off the light source. Must be implemented by subclasses.
% - **`shutdown(obj)`:** Abstract method to properly shut down the light source and clear any used ports or connections. Must be implemented by subclasses.
% - **`updateGui(obj)`:** Updates the GUI with current parameters such as power and on/off status. This method checks if a GUI is open and valid before attempting to update.
% ## Note:
    % The constructor in each subclass must begin with the following line 
    % inorder to enable the auto-naming functionality:
    % obj=obj@MIC_LightSource_Abstract(~nargout);
    %
    % ## REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MATLAB software version R2016b or later
    %
    % CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
    
    properties (Abstract,SetAccess=protected)
        PowerUnit;          % Power Unit based on each Device.
        Power;              % Currently Set Power based on Power Limit
        IsOn;               % LaserStatus, On=1, Off=0
        MinPower;           % Lower limit for power 
        MaxPower;           % Upper limit for power
    end
    
   
    methods
        
        function obj=MIC_LightSource_Abstract(AutoName)
            %set  auto-naming functionality from MIC_Abstract Class 
            obj=obj@MIC_Abstract(AutoName);
        end
        
        
        function updateGui(obj)
            % update gui with current parameters
            % check whether gui is open
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            % find edit box and slider and update
            for ii = 1 : numel(obj.GuiFigure.Children)
                if strcmp(obj.GuiFigure.Children(ii).Tag,'positionEdit')
                    obj.GuiFigure.Children(ii).String = num2str(obj.Power);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'positionSlider')
                    obj.GuiFigure.Children(ii).Value = obj.Power;
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'positionButton')
                    obj.GuiFigure.Children(ii).Value = obj.IsOn;
                    if obj.IsOn
                        obj.GuiFigure.Children(ii).String = 'On';
                        obj.GuiFigure.Children(ii).BackgroundColor = 'red';
                    else 
                        obj.GuiFigure.Children(ii).String = 'Off';
                        obj.GuiFigure.Children(ii).BackgroundColor = [0.8  0.8  0.8];
                    end
                end
            end
         end
    end
    
    methods (Abstract)
        setPower(obj,power);  % Set obj.Power
        on(obj);              % Turn on Light Source
        off(obj);             % Turn off Light Source
        shutdown(obj);        % clear the ports
    end
    
end




