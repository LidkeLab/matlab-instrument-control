# mic.ShutterTTL: Matlab Instrument Control Class for the shutter

## Description
This class controls a Thorlabs SH05 shutter via a Thorlabs KSC101
solenoid controller. KSC101 controller is triggerd in
(put the controller in trigger mode) via a TTL signal passing
from the computer to the controller through a NI-DAQ card.
TTL signal lets the shutter to be set open or close.
so shutter is regulated by the Digital voltage output of the NI-DAQ card.
Make the object by: obj=mic.ShutterTTL('Dev#','Port#/Line#')where:
Dev# = Device number assigned to DAQ card by computer USB port of the
Port# = Port number in use on the DAQ card by your shutter connection
Line# = Line number in use on the DAQ card by the Port.

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'ShutterTTL'`

#### `DAQ`
- **Description:** Data acquisition (DAQ) card used for controlling the shutter.

#### `IsOpen`
- **Description:** Indicates the current state of the shutter (open or closed).

### Public Properties

#### `NIDevice`
- **Description:** Device number of the DAQ card connected to the USB port.

#### `DOChannel`
- **Description:** Specifies the digital output channel, including port and line information.

#### `StartGUI`
- **Description:** Determines whether to use `mic.Abstract` to bring up the GUI.
- **Default Value:** `0`

#### `NIString`
- **Description:** String representing the combination of Device/Port/Line used by the shutter.

## Constructor
Example: obj=mic.ShutterTTL('Dev1','Port0','Line1');

Key Functions:
close, open, delete, exportState

## REQUIRES:
mic.abstract.m
Data Acquisition Toolbox on MATLAB
MATLAB NI-DAQmx driver in MATLAB installed via the Support Package Installer
type "SupportPackageInstaller" on command line to install the
support package for NI-DAQmx use MATLAB 2014b and higher
Data Acquisition Toolbox Support Package for National Instruments
NI-DAQmx Devices: This add-on can be installed from link:
https://www.mathworks.com/matlabcentral/fileexchange/45086-data-acquisition-toolbox-support-package-for-national-instruments-ni-daqmx-devices

### CITATION: Farzin Farzam, Lidkelab, 2017.

