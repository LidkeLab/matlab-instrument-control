# MIC_ThorlabsLED Matlab Instrument Class for control of the Thorlabs LED
## Description
This class controls a LED lamp with different wavelength from Thorlabs.
Requires TTL input from the Analogue Input/Output channel of NI card
to turn the laser ON/OFF as well as set the power remotely.
BNC cable is needed to connect to device.
Set Trig=MOD on control device for Lamp and turn on knob manually
more than zero to control from computer.
## Requirements
- `MIC_Abstract.m`
- `MIC_LightSource_Abstract.m`
- MATLAB (R2016b or later)
- Data Acquisition Toolbox
- MATLAB NI-DAQmx driver (installed via the Support Package Installer)
## Installation
Ensure all required files are in the MATLAB path and that the NI-DAQmx driver is correctly installed and configured on your system.
## Functions:
on(obj)
- Turns the LED lamp ON.
- Usage: obj.on();
off(obj)
- Turns the LED lamp OFF.
- Usage: obj.off();
setPower(obj, Power_in)
- Sets the power level of the lamp.
- Power_in must be between obj.MinPower and obj.MaxPower.
- Usage: obj.setPower(50);  Sets power to 50
exportState(obj)
- Exports the current state of the lamp.
- Returns a structure with fields for Power and IsOn.
- Usage: state = obj.exportState();
delete(obj)
- Cleans up resources, called before clearing the object.
- Usage: delete(obj);
shutdown(obj)
- Sets power to zero, turns off the lamp, and cleans up resources.
- Usage: obj.shutdown();
## Usage
To create an instance of the `MIC_ThorlabsLED` class:
```matlab
obj = MIC_ThorlabsLED('Dev1', 'ao1');
Create an object
led = MIC_ThorlabsLED('Dev1', 'ao1');
Set power to maximum
led.setPower(100);
Turn the LED on
led.on();
Wait for 1 second
pause(1);
Turn the LED off
led.off();
Clean up
led.delete();
```
CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
