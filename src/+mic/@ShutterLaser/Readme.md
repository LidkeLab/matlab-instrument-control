# mic.shutterTTL: Matlab Instrument Control Class for the shutter

This class controls on/off of a laser object

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'ShutterLaser'`

#### `Laserobj`
- **Description:** Object representing the laser associated with the shutter control.

#### `IsOpen`
- **Description:** Indicates the current state of the shutter (open or closed).

### Public Properties

#### `StartGUI`
- **Description:** Determines whether to use `mic.abstract` to bring up the GUI.
- **Default Value:** `0`

## Methods

### Public Methods

#### `ShutterLaser(laserobj)`
- **Description:** Constructor for `ShutterLaser`.
- **Usage:** `obj = ShutterLaser(laserobj)`

#### `delete(obj)`
- **Description:** Deletes the GUI figure when the object is deleted.

#### `close(obj)`
- **Description:** Closes the shutter by turning off the laser.

#### `open(obj)`
- **Description:** Opens the shutter by turning on the laser.

#### `gui(obj)`
- **Description:** Creates a GUI to control the shutter with a toggle button to open or close the shutter.

#### `exportState(obj)`
- **Description:** Exports the current state of the object.
- **Returns:** `Attributes`, `Data`, `Children`.

### Static Methods

#### `funcTest(laserobj)`
- **Description:** Tests the functionality of the `ShutterLaser` class, including opening, closing, and exporting state.
- **Usage:** `State = funcTest(laserobj)`

Example: obj=mic.ShutterLaser(laserobj);
Functions: close, open, delete, exportState

REQUIRES:
mic.abstract.m

CITATION: Sheng, Lidkelab, 2024.

