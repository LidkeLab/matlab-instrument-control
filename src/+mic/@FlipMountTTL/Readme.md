# mic.FlipMountTTL: Matlab Instrument Control Class for the flipmount

## Description
This class controls a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M
controller.  Controller is triggered in via a TTL signal passing from the
computer to the controller through a NI-DAQ card. TTL signal lets the
flipmount to be set in up or down positions, so flipmount is regulated by
the Digital voltage output of the NI-DAQ card.

## Usage Example
Make the object by: obj = mic.FlipMountTTL('Dev#', 'Port#/Line#') where:
Dev#  = Device number assigned to DAQ card by computer USB port of the
Port# = Port number in use on the DAQ card by your flipmount connection
Line# = Line number in use on the DAQ card by the Port

## Class Properties

### Protected Properties

- **`InstrumentName`**
- **Description**: Descriptive name for the instrument.
- **Type**: String
- **Default**: `'FlipMountTTL'`

- **`DAQ`**
- **Description**: DAQ session object used to communicate with and control the TTL-driven flip mount.
- **Type**: DAQ Session Object

- **`IsOpen`**
- **Description**: Indicates whether the flip mount is currently open.
- **Type**: Boolean

### Public Properties

- **`NIDevice`**
- **Description**: The device number of the DAQ card connected via the USB port of the computer.
- **Type**: String or Integer

- **`DOChannel`**
- **Description**: The digital output channel information, including both port and line details.
- **Type**: String or Numeric Identifier

- **`StartGUI`**
- **Description**: Determines if the graphical user interface (GUI) will be launched upon object creation.
- **Type**: Boolean
- **Default**: `0` (disabled)

- **`NIString`**
- **Description**: Displays a string that combines the device, port, and line details being used by the flip mount.
- **Type**: String

## Constructor
Example: obj = mic.FlipMountTTL('Dev1', 'Port0/Line1');

## Key Functions: FilterIn, FilterOut, gui, exportState

## REQUIREMENTS:
mic.abstract.m
Data Acquisition Toolbox on MATLAB
MATLAB NI-DAQmx driver in MATLAB installed via the Support Package
Installer
type "SupportPackageInstaller" on command line to install the support
package for NI-DAQmx

### CITATION: Farzin Farzam, Lidkelab, 2017.

