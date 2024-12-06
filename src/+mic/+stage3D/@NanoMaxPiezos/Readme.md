# mic.stage3D.NanoMaxPiezos Class

## Description
The `mic.stage3D.NanoMaxPiezos` class provides comprehensive control over the three piezo stages (x, y, z) of a Thorlabs NanoMax stage. It is designed to handle precise positioning necessary in advanced microscopy setups.

## Key Features
- Individual control of x, y, and z piezo stages.
- Automatic connection to piezo stages based on serial numbers.
- Methods to center and set positions of piezos.
- Integration with both TCube and KCube piezo systems.

## Requirements
- `mic.abstract.m`
- `mic.stage3D.abstract.m`
- Piezo control classes (`mic.linearstage.TCubePiezo.m` and `mic.linearstage.KCubePiezo.m`)
- MATLAB 2016b or later.

## Installation Notes
Before using this class, ensure that all dependent classes and required Thorlabs drivers are installed and properly configured on your system.

## Public Properties

### `ControllerXSerialNum`
x piezo controller serial number (string).

### `ControllerYSerialNum`
y piezo controller serial number (string).

### `ControllerZSerialNum`
z piezo controller serial number (string).

### `MaxPiezoConnectAttempts`
Maximum attempts to connect to a piezo (default: `1`).

### `StrainGaugeXSerialNum`
x piezo strain gauge serial number (string).

### `StrainGaugeYSerialNum`
y piezo strain gauge serial number (string).

### `StrainGaugeZSerialNum`
z piezo strain gauge serial number (string).

### `StagePiezoX`
Piezo object for x position piezo on the stage.

### `StagePiezoY`
Piezo object for y position piezo on the stage.

### `StagePiezoZ`
Piezo object for z position piezo on the stage.

### `StepSize`
Three-element vector specifying the step size in each direction.

## Protected Properties

### `InstrumentName`
Meaningful instrument name (default: `'NanoMaxStagePiezos'`). This property should not be modified by users.

### `Position`
Vector `[x, y, z]` giving the current piezo positions. This property should not be set directly by users.

### `PositionUnit`
Units of the position parameter (e.g., `um`, `mm`, etc.). This property should not be set directly by users.

## Hidden Properties

### `StartGUI`
Flag to control whether the GUI opens on object creation (default: `0`).
## Methods
### `Constructor (mic.stage3D.NanoMaxPiezos())`
Initializes piezo controllers for x, y, and z axes based on provided serial numbers. It attempts to connect to the piezos, with error handling to manage connection issues.

### `center()`
Centers all three piezo stages.

### `setPosition([x, y, z])`
Sets the position of the piezo stages to specified x, y, and z coordinates.

### `exportState()`
Exports the current state of all piezo stages, providing detailed attributes for each stage.

### `delete()`
Properly deletes piezo stage objects and cleans up resources to prevent memory leaks.

## Usage Example
```matlab
% Initialize NanoMax Piezos
nmPiezos = mic.stage3D.NanoMaxPiezos('81850186', '84850145', '81850193', '84850146', '81850176', '84850203', 3);

% Center all piezos
nmPiezos.center();

% Set a specific position
nmPiezos.setPosition([10, 10, 5]);

% Export the current state
state = nmPiezos.exportState();
disp(state);

% Clean up on completion
delete(nmPiezos);
```
### CITATION: David James Schodt (Lidkelab, 2018)

