# mic.camera.ThorlabsIR Matlab Instrument Class for control of
Thorlabs Scientific Camera (Model:CS165MU)

This class controls the Thorlabs Scientific Camera via a USB port. It is required to
install the software from the following link
https://www.thorlabs.com/software_pages/viewsoftwarepage.cfm?code=ThorCam
unzip 'Scientific Camera Interfaces.zip' which can be found in the installation folder at
'C:\Program Files\Thorlabs\Scientific Imaging\Scientific Camera Support\'
Copy the .dll files from:
'Scientific Camera Interfaces\SDK\DotNet Toolkit\dlls\Managed_64_lib\'
in this directory:
'C:\Program Files\Thorlabs\Scientific Imaging\Scientific Camera Support\Scientific Camera Interfaces\MATLAB\'
to initialize the camera
For the first time it is required to load the directory of .dll file
from Program Files.

## Protected and Transient Properties

### `AbortNow`
Flag to stop acquisition.

### `FigurePos`
Position of the figure window.

### `FigureHandle`
Handle for the figure window.

### `ImageHandle`
Handle for the image display.

### `ReadyForAcq`
Flag indicating if the camera is ready for acquisition.
**Default:** `0` (call `setup_acquisition` if not ready).

### `TextHandle`
Handle for text display.

### `dllPath`
Path for the DLL file.

## Protected Properties

### `CameraIndex`
Index used when more than one camera is present.

### `SerialNumbers`
Serial numbers associated with the camera.

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

### `XPixels`
Number of pixels in the first dimension.

### `YPixels`
Number of pixels in the second dimension.

### `InstrumentName`
Name of the instrument.
**Default:** `'TSICamera'`.

## Hidden Properties

### `StartGUI`
Flag to control whether the GUI starts automatically.
**Default:** `false`.

## Public Properties

### `Binning`
Binning settings in the format `[binX binY]`.

### `Data`
Last acquired data.

### `ExpTime_Focus`
Exposure time for focus mode.
**Default:** `0.01`.

### `ExpTime_Capture`
Exposure time for capture mode.
**Default:** `0.01`.

### `ExpTime_Sequence`
Exposure time for sequence mode.
**Default:** `0.01`.

### `ROI`
Region of interest in the format `[Xstart Xend Ystart Yend]`.

### `SequenceLength`
Length of the kinetic series.

### `SequenceCycleTime`
Cycle time for the kinetic series (equivalent to `1/frame rate`).

### `CameraHandle`
.NET Camera object handle.

### `SDKHandle`
Handle for the TLCameraSDK.

### `TriggerMode`
Trigger mode for the camera.
**Default:** `'internal'`.

Example: obj=mic.camera.ThorlabsSICamera();
Function: initialize, abort, delete, shutdown, getlastimage, getdata,
setup_acquisition, start_focus, start_capture, start_sequence, set.ROI,

