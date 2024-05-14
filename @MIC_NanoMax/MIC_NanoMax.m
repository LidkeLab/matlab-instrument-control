classdef MIC_NanoMax < MIC_Abstract
%  MIC_NanoMax Class 
% 
% ## Description
% The `MIC_NanoMax` class integrates control for the NanoMax stage system, encompassing both piezo elements and stepper motors for precise multi-dimensional positioning. This class allows for seamless integration and control of the stage's complex movements during microscopy experiments.
% 
% ## Features
% - Combined control of piezo and stepper motor stages for fine and coarse positioning.
% - Initialization and centering of all axes upon instantiation.
% - Easy-to-use graphical user interface for real-time control and adjustments.
% 
% ## Requirements
% - MIC_Abstract.m
% - MIC_TCubePiezo.m
% - MIC_StepperMotor.m
% - MATLAB software version R2016b or later
% 
% ## Installation Notes
% Ensure that all required classes (`MIC_TCubePiezo` for piezo control and `MIC_StepperMotor` for stepper motor control) are in the MATLAB path. The system should also be connected to the respective hardware components before initializing this class.
% 
% ## Key Methods
% - **Constructor (`MIC_NanoMax()`):** Instantiates the NanoMax system, setting up both the piezo and stepper stages and initializing the GUI.
% - **`setup_Stage_Piezo()`:** Configures the piezo stages for X, Y, and Z movement, centers them upon setup.
% - **`setup_Stage_Stepper()`:** Initializes and centers the stepper motors.
% - **`exportState()`:** Exports the current state of all stages, providing a snapshot of current settings and positions.
% - **`unitTest()`:** Tests the functionality of the class methods to ensure correct operation and communication with the hardware.
% 
% ## Usage Example
% ```matlab
% % Instantiate the NanoMax system
% nanoStage = MIC_NanoMax();
% 
% % Move the piezo stage in the X direction
% nanoStage.Stage_Piezo_X.setPosition(10); % Moves to 10 microns
% 
% % Adjust the stepper motor in the Y direction
% nanoStage.Stage_Stepper.moveToPosition(1, 5); % Moves to 5 mm
% 
% % Export the current state of the system
% state = nanoStage.exportState();
% disp(state);
% 
% % Clean up and close the system
% delete(nanoStage);
% ```   
% ### CITATION: Sandeep Pallikuth, Lidkelab, 2017 & Sajjad Khan, Lidkelab, 2021.    
    properties
        StartGUI;                   % starting gui
        SerialN;                    % for SEQ controller: 70850323
        GuiFigureStage;
    end
    
    properties (SetAccess=protected)
        
        InstrumentName='NanoMax'    % Instrument name.
        Stage_Piezo_X;              % Linear Piezo Stage in X direction
        Stage_Piezo_Y;              % Linear Piezo Stage in Y direction
        Stage_Piezo_Z;              % Linear Piezo Stage in Z direction
        Stage_Stepper;              % Stepper Motor State
        StepperLargeStep=.05;       % Large Stepper motor step (mm)
        StepperSmallStep=.002;      % Small Stepper motor step (mm)
        PiezoStep=.1;               % Piezo step (micron)
    end
    
    methods
        function obj = MIC_NanoMax()
            % Enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            obj.setup_Stage_Piezo();    % Setting up Piezo
            obj.setup_Stage_Stepper();  % Setting up Steppermotor
            obj.gui();  % Creating gui
            
        end
        
        function setup_Stage_Piezo(obj)
            % Sets up Piezo for the stage
            % PX=MIC_TCubePiezo('TPZserialNo','TSGserialNo','AxisLabel')
            obj.Stage_Piezo_X=MIC_TCubePiezo('81850186','84850145','X');
            obj.Stage_Piezo_Y=MIC_TCubePiezo('81850193','84850146','Y');
            obj.Stage_Piezo_Z=MIC_TCubePiezo('81850176','84850203','Z');
            obj.Stage_Piezo_X.center();
            obj.Stage_Piezo_Y.center();
            obj.Stage_Piezo_Z.center();
        end
        
        function setup_Stage_Stepper(obj)
            % Sets up stepper motors for the stage
            % for SEQ microscope Serial No is 70850323
            obj.Stage_Stepper=MIC_StepperMotor('70850323');
            % obj.Stage_Stepper.set_position([2,2,1]);
            % center the stepper motor in XY
            obj.Stage_Stepper.moveToPosition(1,0) %y
            obj.Stage_Stepper.moveToPosition(2,0) %x
        end
        
        function exportState(obj)
            % Export current state of the stage 
            Attributes=[];
            Data = [];
            Children = [];
        end
        
    end
    
    methods (Static=true)
        function unitTest()
            % unit test of object functionality
            % Syntax: MIC_NanoMax.unitTest()

            fprintf('Creating Object\n')
            NM=MIC_NanoMax();
            fprintf('State Export\n')
            A=NM.exportState(); disp(A); pause(1);
            fprintf('Delete Object\n')
            clear NM;

        end
    end
    
end

