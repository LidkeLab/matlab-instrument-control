# mic.camera.IMGSourceCamera: Matlab instument class for ImagingSource camera.

## Description
It requires dll to be registered in MATLAB.
TISImaq interfaces directly with the IMAQ Toolbox. This allows you to
bring image data directly into MATLAB for analysis, visualization,
and modelling.
The plugin allows the access to all camera Properties as they are
known from IC Capture. The plugin works in all Matlab versions
since 2013a. Last tested version is R2016b.
After installing the plugin it must be registered in Matlab manually.
How to do that is shown in a Readme, that can be displayed after
installation.
imaqregister('C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\x64\TISImaq_R2013.dll')
http://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/
This was done with imaqtool using Tools menu.

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
Indicates if the camera is ready for acquisition.
**Default:** `0` (call `setup_acquisition` if not ready).

### `TextHandle`
Handle for text display.

### `CameraHandle`
Handle for the camera object.

### `CameraCap`
Camera capabilities.

## Hidden Properties

### `StartGUI`
Defines whether the GUI starts automatically on object creation.
**Default:** `false`.

## Protected Properties (with Set Access)

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
Specific settings for the camera.

### `XPixels`
Number of pixels in the first dimension.

### `YPixels`
Number of pixels in the second dimension.

### `InstrumentName`
Name of the instrument.
**Default:** `'IMGSourceCamera'`.

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
**Default:** `1`.

### `SequenceCycleTime`
Cycle time for the kinetic series (equivalent to `1/frame rate`).

### `ScanMode`
Scan mode for the Hamamatsu sCMOS camera.

### `TriggerMode`
Trigger mode for the Hamamatsu sCMOS camera.

### `DefectCorrection`
Defect correction setting for the Hamamatsu sCMOS camera.

### `GuiDialog`
GUI dialog object.

## Contructor
Example: obj=mic.camera.IMGSourceCamera();

## Methods

### `abort()`
Aborts the current acquisition process.
- Stops the camera handle.
- Sets `ReadyForAcq` to `0`.

### `shutdown()`
Shuts down the object and releases resources.
- Deletes and clears the `CameraHandle`.

### `errorcheck(funcname)`
Performs error checking for the specified function name.

### `initialize()`

