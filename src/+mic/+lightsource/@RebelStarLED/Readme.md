# mic.lightsource.RebelStarLED: Matlab Instrument Control Class for the Rebel Star LED

## Description
This class controls a Luxeon Rebel Star LED via a 700 mA 'BUCKPUCK'
model 3023-D-E-700.  The power can be set between 0 and 100% as well as
turned off or on.
The current from the LED driver is regulated by the analog voltage output
of a NI DAQ card. The Constructor requires the Device and Channel details.
The output current, and therfore the light output follows the
relationship
C_out/C_max = (V_off - V_in)/(V_off - V_100)
Where C_out is the output current, V_in is the input voltage,
V_off is the voltage where output current drops to zero and V_100 is the
Voltage where current begins to drop from 100%. V_off and V_100 must be
measured and set in the class.

## Link to Driver:
http://www.luxeonstar.com/700ma-external-dimming-buckpuck-dc-driver-leaded

## Protected Properties

### `InstrumentName`
Descriptive name of the instrument.
**Default:** `'RebelStarLED'`.

### `Power`
Currently set output power.
**Default:** `0`.

### `PowerUnit`
Unit for measuring power.
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

### `V_off`
Voltage at which output current drops to zero.
**Default:** `4.2`.

### `V_100`
Voltage at which current begins to drop from 100%.
**Default:** `3.5`.

### `V_0`
Voltage setting to completely turn off the device.
**Default:** `5`.

### `DAQ`
NI DAQ session object.
**Default:** `[]`.

## Hidden Properties

### `StartGUI`
Indicates whether the GUI should start when creating an instance of the class.
**Default:** `false`.
## Constructor
Example: RS = mic.lightsource.RebelStarLED('Dev1', 'ao1');

## Key Functions:
delete, setPower, on, off, exportState, shutdown

## REQUIREMENTS:
mic.abstract.m
mic.lightsource.abstract.m
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Lidkelab, 2017.

