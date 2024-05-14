# MIC_NanoMaxPiezos Class

## Description
The `MIC_NanoMaxPiezos` class provides comprehensive control over the three piezo stages (x, y, z) of a Thorlabs NanoMax stage. It is designed to handle precise positioning necessary in advanced microscopy setups.

## Key Features
- Individual control of x, y, and z piezo stages.
- Automatic connection to piezo stages based on serial numbers.
- Methods to center and set positions of piezos.
- Integration with both TCube and KCube piezo systems.

## Requirements
- `MIC_Abstract.m`
- `MIC_3DStage_Abstract.m`
- Piezo control classes (`MIC_TCubePiezo.m` and `MIC_KCubePiezo.m`)
- MATLAB 2016b or later.

## Installation Notes
Before using this class, ensure that all dependent classes and required Thorlabs drivers are installed and properly configured on your system.

## Methods
### `Constructor (MIC_NanoMaxPiezos())`
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
nmPiezos = MIC_NanoMaxPiezos('81850186', '84850145', '81850193', '84850146', '81850176', '84850203', 3);

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

