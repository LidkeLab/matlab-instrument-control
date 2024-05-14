# MIC_NewportLaser488: Matlab Instrument Class for Newport Cyan Laser 488 on TIRF microscope.
## Description
The `MIC_TIRFLaser488` is a MATLAB instrument class for controlling the Newport Cyan Laser 488 used in
TIRF (Total Internal Reflection Fluorescence) microscopy setups. It integrates functionalities for managing
laser power through ND (Neutral Density) filter wheels and a shutter for toggling the laser ON and OFF.
## Requirements
- `MIC_Abstract.m`
- `MIC_LightSource_Abstract.m`
- `MIC_FilterWheel.m`
- `MIC_DynamixelServo.m`
- `MIC_ShutterTTL.m`
- MATLAB (R2016b or later)
- Data Acquisition Toolbox
## Installation
Ensure all required files are in the MATLAB path and that your system is properly configured to interface with the hardware components.
## Key Functions:
- on(obj): Opens the shutter to turn the laser ON.
- Usage: obj.on();
- off(obj): Closes the shutter to turn the laser OFF.
- Usage: obj.off();
- setPower(obj, PowerIn): Sets the laser power by selecting the appropriate ND filters.
- PowerIn should be within the allowed range of obj.MinPower to obj.MaxPower.
- Usage: obj.setPower(50);  Sets power to 50 mW
- exportState(obj): Exports the current state of the laser.
- Returns a structure with fields for Power, IsOn, and InstrumentName.
- Usage: state = obj.exportState();
- delete(obj): Destructs the object and cleans up resources such as shutter and filter wheels.
- Usage: delete(obj);
- shutdown(obj): Safely shuts down the laser by turning it off and setting the power to zero.
- Usage: obj.shutdown();
## Usage
To create an instance of the `MIC_TIRFLaser488` class:
```matlab
obj = MIC_TIRFLaser488();
Create an object
laser = MIC_TIRFLaser488();
Set power to 70 mW
laser.setPower(70);
Turn the laser on
laser.on();
Wait for a moment
pause(1);
Turn the laser off
laser.off();
Clean up
laser.delete();
```
### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
