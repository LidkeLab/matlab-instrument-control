# MIC_MCLNanoDrive controls the Mad City Labs 3D Piezo Stage
## Description
This class controls a 3D Peizo stage from Mad City Labs.  The class
uses 'calllib' to directly call funtions from the madlib.dll. The instument
is attached via USB.
The first time an object of this class is created, the user must
direct the object to the 'madlib.h' header file.  This is usually
located here:  C:\Program Files\Mad City Labs\NanoDrive
## Features
- Direct control of Mad City Labs 3D Piezo stages via USB.
- Dynamic link library interaction using `madlib.dll` for stage control.
- Error handling and reporting integrated within the class structure.
- Simple and intuitive GUI for easy operation.
## Requirements
- MIC_3DStage_Abstract.m
- MIC_Abstract.m
- MATLAB 2014b or higher
- Mad City Labs drivers and `madlib.h` installed on the system.
## Installation Notes
During the first initialization of this class on a system, users are prompted to direct the class to the `madlib.h` header file, typically located in `C:\Program Files\Mad City Labs\NanoDrive`.
## Key Methods
- **Constructor (`MIC_MCLNanoDrive()`):** Initializes the connection to the Mad City Labs stage and loads necessary libraries.
- **`setPosition([x, y, z])`:** Moves the stage to the specified x, y, z coordinates.
- **`getSensorPosition()`:** Retrieves the current sensor position from the stage.
- **`center()`:** Centers the stage based on its configured range of motion.
- **`delete()`:** Releases the hardware handle and properly shuts down the connection to the stage.
- **`gui()`:** Launches a graphical user interface for real-time stage control.
- **`exportState()`:** Exports the current state of the stage including settings and position for record-keeping or analysis.
## Usage Example
```matlab
Create an instance of the MIC_MCLNanoDrive
stage = MIC_MCLNanoDrive();
Move the stage to a specific position
stage.setPosition([10, 10, 10]);
Retrieve and display the current sensor position
stage.getSensorPosition();
disp(stage.SensorPosition);
Center the stage
stage.center();
Display the GUI
stage.gui();
```
Citation:Hanieh Mazloom-Farsibaf, Lidke Lab 2018
# certain errors throw variable error codes but are specific to axis controls, this is logical branch for that
# set the ErrorCode static codes as a structure
