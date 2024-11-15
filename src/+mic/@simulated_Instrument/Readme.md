# simulated_Instrument: Example for classes inheriting from mic.abstract

## Description
This class is written to serve as a template for implementing
classes inheriting from mic.abstract. This class also serves as a
template for the basic functions such as exportState and funcTest.
## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'SimulatedInst'`

### Public Properties

#### `MinPower`
- **Description:** Minimum power setting for the instrument.
- **Default Value:** `0.5`

#### `MaxPower`
- **Description:** Maximum power setting for the instrument.
- **Default Value:** `2`

#### `Power`
- **Description:** Current power setting of the instrument.

#### `Wavelength`
- **Description:** Current wavelength setting of the instrument.

#### `Result`
- **Description:** Holds the result data or status of the instrument's operation.

### Hidden Properties

#### `StartGUI`
- **Description:** Indicates whether the graphical user interface (GUI) starts automatically.
- **Default Value:** `true`

## Methods

### `simulated_Instrument()`
- **Description:** Constructor method for the `simulated_Instrument` class.
- Calls the superclass constructor to auto-name the object using `mic.abstract`.
- Automatically launches the GUI upon instantiation.

### `exportState()`
- **Description:** Exports the current state of the instrument.
- **Returns:**
- `Attributes`: A struct containing `InstrumentName`.
- `Data`: An empty struct for storing data (can be customized further).
- `Children`: An empty struct for storing child elements.

### Static Method: `funcTest()`
- **Description:** Tests all functionality of the instrument methods and verifies object creation and deletion.
- Creates an instance of `simulated_Instrument`.
- Exports and displays the state.
- Cleans up after testing.

## REQUIREMENTS:
mic.abstract.m
MATLAB software version R2016b or later

### CITATION: Farzin Farzam, LidkeLab, 2017.

