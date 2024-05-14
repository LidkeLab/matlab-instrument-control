# MIC_RB_SRcollect
## Overview
The `MIC_RB_SRcollect` class is designed for super-resolution data collection on the Reflected Beam (RB) microscope. This software integrates with various hardware components through Matlab Instrument Control (MIC) classes to manage and control super-resolution microscopy experiments effectively.
## Features
- Control and synchronize multiple light sources including lasers and LEDs.
- Interface with cameras for image acquisition.
- Manage piezo stages for precise positioning.
- Utilize galvanometers for scanning applications.
- Integrate with Spatial Light Modulators (SLMs) for advanced optical manipulation.
## Requirements
- MATLAB 2014b or higher.
- Dependencies on several MIC classes:
- `MIC_Abstract`
- `MIC_LightSource_Abstract`
- `MIC_TCubeLaserDiode`
- `MIC_VortranLaser488`
- `MIC_CrystaLaser561`
- `MIC_HamamatsuCamera`
- `MIC_RebelStarLED`
- `MIC_OptotuneLens`
- `MIC_GalvoAnalog`
## Installation
1. Ensure all dependent classes are available in your MATLAB path.
2. Clone or download this repository into your MATLAB environment.
3. Instantiate an object using the command: `SRC = MIC_RB_SRcollect();`
## Methods
- `setupPiezo()`: Configures and initializes the piezo stages.
- `loadref()`: Loads a reference image for alignment.
- `takecurrent()`: Captures the current image from the camera.
- `align()`: Aligns the current image to a reference.
- `showref()`: Displays the reference image.
- `takeref()`: Captures and sets a new reference image.
- `saveref()`: Saves the current reference image.
- `focusLow()`, `focusHigh()`: Methods to focus the microscope using low or high laser power settings.
- `focusLamp()`: Uses the LED for continuous image display, useful for manual focusing.
- `StartSequence()`: Begins the data acquisition sequence.
## Usage
Here is a simple example on how to start a session with the `MIC_RB_SRcollect` class:
```matlab
Create the SRcollect object
SRC = MIC_RB_SRcollect();
Setup camera and laser parameters
SRC.Camera.ExpTime = 0.1;   Set exposure time
SRC.Laser642.setPower(10);  Set laser power
Start acquisition
SRC.StartSequence();
```
### Citation: Marjolein Meddens, Lidke Lab 2017
# blazeScanIntensity Calculates expected intensity during blaze scan
Function consists of 4 parts:
1. Pupil function is unblazed
2. Less than half of pupil is blazed
3. More than half of pupil is blazed
4. Pupil is completely blazed
Intensity is calculated as follows:
Icalc = Ibead * (AreaUnblazed/AreaTotal) + Ibg
where the area's are of the pupil
INPUTS:
BlazeWidth: Width of blaze (pixels)
Ibead:      Integrated intensity of bead without blaze (to be
optimized)
Ibg:        Background intensity when pupil is completely blazed
PupilPos:   Position of pupil center (pixels)
Rpupil:     Pupil radius
OUTPUTS:
I:          Expected intensity
Marjolein Meddens 2017, Lidke Lab
check input
# blazeScanObjFcn Objective function to fit blaze scan result
Objective function consists of 4 parts:
1. Pupil function is unblazed
2. Less than half of pupil is blazed
3. More than half of pupil is blazed
4. Pupil is completely blazed
Intensity is calculated as follows:
Icalc = Ibead * (AreaUnblazed/AreaTotal) + Ibg
where the area's are of the pupil
Cost parameter f is calculated as sum of squared errors
INPUTS:
X:          Vector containing parameters to be optimized:
X(1):   Integrated intensity of bead without blaze
X(2):   Background intensity when pupil is completely blazed
X(3):   Position of pupil center (pixels)
X(4):   Pupil radius (pixels)
I:          Measured integrated intensity of a bead during blaze scan
BlazeWidth: Width of blaze (pixels)
OUTPUTS:
f:          value to minimize in fminsearch
Marjolein Meddens 2017, Lidke Lab
# GUI SRcollect Gui for RB microscope
Detailed explanation goes here
# GUIPSF Gui for PSF engineering and acquisition for MIC_SR_CollectRB class
Detailed explanation goes here
Prevent opening more than one figure for same instrument
