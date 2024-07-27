# MIC_ShutterELL6

## Overview
MIC_ShutterELL6 Matlab Instrument Control Class for the 2-position
slider ELL6, which can be used as a shutter (or filter slider).
This class controls an Elliptec ELL6 shutter, which is USB
connected via a rs232-to-USB2.0 board.  The shutter and the board are
delivered as a package, see the Thorlabs catalog, # ELL6K.
Make the object by: obj=MIC_ShutterELL6('COM#',Shutter#)where:
COM# = the number string of the RS232 com port reserved for the shutter;
Shutter# = the address string of the shutter motor, default '0', it
can be between 0 and F.

## Features
- Control of the Elliptec ELL6 shutter via RS232 commands.
- Open and close shutter operations.
- Graphical User Interface (GUI) for manual control of the shutter.
- Export of current shutter state.
- Comprehensive unit testing to ensure functionality.

## Requirements
- MIC_Abstract.m
- Data Acquisition Toolbox on MATLAB
- MATLAB 2014b or higher

## Note
To use the `MIC_ShutterELL6` class, ensure that the required files are in your MATLAB path.

## Usage
To create an instance of the `MIC_ShutterELL6` class, specify the COM port and shutter address as arguments:
```matlab
shutter = MIC_ShutterELL6('COM3', '0');
shutter.open();  % Opens the shutter
shutter.close(); % Closes the shutter
shutter.gui();
delete(shutter);
```
### Citation: Gert-Jan based on ShutterTLL (by Farzin)

