# mic.Reg3DTrans

## Description
This class Register a sample to a stack of transmission images Class that performs 3D registration using transmission images

## INPUT
CameraObj - camera object -- tested with mic.AndorCamera only
StageObj - stage object -- tested with mic.MCLNanoDrive only
LampObj - lamp object -- tested with mic.IX71Lamp only, will work
with other lamps that inherit from
LightSource_Abstract
Calibration file (optional)

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'ShutterELL6'`

#### `IsOpen`
- **Description:** Indicates whether the shutter is currently open.

### Public Properties

#### `Comport`
- **Description:** Communication port used for the shutter connection.

#### `ShutterAddress`
- **Description:** Address of the shutter for communication purposes.

#### `RS232`
- **Description:** RS232 communication object used to interface with the shutter.

#### `openstr`
- **Description:** Command string used to open the shutter.

#### `closestr`
- **Description:** Command string used to close the shutter.

#### `StartGUI`
- **Description:** Determines whether to use `mic.abstract` to bring up the GUI (no need for a separate GUI function in `mic.ShutterTTL`).
- **Default Value:** `0`

### Hidden Properties
- **`StartGUI`**: Defines GUI start mode (default: `false`).
- **`PlotFigureHandle`**: Handle for plotting calibration and alignment results.
## SETTING (IMPORTANT!!)
There are several Properties that are system specific. These need
to be specified after initialization of the class, before using
any of the functionality. See Properties section for explanation
and which ones.

## Constructor

### `Reg3DTrans(CameraObj, StageObj, [CalFileName])`
Creates a `Reg3DTrans` object.
- **Parameters**:
- `CameraObj`: Camera object for image acquisition.
- `StageObj`: Stage object for movement control.
- `CalFileName` (optional): Path to calibration file containing `PixelSize` and `OrientationMatrix`.

## Public Methods

### Calibration Methods
- **`calibrate(PlotFlag)`**: Calibrates the orientation matrix between the camera and stage.
- **Parameters**:
- `PlotFlag` (optional): Boolean indicating whether to plot results.

- **`takerefimage()`**: Takes a new reference image for alignment.

- **`saverefimage()`**: Saves the reference image to a `.mat` file.

### Alignment Methods
- **`align2imageFit()`**: Aligns the current image to the reference image using iterative optimization.

- **`findXYShift()`**: Finds the XY shift between the current and reference images.

- **`findZPos()`**: Finds the best Z-position for alignment using cross-correlation.

### Z-Stack Collection
- **`collect_zstack(ZStackMaxDev, ZStackStep, NMean)`**: Collects a Z-stack of images.
- **Parameters**:
- `ZStackMaxDev`: Maximum deviation for Z-stack (default: `ZStack_MaxDev`).
- `ZStackStep`: Step size for Z-stack (default: `ZStack_Step`).
- `NMean`: Number of images to average per position (default: `NMean`).

### Image Capture Methods
- **`capture()`**: Captures a single image.
- **`capture_single()`**: Captures a single image with predefined settings.

### Utility Methods
- **`showoverlay()`**: Displays an overlay of the aligned image on top of the reference image.
- **`savealignment()`**: Saves the current, reference, and overlay images.

### State Export
- **`exportState()`**: Exports the current state of the object.

## Static Methods

### `funcTest(camObj, stageObj, lampObj)`
Tests the functionality of the `Reg3DTrans` class using the provided camera, stage, and lamp objects.

### Utility Static Methods
- **`GaussFit(X, CC, Zpos)`**: Fits a Gaussian model to data.
- **`findStackOffset(Stack1, Stack2, Params)`**: Finds the offset between two stacks.
- **`findOffsetIter(RefStack, MovingStack, NIterMax, Tolerance, CorrParams, ShiftParams)`**: Iterative offset finding.
- **`shiftImage(ImageStack, Shift, Params)`**: Shifts an image stack.
- **`frequencyMask(ImSize, FreqCutoff)`**: Creates a frequency mask for filtering.

## Usage Example

```matlab
% Create a Reg3DTrans object
RegObj = mic.Reg3DTrans(cameraObj, stageObj);

% Calibrate the system
RegObj.calibrate();

% Take a reference image
RegObj.takerefimage();

% Align the current image to the reference image
RegObj.align2imageFit();

% Export the current state
state = RegObj.exportState();
```

## REQUIREMENT
Matlab 2014b or higher
mic.abstract

## MICROSCOPE SPECIFIC SETTINGS
TIRF: LampPower=2; LampWait=2.5; CamShutter=true; ChangeEMgain=true;
EMgain=2; ChangeExpTime=true; ExposureTime=0.01;
### Citations: Marjolein Meddens,  Lidke Lab 2017
### Updated version:Hanieh Mazloom-Farsibaf, Lidke Lab 2018.

