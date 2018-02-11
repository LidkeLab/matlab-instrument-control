classdef MIC_LinearStage_Abstract < MIC_Abstract
    % MIC_LinearStage_Abstract: Matlab Instrument Control abstract class 
    % for linear stages.
    %
    % This class defines a set of Abstract properties and methods that must
    % implemented in inheritting classes. This class also provides a simple 
    % and intuitive GUI.   
    % The constructor in each subclass must begin with the following line 
    % inorder to enable the auto-naming functionality: 
    % 	obj=obj@MIC_LinearStage_Abstract(~nargout);
    %
    % REQUIRES:
    %   MIC_Abstract.m
    %   MATLAB 2014b or higher
    %
    % Marjolein Meddens, Lidke Lab, 2017.
    
    properties (Abstract,SetAccess=protected)
        PositionUnit;          % Units of position parameter (eg. um/mm)
        CurrentPosition;       % Current position of device
        MinPosition;           % Lower limit position 
        MaxPosition;           % Upper limit position
        Axis;                  % Stage axis (X, Y or Z)
    end
    
   methods
        function obj=MIC_LinearStage_Abstract(AutoName)
            obj=obj@MIC_Abstract(AutoName);
        end
        
        function center(obj) 
            % obj.center Moves stage to center position
            % Center is calculated as (MaxPosition-MinPosition)/2
            centerPos = (obj.MaxPosition-obj.MinPosition)/2;
            obj.setPosition(centerPos);
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
                    obj.GuiFigure.Children(ii).String = num2str(obj.CurrentPosition);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'positionSlider')
                    obj.GuiFigure.Children(ii).Value = obj.CurrentPosition;
                end
            end
         end
    
   end
    
   
        
    methods (Abstract)
        setPosition(obj,position);  % Move stage to position
        pos = getPosition(obj); % Get current position by querying the stage
    end
    
end




