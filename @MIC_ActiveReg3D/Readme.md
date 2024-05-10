# # MIC_ActiveReg3D
`MIC_ActiveReg3D` is a MATLAB class designed for three-dimensional active registration using camera and stage control via piezoelectric actuators. This class is intended for precision imaging applications where maintaining focus and alignment within sub-micron tolerances is crucial.
## Features
- Three-dimensional control of piezo stages (`Stage_Piezo_X`, `Stage_Piezo_Y`, `Stage_Piezo_Z`).
- Error correction in real-time based on captured image feedback.
- Dynamic adjustment and correction history tracking.
- Calibration function to determine pixel size based on stage movements and image alignment.
- Periodic alignment capability with adjustable intervals.
## Properties
- `CameraObj`: Camera object for image capture.
- `Stage_Piezo_X/Y/Z`: Piezo actuators for stage control in X, Y, and Z directions.
- `SCMOS_PixelSize`, `PixelSize`: Pixel size in microns, updated during calibration.
- `ImageFile`, `Image_ReferenceStack`, `Image_ReferenceInfocus`: Image storage for reference and processing.
- `ZStack_MaxDev`, `ZStack_Step`: Parameters defining the Z-stack acquisition.
- `X_Current`, `Y_Current`, `Z_Current`: Current positions in microns.
- `Tol_X`, `Tol_Y`, `Tol_Z`: Tolerance levels for positioning corrections.
- `MaxIter`, `MaxXYShift`, `MaxZShift`: Maximum allowed iterations and shifts during corrections.
- `Timer`, `Period`: Timer object and period for periodic alignment.
## Methods
- `ActiveReg3D`: Constructor to initialize the object with camera and stage settings.
- `calibrate`: Calibration method to determine the pixel size based on stage displacement and image shift correlation.
- `takeRefImageStack`: Captures a stack of reference images to determine the best focus across a range of Z positions.
- `start`, `stop`: Methods to start and stop periodic alignment.
- `align2imageFit`: Function called periodically to align the current image to a reference image.
- `findZPos`, `findXYShift`: Methods to find the optimal Z position and XY shifts based on image correlation.
## Usage Example
Here's a brief example on how to use `MIC_ActiveReg3D`:
```matlab
cameraObj = Camera();  Replace with actual camera object initialization
stageX = PiezoStage();  Replace with actual piezo stage initialization
stageY = PiezoStage();  Replace with actual piezo stage initialization
stageZ = PiezoStage();  Replace with actual piezo stage initialization
reg3d = MIC_ActiveReg3D(cameraObj, stageX, stageY, stageZ);
reg3d.calibrate();
reg3d.takeRefImageStack();
reg3d.start();
To stop the alignment process:
reg3d.stop();
