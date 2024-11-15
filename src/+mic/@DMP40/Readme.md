# mic.DMP40 Class Documentation

## Description
The `mic.DMP40` class controls a deformable mirror using MATLAB. This class interfaces with the mirror through .NET assemblies,
specifically designed for the Thorlabs DMP40 deformable mirror. It utilizes a digital-to-analog converter (DAC)
to set voltages for mirror deformation and can apply different voltages to control tilt, Zernike modes, and other mirror settings.

## Requirements
- MATLAB R2016b or later
- mic.abstract.m
- .NET assemblies installed for Thorlabs DMP40 (.dll files for mirror control)
- .NET environment setup for MATLAB

## Installation and Setup
1. Install MATLAB R2016b or later.
2. Ensure that the required .NET assemblies (`Thorlabs.TLDFMX_64.Interop.dll` and `Thorlabs.TLDFM_64.Interop.dll`) are installed on your system.
3. Ensure that the path to the .NET assemblies is correctly set in your MATLAB environment. For example, use `NET.addAssembly` to load the assemblies:
```matlab
p = 'C:\\Program Files (x86)\\Microsoft.NET\\Primary Interop Assemblies';
NET.addAssembly(fullfile(p,'Thorlabs.TLDFMX_64.Interop.dll'));
NET.addAssembly(fullfile(p,'Thorlabs.TLDFM_64.Interop.dll'));
```

## Class Properties

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive instrument name.
- **Type**: String
- **Default**: `'DMP40'`
- **`DAQ`**:
- **Description**: National Instruments DAQ session object used for communication.
- **Type**: Object
- **`IsOpen`**:
- **Description**: Status indicator for the connection to the device.
- **Type**: Boolean
- **`DMP40mirror`**:
- **Description**: Instance of the .NET `DMP40mirror` class used to interact with the deformable mirror.
- **Type**: Object

### Public Properties
- **`NIDevice`**:
- **Description**: Device number assigned to the NI DAQ card connected via USB.
- **Type**: String or Integer
- **`DOChannel`**:
- **Description**: Digital Output (DO) channel configuration, including both port and line information.
- **Type**: String
- **`StartGUI`**:
- **Description**: Flag indicating whether a GUI should be launched when an instance of the class is created. Utilizes the `mic.abstract` framework for GUI functionality.
- **Type**: Boolean
- **Default**: `0` (false)
- **`NIString`**:
- **Description**: String representation of the NI DAQ device, including port and line configuration used by the shutter.
- **Type**: String

## Key Functions
- **Constructor (`DMP40()`):** Sets up the initial connection to the deformable mirror using specified .NET libraries and verifies device availability.
- **`setMirrorVoltages(VoltageArray)`:** Applies specific voltages to control the overall shape and curvature of the deformable mirror.
- **`setTiltVoltages(VoltageArray)`:** Adjusts the tilt of the mirror using voltages for precise alignment or calibration tasks.
- **`setZernikeModes(ZernikeArray)`:** Utilizes Zernike polynomial coefficients to manipulate the mirror surface for advanced optical wavefront shaping.
- **`delete()`:** Cleans up the connection to the mirror and releases all system resources.
- **`gui()`:** Opens a graphical user interface to facilitate interactive adjustments and monitoring of the mirror settings.
- **`exportState()`:** Captures and returns the current operational state of the deformable mirror, including any settings or adjustments made during operation.

## Usage Example
```matlab
Initialize the deformable mirror
mirror = mic.DMP40();

Set mirror voltages for a specific application
mirror.setMirrorVoltages([1.0, 0.5, 0.3, ...]);

Modify the tilt of the mirror using voltages
mirror.setTiltVoltages([0.1, 0.1]);

Apply Zernike modes for advanced mirror shaping
mirror.setZernikeModes([0.2, 0.4, 0.1, ...]);

Clean up and delete the object when done
delete(mirror);
```
### CITATION: Ellyse Taylor, Lidke Lab, 2024.

