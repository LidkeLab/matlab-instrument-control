# mic.SyringePump Matlab Instrument Class for control of Syringe Pump by kdScientific (Model: LEGATO100)

## Description
This class controls the Syring Pump via a USB port. It is required to
install the drivers from the given CD drivers

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** The name of the instrument.
- **Default Value:** `'SyringPump'`

#### `PumpAddress`
- **Description:** Index for each pump connected to one computer.

#### `SerialNumber`
- **Description:** Serial number of the device.

### Public Properties

#### `StartGUI`
- **Description:** Indicates if the GUI should be started.

#### `S`
- **Description:** Serial object used for communication with the pump.

#### `Force`
- **Description:** Force applied during pumping as a percentage.

#### `Target`
- **Description:** Target final volume for pumping.

#### `Mode`
- **Description:** Mode of the pump operation.
- **Default Value:** `'Infuse Only'`

#### `Rate`
- **Description:** Rate at which to pump.

#### `MaxRate`
- **Description:** Maximum pumping rate, which depends on the syringe type.

#### `MinRate`
- **Description:** Minimum pumping rate, which depends on the syringe type.

#### `SyringeVolume`
- **Description:** Maximum volume of the syringe.

#### `SyringeList`
- **Description:** List of all possible syringe types.

#### `TypeSyringe`
- **Description:** Type of syringe being used.
- **Default Value:** `'bdp'`

#### `N_typeSyringe`
- **Description:** Number representing the type of syringe used for this pump.
- **Default Value:** `17`

## Constructor
obj=mic.SyringePump();

## Key Function:
delete, getForce, getTarget, getTypeSyringe, setForce,
setTarget, setSyringe, setRate, run, stop, exportState, funcTest

## REQUIREMENTS:
mic.abstract.m
MATLAB software version R2016b or later
Instrument Control Toolbox
Syringe Pump driver installed via the CD drivers

### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.

