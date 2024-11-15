# mic.lightsource.DHOMLaser532: Matlab Instrument Class for DHOM Laser 532.

## Description
This class controls DHOM laser module, setting power within the range of 0 to
400 mW (measured on 2/23/2017). The power modulation
is done by providing input analog voltage to the laser controller
from a NI card (range 0 to 5V).
Needs input of NI Device and AO Channel.

## Protected Properties

### `InstrumentName`
Name of the instrument.
**Default:** `'DHOMLaser532'`.

### `MinPower`
Minimum power of the laser.
**Default:** `0`.

### `MaxPower`
Maximum power of the laser.
**Default:** `400`.

### `PowerUnit`
Units of laser power.
**Default:** `'mW'`.

### `IsOn`
ON/OFF state of the laser (`1` for ON, `0` for OFF).
**Default:** `0`.

### `Power`
Current power of the laser.
**Default:** `0`.

## Hidden Properties

### `NIVolts`
NI Analog Voltage Initialization.
**Default:** `0`.

### `DAQ`
NI card session.

## Public Properties

### `StartGUI`
Laser GUI control.

## Constructor
Example: obj=mic.lightsource.DHOMLaser532('Dev2','ao1');

## Key Functions
on, off, State, setPower, delete, shutdown, exportState

## REQUIREMENTS:
mic.abstract.m
mic.lightsource.abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.

