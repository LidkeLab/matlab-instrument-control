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

## NOTE:
I had to manually modify MicroDrive.h to remove the precompiler
directives related to the '_cplusplus' stuff.  I was getting
errors otherwise that I didn't know what to do about! -DS 2021.

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
% Assuming MicroDrive.dll is correctly installed and the MATLAB path is set
PX = MIC_MCLMicroDrive(true);
PX.gui();
PX.moveDistance(5);  % Moves the stage 5 mm from the current position
```
### Citation: David J. Schodt (Lidkelab, 2021) based on MIC_MCLNanoDrive class.

