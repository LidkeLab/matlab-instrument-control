# mic.camera.HamamatsuCamera Class

## Description
The `mic.camera.HamamatsuCamera` class inherits from `mic.camera.abstract` and is specifically tailored for
controlling Hamamatsu cameras in MATLAB. It offers comprehensive control over camera settings such as exposure time,
binning, ROI (Region of Interest), and acquisition modes (focus, capture, sequence). This class also supports
asynchronous data acquisition, status checks, and advanced configuration through a graphical user interface.

## Protected Properties

### `AbortNow`
Stop acquisition flag.

### `ErrorCode`
Error code encountered during operation.

### `FigurePos`
Position of the figure window.

### `FigureHandle`
Handle for the figure window.

### `ImageHandle`
Handle for the image display.

### `ReadyForAcq`
Indicates if the camera is ready for acquisition. If not, `setup_acquisition` should be called.
**Default:** `0`.

### `TextHandle`
Handle for text display.

### `SDKPath`
Path to the camera SDK.

## Protected Properties (Set Access)

### `CameraHandle`
Handle for the camera object.

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

### `CameraCap`
Capability (all options) of camera parameters.

### `CameraSetting`
Camera-specific settings.

### `Capabilities`
Capabilities structure from the camera.

### `XPixels`
Number of pixels in the first dimension.

### `YPixels`
Number of pixels in the second dimension.

### `InstrumentName`
Name of the instrument.
**Default:** `'HamamatsuCamera'`.

## Hidden Properties

### `StartGUI`
Defines whether the GUI starts automatically on object creation.
**Default:** `false`.

## Key Functions
- **Constructor (`mic.camera.HamamatsuCamera()`):** Initializes the camera, setting up default values and configuring the camera for initial use.
- **`delete()`:** Cleans up resources, ensuring proper shutdown of the camera connection.
- **`initialize()`:** Sets up camera parameters and GUI based on current settings. Required before starting any acquisition.
- **`setup_acquisition()`:** Prepares the camera for data acquisition based on the selected mode (focus, capture, sequence).
- **`start_focus()`, `start_capture()`, `start_sequence()`:** These methods begin data acquisition in focus, capture, or sequence mode, respectively.
- **`abort()`:** Aborts any ongoing data acquisition immediately.
- **`getdata()`:** Retrieves the most recent frame or set of frames from the camera, depending on the acquisition mode.
- **`getlastimage()`:** Fetches the last acquired image from the camera buffer.
- **`shutdown()`:** Properly closes the connection to the camera, ensuring all settings are reset and the camera is left in a stable state.
- **`set.ROI()`, `set.ExpTime_Focus()`, `set.ExpTime_Capture()`, `set.ExpTime_Sequence()`, `set.Binning()`:** These setter methods adjust camera parameters like the region of interest, exposure times for different modes, and binning settings.

## Usage Example
```matlab
Create an instance of the Hamamatsu camera
cam = mic.camera.HamamatsuCamera();

Initialize camera with default settings
cam.initialize();

Set exposure time for focus mode and start focus acquisition
cam.ExpTime_Focus = 0.1;  % in seconds
cam.start_focus();

Change to capture mode, set exposure time, and capture one frame
cam.AcquisitionType = 'capture';
cam.ExpTime_Capture = 0.1;
cam.start_capture();

Set up and start a sequence acquisition
cam.AcquisitionType = 'sequence';
cam.ExpTime_Sequence = 0.01;
cam.SequenceLength = 100;
cam.start_sequence();

Retrieve and display the last acquired data
dipshow(cam.Data);

Export current state of the camera
state = cam.exportState();

Clean up on completion
delete(cam);
```
### Citation: Lidkelab 2020

