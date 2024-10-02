# MIC_PyDcam Class Documentation

## Overview
`MIC_PyDcam` is a MATLAB class designed for controlling a camera through a Python interface. It extends the `MIC_Camera_Abstract` class and includes methods for camera setup, acquisition control, and image retrieval.

## Methods
- **Constructor**: Initializes the camera settings.
- `abort()`: Aborts the ongoing acquisition.
- `shutdown()`: Closes the camera connection and cleans up.
- `errorcheck(funcname)`: Placeholder for error checking.
- `initialize()`: Placeholder for initialization.
- `fireTrigger()`: Placeholder for manual trigger.
- `initializeDcam(envpath)`: Initializes the camera with the specified Python environment path.
- `getlastimage()`: Retrieves the last frame from the camera buffer.
- `getdata()`: Retrieves data based on the current acquisition type.
- `start_focus()`: Starts acquisition in focus mode.
- `start_capture()`: Starts acquisition in capture mode.
- `start_sequence()`: Starts acquisition in sequence mode.
- `setup_acquisition()`: Prepares the camera for acquisition based on the current settings.
- `setup_fast_acquisition(numFrames)`: Prepares the camera for a fast acquisition sequence.
- `triggeredCapture()`: Captures a frame upon receiving a trigger.
- `finishTriggeredCapture()`: Finishes the triggered capture session and retrieves data.
- `get_PropertiesDcam()`: Retrieves camera Properties from the DCAM API.
- `get_propAttr(idprop)`: Retrieves Property attributes from the camera.
- `setCamProperties(Infield)`: Sets camera Properties based on the provided fields.
- `setProperty(idprop, value)`: Sets a camera Property.
- `getProperty(idprop)`: Gets a camera Property.
- `setgetProperty(idprop, value)`: Sets and gets a camera Property.
- `build_guiDialog(GuiCurSel)`: Builds the GUI dialog based on current settings.
- `apply_camSetting()`: Applies changes from the GUI to the camera settings.
- `valuecheck(propname, val)`: Checks and adjusts the value based on the camera setting constraints.
- `exportState()`: Exports the current state of the camera.
- `exportParameters()`: Exports current camera parameters.

## Static Methods
- `unitTest()`: Tests the functionality of the class.
- `camSet2GuiSel(CameraSetting)`: Converts current camera settings into GUI selections.

## Usage
To use `MIC_PyDcam`, create an instance of the class and call its methods to interact with the camera. Ensure Python and required libraries are properly set up and accessible to MATLAB.

### CITATION: Sheng Liu, Lidkelab, 2024.

