# mic.lightsource.NewportLaser488: Matlab Instrument Class for Newport Cyan Laser 488 on TIRF microscope.

## Description
The `mic.lightsource.TIRFLaser488` is a MATLAB instrument class for controlling the Newport Cyan Laser 488 used in
TIRF (Total Internal Reflection Fluorescence) microscopy setups. It integrates functionalities for managing
laser power through ND (Neutral Density) filter wheels and a shutter for toggling the laser ON and OFF.

## Requirements
- `mic.abstract.m`
- `mic.lightsource.abstract.m`
- `mic.NDFilterWheel.m`
- `mic.DynamixelServo.m`
- `mic.ShutterTTL.m`
- MATLAB (R2016b or later)
- Data Acquisition Toolbox

## Installation
Ensure all required files are in the MATLAB path and that your system is properly configured to interface with the hardware components.

## Protected Properties

### `InstrumentName`
Instrument name.
**Default:** `'TIRFLaser488'`.

### `PowerUnit`
Power unit based on each device.
**Default:** `'mW'`.

### `Power`
Currently set power based on the power limit.

### `IsOn`
Laser status (`1` for ON, `0` for OFF).
**Default:** `0`.

### `MinPower`
Lower limit for power.
**Default:** `0`.

### `MaxPower`
Upper limit for power.
**Default:** `100`.

## Private Properties (with Public Get Access)

### `LaserState`
State of the laser (`0` for OFF, other values for ON).
**Default:** `0`.

### `LaserStatus`
Status of the laser.

## Public Properties

### `VecIndex`
Finds the filter wheels combination closest to the user input power.

### `ShutterObj`
Shutter object.

### `FilterWheelObj1`
First filter wheel object.

### `FilterWheelObj2`
Second filter wheel object.

### `FilterPos`
Angle vector showing the position of all ND filters in a wheel.

### `FracTransmVals`
Transmission percentage vector for a set of ND filters.

### `Transmission`
Transmission percentage of both filter wheels.

### `StartGUI`
GUI control for the laser.
**Default:** `0`.

### `Laser488`
Laser object for the 488nm laser.

### `LaserPower`
Power of the laser.

### `LaserTag`
Tag identifier for the laser.

### `Serial`
Serial number of the 488 Laser COM port.

### `DOChannel`
Digital Output channel.

### `PowerIn`
User input for power.

### `PowerVector`
Vector showing different combinations of ND filters in two filter wheels.

### `DAQ`
Data acquisition (DAQ) object.
**Default:** `[]`.

## Key Functions:
- on(obj): Opens the shutter to turn the laser ON.
- Usage: obj.on();

- off(obj): Closes the shutter to turn the laser OFF.
- Usage: obj.off();
- setPower(obj, PowerIn): Sets the laser power by selecting the appropriate ND filters.
- PowerIn should be within the allowed range of obj.MinPower to obj.MaxPower.
- Usage: obj.setPower(50); % Sets power to 50 mW
- exportState(obj): Exports the current state of the laser.
- Returns a structure with fields for Power, IsOn, and InstrumentName.
- Usage: state = obj.exportState();
- delete(obj): Destructs the object and cleans up resources such as shutter and filter wheels.
- Usage: delete(obj);
- shutdown(obj): Safely shuts down the laser by turning it off and setting the power to zero.
- Usage: obj.shutdown();

## Usage
To create an instance of the `mic.lightsource.TIRFLaser488` class:
```matlab
obj = mic.lightsource.TIRFLaser488();
% Create an object
laser = mic.lightsource.TIRFLaser488();

% Set power to 70 mW
laser.setPower(70);

% Turn the laser on
laser.on();

% Wait for a moment
pause(1);

% Turn the laser off
laser.off();

% Clean up
laser.delete();
```
### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.

