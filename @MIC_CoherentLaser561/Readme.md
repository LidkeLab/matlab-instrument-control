# # MIC_CoherentLaser561 Class
## Description
The `MIC_CoherentLaser561` class is a MATLAB Instrument Class for controlling the Coherent Sapphire Laser 561 via a USB connection.
It integrates with additional classes like `FilterWheel` and `Shutter` to manage laser power output continuously
from 0 to 100 mW, despite the laser controller's minimum power setting of 10 mW.
## Requirements
- MATLAB 2016b or later
- MIC_Abstract
- MIC_LightSource_Abstract
- MIC_FilterWheel
- MIC_DynamixelServo
- MIC_ShutterTTL
## Installation
Ensure that all required classes (`MIC_Abstract`, `MIC_LightSource_Abstract`, `MIC_FilterWheel`, `MIC_DynamixelServo`,
`MIC_ShutterTTL`) are in your MATLAB path. The laser connects via a specified COM port (e.g., 'COM3').
## Key Functions
- **Constructor (`MIC_CoherentLaser561(SerialPort)`):** Initializes the laser on a specified COM port, sets up the filter wheel and shutter, and establishes serial communication.
- **`on()`:** Activates the laser, opening the shutter and setting the laser state to on.
- **`off()`:** Deactivates the laser, closing the shutter and turning the laser off.
- **`setPower(Power_in)`:** Adjusts the laser's output power. This method selects the appropriate filter based on the desired power setting and modifies the laser's power output accordingly.
- **`getCurrentPower()`:** Fetches and displays the current power setting from the laser.
- **`GetStatus()`:** Queries the laser for its current operational status, updating internal status properties.
- **`delete()`:** Safely terminates the connection to the laser, ensuring all resources are properly released.
- **`exportState()`:** Exports a snapshot of the laser's current settings, including power and operational state.
## Usage Example
```matlab
Create an instance of the Coherent Laser 561 on COM3
CL561 = MIC_CoherentLaser561('COM3');
Set power to 50 mW
CL561.setPower(50);
Turn on the laser
CL561.on();
Turn off the laser
CL561.off();
Delete the object when done
delete(CL561);
```
CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
