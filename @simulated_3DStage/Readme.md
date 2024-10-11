# Example_3DStage Class Documentation

## Class Description
The `Example_3DStage` class is an example implementation of a 3D Stage Class. It simulates a 3D stage that can move along the x, y, and z axes.

### Requirements
- `MIC_3DStage_Abstract.m`

## Properties
### Protected Properties
- `InstrumentName`: Name of the instrument (`'Simulated 3D Stage'`)
- `Position`: Example position `[x, y, z]` (initially `[0, 0, 0]`)
- `PositionUnit`: Example position unit (`'mm'`)

### Hidden Properties
- `StartGUI`: Boolean indicating if GUI starts automatically (initially `false`)

## Methods

### Constructor
#### `Example_3DStage()`
Constructs an instance of the `Example_3DStage` class.

### Center Stage
#### `center(obj)`
Sets the stage to the center `[0, 0, 0]`.

### Set Position
#### `setPosition(obj, position)`
Sets the stage to a specified position.
- **Parameters**: 
  - `position`: A 3-element vector `[x, y, z]`.
- **Error Handling**: 
  - Throws an error if `position` is not a 3-element vector.

### Export State
#### `exportState(obj)`
Exports the state of the stage.
- **Returns**:
  - `Attributes`: Struct containing position unit.
  - `Data`: Struct containing position.
  - `Children`: Empty struct (no children in this example).

### Graphical User Interface
#### `gui(obj)`
Creates and manages the graphical user interface for the `Example_3DStage` class.

#### Callback Functions for GUI
- `gui2properties(~,~)`: Sets the object properties based on the GUI widgets.
- `properties2gui(~,~)`: Sets the GUI widgets based on the object properties.
- `set_pushbutton_Callback(~,~)`: Callback for setting the position.
- `center_pushbutton_Callback(~,~)`: Callback for centering the stage.
- `left_pushbutton_Callback(~,~)`: Callback for moving left.
- `right_pushbutton_Callback(~,~)`: Callback for moving right.
- `up_pushbutton_Callback(~,~)`: Callback for moving up.
- `down_pushbutton_Callback(~,~)`: Callback for moving down.
- `zup_pushbutton_Callback(~,~)`: Callback for moving in the Z direction up.
- `zdown_pushbutton_Callback(~,~)`: Callback for moving in the Z direction down.
- `gui_ZScroll(~,Callbackdata)`: Callback for scrolling the mouse in the Z direction.

### Close GUI
#### `closeGui(obj, src, ~)`
Handles the close request for the GUI.

### Static Methods
#### `unitTest()`
Tests the functionality of the class.
- **Returns**: `Success` (Boolean indicating if the test was successful).

```matlab
% Example usage of the Example_3DStage class

% Create an instance of Example_3DStage
stage = Example_3DStage();

% Center the stage
stage.center();

% Set the stage position to [1, 2, 3]
stage.setPosition([1, 2, 3]);

% Export the state of the stage
[Attributes, Data, Children] = stage.exportState();

% Launch the GUI
stage.gui();

% Close the GUI
stage.closeGui();

% Run the unit test
Success = Example_3DStage.unitTest();
```

### Citation: Sajjad Khan, Lidkelab, 2024.