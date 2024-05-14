# MIC_ActiveReg3D_Seq
## Description
`MIC_ActiveReg3D_Seq` is a MATLAB class designed for 3D sequential active registration using a camera and piezo stages. This class manages the positioning and alignment of optical components in three-dimensional space to correct for positional drifts during imaging processes.
## Properties
- **CameraObj**: Object handling camera operations.
- **Stage_Piezo_X/Y/Z**: Piezo stage controllers for X, Y, and Z axes.
- **SCMOS_PixelSize, PixelSize**: Pixel size settings for the camera in microns.
- **ImageFile**: File path for saving images.
- **Image_ReferenceStack**: Stack of reference images for alignment.
- **Image_ReferenceInfocus**: Reference image at the focal plane.
- **Image_preCorrection**: Image before applying corrections.
- **Image_Current**: Image after applying all corrections.
- **ZStack_MaxDev, ZStack_Step**: Parameters for Z-stack deviation and step size in microns.
- **X_Current, Y_Current, Z_Current**: Current positions in microns.
- **ZStack_Pos**: Array of Z positions for the stack.
- **Tol_X/Y/Z**: Tolerance levels for positioning in microns.
- **MaxIter, MaxXYShift, MaxZShift**: Maximum iterations and shift parameters for alignment corrections.
- **ErrorSignal, Correction, PosPostCorrect**: Current error signals, corrections applied, and post-correction positions.
- **ErrorSignal_History, Correction_History, PosPostCorrect_History**: Historical data of errors, corrections, and positions.
- **Timer, Period**: Timer object and its period for periodic alignment checks.
## Methods
- **Constructor**: Initializes the camera and stage settings, and loads properties.
- **calibrate()**: Calibrates the pixel size by moving the stage and capturing images.
- **takeRefImageStack()**: Captures a stack of images at different Z positions to create a reference stack.
- **start()**: Starts periodic alignment using a timer.
- **stop()**: Stops the periodic alignment and cleans up.
- **align2imageFit()**: Main function to align current images to the reference by adjusting the stage positions based on calculated shifts.
- **findZPos()**: Finds the best in-focus Z position by cross-correlating the current image with the reference stack.
- **findXYShift()**: Computes the XY shift required to align the current image with the reference.
- **capture_single()**: Captures a single image from the camera.
## Usage
Instantiate the class with the required camera and stage objects. Use the methods provided to calibrate, set the reference image stack, start/stop the alignment process, and retrieve alignment data.
### Citations: Lidkelab, 2019.
