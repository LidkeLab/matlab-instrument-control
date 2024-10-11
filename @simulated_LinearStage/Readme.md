# Example_LinearStage Class Documentation

## Class Description
The `Example_LinearStage` class is an example implementation of the `MIC_LinearStage_Abstract` class. It simulates a linear stage that can move along one axis.

### Requirements
- `MIC_LinearStage_Abstract.m`

## Properties
### Protected Properties
- `InstrumentName`: Name of the instrument (`'Simulated Linear Stage'`)
- `PositionUnit`: Units of position parameter (e.g., `'mm'`)
- `CurrentPosition`: Current position of the device (initially `0`)
- `MinPosition`: Lower limit position (`0`)
- `MaxPosition`: Upper limit position (`100`)
- `Axis`: Stage axis (`'X'`)

### Hidden Properties
- `StartGUI`: Boolean indicating if GUI starts automatically (initially `false`)

## Methods

### Constructor
#### `Example_LinearStage()`
Constructs an instance of the `Example_LinearStage` class.

### Set Position
#### `setPosition(obj, position)`
Sets the position of the stage to the specified position.
- **Parameters**: 
  - `position`: Desired position within the range `[MinPosition, MaxPosition]`.
- **Error Handling**: 
  - Throws an error if `position` is outside the bounds of `MinPosition` and `MaxPosition`.

### Get Position
#### `getPosition(obj)`
Returns the current position of the stage.
- **Returns**: `pos` (current position)

### Graphical User Interface
#### `gui(obj)`
Creates and manages the graphical user interface for the `Example_LinearStage` class.

#### Callback Functions for GUI
- `positionSlider(~,~)`: Callback function for the slider.
- `setFineStepSize(~,~)`: Callback function to set fine step size.
- `setPos(~,~)`: Callback function to set the position.
- `wheel(~,Event)`: Callback function for mouse wheel scroll.
- `wheelToggle(~,~)`: Callback function to toggle between fine and coarse mouse wheel steps.
- `jogUp(~,~)`: Callback function to jog the stage up.
- `jogDown(~,~)`: Callback function to jog the stage down.

#### Internal Functions for GUI
- `closeFigure(~,~)`: Closes the figure.
- `properties2gui()`: Updates the GUI from the properties.

### Export State
#### `exportState(obj)`
Exports the current state of the linear stage.
- **Returns**:
  - `Attributes`: Struct containing `PositionUnit`, `CurrentPosition`, `MinPosition`, `MaxPosition`, and `Axis`.
  - `Data`: Empty struct (no additional data in this example).
  - `Children`: Empty struct (no children objects in this example).

### Static Methods
#### `unitTest()`
Tests the functionality of the class.
- **Returns**: `Success` (Boolean indicating if the test was successful).

```matlab
% Example usage of the Example_LinearStage class

% Create an instance of Example_LinearStage
linearStage = Example_LinearStage();

% Set the position
linearStage.setPosition(50);

% Get the current position
position = linearStage.getPosition();

% Export the state of the linear stage
[Attributes, Data, Children] = linearStage.exportState();

% Launch the GUI
linearStage.gui();

% Run the unit test
Success = Example_LinearStage.unitTest();
```

### Citation: Sajjad Khan, Lidkelab, 2024.

