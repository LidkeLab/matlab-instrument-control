# mic.camera.AndorCameraZyla Class

## Description
The `mic.camera.AndorCameraZyla` class interfaces with Andor Zyla cameras via the Andor SDK3, providing comprehensive control over camera operations in MATLAB. This class enables precise manipulation of camera settings and acquisition modes, tailored specifically for the Zyla model.

## Installation
Install Andor MATLAB SDK3 to the default directory, e.g. C:\Program Files\MATLAB\R2024b\. This will ensure the dependency files will be installed into the correct directories, otherwise, the SDK won't work.
The first time an object of this class is created, the user must direct the object to the 'andorsdk3functions.mexw64' file.  This is usually located here:  C:\Program Files\MATLAB\R2024b\toolbox\AndorSDK3\

## Features
- Direct integration with Andor SDK3.
- Support for multiple acquisition modes including focus, capture, and sequence.
- Customizable Region of Interest (ROI), binning settings, and exposure times.
- Automatic handling of camera initialization and shutdown procedures.

## Requirements
- MATLAB
- Andor MATLAB SDK3 version 2.94.30005 or higher.

## Properties
- `CameraHandle`: Reference to the camera handle used in SDK calls.
- `ImageSize`: Current size of the ROI in pixels.
- `ExpTime_Focus`, `ExpTime_Capture`, `ExpTime_Sequence`: Exposure times for different operational modes.
- `ROI`: Region of interest specified as [Xstart, Xend, Ystart, Yend].
- `Binning`: Pixel binning configuration.

## Methods
### `initialize`
Prepares the camera for operation by loading the SDK and setting default configurations.

### `start_sequence`
Initiates a sequence acquisition based on predefined settings.

### `start_focus`
Starts a continuous acquisition for focusing purposes, providing live updates to the image display.

### `start_capture`
Captures a single image using the current camera settings.

### `shutdown`
Properly closes the camera connection and cleans up resources to ensure a safe shutdown process.

## Usage Example

```matlab
Instantiate the camera
camera = mic.camera.AndorCameraZyla();

Configure the camera for a sequence acquisition
camera.setup_acquisition('sequence');
camera.SequenceLength = 100;
camera.start_sequence();
Capture a single frame
camera.start_capture();
Shut down the camera
camera.shutdown();
```
### CITATION: Sandeep Pallikkuth, Lidke Lab, 2018

