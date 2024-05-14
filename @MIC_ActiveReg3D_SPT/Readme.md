# MIC_ActiveReg3D_SPT Class
## Description
The `MIC_ActiveReg3D_SPT` class is designed for active 3D alignment and stabilization of images captured using a specific camera and stage setup in MATLAB. This class is a part of a microscope imaging suite and is used for precise correction and calibration to maintain focus and alignment during imaging sessions.
## Properties
- `CameraObj`: Camera object handling image capture.
- `StageObj`: Stage object handling the positioning of the sample.
- `PixelSize`: Pixel size in microns, specifying the scale of image pixels.
- `ImageFile`: Path to the image file.
- `Image_ReferenceStack`: Reference image stack for alignment.
- `Image_ReferenceInfocus`: Reference image in focus.
- `Image_preCorrection`: Image before correction is applied.
- `Image_Current`: Current image after all corrections.
- `ZStack_MaxDev`: Maximum deviation in the Z-stack in microns.
- `ZStack_Step`: Step size in the Z-stack in microns.
- `X_Current`, `Y_Current`, `Z_Current`: Current position in microns.
- `ZStack_Pos`: Position stack for Z.
- `Tol_X`, `Tol_Y`, `Tol_Z`: Tolerances for X, Y, and Z corrections in microns.
- `MaxIter`: Maximum number of iterations for alignment.
- `MaxXYShift`, `MaxZShift`: Maximum allowable shifts in XY and Z directions in microns.
- `ZFitPos`, `ZFitModel`, `ZMaxAC`, `IndexFocus`: Parameters and models for Z position fitting.
- `ErrorSignal`: Error signal in micron for XYZ.
- `Correction`: Amount of correction applied in XYZ.
- `PosPostCorrect`: Position after correction is applied.
- `ErrorSignal_History`, `Correction_History`, `PosPostCorrect_History`: Historical data for error signals, corrections, and positions post-correction.
- `Timer`: Timer object for periodic alignment tasks.
- `Period`: Period of the alignment timer.
- `PlotFigureHandle`: Handle for the plot figure.
## Methods
### `Constructor`
- Initializes a new instance of the `MIC_ActiveReg3D_SPT` with a specified camera and stage object.
### `exportState`
- Exports the current state of the object including all historical data.
### `calibrate`
- Calibrates the camera and stage setup by moving the stage and capturing images to determine the pixel size.
### `takeRefImageStack`
- Takes a reference image stack around the current Z position for future alignment.
### `start`, `stop`
- Starts and stops the periodic alignment process.
### `align2imageFit`
- Aligns the current image to the reference by adjusting the Z position and correcting based on XY shifts.
### `findZPos`
- Finds the optimal Z position based on the maximum cross-correlation with the reference stack.
### `findXYShift`
- Calculates the shift in XY plane needed to align the current image with the reference.
### `capture_single`
- Captures a single image from the camera.
## Usage Example
```matlab
cameraObj = YourCameraDriver();  Initialize your camera driver
stageObj = YourStageDriver();  Initialize your stage driver
alignmentSystem = MIC_ActiveReg3D_SPT(cameraObj, stageObj);
alignmentSystem.calibrate();
alignmentSystem.takeRefImageStack();
alignmentSystem.start();
Perform imaging tasks
alignmentSystem.stop();
```
### Citations: Lidkelab, 2017.
