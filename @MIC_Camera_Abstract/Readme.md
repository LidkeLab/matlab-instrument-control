# MIC_Camera_Abstract Class

## Description
The `MIC_Camera_Abstract` class serves as a base class for creating specific camera control classes in MATLAB. This abstract class provides a structured approach to implement common camera functionalities, ensuring consistency and ease of use across different camera models.

## Features
- Uniform interface for various camera operations such as focus, capture, and sequence modes.
- Properties for auto-scaling, display zoom, and live image display.
- Customizable return types for image data and file saving formats.
- Abstract methods that must be implemented for specific camera functionalities like initialization, acquisition setup, and shutdown.

## Requirements
- MATLAB 2014 or higher.
- Image Acquisition Toolbox.

## Properties
- `AcquisitionType`: Type of acquisition ('focus', 'capture', 'sequence').
- `AutoScale`: Enables automatic scaling of display images.
- `DisplayZoom`: Factor by which the live display is zoomed.
- `KeepData`: Specifies whether to store captured images.
- `LUTScale`: Range for image display stretching.
- `RangeDisplay`: Enables display of the minimum and maximum values on the live image.
- `ReturnType`: Format of the returned image data ('matlab', 'dipimage').
- `SaveType`: Format for saving images ('mat', 'ics').
- `ShowLive`: Determines whether to show live data during acquisition.

## Methods
### Abstract Methods
These methods must be implemented by subclasses to handle specific camera functionalities:

- `initialize()`: Initializes the camera settings.
- `setup_acquisition()`: Prepares the camera for a specific type of acquisition.
- `shutdown()`: Safely shuts down the camera.
- `start_capture()`: Starts capturing images in capture mode.
- `start_focus()`: Starts capturing images in focus mode.
- `start_sequence()`: Starts capturing a sequence of images.
- `getlastimage()`: Retrieves the most recent image captured.
- `getdata()`: Retrieves all data acquired in the current session.

### CITATION: Sajjad Khan, Lidkelab, 2024.

