# mic.camera.AndorCamera class

## Description
The `mic.camera.AndorCamera` class in MATLAB is designed for controlling Andor cameras using the Andor SDK. This class handles camera operations such as initialization, capturing images, adjusting settings, and more.

## Features
- Full control over Andor camera settings including exposure time, ROI, and binning.
- Different acquisition modes: focus, capture, and sequence.
- Integration with the Andor SDK for advanced camera operations.
- Provides methods for starting and stopping acquisitions, setting temperatures, and managing the camera shutter.

## Requirements
- MATLAB
- Andor MATLAB SDK version 2.94.30005 or higher.

## Properties
- `CameraObj`: Object representing the camera.
- `ImageSize`: Current size of the ROI.
- `ExpTime_Focus`, `ExpTime_Capture`, `ExpTime_Sequence`: Exposure times for different modes.
- `ROI`: Current region of interest.
- `Binning`: Current binning settings.

## Methods
### `start`
Initializes the camera and sets up the acquisition based on the current settings.

### `capture`
Starts the acquisition process in capture mode.

### `focus`
Starts a continuous acquisition in focus mode to aid in focusing the camera.

### `sequence`
Starts acquisition in sequence mode, capturing a series of images based on the sequence settings.

### `setTemperature`
Sets the camera's temperature for thermoelectric cooling.

### `getlastimage`
Retrieves the most recent image captured by the camera.

### `shutdown`
Safely shuts down the camera, ensuring that all resources are properly released.

## Usage Example

```matlab
Create an instance of the mic.camera.AndorCamera
camera = mic.camera.AndorCamera();

Set exposure time for focus mode
camera.ExpTime_Focus = 0.1;

Start the camera in focus mode
camera.start_focus();

Capture a single image
camera.start_capture();

Close the camera
camera.shutdown();
```
## Requirement:
Andor MATLAB SDK 2.94.30005 or higher

## To Do:
Add quarter CCD left, right ROI selection (for TIRF system).
Fix warning error about not acquiring
Add shutter options so capture can be run with/without shutter
GUI doesn't show programic updates to CameraSettings
Clear of object doesn't warm up to shutdown.

### Citations: Lidkelab, 2017.

