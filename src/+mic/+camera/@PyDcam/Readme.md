# mic.camera.PyDcam Class Documentation

## Overview
`mic.camera.PyDcam` is a MATLAB class designed for controlling a camera through a Python interface. It extends the `mic.camera.abstract` class and includes methods for camera setup, acquisition control, and image retrieval.

## Protected Properties

### `AbortNow`
Flag to stop acquisition.

### `FigurePos`
Position of the figure window.

### `FigureHandle`
Handle for the figure window.

### `ImageHandle`
Handle for the image display.

### `ReadyForAcq`
Indicates if the camera is ready for acquisition. If not, call `setup_acquisition`.

### `TextHandle`
Handle for text display.

## Protected Properties (with Set Access)

### `CameraIndex`
Index used when more than one camera is present.

### `CameraHandle`
Handle for the camera object.

### `ImageSize`
Size of the current ROI (Region of Interest).

### `LastError`
Last error code encountered.

### `Manufacturer`
Camera manufacturer.

### `Model`
Camera model.

### `CameraParameters`
Camera-specific parameters.

### `CameraSetting`
Specific settings for the camera.

### `XPixels`
Number of pixels in the first dimension.

### `YPixels`
Number of pixels in the second dimension.

### `InstrumentName`
Name of the instrument.
**Default:** `''` (empty string).

## Public Properties

### `Binning`
Binning settings in the format `[binX binY]`.

### `Data`
Last acquired data.

### `ExpTime_Focus`
Exposure time for focus mode.

### `ExpTime_Capture`
Exposure time for capture mode.

### `ExpTime_Sequence`
Exposure time for sequence mode.

### `ROI`
Region of interest in the format `[Xstart Xend Ystart Yend]`.

### `SequenceLength`
Length of the kinetic series.
**Default:** `10`.

### `SequenceCycleTime`
Cycle time for the kinetic series (equivalent to `1/frame rate`).

### `GuiDialog`
GUI dialog object.

### `TimeOut`
Timeout duration (in milliseconds).
**Default:** `10000`.

### `TriggerMode`
Trigger mode for the camera.

## Hidden Properties

### `StartGUI`
Defines whether the GUI starts automatically on object creation.
**Default:** `false`.

## Methods
- **Constructor**: Initializes the camera settings.
- `abort()`: Aborts the ongoing acquisition.
- `shutdown()`: Closes the camera connection and cleans up.
- `errorcheck(funcname)`: Placeholder for error checking.
- `initialize()`: Placeholder for initialization.
- `fireTrigger()`: Placeholder for manual trigger.
- `initializeDcam(envpath)`: Initializes the camera with the specified Python environment path.
- `getlastimage()`: Retrieves the last frame from the camera buffer.
- `getdata()`: Retrieves data based on the current acquisition type.
- `start_focus()`: Starts acquisition in focus mode.
- `start_capture()`: Starts acquisition in capture mode.
- `start_sequence()`: Starts acquisition in sequence mode.
- `setup_acquisition()`: Prepares the camera for acquisition based on the current settings.
- `setup_fast_acquisition(numFrames)`: Prepares the camera for a fast acquisition sequence.
- `triggeredCapture()`: Captures a frame upon receiving a trigger.
- `finishTriggeredCapture()`: Finishes the triggered capture session and retrieves data.
- `get_PropertiesDcam()`: Retrieves camera Properties from the DCAM API.
- `get_propAttr(idprop)`: Retrieves Property attributes from the camera.
- `setCamProperties(Infield)`: Sets camera Properties based on the provided fields.
- `setProperty(idprop, value)`: Sets a camera Property.
- `getProperty(idprop)`: Gets a camera Property.
- `setgetProperty(idprop, value)`: Sets and gets a camera Property.
- `build_guiDialog(GuiCurSel)`: Builds the GUI dialog based on current settings.
- `apply_camSetting()`: Applies changes from the GUI to the camera settings.
- `valuecheck(propname, val)`: Checks and adjusts the value based on the camera setting constraints.
- `exportState()`: Exports the current state of the camera.
- `exportParameters()`: Exports current camera parameters.

## Static Methods
- `funcTest()`: Tests the functionality of the class.
- `camSet2GuiSel(CameraSetting)`: Converts current camera settings into GUI selections.

## Usage
To use `mic.camera.PyDcam`, create an instance of the class and call its methods to interact with the camera. Ensure Python and required libraries are properly set up and accessible to MATLAB.

### CITATION: Sheng Liu, Lidkelab, 2024.

