# MIC_HSMLaser488 Class
## Description
The `MIC_HSMLaser488` class is used for controlling a 488 nm laser mounted on the HSM microscope.
This class facilitates the operation of the laser through a MATLAB interface, leveraging both a shutter and a
liquid crystal controller (LCC). The use of a specific filter (No: 2) in front of the laser is critical to prevent damage to the LCC.
## Requirements
- MATLAB R2016b or later
- Data Acquisition Toolbox
- MATLAB NI-DAQmx driver (installed via the Support Package Installer)
- MIC_Abstract.m
- MIC_LightSource_Abstract.m
- MIC_Attenuator
- MIC_ShutterTTL
## Key Functions
- **Constructor (`MIC_HSMLaser488()`):** Sets up the laser controls, initializing the shutter and attenuator, and calculates power limits based on the attenuator's transmission and laser filter settings.
- **`on()`:** Activates the laser by opening the shutter.
- **`off()`:** Deactivates the laser by closing the shutter.
- **`setPower(Power_in)`:** Sets the output power of the laser, ensuring it falls within the allowable range adjusted for the filter and attenuator settings.
- **`delete()`:** Safely shuts down the laser and cleans up resources when the object is destroyed.
- **`shutdown()`:** Ensures the laser is turned off and all settings are safely reset.
- **`exportState()`:** Exports the current state of the laser, including power settings and on/off status.
## Usage Example
```matlab
Initialize the MIC_HSMLaser488 object
laser = MIC_HSMLaser488();
Set the laser to its maximum allowable power and turn it on
laser.setPower(laser.MaxPower);
laser.on();
Display the current state of the laser
state = laser.exportState();
disp(state);
Turn the laser off and delete the object
laser.off();
delete(laser);
```
### CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
