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
SRC.Camera.ExpTime = 0.1;  % Set exposure time
SRC.Laser642.setPower(10); % Set laser power

Start acquisition
SRC.StartSequence();
```
### Citation: Marjolein Meddens, Lidke Lab 2017

