# mic.lightsource.CrystaLaser561: Matlab Instrument Class for control of CrystaLaser 561 nm.

## Description:
This class Controls CrystaLaser module; can switch the laser ON/OFF, but cannot
set power. Power for this laser is set using the knob on the front
panel of controller.
Requires TTL input from the Digital Input/Output channel of NI card
to turn the laser ON/OFF remotely. STP CAT6 cable connection from
rear board of laser controller to the NI card should have pin
configuration: Pins 4-5: paired (for interlock); Pin 3: TTL;
Pin6: GND.

## Protected Properties

### `InstrumentName`
Name of the instrument.
**Default:** `'CrystaLaser561'`.

### `MinPower`
Minimum power setting.
**Default:** `0`.

### `MaxPower`
Maximum power setting.
**Default:** `25`.

### `PowerUnit`
Units of power measurement.
**Default:** `'mW'`.

### `IsOn`
ON/OFF state of the laser (`1` for ON, `0` for OFF).
**Default:** `0`.

### `Power`
Current power of the laser.

### `DAQ`
NI card session.

## Public Properties

### `StartGUI`
Starts the GUI.

## Constructor
Example: obj=mic.lightsource.CrystaLaser561('Dev1','Port0/Line0:1');

## Key Functions
on, off, delete, shutdown, exportState, setPower

## REQUIREMENTS:
mic.Abstract.m
mic.lightsource.abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Sandeep Pallikkuth, LidkeLab, 2017.

