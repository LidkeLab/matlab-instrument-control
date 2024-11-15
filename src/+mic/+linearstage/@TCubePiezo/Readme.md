# mic.linearstage.TCubePiezo Matlab Instrument Control Class for ThorLabs TCube Piezo

Description
This class controls a linear piezo stage using the Thorlabs TCube Piezo
controller TPZ001 and TCube strain gauge controller TSG001. It uses the Thorlabs
Kinesis C-API via pre-complied mex files.

## Protected Properties

### `PositionUnit`
Units of the position parameter (default: `'um'`).

### `CurrentPosition`
Current position of the device (default: `0`).

### `MinPosition`
Lower limit position (default: `0`).

### `MaxPosition`
Upper limit position (default: `20`).

### `Axis`
Stage axis (X, Y, or Z).

### `SerialNoTPZ001`
Serial number of the TCube Piezo Controller.

### `SerialNoTSG001`
Serial number of the TCube Strain Gauge Controller.

### `Slope`
Strain gauge calibration parameter.

### `Offset`
Strain gauge calibration parameter.

### `InstrumentName`
Name of the instrument (default: `'TCubePiezo'`).

### `WaitTime`
Time to wait before returning after a `setPosition` (in seconds, default: `0`).

## Hidden Properties

### `StartGUI`
Indicates whether the GUI should start when creating an instance of the class.

## Methods

### `TCubePiezo(SerialNoTPZ001, SerialNoTSG001, AxisLabel)`
Creates a `TCubePiezo` object and centers the stage.
- **Example:** `PX = mic.linearstage.TCubePiezo('81843229', '84842506', 'X')`
- Initializes the object and sets up devices for the specified serial numbers and axis.
- Calls methods to open devices, zero the strain gauge, calibrate it, and center the device.

### `delete()`
Destructor that shuts down the object and closes connections to devices.

### `openDevices()`
Opens communication with the piezo (`PZ`) and strain gauge (`SG`) using the Kinesis C-API via MEX files.
- Calls `Kinesis_TLI_BuildDeviceList()` and attempts to establish connections.
- Handles errors during connection with appropriate warnings.

### `closeDevices()`
Closes communication with the piezo (`PZ`) and strain gauge (`SG`). This must be done before using Kinesis or creating new objects.

### `resetDevices()`
Closes and reopens communication with devices, effectively resetting connections.

### `zeroStrainGauge()`
Initiates automatic voltage-position calibration for the strain gauge.
- Puts the device in open loop mode, sets voltage to zero, and reinitializes calibration.

### `calibrateStrainGauge()`
Calibrates the piezo and strain gauge for accurate positioning.
- Moves to predefined positions, reads values from the strain gauge, and calculates slope and offset for calibration.

### `setPosition(Position)`
Sets the piezo stage position in microns.
- Ensures the position is within the specified limits.
- Sends the new position to the piezo controller and updates the GUI.

### `getPosition()`
Returns the currently set position of the device.

### `exportState()`
Exports the current state of the object, including attributes such as position, serial numbers, and calibration parameters.
- **Returns:** Attributes, Data, and Children related to the object's state.

### `shutdown()`
Closes connections to devices and sets power to zero.
## Usage Example:
```matlab
PX=mic.linearstage.TCubePiezo(SerialNoTPZ001,SerialNoTSG001,AxisLabel)
PX.gui()
PX.setPosition(10);
```
## Kinesis Setup:
change these settings in Piezo device on Kinesis Software GUI before you create object:
1-set on "External SMA signal" (in Advanced settings: Drive Input Settings)
2-set on "Software+Potentiometer" (in Advanced settings: Input Source)
3-set on "closed loop" (in Control: Feedback Loop Settings>Loop Mode)
4-check box of "Persist Settings to the Device" (in Settings)

## REQUIRMENT:
mic.Abstract.m
mic.linearstage.abstract.m
Precompiled set of mex files Kinesis_PCC_*.mex64 and Kinesis_SG_*.mex64
The following dll must be in system path or same directory as mex files:
Thorlabs.MotionControl.TCube.Piezo.dll
Thorlabs.MotionControl.TCube.StrainGauge.dll
Thorlabs.MotionControl.DeviceManager.dll

### CITATION: Keith Lidke, LidkeLab, 2017.

