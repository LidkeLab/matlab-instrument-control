# This class is an example implementation of mic.lightsource.abstract.
This class provides full functionalities for a simulated light source such as Laser.
REQUIRES:
mic.lightsource.abstract.m

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'SimulatedLightSource'`

#### `PowerUnit`
- **Description:** Unit of measurement for power.
- **Default Value:** `'Watts'`

#### `Power`
- **Description:** Current power level.
- **Default Value:** `0`

#### `IsOn`
- **Description:** State of the light source (on/off).
- **Default Value:** `0`

#### `MinPower`
- **Description:** Minimum allowable power.
- **Default Value:** `0`

#### `MaxPower`
- **Description:** Maximum allowable power.
- **Default Value:** `100`

### Hidden Properties

#### `StartGUI`
- **Description:** Determines if the GUI should start automatically.
- **Default Value:** `false`

## Methods

### `simulated_LightSource()`
- **Description:** Constructor for the `simulated_LightSource` class.
- Calls the superclass constructor.

### `setPower(power)`
- **Description:** Sets the power of the light source to a specified value.
- Validates that the input `power` is within the bounds `[MinPower, MaxPower]`.

### `on()`
- **Description:** Turns on the light source if the power is set above the minimum.

### `off()`
- **Description:** Turns off the light source.

### `shutdown()`
- **Description:** Turns off the light source and performs any necessary cleanup.

### `gui()`
- **Description:** Creates and displays a graphical user interface (GUI) for controlling the simulated light source.
- Allows setting power and turning the light source on/off using sliders and toggle buttons.

### `exportState()`
- **Description:** Exports the current state of the light source.

