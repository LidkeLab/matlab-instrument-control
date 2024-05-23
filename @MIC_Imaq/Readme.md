# MIC_Imaq Class Documentation

## Overview
`MIC_Imaq` is a MATLAB class designed for camera control using the Image Acquisition Toolbox. It extends the `MIC_Camera_Abstract` class and includes methods for initializing the camera, managing acquisitions, and retrieving images.

## Methods
- **Constructor**: Initializes the camera with optional parameters for adaptor name, format, and device ID.
- `abort()`: Aborts the ongoing acquisition.
- `shutdown()`: Stops the camera and cleans up the handle.
- `initializeImaq(AdaptorName, Format, DevID)`: Initializes the camera with specific settings.
- `setup_acquisition()`: Configures the camera for the current acquisition mode.
- `setup_softwareTrigger(TriggerN)`: Prepares the camera for software triggered acquisition.
- `start_softwareTrigger()`: Starts acquisition using software triggers.
- `getlastimage()`: Retrieves the last captured image.
- `getdata()`: Retrieves data based on the current acquisition type.
- `start_focus()`: Starts acquisition in focus mode.
- `start_capture()`: Starts acquisition in capture mode.
- `start_sequence()`: Starts acquisition in sequence mode.
- `setCamProperties(Infield)`: Applies camera settings from a structured input.
- `build_guiDialog(GuiCurSel)`: Constructs the GUI dialog based on current settings.
- `apply_camSetting()`: Applies GUI changes to the camera settings.
- `getExpfield()`: Determines the appropriate exposure field from camera settings.
- `valuecheck(prop, val)`: Checks and adjusts the value based on camera constraints.

## Static Methods
- `unitTest()`: Tests the functionality of the class.
- `camSet2GuiSel(CameraSetting)`: Converts camera settings into GUI selections.

## Usage
To utilize `MIC_Imaq`, create an instance of the class specifying the adaptor name, format, and device ID as needed. Use the class methods to control the camera and manage image acquisition within MATLAB.

### CITATION: Sheng Liu, Lidkelab, 2024.

