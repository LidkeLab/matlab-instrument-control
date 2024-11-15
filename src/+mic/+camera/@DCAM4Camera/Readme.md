# mic.camera.DCAM4Camera contains methods to control Hamamatsu cameras.
This class is a modified version of mic.camera.HamamatsuCamera that uses the
DCAM4 API.
## Protected Properties

### `AbortNow`
Flag for stopping the acquisition process.

### `ErrorCode`
Stores the error code.

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

### `TriggerPause`
Pause duration (in seconds) after firing a trigger in `fireTrigger()`.

### `IsRunning`
Indicates if the camera is currently running.
**Default:** `0`.

### `CameraFrameIndex`
Index for the camera frames.

## Hidden Properties

### `StartGUI`
Defines whether the GUI starts automatically on object creation.
**Default:** `false`.

## Public Properties

### `Binning`
Binning mode, see `DCAM_IDPROP_BINNING`.

### `Data`
Last acquired data.
**Default:** `[]`.

### `ExpTime_Focus`
Exposure time for focus mode.

### `ExpTime_Capture`
Exposure time for capture mode.

### `ExpTime_Sequence`
Exposure time for sequence mode.

### `ROI`
Region of interest specified as `[Xstart Xend Ystart Yend]`.

### `SequenceLength`
Length of the kinetic series.
**Default:** `1`.

### `SequenceCycleTime`
Cycle time for the kinetic series (in seconds).

### `FrameRate`
Frame rate of the camera.

### `TriggerMode`
Trigger mode for the Hamamatsu sCMOS camera.

### `GuiDialog`
GUI dialog object.

### `Timeout`
Timeout duration for several DCAM functions (in milliseconds).
**Default:** `10000`.

### `Abortnow`
Flag for stopping the acquisition process (duplicated with `AbortNow`).

## Methods

### `DCAM4Camera()`
Constructor for creating an instance of `DCAM4Camera`.

### `errorcheck()`
Performs error checking.

### `getcamera()`
Method to retrieve camera settings (implementation not shown).

### `abort()`
Aborts the current capture.
- Stops capture with `DCAM4StopCapture`.
- Releases memory with `DCAM4ReleaseMemory`.

### `getlastimage()`
Returns the last image captured by the camera.
- Reshapes and returns the image data.

### `getoneframe()`
Returns a specific frame from the camera.
- Retrieves and reshapes a specified frame.

### `getdata()`
Grabs data from the camera based on acquisition type (`focus`, `capture`, `sequence`).

### `initialize()`

