# mic.lightsource.VortranLaser488: Matlab Instrument Class for Vortran Laser 488.

## Description
Controls Vortran laser module, setting power within the range of 0 to
50 mW. This is acheived by providing input voltage to the laser
controller from a NI card (range 0 to 5V).
Needs input of NI Device and AO Channel.
The "External Control" and Max Power Range" for the laser needs to
be set by connecting the laser to the computer by miniUSB-USB cable
and using the Vortran_Stradus Laser Control Software Version 4.0.0
(CD located in second draw of filing cabinet in room 118).

## Protected Properties

### `InstrumentName`
Name of the instrument.
**Default:** `'VortranLaser488'`.

### `NIVolts`
NI Analog Voltage Initialization.
**Default:** `0`.

### `MinPower`
Minimum power of the laser.
**Default:** `0`.

### `MaxPower`
Maximum power of the laser.
**Default:** `50`.

### `PowerUnit`
Units of laser power.
**Default:** `'mW'`.

### `IsOn`
ON/OFF state of the laser (`1` for ON, `0` for OFF).
**Default:** `0`.

### `Power`
Current power of the laser.
**Default:** `0`.

### `DAQ`
NI card session.

## Public Properties

### `StartGUI`
Laser GUI.
## Constructor
obj=mic.lightsource.VortranLaser488('Dev1','ao1');
## Key Functions:
on, off, exportState, setPower, delete, shutdown

## REQUIREMENTS:
mic.Abstract.m
mic.lightsource.abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.

