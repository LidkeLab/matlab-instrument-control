# mic.camera.Imaq Class Documentation

## Overview
`mic.camera.Imaq` is a MATLAB class designed for camera control using the Image Acquisition Toolbox. It extends the `mic.camera.abstract` class and includes methods for initializing the camera, managing acquisitions, and retrieving images.

## Protected Properties

### `AbortNow`
Stop acquisition flag.

### `FigurePos`
Position of the figure window.

### `FigureHandle`
Handle for the figure window.

### `ImageHandle`
Handle for the image display.

### `ReadyForAcq`
Indicates if the camera is ready for acquisition. If not, `setup_acquisition` should be called.

### `TextHandle`
Handle for text display.

### `CameraHandle`
Handle for the camera object.

### `CameraCap`
Camera capabilities.

### `CameraIndex`
Index used when more than one camera is present.

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
Camera-specific settings.

### `XPixels`
Number of pixels in the first dimension.

### `YPixels`
Number of pixels in the second dimension.

### `InstrumentName`
Name of the instrument.
**Default:** `''` (empty string).

### `Expfield`
Field for experiment settings.

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

### `SequenceCycleTime`
Cycle time for the kinetic series (equivalent to `1/frame rate`).

### `GuiDialog`
GUI dialog object.

## Hidden Properties

### `StartGUI`
Defines whether the GUI starts automatically on object creation.
**Default:** `false`.

## Methods
- **Constructor**: Initializes the camera with optional parameters for adaptor name, format, and device ID.
- `abort()`: Aborts the ongoing acquisition.
- `shutdown()`: Stops the camera and cleans up the handle.
- `initializeImaq(AdaptorName, Format, DevID)`: Initializes the camera with specific settings.
- `setup_acquisition()`: Configures the camera for the current acquisition mode.
- `setup_softwareTrigger(TriggerN)`: Prepares the camera for software triggered acquisition.
- `start_softwareTrigger()`: Starts acquisition using software triggers.
- `getlastimage()`: Retrieves the last captured image.
- `getdata()`: Retrieves data based on the current acquisition type.
- `start_focus()`: Starts acquisition in focus mode.
- `start_capture()`: Starts acquisition in capture mode.
- `start_sequence()`: Starts acquisition in sequence mode.
- `setCamProperties(Infield)`: Applies camera settings from a structured input.
- `build_guiDialog(GuiCurSel)`: Constructs the GUI dialog based on current settings.
- `apply_camSetting()`: Applies GUI changes to the camera settings.
- `getExpfield()`: Determines the appropriate exposure field from camera settings.
- `valuecheck(prop, val)`: Checks and adjusts the value based on camera constraints.

## Static Methods
- `funcTest()`: Tests the functionality of the class.
- `camSet2GuiSel(CameraSetting)`: Converts camera settings into GUI selections.

## Usage
To utilize `mic.camera.Imaq`, create an instance of the class specifying the adaptor name, format, and device ID as needed. Use the class methods to control the camera and manage image acquisition within MATLAB.

### CITATION: Sheng Liu, Lidkelab, 2024.

