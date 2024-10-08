classdef NanoMaxPiezos < mic.stage3D.abstract
    % mic.stage3D.NanoMaxPiezos Class
    %
    % ## Description
    % The `mic.stage3D.NanoMaxPiezos` class provides comprehensive control over the three piezo stages (x, y, z) of a Thorlabs NanoMax stage. It is designed to handle precise positioning necessary in advanced microscopy setups.
    %
    % ## Key Features
    % - Individual control of x, y, and z piezo stages.
    % - Automatic connection to piezo stages based on serial numbers.
    % - Methods to center and set positions of piezos.
    % - Integration with both TCube and KCube piezo systems.
    %
    % ## Requirements
    % - `mic.abstract.m`
    % - `mic.stage3D.abstract.m`
    % - Piezo control classes (`mic.linearstage.TCubePiezo.m` and `mic.linearstage.KCubePiezo.m`)
    % - MATLAB 2016b or later.
    %
    % ## Installation Notes
    % Before using this class, ensure that all dependent classes and required Thorlabs drivers are installed and properly configured on your system.
    %
    % ## Methods
    % ### `Constructor (mic.stage3D.NanoMaxPiezos())`
    % Initializes piezo controllers for x, y, and z axes based on provided serial numbers. It attempts to connect to the piezos, with error handling to manage connection issues.
    %
    % ### `center()`
    % Centers all three piezo stages.
    %
    % ### `setPosition([x, y, z])`
    % Sets the position of the piezo stages to specified x, y, and z coordinates.
    %
    % ### `exportState()`
    % Exports the current state of all piezo stages, providing detailed attributes for each stage.
    %
    % ### `delete()`
    % Properly deletes piezo stage objects and cleans up resources to prevent memory leaks.
    %
    % ## Usage Example
    % ```matlab
    % % Initialize NanoMax Piezos
    % nmPiezos = mic.stage3D.NanoMaxPiezos('81850186', '84850145', '81850193', '84850146', '81850176', '84850203', 3);
    %
    % % Center all piezos
    % nmPiezos.center();
    %
    % % Set a specific position
    % nmPiezos.setPosition([10, 10, 5]);
    %
    % % Export the current state
    % state = nmPiezos.exportState();
    % disp(state);
    %
    % % Clean up on completion
    % delete(nmPiezos);
    % ```
    % ### CITATION: David James Schodt (Lidkelab, 2018)
    properties
        ControllerXSerialNum; % x piezo controller ser. no. (string)
        ControllerYSerialNum; % y piezo controller ser. no. (string)
        ControllerZSerialNum; % z piezo controller ser. no. (string)
        MaxPiezoConnectAttempts = 1; % max attempts to connect to a piezo
        StrainGaugeXSerialNum; % x piezo strain gauge ser. no. (string)
        StrainGaugeYSerialNum; % y piezo strain gauge ser. no. (string)
        StrainGaugeZSerialNum; % z piezo strain gauge ser. no. (string)
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
        function obj = NanoMaxPiezos(...
                ControllerXSerialNum, StrainGaugeXSerialNum, ...
                ControllerYSerialNum, StrainGaugeYSerialNum, ...
                ControllerZSerialNum, StrainGaugeZSerialNum, ...
                MaxPiezoConnectAttempts)
            % Constructor for NanoMax Stage piezo control class.
            
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@mic.stage3D.abstract(~nargout);
            
            % Set the object properties based on the appropriate inputs.
            if exist('MaxPiezoConnectAttempts', 'var')
                obj.MaxPiezoConnectAttempts = MaxPiezoConnectAttempts;
            end
            obj.ControllerXSerialNum = ControllerXSerialNum;
            obj.ControllerYSerialNum = ControllerYSerialNum;
            obj.ControllerZSerialNum = ControllerZSerialNum;
            obj.StrainGaugeXSerialNum = StrainGaugeXSerialNum;
            obj.StrainGaugeYSerialNum = StrainGaugeYSerialNum;
            obj.StrainGaugeZSerialNum = StrainGaugeZSerialNum;
            
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
            DeviceVersionTagArray.X = obj.ControllerXSerialNum(1:2);
            DeviceVersionTagArray.Y = obj.ControllerYSerialNum(1:2);
            DeviceVersionTagArray.Z = obj.ControllerZSerialNum(1:2);
            for cc = ['X', 'Y', 'Z']
                % Determine the object name of the piezo to be connected.
                StagePiezo = sprintf('StagePiezo%c', cc);
                
                % Determine the appropriate piezo controller and strain
                % gauge serial numbers.
                ControllerSN = ...
                    obj.(sprintf('Controller%cSerialNum', cc));
                StrainGaugeSN = ...
                    obj.(sprintf('StrainGauge%cSerialNum', cc));
                
                % Setup the piezos on the NanoMax stage, ensuring a proper
                % connection was made by setting the piezo to an arbitrary
                % position and checking that the strain gauge reading
                % matches the set position.
                TestPosition = 12.3; % arbitrary set position to test
                for jj = 1:obj.MaxPiezoConnectAttempts
                    % Attempt the connection to the piezo, pausing after
                    % the call to allow the piezo setup to complete.
                    if strcmp(DeviceVersionTagArray.(cc), '81') ...
                            || strcmp(DeviceVersionTagArray.(cc), '84')
                        % This is a T-Cube piezo pair.
                        obj.(StagePiezo) = mic.linearstage.TCubePiezo(...
                            ControllerSN, StrainGaugeSN, cc);
                    elseif strcmp(DeviceVersionTagArray.(cc), '29') ...
                            || strcmp(DeviceVersionTagArray.(cc), '59')
                        % This is a K-Cube piezo pair.
                        obj.(StagePiezo) = mic.linearstage.KCubePiezo(...
                            ControllerSN, StrainGaugeSN, cc);
                    else
                        warning(['Piezo controller serial number', ...
                            '%s not recognized'], ...
                            obj.(sprintf('SerialNumberController%c', cc)));
                        continue % move on to the next iteration
                    end
                    pause(2);
                    
                    % Attempt to set the position of the piezo and then
                    % pause briefly to allow the piezo to reach it's set
                    % position.
                    obj.(StagePiezo).setPosition(TestPosition);
                    pause(2);
                    
                    % Read the strain gauge to determine the piezo
                    % position, and determine if it matches the test
                    % position.
                    % NOTE: 15 bits cover a range of 20um -> convert a
                    %       0-(2^15-1) range to ~0-20um with a factor of
                    %       (20um / 2^15).
                    
                    switch DeviceVersionTagArray.(cc)
                        case '29' %Kcube
                            PiezoPosition = (20 / 2^15) ...
                                * Kinesis_KCube_SG_GetReading(StrainGaugeSN);
                        case '81' %TCube
                            PiezoPosition = (20 / 2^15) ...
                                * Kinesis_SG_GetReading(StrainGaugeSN);
                    end
                    
                    if round(PiezoPosition, 1) == TestPosition
                        % Position matches TestPosition to the nearest
                        % 1/10 um: re-center piezo and break the loop.
                        obj.(StagePiezo).center();
                        break
                    elseif jj == obj.MaxPiezoConnectAttempts
                        % This was the last attempt, warn the user and
                        % proceed.
                        warning('Connection to %c piezo has failed', cc)
                    else
                        obj.(StagePiezo).delete;
                    end
                end
            end
            
            % Assuming piezos were connected succesfully, set the Position
            % property to [10, 10, 10].
            obj.Position = [10, 10, 10];
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
        end
        
        function delete(obj)
            % Class destructor for the NanoMax Stage piezo control class.
            % Closes the connection to both the strain gauge and the piezo
            % controller for each of the three (x, y, z) piezos.
            obj.StagePiezoX.delete();
            obj.StagePiezoY.delete();
            obj.StagePiezoZ.delete();
        end
        

        function center(obj, AxisBool)
            % This method will center the stage along the axes specified in
            % AxisBool.  For example, if AxisBool = [1; 0; 1], the stage
            % will be centered along the X and Z axes, and the Y axis will
            % remain unchanged. 

            
            % Check if the AxisBool was entered, setting a default if not.
            if ~exist('AxisBool', 'var')
                AxisBool = [1; 1; 1];
            end
            
            % Center the three piezos in the NanoMax stage. 
            if AxisBool(1)
                obj.StagePiezoX.center();
                obj.Position(1) = 10;
            end
            if AxisBool(2)
                obj.StagePiezoY.center();
                obj.Position(2) = 10;
            end
            if AxisBool(3)
                obj.StagePiezoZ.center();
                obj.Position(3) = 10;
            end
        end
        
        function setPosition(obj, Position)
            % Move the piezos to position given by Position.
            obj.StagePiezoX.setPosition(Position(1));
            obj.StagePiezoY.setPosition(Position(2));
            obj.StagePiezoZ.setPosition(Position(3));
            
            % Update the position property to the appropriate value.
            if size(Position, 1) < size(Position, 2)
                % Position is a row vector, no need to modify it.
                obj.Position = Position;
            else
                % Position is a column vector, we should make it a row
                % vector.
                obj.Position = Position.';
            end
        end
        
        function connectTCubePiezo(obj, StagePiezo, ...
                ControllerSN, StrainGaugeSN)
            % This method will connect (or reconnect) a TCube piezo,
            % attempting iterative re-connection if needed/requested.
            
            % Setup the piezos on the NanoMax stage, ensuring a proper
            % connection was made by setting the piezo to an arbitrary
            % position and checking that the strain gauge reading matches
            % the set position.
            TestPosition = 12.3; % arbitrary set position for the piezos
            for cc = ['X', 'Y', 'Z']
                for jj = 1:obj.MaxPiezoConnectAttempts
                    % Attempt the connection to the piezo, pausing after
                    % the call to allow the piezo setup to complete.
                    obj.(StagePiezo) = mic.linearstage.TCubePiezo(...
                        obj.(ControllerSN), obj.(StrainGaugeSN), cc);
                    pause(2);
                    
                    % Attempt to set the position of the piezo and then
                    % pause briefly to allow the piezo to reach it's set
                    % position.
                    obj.(StagePiezo).setPosition(TestPosition);
                    pause(2);
                    
                    % Read the strain gauge to determine the piezo
                    % position, and determine if it matches the test
                    % position.
                    PiezoPosition = (20 / 2^15) ...
                        * Kinesis_SG_GetReading(StrainGaugeSN);
                    if round(PiezoPosition, 1) == TestPosition
                        % Position matches TestPosition to the nearest
                        % 1/10um: re-center piezo and break the loop.
                        obj.(StagePiezo).center();
                        break
                    elseif jj == obj.MaxPiezoConnectAttempts
                        % This was the last attempt, warn the user and
                        % proceed.
                        warning('Connection to %c piezo has failed', cc)
                    end
                end
            end
        end
        
        function connectKCubePiezo(obj)
        end
    end
    
    methods (Static)
        function funcTest()
            fprintf('Starting unit test for mic.stage3D.NanoMaxPiezos class.\n');
            
            % Specify example serial numbers for controllers and strain gauges
            % These serial numbers need to be replaced with actual serial numbers.
            ControllerXSN = '81850186'; % Example serial number for X piezo controller
            StrainGaugeXSN = '84850145'; % Example serial number for X strain gauge
            ControllerYSN = '81850193'; % Example serial number for Y piezo controller
            StrainGaugeYSN = '84850146'; % Example serial number for Y strain gauge
            ControllerZSN = '81850176'; % Example serial number for Z piezo controller
            StrainGaugeZSN = '84850203'; % Example serial number for Z strain gauge
            
            % Create an instance of the NanoMaxPiezos class
            try
                nmPiezos = mic.stage3D.NanoMaxPiezos(ControllerXSN, StrainGaugeXSN, ...
                    ControllerYSN, StrainGaugeYSN, ControllerZSN, StrainGaugeZSN);
                fprintf('Successfully created mic.stage3D.NanoMaxPiezos object.\n');
            catch
                error('Failed to create mic.stage3D.NanoMaxPiezos object.');
            end
            
            % Test centering function
            try
                nmPiezos.center();
                fprintf('Successfully centered all piezos.\n');
            catch
                error('Failed to center piezos.');
            end
            
            % Test setting a specific position
            TestPosition = [5, 5, 5]; % example position
            try
                nmPiezos.setPosition(TestPosition);
                fprintf('Successfully set piezo positions to [%g, %g, %g].\n', TestPosition);
            catch
                error('Failed to set specific piezo positions.');
            end
            
            % Test exporting the current state
            try
                state = nmPiezos.exportState();
                disp('Current state exported:');
                disp(state);
            catch
                error('Failed to export the current state.');
            end
            
            % Delete the instance to clean up resources
            try
                delete(nmPiezos);
                fprintf('mic.stage3D.NanoMaxPiezos object deleted successfully.\n');
            catch
                error('Failed to delete mic.stage3D.NanoMaxPiezos object.');
            end
            
            fprintf('Unit test for mic.stage3D.NanoMaxPiezos completed successfully.\n');
        end
    end
    
end
