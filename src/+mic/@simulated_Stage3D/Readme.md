# This class is an simulated implementation of 3D Stage Class.
This class simulates a 3D stage that can move along x,y,z axes.
REQUIRES:
mic.stage3D.abstract.m

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'SimulatedStage3D'`

#### `Position`
- **Description:** Current position represented as a vector `[x, y, z]`.
- **Default Value:** `[0, 0, 0]`

#### `PositionUnit`
- **Description:** Unit of measurement for position.
- **Default Value:** `'mm'` (millimeters)

### Hidden Properties

#### `StartGUI`
- **Description:** Indicates if the GUI should start automatically.
- **Default Value:** `false`

## Methods

### `simulated_Stage3D()`
- **Description:** Constructor method for the `simulated_Stage3D` class.
- Calls the superclass constructor.

### `center()`
- **Description:** Method to set the stage to the center position `(0, 0, 0)`.

### `setPosition(position)`
- **Description:** Sets the stage to a specified position.
- **Parameters:** `position` (must be a 3-element vector `[x, y, z]`).

### `exportState()`
- **Description:** Exports the state of the stage, including position attributes and data.

### `gui()`
- **Description:** Creates and displays a Graphical User Interface (GUI) for interacting with the stage.
- Provides options for setting and adjusting the position using various controls.

### `closeGui(obj, src, ~)`
- **Description:** Close request function for the GUI.

### Static Method: `funcTest()`
- **Description:** Tests the functionality of the class by creating an instance, setting the position, and ensuring basic behaviors work correctly.

CITATION: Sajjad Khan, Lidkelab, 2024.

