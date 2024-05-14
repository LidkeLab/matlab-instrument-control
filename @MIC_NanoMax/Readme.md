# MIC_NanoMax Class
## Description
The `MIC_NanoMax` class integrates control for the NanoMax stage system, encompassing both piezo elements and stepper motors for precise multi-dimensional positioning. This class allows for seamless integration and control of the stage's complex movements during microscopy experiments.
## Features
- Combined control of piezo and stepper motor stages for fine and coarse positioning.
- Initialization and centering of all axes upon instantiation.
- Easy-to-use graphical user interface for real-time control and adjustments.
## Requirements
- MIC_Abstract.m
- MIC_TCubePiezo.m
- MIC_StepperMotor.m
- MATLAB software version R2016b or later
## Installation Notes
Ensure that all required classes (`MIC_TCubePiezo` for piezo control and `MIC_StepperMotor` for stepper motor control) are in the MATLAB path. The system should also be connected to the respective hardware components before initializing this class.
## Key Methods
- **Constructor (`MIC_NanoMax()`):** Instantiates the NanoMax system, setting up both the piezo and stepper stages and initializing the GUI.
- **`setup_Stage_Piezo()`:** Configures the piezo stages for X, Y, and Z movement, centers them upon setup.
- **`setup_Stage_Stepper()`:** Initializes and centers the stepper motors.
- **`exportState()`:** Exports the current state of all stages, providing a snapshot of current settings and positions.
- **`unitTest()`:** Tests the functionality of the class methods to ensure correct operation and communication with the hardware.
## Usage Example
```matlab
Instantiate the NanoMax system
nanoStage = MIC_NanoMax();
Move the piezo stage in the X direction
nanoStage.Stage_Piezo_X.setPosition(10);  Moves to 10 microns
Adjust the stepper motor in the Y direction
nanoStage.Stage_Stepper.moveToPosition(1, 5);  Moves to 5 mm
Export the current state of the system
state = nanoStage.exportState();
disp(state);
Clean up and close the system
delete(nanoStage);
```
### CITATION: Sandeep Pallikuth, Lidkelab, 2017 & Sajjad Khan, Lidkelab, 2021.
# gui_NanoMax: is the graphical user interface (GUI) for MIC_NanoMax.m
Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigureStage)
guiFig = obj.GuiFigureStage;
figure(obj.GuiFigureStage);
return
end
Open figure
