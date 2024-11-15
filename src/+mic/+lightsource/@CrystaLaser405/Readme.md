# mic.lightsource.CrystaLaser405: Matlab Instrument Class for CrystaLaser 405 nm.

## Description
Controls CrystaLaser module; setting power within the range of 0 to
10 mW (The values measured on 2/23/2017 are 0.25 to 8.5 mW).
The ON/OFF funtion is controlled by a TTL pulse and the power variation
is acheived by providing analog voltage to the laser controller (range 0 to 10V).
The TTL pulse and analog voltage are provided by an NI card.
An STP CAT6 cable connection is needed from the rear board of the
laser controller to the Digital/Analog Input/Output channels of NI card. The
cable pin configuration is:
Pins 4-5: paired (for interlock); Pin 2: Analog; Pin 3: TTL; Pin6: GND.
The power range of the laser is set using the knob on front panel of
controller.

## Note:
Please check the laser is turned on at the controller before calling funtions in
this class

## Protected Properties

### `InstrumentName`
Name of the instrument.
**Default:** `'CrystaLaser405'`.

### `NIVolts`
Analog voltage from the NI card.
**Default:** `0`.

### `MinPower`
Minimum power setting.
**Default:** `0.25`.

### `MaxPower`
Maximum power setting.
**Default:** `8.5`.

### `PowerUnit`
Units of power measurement.
**Default:** `'mW'`.

### `IsOn`
ON/OFF state of the laser (`1` for ON, `0` for OFF).
**Default:** `0`.

### `Power`
Current set power.
**Default:** `0`.

### `DAQ`
NI session.

## Public Properties

### `StartGUI`
Starts the GUI.

## Usage Example
Example: obj=mic.lightsource.CrystaLaser405('Dev1','ao1','Port0/Line3');

## Key Functions:
on, off, State, setPower, delete, shutdown, funcTest

## REQUIREMENTS:
mic.abstract.m
mic.lightsource.abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.

