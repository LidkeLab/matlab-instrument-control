# This is an example implementation of mic.camera.abstract
Matlab Instrument Control Camera Class.
REQUIRES:
mic.abstract.m
## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'SimulatedCamera'`

#### `CameraIndex`
- **Description:** Index to identify the camera instance.
- **Default Value:** `1`

#### `ImageSize`
- **Description:** Resolution of the camera's images in pixels `[XPixels, YPixels]`.
- **Default Value:** `[1024, 768]`

#### `LastError`
- **Description:** Stores the last error message encountered.

#### `Manufacturer`
- **Description:** Manufacturer name of the camera.
- **Default Value:** `'MyCam'`

#### `Model`
- **Description:** Model name of the camera.
- **Default Value:** `'CamModelX100'`

#### `CameraParameters`
- **Description:** Structure defining camera parameters such as `Gain` and `FrameRate`.
- **Default Value:** `struct('Gain', 1, 'FrameRate', 30)`

#### `XPixels`
- **Description:** Horizontal resolution of the camera image.
- **Default Value:** `1024`

#### `YPixels`
- **Description:** Vertical resolution of the camera image.
- **Default Value:** `768`

### Public Properties

#### `Binning`
- **Description:** Binning factor `[horizontal, vertical]` to reduce image resolution.
- **Default Value:** `[1, 1]`

#### `Data`
- **Description:** Data acquired from the camera.

#### `ExpTime_Focus`
- **Description:** Exposure time for focus mode in seconds.
- **Default Value:** `0.01`

#### `ExpTime_Capture`
- **Description:** Exposure time for capture mode in seconds.
- **Default Value:** `0.02`

#### `ExpTime_Sequence`
- **Description:** Exposure time for sequence acquisition in seconds.
- **Default Value:** `0.05`

#### `ROI`
- **Description:** Region of interest for image acquisition `[xStart, xEnd, yStart, yEnd]`.
- **Default Value:** `[1, 1024, 1, 768]`

#### `SequenceLength`
- **Description:** Number of images in a sequence acquisition.
- **Default Value:** `10`

#### `SequenceCycleTime`
- **Description:** Time between consecutive images in a sequence in seconds.
- **Default Value:** `0.1`

#### `TriggerMode`
- **Description:** Specifies the trigger mode used by the camera.
- **Default Value:** `'internal'`

### Hidden Properties

#### `StartGUI`
- **Description:** Indicates whether the GUI starts automatically.
- **Default Value:** `false`

### Protected Properties

#### `AbortNow`
- **Description:** Flag to indicate if an ongoing process should be aborted.
- **Default Value:** `false`

#### `FigurePos`
- **Description:** Stores the position of the GUI figure.

#### `FigureHandle`
- **Description:** Handle for the main GUI figure.

#### `ImageHandle`
- **Description:** Handle for image display in GUI.

#### `ReadyForAcq`
- **Description:** Indicates if the camera is ready for acquisition.
- **Default Value:** `false`

#### `TextHandle`
- **Description:** Handle for text display in GUI.

#### `TimerHandle`
- **Description:** Handle for a timer object used in GUI operations.

## Methods

### `simulated_Camera()`
- **Description:** Constructor method for the `simulated_Camera` class. Initializes the object.

### `exportState()`
- **Description:** Exports the state of the camera, including parameters and settings.

### `abort()`
- **Description:** Aborts an ongoing acquisition or operation.

### `errorcheck(funcname)`
- **Description:** Checks and displays any errors for the given function.

### `getlastimage()`
- **Description:** Retrieves the last acquired image.
- **Returns:** Simulated random image data.

### `getdata()`
- **Description:** Acquires and returns image data.

### `initialize()`
- **Description:** Initializes camera settings.

### `setup_acquisition()`
- **Description:** Sets up acquisition parameters.

### `shutdown()`
- **Description:** Shuts down the camera and releases resources.

### `start_capture()`
- **Description:** Starts capture mode.
- **Returns:** Simulated random image data.

### `start_focus()`
- **Description:** Starts focus mode.
- **Returns:** Simulated random image data.

### `start_sequence()`
- **Description:** Starts sequence acquisition mode.
- **Returns:** Simulated random sequence data.

### `fireTrigger()`
- **Description:** Fires a trigger for acquisition.

### `setupGUI()`
- **Description:** Sets up a GUI for controlling the camera.

### `onButtonClicked(src)`
- **Description:** Handles button clicks in the GUI.

### `closeGui()`
- **Description:** Closes the GUI and releases associated resources.

### `setupTemperatureTimer(displayHandle)`
- **Description:** Sets up a timer to periodically update temperature display.

### `updateTemperatureDisplay(displayHandle)`
- **Description:** Updates temperature displayed in GUI.

### `stopAndCleanupTimer()`
- **Description:** Stops and cleans up the timer.

### `call_temperature()`
- **Description:** Retrieves simulated temperature values.

### Protected Methods


