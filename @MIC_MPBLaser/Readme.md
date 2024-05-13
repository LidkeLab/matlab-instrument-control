# MIC_MPBLaser Matlab Instrument Control Class for the MPB-laser.
## Description
This class controls the PMB-laser.
The constructor do not need any info about the port, it will
automatically find the available port to communicate with the
laser.
Because it is trying to find the port to communicate with the
instrument it will send messages to different ports and if the port
is not giving any feedback, which means that it's not the port that
we are looking for, it will give a timeout warning which can be
neglected.
## Features
- Automatic port detection for communication with the laser.
- Control over laser power with adjustable set points.
- Ability to turn the laser on and off programmatically.
- Retrieves and sets various laser parameters such as power limits and serial number.
## Requirements
- MIC_Abstract.m
- MIC_LightSource_Abstract.m
- MATLAB 2014 or higher
- Proper installation of the laser's accompanying software.
## Installation Notes
During the initial setup, the class attempts to identify the correct communication port by sending commands
to potential ports and listening for valid responses. Timeout warnings during this process are expected when
incorrect ports do not respond and can be safely ignored.
## Key Methods
- **Constructor (`MIC_MPBLaser()`):** Initializes the laser control by automatically finding the available communication port and setting up the laser parameters.
- **`setPower(Power_mW)`:** Sets the laser's power to a specified value in milliwatts.
- **`on()`:** Turns the laser on.
- **`off()`:** Turns the laser off.
- **`send(Message)`:** Sends a specified command to the laser and reads the response.
- **`exportState()`:** Exports the current state of the laser, including power settings and operational status.
- **`shutdown()`:** Closes the communication port and prepares the system for shutdown.
- **`delete()`:** Destructor that ensures proper closure of the communication link and cleanup of the object.
## Usage Example
```matlab
Create an instance of the MIC_MPBLaser
laser = MIC_MPBLaser();
Set the laser power
laser.setPower(50);   Set power to 50 mW
Turn the laser on
laser.on();
Query the current state
state = laser.exportState();
disp(state);
Turn the laser off and clean up
laser.off();
delete(laser);
```
Citation: Sajjad Khan, Lidkelab, 2024.
