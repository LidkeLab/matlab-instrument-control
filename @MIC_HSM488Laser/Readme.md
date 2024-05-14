# MIC_HSM488Laser Class

## Description
The `MIC_HSM488Laser` class is used for controlling the HSM 488 nm laser, part of the MIC framework.
The laser control involves manual operation as well as automated control via a shutter and an attenuator.
This class assumes the laser is manually turned on using its controller on the top shelf of the HSM table and is
controlled programmatically using a shutter and an LCC in front of the laser.

## Requirements
- MIC_LightSource_Abstract.m
- MIC_ShutterTTL.m
- MIC_Attenuator.m

## Key Functions
- **Constructor (`MIC_HSM488Laser()`):** Initializes the laser, setting up the shutter and attenuator for operational control.
- **`on()`:** Opens the shutter and sets the laser transmission to the current value, effectively turning the laser on.
- **`off()`:** Closes the shutter and sets the laser transmission to the minimum value, turning the laser off.
- **`setPower(Power_in, FilterID)`:** Sets the desired output power of the laser. `FilterID` can only be 2, 4, or 6, with other IDs blocking the beam due to the damage threshold of the attenuator.
- **`delete()`:** Properly cleans up and shuts down the laser connection when the object is deleted.
- **`shutdown()`:** A method that mirrors the functionality of `off()`, ensuring the laser is safely turned off.
- **`exportState()`:** Exports the current operational state of the laser, including power settings and on/off status.

## Usage Example
```matlab
Create an instance of the HSM 488 nm laser
laser = MIC_HSM488Laser();

Set the laser power to 10 mW using FilterID 2
laser.setPower(10, 2);

Turn the laser on
laser.on();

Display the current state of the laser
state = laser.exportState();
disp(state);

Turn the laser off
laser.off();

Clean up on completion
delete(laser);
```
Citation: Sajjad Khan, Lidkelab, 2024

