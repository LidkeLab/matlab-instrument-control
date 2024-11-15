# mic.lightsource.IX71Lamp Class

## Description
The `mic.lightsource.IX71Lamp` class is a MATLAB Instrument Control Class used to manage the Olympus lamp,
which can be turned on and off and adjusted in terms of power. It is part of the microscope control framework
and is particularly useful for applications requiring precise light control.

## Requirements
- MATLAB 2014 or higher
- Data Acquisition Toolbox
- MATLAB NI-DAQmx driver installed via the Support Package Installer
- mic.Abstract.m
- mic.lightsource.abstract.m

## Protected Properties

### `InstrumentName`
Descriptive name of the instrument.
**Default:** `'MIC_IX71Lamp'`.

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
On or off state of the lamp (`0` for OFF, `1` for ON).
**Default:** `0`.

### `LampWait`
Wait time (in seconds) used in the on function.
**Default:** `2`.

### `V_100`
Voltage at which current begins to drop from 100%.
**Default:** `5`.

### `V_0`
Voltage to completely turn off the lamp.
**Default:** `0`.

### `DAQ_AC`
NI DAQ session for the analog channel.
**Default:** `[]`.

### `DAQ_DC`
NI DAQ session for the digital channel.
**Default:** `[]`.

## Public Properties

### `StartGUI`
Indicates whether the GUI should start.

## Key Functions
- **Constructor (`mic.lightsource.IX71Lamp(NIDevice, AOChannel, DOChannel)`):** Initializes the lamp control with specified NI DAQ channels. It sets the output to the minimum and ensures the lamp is off initially.
- **`setPower(Power_in)`:** Sets the lamp's output power as a percentage of its maximum, with adjustments made through the DAQ device.
- **`on()`:** Turns on the lamp using the digital channel to ensure full activation and sets the power to the previously specified level.
- **`off()`:** Completely turns off the lamp using the digital channel.
- **`delete()`:** Cleans up the object, ensuring the lamp is properly shut down to prevent damage or resource locking.
- **`shutdown()`:** Safely turns off the lamp and sets its power to zero.
- **`exportState()`:** Exports the current state of the lamp, including power settings and on/off status.

## Usage Example
```matlab
Define the NI DAQ device and channels
NIDevice = 'Dev1';
AOChannel = 'ao0';
DOChannel = 'Port0/Line0';

Create an instance of the IX71 lamp control
lamp = mic.lightsource.IX71Lamp(NIDevice, AOChannel, DOChannel);

Set the lamp to 50% power and turn it on
lamp.setPower(50);
lamp.on();

Turn off the lamp and clean up
lamp.off();
delete(lamp);
```
### CITATION: Mohamadreza Fazel and Hanieh Mazloom-Farsibaf, Lidkelab, 2017

