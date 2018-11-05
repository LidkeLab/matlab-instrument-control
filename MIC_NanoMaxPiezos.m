classdef MIC_NanoMaxPiezos < MIC_3DStage_Abstract
    % MIC class for control of the NanoMax Stage piezos.
    %
    % This class is used to control the three piezos (x, y, z) in a
    % Thorlabs NanoMax stage. 
    %
    % Example: 
    % Functions: 
    %
    % REQUIREMENTS:
    %   MIC_Abstract.m
    %   MIC_PiezoStage_Abstract.m
    %   MIC_TCubePiezo.m
    %   MATLAB 2016b or later required.
    %
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties
        InstrumentName = 'NanoMaxStagePiezos'; % Meaningful instrument name
        StagePiezoX; % Piezo object for x position piezo on the stage
        StagePiezoY; % Piezo object for y position piezo on the stage
        StagePiezoZ; % Piezo object for z position piezo on the stage
        SerialNumberControllerX; % x piezo controller ser. no. (string)
        SerialNumberControllerY; % y piezo controller ser. no. (string)
        SerialNumberControllerZ; % z piezo controller ser. no. (string)
        SerialNumberStrainGaugeX; % x piezo strain gauge ser. no. (string)
        SerialNumberStrainGaugeY; % y piezo strain gauge ser. no. (string)
        SerialNumberStrainGaugeZ; % z piezo strain gauge ser. no. (string)
    end
    
    properties (SetAccess = protected) % users shouldn't set these directly
       Position; % Vector [x, y, z] giving the current piezo positions
       PositionUnit; % Units of position parameter (e.g. um, mm, etc.)
       StepSize; % Three element vector giving step size in each direction
    end
 
    methods
        function obj = MIC_NanoMaxPiezos(SerialNumberControllerX, ...
                SerialNumberControllerY, SerialNumberControllerZ, ...
                SerialNumberStrainGaugeX, SerialNumberStrainGaugeY, ...
                SerialNumberStrainGaugeZ)
            % Constructor for NanoMax Stage piezo control class.
            
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@MIC_3DStage_Abstract(~nargout);
            
            % Set the object properties based on the appropriate inputs.
            obj.SerialNumberControllerX = SerialNumberControllerX; 
            obj.SerialNumberControllerY = SerialNumberControllerY;
            obj.SerialNumberControllerZ = SerialNumberControllerZ; 
            obj.SerialNumberStrainGaugeX = SerialNumberStrainGaugeX; 
            obj.SerialNumberStrainGaugeY = SerialNumberStrainGaugeY;
            obj.SerialNumberStrainGaugeZ = SerialNumberStrainGaugeZ; 
            
            % Connect the appropriate piezos and center them. 
            % NOTE: usage MIC_TCubePiezo(PiezoControllerSerialNum, ...
            %                            PiezoStrainGaugeSerialNum, ...
            %                            AxisLabel);
            obj.StagePiezoX = MIC_TCubePiezo(...
                obj.SerialNumberControllerX, ...
                obj.SerialNumberStrainGaugeX, 'X'); 
            obj.StagePiezoY=MIC_TCubePiezo(...
                obj.SerialNumberControllerY, ...
                obj.SerialNumberStrainGaugeY, 'Y'); 
            obj.StagePiezoZ=MIC_TCubePiezo(...
                obj.SerialNumberControllerZ, ...
                obj.SerialNumberStrainGaugeZ, 'Z'); 
            obj.center();
        end
        
        function delete(obj)
            % Class destructor for the NanoMax Stage piezo control class.
            % Closes the connection to both the strain gauge and the piezo
            % controller for each of the three (x, y, z) piezos.
            
            % Close the x controller/strain gauges.
            obj.StagePiezoX.closeDevices();
            
            % Close the y controller/strain gauges.
            obj.StagePiezoY.closeDevices();
            
            % Close the z controller/strain gauges.
            obj.StagePiezoZ.closeDevices();
        end
        
        function [Attributes, Data, Children] = exportState(obj) 
            % Exports the current state of the instrument and associated
            % children.
            [Children.StagePiezoX.Attributes, ...
                Children.StagePiezoX.Data, ...
                Children.StagePiezoX.Children] = ...
                obj.StagePiezoX.exportState();
            [Children.StagePiezoY.Attributes, ...
                Children.StagePiezoY.Data, ...
                Children.StagePiezoY.Children] = ...
                obj.StagePiezoY.exportState();
            [Children.StagePiezoZ.Attributes, ...
                Children.StagePiezoZ.Data, ...
                Children.StagePiezoZ.Children] = ...
                obj.StagePiezoZ.exportState();
            Attributes.InstrumentName = obj.InstrumentName;
            Data=[];
            Children=[];
        end
        
        function center(obj)
            % Center the three piezos in the NanoMax stage. 
            obj.StagePiezoX.center();
            obj.StagePiezoY.center();
            obj.StagePiezoZ.center();
        end
        
        function setPosition(obj, Position)
            % Move the piezos to position given by Position.
            obj.StagePiezoX.setPosition(Position(1));
            obj.StagePiezoY.setPosition(Position(2));
            obj.StagePiezoZ.setPosition(Position(3));
        end

    end
    
    methods (Static)
        unitTest(); % not yet implemented
    end
end