# miC_GalvoAnalog: Matlab Instrument Class for controlling Galvo Mirror

## Description
The `GalvoAnalog` class controls a Galvo mirror by setting its position through
a fixed output voltage using an NI (National Instruments) DAQ device. The Galvo mirror
is positioned by adjusting the analog output voltage within a specified range (-10V to 10V).

## Class Properties

### Protected Properties

- **`InstrumentName`**
- **Description**: Descriptive name for the instrument.
- **Type**: String
- **Default**: `'GalvoAnalog'`

- **`Voltage`**
- **Description**: Current output voltage applied to the galvo system.
- **Type**: Float
- **Units**: Volts

- **`DAQ`**
- **Description**: The NI DAQ session used for controlling the analog output voltage.
- **Type**: DAQ Session Object

- **`MinVoltage`**
- **Description**: Minimum allowable output voltage of the NI DAQ card.
- **Type**: Float
- **Default**: `-10`
- **Units**: Volts

- **`MaxVoltage`**
- **Description**: Maximum allowable output voltage of the NI DAQ card.
- **Type**: Float
- **Default**: `10`
- **Units**: Volts

### Hidden Properties

- **`StartGUI`**
- **Description**: Flag for determining whether to pop up a GUI upon object creation.
- **Type**: Boolean
- **Default**: `false`

## Constructor
obj=mic.GalvoAnalog('Dev1','ao1');
- Initializes the GalvoAnalog object using the specified NI device (e.g., 'Dev1')
and analog output channel (e.g., 'ao1').

## Key Functions
- **delete**: Cleans up the object and sets the output voltage to 0V.
- **exportState**: Exports the current state of the Galvo.
- **setVoltage**: Sets the Galvo position by adjusting the output voltage.

## REQUIREMENTS:
mic.abstract.m
MATLAB NI-DAQmx driver installed via the Support Package Installer

### CITATION: Marjolein Meddens, Lidke Lab 2017

