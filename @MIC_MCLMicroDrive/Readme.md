# MIC_MCLMicroDrive controls a Mad City Labs Micro Stage
## Description
This class controls a Mad City Labs (MCL) micro-positioner stage.
This class uses the built-in MATLAB methods for calling C libraries,
e.g., calllib(), to call functions in MicroDrive.dll.  The
micro-positioner stage controller is to expected to be connected via
USB.
The first time this class is used on a given computer, the user will
be prompted to select the location of MicroDrive.dll.  On a Windows
machine, this is typically placed by default in
C:\Program Files\Mad City Labs\MicroDrive\MicroDrive.dll  during the
installation process (installation files provided by MCL).
NOTE: I had to manually modify MicroDrive.h to remove the precompiler
directives related to the '_cplusplus' stuff.  I was getting
errors otherwise that I didn't know what to do about! -DS 2021
## Features
- Direct control over MCL micro-positioner stages through MATLAB using C libraries.
- Auto-detection and handling of hardware errors with comprehensive error reporting.
- GUI support for real-time control and feedback.
- Auto-connect functionality for ease of use in experimental setups.
## Key Methods
- **Constructor (`MIC_MCLMicroDrive(AutoConnect)`):** Initializes a connection to the MCL stage. If `AutoConnect` is true, the constructor attempts to establish a connection immediately.
- **`setPosition(Position)`:** Sets the desired position of the stage. *(Note: Currently not functional due to lack of a position encoder in our hardware.)*
- **`getPosition()`:** Retrieves the current position of the stage. *(Note: Currently not functional due to lack of a position encoder in our hardware.)*
- **`center()`:** Moves the stage to its center position. *(Note: Currently not functional due to lack of a position encoder in our hardware.)*
- **`connectStage()`:** Establishes a connection with the stage and initializes the device.
- **`moveSingleStep(Direction)`:** Moves the stage a single step in the specified direction.
- **`moveDistance(Distance)`:** Moves the stage a specified distance from the current position.
- **`gui()`:** Launches a graphical user interface for the stage control.
- **`exportState()`:** Exports the current state of the stage including settings and position.
- **`delete()`:** Properly releases the hardware and cleans up resources on object destruction.
## Requirements
- MIC_LinearStage_Abstract.m
- MIC_Abstract.m
- MATLAB 2014b or higher
- MCL MicroDrive files installed on the system.
- MicroDrive.dll located typically in `C:\Program Files\Mad City Labs\MicroDrive\`
## Usage Example
```matlab
Assuming MicroDrive.dll is correctly installed and the MATLAB path is set
PX = MIC_MCLMicroDrive(true);
PX.gui();
PX.moveDistance(5);   Moves the stage 5 mm from the current position
```
Citation: David J. Schodt (Lidkelab, 2021) based on MIC_MCLNanoDrive class.
# connectStage attempts to connect to the stage.
This method will use the MCL libraries to attempt to connect to an MCL
micro-drive stage attached to the calling computer.
Created by:
David J. Schodt (Lidke lab, 2021)
Attempt to make the connection.
# displayLastError displays the last error message received from the stage
This method will take the struct in obj.LastError and display it in a
more user friendly way in the Command Window.  If the "error" code
returned was 0 (success), no message will be displayed (for the sake of
avoiding CommandWindow clutter).
Created by:
David J. Schodt (Lidke lab, 2021)
Attempt to display the error.
# gui is the GUI method for the MIC_MCLMicroDrive class.
This GUI has several elements which can be used to control a (single
axis) Mad City Labs micro-drive stage.
INPUTS:
GUIParent: The 'Parent' of this GUI, e.g., a figure handle.
(Default = figure(...))
Created by:
David J. Schodt (Lidke lab, 2021)
Create a figure handle for the GUI if needed.
# moveDistance moves the specified distance with the given velocity.
This method will move an amount specified by 'Distance' at the speed
defined in obj.Velocity
INPUTS:
Distance: Distance the stage will be moved (millimeters)
Created by:
David J. Schodt (Lidke lab, 2021)
Set defaults if needed.
# moveSingleStep moves a single step in the specified direction.
This method will take the smallest possible step size of the connected
MCL micro-drive stage in the direction specified by 'Direction'.
INPUTS:
Direction: Direction in which the stage will take a single step.
(integer, 1 or -1)
Created by:
David J. Schodt (Lidke lab, 2021)
Ensure 'Direction' makes sense.
