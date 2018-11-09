classdef MIC_NanoMaxPiezos < MIC_3DStage_Abstract
    % MIC class for control of the NanoMax Stage piezos.
    %
    % This class is used to control the three piezos (x, y, z) in a
    % Thorlabs NanoMax stage. 
    %
    % Example: 
    % Functions:
    %   center()
    %   setPosition()
    %   exportState()
    %   delete()
    %
    % REQUIREMENTS:
    %   MIC_Abstract.m
    %   MIC_3DStage_Abstract.m
    %   MIC_TCubePiezo.m AND/OR MIC_KCubePiezo.m
    %   MATLAB 2016b or later required.
    %
    % CITATION:
    
    %Created by:
    %   David James Schodt (Lidkelab, 2018)
    
    
    properties
        SerialNumberControllerX; % x piezo controller ser. no. (string)
        SerialNumberControllerY; % y piezo controller ser. no. (string)
        SerialNumberControllerZ; % z piezo controller ser. no. (string)
        SerialNumberStrainGaugeX; % x piezo strain gauge ser. no. (string)
        SerialNumberStrainGaugeY; % y piezo strain gauge ser. no. (string)
        SerialNumberStrainGaugeZ; % z piezo strain gauge ser. no. (string)
        StagePiezoX; % Piezo object for x position piezo on the stage
        StagePiezoY; % Piezo object for y position piezo on the stage
        StagePiezoZ; % Piezo object for z position piezo on the stage
        StepSize; % Three element vector giving step size in each direction
    end
    
    properties (SetAccess = protected) % users shouldn't set these directly
       InstrumentName = 'NanoMaxStagePiezos'; % Meaningful instrument name
       Position; % Vector [x, y, z] giving the current piezo positions
       PositionUnit; % Units of position parameter (e.g. um, mm, etc.)
    end
    
    properties (Hidden)
        StartGUI = 0; % don't open GUI on object creation
    end
 
    methods
        function obj = MIC_NanoMaxPiezos(...
                SerialNumberControllerX, SerialNumberStrainGaugeX, ...
                SerialNumberControllerY, SerialNumberStrainGaugeY, ...
                SerialNumberControllerZ, SerialNumberStrainGaugeZ)
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
            
            % Determine the instrument version being connected (i.e. TCube
            % or KCube) based on the provided serial numbers and connect to
            % the instruments with the appropriate methods.
            % NOTE: This assumes that a given piezo controller is
            %       associated with a strain gauge of the same type, e.g. 
            %       if the 'X' piezo controller is a T-Cube, the 'X' strain
            %       gauge must also be a T-Cube.            % 
            % NOTE: Piezo controllers serial numbers starting with '81' are
            %       T-Cubes, and those starting with '29' are K-Cubes.
            %       Strain gauge serial numbers starting with '84' are
            %       T-Cubes, and those starting with '59' are K-Cubes.
            DeviceVersionTagArray.X = obj.SerialNumberControllerX(1:2);
            DeviceVersionTagArray.Y = obj.SerialNumberControllerY(1:2);
            DeviceVersionTagArray.Z = obj.SerialNumberControllerZ(1:2);
            for ii = ['X', 'Y', 'Z']
                if strcmp(DeviceVersionTagArray.(ii), '81') ...
                        || strcmp(DeviceVersionTagArray.(ii), '84') 
                    % This is a T-Cube piezo pair.
                    % USAGE NOTE:
                    % MIC_TCubePiezo(PiezoControllerSerialNum, ...
                    %                PiezoStrainGaugeSerialNum, ...
                    %                AxisLabel);
                    obj.(sprintf('StagePiezo%c', ii)) = MIC_TCubePiezo(...
                        obj.(sprintf('SerialNumberController%c', ii)), ...
                        obj.(sprintf('SerialNumberStrainGauge%c', ii)), ...
                        ii);
                elseif strcmp(DeviceVersionTagArray.ii, '29') ...
                        || strcmp(DeviceVersionTagArray.(ii), '59') 
                    % This is a K-Cube piezo pair.
                    obj.(sprintf('StagePiezo%c', ii)) = MIC_KCubePiezo(...
                        obj.(sprintf('SerialNumberController%c', ii)), ...
                        obj.(sprintf('SerialNumberStrainGauge%c', ii)), ...
                        ii);
                else
                    warning(['Piezo controller serial number', ...
                        '%s not recognized'], ...
                        obj.(sprintf('SerialNumberController%c', ii)));
                end
            end
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
        
        function delete(obj)
            % Class destructor for the NanoMax Stage piezo control class.
            % Closes the connection to both the strain gauge and the piezo
            % controller for each of the three (x, y, z) piezos.
            obj.StagePiezoX.delete();
            obj.StagePiezoY.delete();
            obj.StagePiezoZ.delete();
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