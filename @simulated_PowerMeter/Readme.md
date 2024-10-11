# Example_PowerMeter Class Documentation

## Class Description
The `Example_PowerMeter` class is an example implementation of the `MIC_PowerMeter_Abstract` class. It provides an interface to the example power meter, implementing all necessary methods to operate the device and manage data acquisition and GUI representation.

### Requirements
- `MIC_PowerMeter_Abstract.m`

## Properties
### Protected Properties
- `InstrumentName`: Name of the instrument (`'ExamplePowerMeter'`)

## Methods

### Constructor
#### `Example_PowerMeter()`
Constructs an instance of the `Example_PowerMeter` class and initializes property values.

### Initialize Properties
#### `initializeProperties(obj)`
Initializes or resets properties of the power meter.

### Graphical User Interface
#### `gui(obj)`
Creates and manages the graphical user interface for the `Example_PowerMeter` class.

#### Callback Functions for GUI
- `startPlotbutton_Callback(source, eventdata)`: Starts plotting data.
- `stopPlotbutton_Callback(source, eventdata)`: Stops plotting data.
- `getbutton_Callback(source, eventdata)`: Retrieves and displays the current measurement.
- `popup_menu_Callback(source, eventdata)`: Handles changes in the measurement type from the popup menu.

### Measure
#### `measure(obj)`
Measures the current power or temperature.
- **Returns**: `output` (measured value)

### Export State
#### `exportState(obj)`
Exports the current state of the power meter.
- **Returns**:
  - `Attributes`: Struct containing `InstrumentName`, `Lambda`, and `Limits`.
  - `Data`: Struct containing `Power` and `T`.
  - `Children`: Empty cell array (no children components in this example).

### Shutdown
#### `Shutdown(obj)`
Cleanly shuts down the power meter connection.

### Connect
#### `connect(obj, testMode)`
Connects to the power meter, either in test mode or actual connection.
- **Parameters**: 
  - `testMode`: Boolean indicating whether to simulate the connection (`false` by default).

### Static Methods
#### `unitTest(testMode)`
Tests the functionality of the class.
- **Parameters**: 
  - `testMode`: Boolean indicating whether to run in test mode (`true` by default).
- **Returns**: `Success` (Boolean indicating if the test was successful).

```matlab
% Example usage of the Example_PowerMeter class

% Create an instance of Example_PowerMeter
powerMeter = Example_PowerMeter();

% Initialize properties
powerMeter.initializeProperties();

% Launch the GUI
powerMeter.gui();

% Measure power
powerReading = powerMeter.measure();

% Export the state of the power meter
[Attributes, Data, Children] = powerMeter.exportState();

% Connect to the power meter
powerMeter.connect(true);  % true for test mode, false for actual connection

% Shutdown the power meter
powerMeter.Shutdown();

% Run the unit test
Success = Example_PowerMeter.unitTest();
```

### Citation: Sajjad Khan, Lidkelab, 2024.
