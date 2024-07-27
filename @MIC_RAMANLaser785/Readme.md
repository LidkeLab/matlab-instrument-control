# MIC_RAMANLaser785

## Description
`MIC_RAMANLaser785` is a MATLAB class designed to control the 785 nm ONDAX laser used in RAMAN Lightsheet microscopes. This class manages the connection via an RS232-USB interface and provides functionalities such as setting the laser power, reading the current status, and integrating with a calibration file for accurate power settings.

## Requirements
- MATLAB 2016b or later.
- [MIC_Abstract](#) and [MIC_LightSource_Abstract](#) parent classes.
- A calibration file named `Calibration.mat` containing `CurrInterpol` and `PowerInterpol` arrays for current to power conversion.

## Installation
1. Ensure MATLAB 2016b or later is installed on your system.
2. Place the `MIC_RAMANLaser785.m` file and its parent classes `MIC_Abstract` and `MIC_LightSource_Abstract` in your MATLAB path.
3. Ensure that the `Calibration.mat` file is in the same directory as the `MIC_RAMANLaser785.m` file or adjust the path in the constructor accordingly.

## Usage
To use the `MIC_RAMANLaser785`, instantiate an object of the class with the appropriate COM port.
```matlab
Replace 'COM3' with the actual COM port connected to the laser.
RL785 = MIC_RAMANLaser785('COM3');
Set the laser power to a specific value in milliwatts.
RL785.setPower(20);  % Set power to 20 mW
Get and print the current power setting from the laser.
RL785.getCurrentPower();

Check and print the current status of the laser.
RL785.getStatus();
Properly turn off the laser and clean up resources.
RL785.delete();
```
### CITATION: Sandeep Pallikkuth, Lidkelab, 2020.

