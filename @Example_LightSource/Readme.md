# Example_LightSource Class Documentation

## Class Description
The `Example_LightSource` class is an example implementation of the `MIC_LightSource_Abstract` class. It simulates a light source, such as a laser, with various functionalities.

### Requirements
- `MIC_LightSource_Abstract.m`

## Properties
### Protected Properties
- `InstrumentName`: Name of the instrument (`'ExampleLightSource'`)
- `PowerUnit`: Unit of power (`'Watts'`)
- `Power`: Current power setting (initially `0`)
- `IsOn`: Status of the light source (`0` for off, `1` for on)
- `MinPower`: Minimum power setting (`0`)
- `MaxPower`: Maximum power setting (`100`)

### Hidden Properties
- `StartGUI`: Boolean indicating if GUI starts automatically (initially `false`)

## Methods

### Constructor
#### `Example_LightSource()`
Constructs an instance of the `Example_LightSource` class.

### Set Power
#### `setPower(obj, power)`
Sets the power of the light source.
- **Parameters**: 
  - `power`: Desired power setting.
- **Error Handling**: 
  - Throws an error if `power` is outside the range of `MinPower` and `MaxPower`.

### Turn On
#### `on(obj)`
Turns on the light source.
- **Error Handling**: 
  - Throws an error if `Power` is not set above `MinPower`.

### Turn Off
#### `off(obj)`
Turns off the light source.

### Shutdown
#### `shutdown(obj)`
Shuts down the light source by turning it off.

### Graphical User Interface
#### `gui(obj)`
Creates and manages the graphical user interface for the `Example_LightSource` class.

#### Callback Functions for GUI
- `sliderfn(~,~)`: Callback function for the slider.
- `setPower(~,~)`: Callback function to set the power.
- `ToggleLight(~,~)`: Callback function for the toggle button.

#### Internal Functions for GUI
- `closeFigure(~,~)`: Closes the figure.
- `gui2properties()`: Updates properties from the GUI.
- `properties2gui()`: Updates the GUI from the properties.

### Export State
#### `exportState(obj)`
Exports the current state of the light source.
- **Returns**:
  - `Attributes`: Struct containing `PowerUnit` and `IsOn`.
  - `Data`: Struct containing `Power`, `MinPower`, and `MaxPower`.
  - `Children`: Empty cell array (no children objects in this example).

### Static Methods
#### `unitTest()`
Tests the functionality of the class.
- **Returns**: `Success` (Boolean indicating if the test was successful).

```matlab
% Example usage of the Example_LightSource class

% Create an instance of Example_LightSource
lightSource = Example_LightSource();

% Set the power
lightSource.setPower(50);

% Turn on the light source
lightSource.on();

% Turn off the light source
lightSource.off();

% Shutdown the light source
lightSource.shutdown();

% Export the state of the light source
[Attributes, Data, Children] = lightSource.exportState();

% Launch the GUI
lightSource.gui();

% Run the unit test
Success = Example_LightSource.unitTest();
```

### Citation: Sajjad Khan, Lidkelab, 2024.
