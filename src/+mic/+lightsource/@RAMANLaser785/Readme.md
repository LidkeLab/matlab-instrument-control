# mic.lightsource.RAMANLaser785

## Description
`mic.lightsource.RAMANLaser785` is a MATLAB class designed to control the 785 nm ONDAX laser used in RAMAN Lightsheet microscopes. This class manages the connection via an RS232-USB interface and provides functionalities such as setting the laser power, reading the current status, and integrating with a calibration file for accurate power settings.

## Requirements
- MATLAB 2016b or later.
- [mic.Abstract](#) and [mic.lightsource.abstract](#) parent classes.
- A calibration file named `Calibration.mat` containing `CurrInterpol` and `PowerInterpol` arrays for current to power conversion.

## Installation
1. Ensure MATLAB 2016b or later is installed on your system.
2. Place the `mic.lightsource.RAMANLaser785.m` file and its parent classes `mic.abstract` and `mic.lightsource.abstract` in your MATLAB path.
3. Ensure that the `Calibration.mat` file is in the same directory as the `mic.lightsource.RAMANLaser785.m` file or adjust the path in the constructor accordingly.

## Protected Properties

### `InstrumentName`
Descriptive name of the instrument.
**Default:** `'RAMANLaser785'`.

### `Serial`
Serial number of the COM port.

## Protected Properties (Public Get Access)

### `Power`
Currently set output power.

### `PowerUnit`
Unit for measuring power.
**Default:** `'mW'`.

### `MinPower`
Minimum power setting.
**Default:** `0.00`.

### `MaxPower`
Maximum power setting.
**Default:** `70`.

### `IsOn`
On or off state of the device (`0` for OFF, `1` for ON).
**Default:** `0`.

### `LaserStatus`
Status of the laser with various operational states:
- `1` = Normal
- `2` = TTL modulation
- `3` = Laser Power Scan
- `4` = Waiting for calibrate laser power
- `5` = Over laser current shutdown
- `6` = TEC over temp shutdown
- `7` = Waiting for temperature stability
- `8` = Waiting 30 seconds

### `CurrInterpol`
Interpolated current values from calibration.

### `PowerInterpol`
Interpolated power values from calibration.

## Public Properties

### `StartGUI`
Flag to indicate GUI control.

## Usage
To use the `mic.lightsource.RAMANLaser785`, instantiate an object of the class with the appropriate COM port.
```matlab
Replace 'COM3' with the actual COM port connected to the laser.
RL785 = mic.lightsource.RAMANLaser785('COM3');
Set the laser power to a specific value in milliwatts.
RL785.setPower(20);  % Set power to 20 mW
Get and print the current power setting from the laser.
RL785.getCurrentPower();

Check and print the current status of the laser.
RL785.getStatus();
Properly turn off the laser and clean up resources.
RL785.delete();
```
### CITATION: Sandeep Pallikkuth, Lidkelab, 2020.

