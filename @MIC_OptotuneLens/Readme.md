# MIC_OptotuneLens
## Description
The `MIC_OptotuneLens` MATLAB class facilitates control over an Optotune Electrical Lens via serial communication. The class interfaces with the lens using an embedded Atmel ATmega32U4 microcontroller, allowing for precise adjustments of focal power and monitoring of the lens temperature.
## Features
- **Focal Power Control**: Set and adjust the focal power of the Optotune lens within a defined range.
- **Temperature Monitoring**: Fetch the current operating temperature of the lens.
- **Drift Compensation**: Enable drift compensation to maintain focal stability.
- **Firmware Interaction**: Retrieve and interact with the lens firmware, accommodating different firmware versions for command compatibility.
## Requirements
- MATLAB 2016b or later.
- Instrument Control Toolbox for MATLAB for serial port communication.
- Optotune lens driver and firmware installed and properly configured.
## Installation
1. Ensure MATLAB and the required toolboxes are installed.
2. Connect the Optotune lens to your computer via a USB port and install any necessary drivers.
3. Clone this repository or download the class file directly into your MATLAB working directory.
## Usage Example
```matlab
Creating an instance of the MIC_OptotuneLens class
lens = MIC_OptotuneLens('COM3');   Replace 'COM3' with the actual COM port
Setting Focal Power
desiredPower = 2;   in diopters
lens.setFocalPower(desiredPower);
Reading Temperature
temperature = lens.getTemperature();
disp(['Current Lens Temperature: ', num2str(temperature), ' °C']);
Enabling Drift Compensation
lens.enableDriftCompensation();
Cleanup
delete(lens);
```
### Citation: Marjolein Meddens, Lidke Lab 2017
# gui Graphical User Interface to MIC_OptotuneLens
Prevent opening more than one figure for same instrument
