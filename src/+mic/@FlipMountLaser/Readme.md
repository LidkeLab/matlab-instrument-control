# mic.FlipMountTTL: Matlab Instrument Control Class for the flipmount

This class controls a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M
controller.  Controller is triggered in via a TTL signal passing from the
computer to the controller through a NI-DAQ card. TTL signal lets the
flipmount to be set in up or down positions, so flipmount is regulated by
the Digital voltage output of the NI-DAQ card.

## Class Properties

### Protected Properties

- **`InstrumentName`**
- **Description**: Descriptive name for the instrument.
- **Type**: String
- **Default**: `'FlipMountLaser'`

- **`Laserobj`**
- **Description**: Object representing the laser that is integrated with the flip mount system.
- **Type**: Laser Object (type unspecified)

- **`LaserPower`**
- **Description**: Power of the laser controlled through the flip mount system.
- **Type**: Numeric (Power level)

- **`IsOpen`**
- **Description**: Indicates whether the flip mount is currently open. The default value indicates that the mount starts open.
- **Type**: Boolean
- **Default**: `1` (open)

### Public Properties

- **`Low`**
- **Description**: Represents the lower threshold or minimum operational setting (e.g., for laser power).
- **Type**: Numeric
- **Default**: `0.1`

- **`StartGUI`**
- **Description**: Determines if the graphical user interface (GUI) will be launched upon object creation using the `mic.Abstract` interface.
- **Type**: Boolean
- **Default**: `0` (disabled)

Make the object by: obj = mic.FlipMountTTL('Dev#', 'Port#/Line#') where:
Dev#  = Device number assigned to DAQ card by computer USB port of the
Port# = Port number in use on the DAQ card by your flipmount connection
Line# = Line number in use on the DAQ card by the Port

Example: obj = mic.FlipMountTTL('Dev1', 'Port0/Line1');
Functions: FilterIn, FilterOut, gui, exportState

REQUIREMENTS:
mic.abstract.m
Data Acquisition Toolbox on MATLAB
MATLAB NI-DAQmx driver in MATLAB installed via the Support Package
Installer
type "SupportPackageInstaller" on command line to install the support
package for NI-DAQmx

CITATION: Farzin Farzam, Lidkelab, 2017.

