classdef MIC_3DStage_Abstract < MIC_Abstract
    % MIC_3DStage_Abstract Matlab Instrument Abstact Class for all stages Matlab Instrument Class 
    %
    % ## Description
    % This class defines a set of abstract Properties and methods that must
    % implemented in inheritting classes for all stages devices.  
    % This also provides a simple and intuitive GUI interface.   
    % 
    % ## Constructor
    % The constructor in each subclass must begin with the following line 
    % inorder to enable the auto-naming functionality:
    % obj=obj@MIC_3DStage_Abstract(~nargout);
    %
    % ## REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MATLAB software version R2016b or later
    %
    % ### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
    
    properties (Abstract,SetAccess=protected)
        Position;          % Current position.
        PositionUnit;      % Units of position parameter (eg. um/mm)
    end
    
   
    methods
         function obj=MIC_3DStage_Abstract(AutoName)
            %set  auto-naming functionality from MIC_Abstract Class 
            obj=obj@MIC_Abstract(AutoName);
         end
    end
    
    methods (Abstract)
        center(obj, AxisBool);                % Set to the center
        setPosition(obj,Position);  % Set to any position
    end
    
end



