# MIC_DCAM4Camera class

## Description
The `MIC_DCAM4Camera class` contains methods to control Hamamatsu cameras. This class is a modified version of MIC_HamamatsuCamera that uses the DCAM4 API.

## Key Functions

### Constructor
- **Constructor `MIC_DCAM4Camera()`**: Initializes the camera object.

### Camera Control
- **getcamera(obj)**: Retrieves the camera object.
- **abort(obj)**: Aborts the current capture.
- **getlastimage(obj)**: Returns the last image taken by the camera.
- **getoneframe(obj)**: Returns one frame.
- **getdata(obj)**: Retrieves data from the camera based on the acquisition type.
- **initialize(obj)**: Initializes the camera settings.
- **setup_acquisition(obj)**: Sets up the acquisition process.
- **setup_fast_acquisition(obj)**: Sets up fast acquisition for sequence mode.
- **shutdown(obj)**: Shuts down the camera.
- **prepareForCapture(obj, NImages)**: Prepares the camera for capturing a specified number of images.
- **start_capture(obj)**: Starts the capture process for a single image.
- **start_focus(obj)**: Starts the focus process.
- **start_focusWithFeedback(obj)**: Starts the focus process with feedback.
- **start_sequence(obj, CaptureMode)**: Starts the sequence capture process.
- **start_scan(obj)**: Starts the scan process.
- **getlastframebundle(obj, Nframe)**: Retrieves the last frame bundle.
- **triggeredCapture(obj)**: Fires the trigger and captures an image.
- **fireTrigger(obj)**: Fires the trigger.
- **finishTriggeredCapture(obj, numFrames)**: Finishes the triggered capture.
- **take_sequence(obj)**: Takes a sequence of images.
- **reset(obj)**: Resets the camera.

### Error Handling
- **errorcheck(obj)**: Checks for errors.

### Camera Properties

- **HtsuGetStatus(obj)**: Retrieves the status of the camera.
- **call_temperature(obj)**: Retrieves the temperature of the camera.
- **get_propertiesDcam(obj)**: Retrieves the properties of the camera.
- **get_propAttr(obj, idprop)**: Gets the attributes of a specific property.
- **getProperty(obj, idprop)**: Gets the value of a specific property.
- **setProperty(obj, idprop, value)**: Sets the value of a specific property.
- **setgetProperty(obj, idprop, value)**: Sets and gets the value of a specific property.
- **setCamProperties(obj, Infield)**: Sets multiple camera properties.
- **build_guiDialog(obj, GuiCurSel)**: Builds the GUI dialog.
- **apply_camSetting(obj)**: Applies camera settings from the GUI.

### State Export
- **exportState(obj)**: Exports the state of the camera object.

### Set Methods

- **set.ROI(obj, ROI)**: Sets the Region of Interest.
- **set.ExpTime_Focus(obj, in)**: Sets the focus mode exposure time.
- **set.ExpTime_Capture(obj, in)**: Sets the capture mode exposure time.
- **set.ExpTime_Sequence(obj, in)**: Sets the sequence mode exposure time.
- **set.Binning(obj, in)**: Sets the binning mode.
- **set.SequenceLength(obj, in)**: Sets the sequence length.

### Protected Methods

- **get_properties(obj)**: Retrieves properties (to be implemented).
- **gettemperature(obj)**: Retrieves the temperature (to be implemented).

### Static Methods

- **unitTest()**: Runs unit tests for the class.
- **camSet2GuiSel(CameraSetting)**: Translates current camera settings to GUI selections.

## Usage Example

```matlab
% Create an instance of the camera
camera = MIC_DCAM4Camera();

% Initialize the camera
camera.initialize();

% Set properties
camera.ExpTime_Focus = 0.1;
camera.ROI = [1, 512, 1, 512];

% Start capturing an image
image = camera.start_capture();

% Display the image
imshow(image, []);
```

### CITATION: Sheng Liu, Lidke Lab, 2023.