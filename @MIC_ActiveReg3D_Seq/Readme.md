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

