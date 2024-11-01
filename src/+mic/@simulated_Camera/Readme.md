# Example_Camera Class Documentation

## Class Description
The `Example_Camera` class is an example implementation of the `MIC_Camera_Abstract` class, simulating a camera with various functionalities.

### Requirements
- `MIC_Abstract.m`

## Properties
### Protected Properties
- `InstrumentName`: Name of the instrument (`'Simulated Camera'`)
- `CameraIndex`: Index of the camera (`1`)
- `ImageSize`: Size of the image (`[1024, 768]`)
- `LastError`: Last error encountered (initially `''`)
- `Manufacturer`: Manufacturer of the camera (`'MyCam'`)
- `Model`: Model of the camera (`'CamModelX100'`)
- `CameraParameters`: Struct containing camera parameters (`Gain`, `FrameRate`)
- `XPixels`: Number of pixels in the x-dimension (`1024`)
- `YPixels`: Number of pixels in the y-dimension (`768`)

### Public Properties
- `Binning`: Binning setting (`[1 1]`)
- `Data`: Captured data (initially `[]`)
- `ExpTime_Focus`: Exposure time for focus mode (`0.01`)
- `ExpTime_Capture`: Exposure time for capture mode (`0.02`)
- `ExpTime_Sequence`: Exposure time for sequence mode (`0.05`)
- `ROI`: Region of interest (`[1 1024 1 768]`)
- `SequenceLength`: Length of the sequence (`10`)
- `SequenceCycleTime`: Cycle time of the sequence (`0.1`)

### Protected Properties
- `AbortNow`: Flag to indicate abortion (`false`)
- `FigurePos`: Position of the figure
- `FigureHandle`: Handle for the figure
- `ImageHandle`: Handle for the image
- `ReadyForAcq`: Flag to indicate readiness for acquisition (`false`)
- `TextHandle`: Handle for the text
- `TimerHandle`: Handle for the timer object

### Hidden Properties
- `StartGUI`: Boolean indicating if GUI starts automatically (initially `false`)

## Methods

### Constructor
#### `Example_Camera()`
Constructs an instance of the `Example_Camera` class.

### Export State
#### `exportState(obj)`
Exports the state of the camera.
- **Returns**:
  - `state`: Struct containing camera parameters, image size, exposure times, ROI, and binning.

### Abort
#### `abort(obj)`
Sets the `AbortNow` flag to `true` and displays an abortion message.

### Error Check
#### `errorcheck(obj, funcname)`
Checks for errors in the specified function.
- **Parameters**: 
  - `funcname`: Name of the function to check for errors.

### Get Last Image
#### `getlastimage(obj)`
Retrieves the last captured image.
- **Returns**:
  - `out`: Randomly generated image of size `ImageSize`.

### Get Data
#### `getdata(obj)`
Gets the captured data.
- **Returns**:
  - `out`: Randomly generated image of size `ImageSize`.

### Initialize
#### `initialize(obj)`
Initializes the camera settings and sets the `ReadyForAcq` flag to `true`.

### Setup Acquisition
#### `setup_acquisition(obj)`
Sets up acquisition parameters. Initializes the camera if not ready.

### Shutdown
#### `shutdown(obj)`
Shuts down the camera, aborts ongoing processes, stops and deletes the timer, and closes the figure if it is valid.

### Start Capture
#### `start_capture(obj)`
Starts capture mode and returns a dummy image if the camera is ready.
- **Returns**:
  - `img`: Randomly generated image of size `ImageSize` or empty array if not ready.

### Start Focus
#### `start_focus(obj)`
Starts focus mode and returns a dummy image if the camera is ready.
- **Returns**:
  - `img`: Randomly generated image of size `ImageSize` or empty array if not ready.

### Start Sequence
#### `start_sequence(obj)`
Starts sequence acquisition mode and returns a dummy sequence if the camera is ready.
- **Returns**:
  - `seq`: Repeated randomly generated images of size `ImageSize` and `SequenceLength` or empty array if not ready.

### Setup GUI
#### `setupGUI(obj)`
Sets up the graphical user interface with buttons for focus, capture, and sequence acquisition.

#### `onButtonClicked(obj, src)`
Handles button click events, changes button color, and performs corresponding actions (focus, capture, or sequence).

### Close GUI
#### `closeGui(obj)`
Closes the GUI and cleans up resources.

### Setup Temperature Timer
#### `setupTemperatureTimer(obj, displayHandle)`
Sets up a timer to update the temperature display periodically.

### Update Temperature Display
#### `updateTemperatureDisplay(obj, displayHandle)`
Updates the temperature display with the current temperature and status.

### Stop and Cleanup Timer
#### `stopAndCleanupTimer(obj)`
Stops and deletes the timer.

### Call Temperature
#### `call_temperature(obj)`
Calls and returns the temperature and status.
- **Returns**:
  - `temp`: Example temperature in Celsius (`22`)
  - `status`: Temperature status (`1` for stabilized)

## Protected Methods
### Get Properties
#### `get_properties(obj)`
Displays the camera properties.

### Get Temperature
#### `gettemperature(obj)`
Gets the camera temperature.
- **Returns**:
  - `temp`: Example temperature (`25`)
  - `status`: Temperature status (`1` for stabilized)

## Static Methods
### Unit Test
#### `unitTest()`
Tests the functionality of the class.
- **Returns**: `Success` (Boolean indicating if the test was successful).

```matlab
% Example usage of the Example_Camera class

% Create an instance of Example_Camera
camera = Example_Camera();

% Initialize the camera
camera.initialize();

% Setup acquisition parameters
camera.setup_acquisition();

% Start focus mode
img_focus = camera.start_focus();

% Start capture mode
img_capture = camera.start_capture();

% Start sequence acquisition mode
seq_acquisition = camera.start_sequence();

% Export the state of the camera
state = camera.exportState();

% Launch the GUI
camera.setupGUI();

% Close the GUI
camera.closeGui();

% Run the unit test
Success = Example_Camera.unitTest();
```

### Citation: Sajjad Khan, Lidkelab, 2024.

