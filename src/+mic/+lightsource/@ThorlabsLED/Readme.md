# mic.lightsource.ThorlabsLED Matlab Instrument Class for control of the Thorlabs LED

## Description
This class controls a LED lamp with different wavelength from Thorlabs.
Requires TTL input from the Analogue Input/Output channel of NI card
to turn the laser ON/OFF as well as set the power remotely.
BNC cable is needed to connect to device.
Set Trig=MOD on control device for Lamp and turn on knob manually
more than zero to control from computer.

## Requirements
- `mic.abstract.m`
- `mic.lightsource.abstract.m`
- MATLAB (R2016b or later)
- Data Acquisition Toolbox
- MATLAB NI-DAQmx driver (installed via the Support Package Installer)

## Installation
Ensure all required files are in the MATLAB path and that the NI-DAQmx driver is correctly installed and configured on your system.

## Protected Properties

### `InstrumentName`
Name of the instrument.
**Default:** `'ThorlabsLED'`.

### `Power`
Currently set output power.
**Default:** `0`.

### `PowerUnit`
Unit of power measurement.
**Default:** `'Percent'`.

### `MinPower`
Minimum power setting.
**Default:** `0`.

### `MaxPower`
Maximum power setting.
**Default:** `100`.

### `IsOn`
On or off state of the device (`0` for OFF, `1` for ON).
**Default:** `0`.

### `NIDevice`
NIDAQ device name (e.g., `Dev1`).

### `AOChannel`
Name of the analog output (AO) channel for the LED on the NIDAQ port (e.g., `ao1`).

### `physicalChannel`
Name of the NIDAQ port used for communication.

### `V_100`
Voltage at which the current begins to drop from 100%.
**Default:** `5`.

### `V_0`
Voltage setting to completely turn off the device.
**Default:** `0`.

### `DAQ`
NI DAQ session object.
**Default:** `[]`.

## Hidden Properties

### `StartGUI`
Indicates whether the GUI should start.
**Default:** `false`.

## Functions:
on(obj)
- Turns the LED lamp ON.
- Usage: obj.on();

off(obj)
- Turns the LED lamp OFF.
- Usage: obj.off();

setPower(obj, Power_in)
- Sets the power level of the lamp.
- Power_in must be between obj.MinPower and obj.MaxPower.
- Usage: obj.setPower(50); % Sets power to 50%

exportState(obj)
- Exports the current state of the lamp.
- Returns a structure with fields for Power and IsOn.
- Usage: state = obj.exportState();

delete(obj)
- Cleans up resources, called before clearing the object.
- Usage: delete(obj);

shutdown(obj)
- Sets power to zero, turns off the lamp, and cleans up resources.
- Usage: obj.shutdown();

## Usage Example
To create an instance of the `mic.lightsource.ThorlabsLED` class:
```matlab
obj = mic.lightsource.ThorlabsLED('Dev1', 'ao1');
Create an object
led = mic.lightsource.ThorlabsLED('Dev1', 'ao1');
Set power to maximum
led.setPower(100);
Turn the LED on
led.on();
Wait for 1 second
pause(1);
Turn the LED off
led.off();

Clean up
led.delete();
```
### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.

