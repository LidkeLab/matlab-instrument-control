# mic.camera.ThorlabsIR Matlab Instrument Class for control of Thorlabs IR Camera (Model:DCC1545M)

## Description
This class controls the DCxCamera via a USB port. It is required to
install the software from the following link
https://www.thorlabs.com/software_pages/viewsoftwarepage.cfm?code=ThorCam
and make sure 'uc480DotNet.dll' is in this directory:
'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet'
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
**Default:** `'DCxCamera'`.

## Hidden Properties

### `StartGUI`
Flag to control whether the GUI starts automatically.
**Default:** `false`.
## Constructor
obj=mic.camera.ThorlabsIR()

## Key Function
initialize, abort, delete, shutdown, getlastimage, getdata, setup_acquisition, start_focus, start_capture, start_sequence, set.ROI, get_Properties, exportState, funcTest

## REQUIREMENTS
mic.abstract.m
mic.camera.abstract.m
MATLAB software version R2016b or later
uc480DotNet.dll file downloaded from the Thorlabs website for DCx cameras

### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.

