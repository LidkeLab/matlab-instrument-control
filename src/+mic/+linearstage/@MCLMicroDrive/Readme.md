# mic.linearstage.MCLMicroDrive controls a Mad City Labs Micro Stage

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

## Protected Properties

### `InstrumentName`
Generic name of the instrument (char array).
**Default:** `'MCLMicroDrive'`.

### `ErrorCodes`
Structure describing error codes returned by the instrument.
- The index corresponds to the error code:
- `ErrorCodes(1)` <-> Error code 0
- `ErrorCodes(2)` <-> Error code -1
- `ErrorCodes(3)` <-> Error code -2
- ...

### `LastError`
The last error returned by the instrument (struct).

### `DLLVersion`
Version number for the `MicroDrive.dll` file used.

### `DLLRevision`
Revision number for the `MicroDrive.dll` file used.

### `SerialNumber`
Serial number for the micro-drive being used.

### `DLLPath`
Directory containing the `MicroDrive.dll` file.

### `CurrentPosition`
Current position of the stage (in millimeters).
**Default:** `NaN`.

### `MinPosition`
Minimum position of the stage (in millimeters).
**Note:** Without a position encoder, this value is `NaN`.

### `MaxPosition`
Maximum position of the stage (in millimeters).
**Note:** Without a position encoder, this value is `NaN`.

### `StepSize`
Size of a single step of the stage (in millimeters).

### `VelocityBounds`
Minimum and maximum velocities of the stage (in mm/s).
**Type:** 2x1 array `[min; max]`.
**Default:** `NaN(2, 1)`.

### `Axis`
Axis of the stage.
**Type:** `char` (`'X'`, `'Y'`, or `'Z'`).
**Default:** `'Z'`.

### `PositionUnit`
Units used for the stage position (default: `'millimeters'`).
**Note:** This is for informational purposes and should not be changed.

### `DeviceHandle`
Integer specifying the device handle.
**Default:** `0`.

## Hidden Properties

### `StartGUI`
Indicates whether the GUI should start when creating an instance of the class.
**Default:** `false`.

## Public Properties

### `Velocity`
Velocity of stage movements (in mm/s).
**Type:** Scalar array.
**Default:** `NaN`. This value is set by `moveDistance()` on its first call if `VelocityBounds` is defined.
## Key Methods
- **Constructor (`mic.linearstage.MCLMicroDrive(AutoConnect)`):** Initializes a connection to the MCL stage. If `AutoConnect` is true, the constructor attempts to establish a connection immediately.
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
- mic.linearstage.abstract.m
- mic.abstract.m
- MATLAB 2014b or higher
- MCL MicroDrive files installed on the system.
- MicroDrive.dll located typically in `C:\Program Files\Mad City Labs\MicroDrive\`

## Usage Example
```matlab
% Assuming MicroDrive.dll is correctly installed and the MATLAB path is set
PX = mic.linearstage.MCLMicroDrive(true);
PX.gui();
PX.moveDistance(5);  % Moves the stage 5 mm from the current position
```
### Citation: David J. Schodt (Lidkelab, 2021) based on mic.linearstage.MCLNanoDrive class.

