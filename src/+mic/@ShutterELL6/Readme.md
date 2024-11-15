# mic.ShutterELL6

## Overview
mic.ShutterELL6 Matlab Instrument Control Class for the 2-position
slider ELL6, which can be used as a shutter (or filter slider).
This class controls an Elliptec ELL6 shutter, which is USB
connected via a rs232-to-USB2.0 board.  The shutter and the board are
delivered as a package, see the Thorlabs catalog, # ELL6K.
Make the object by: obj=mic.ShutterELL6('COM#',Shutter#)where:
COM# = the number string of the RS232 com port reserved for the shutter;
Shutter# = the address string of the shutter motor, default '0', it
can be between 0 and F.

## Features
- Control of the Elliptec ELL6 shutter via RS232 commands.
- Open and close shutter operations.
- Graphical User Interface (GUI) for manual control of the shutter.
- Export of current shutter state.
- Comprehensive unit testing to ensure functionality.

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'ShutterELL6'`

#### `IsOpen`
- **Description:** Indicates whether the shutter is currently open.

### Public Properties

#### `Comport`
- **Description:** Communication port used for the shutter connection.

#### `ShutterAddress`
- **Description:** Address of the shutter for communication purposes.

#### `RS232`
- **Description:** RS232 communication object used to interface with the shutter.

#### `openstr`
- **Description:** Command string used to open the shutter.

#### `closestr`
- **Description:** Command string used to close the shutter.

#### `StartGUI`
- **Description:** Determines whether to use `mic.abstract` to bring up the GUI (no need for a separate GUI function in `mic.ShutterTTL`).
- **Default Value:** `0`

## Requirements
- mic.abstract.m
- Data Acquisition Toolbox on MATLAB
- MATLAB 2014b or higher

## Note
To use the `mic.ShutterELL6` class, ensure that the required files are in your MATLAB path.

## Usage
To create an instance of the `mic.ShutterELL6` class, specify the COM port and shutter address as arguments:
```matlab
shutter = mic.ShutterELL6('COM3', '0');
shutter.open();  % Opens the shutter
shutter.close(); % Closes the shutter
shutter.gui();
delete(shutter);
```
### Citation: Gert-Jan based on ShutterTLL (by Farzin)

