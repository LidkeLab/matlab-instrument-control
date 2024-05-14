# MIC_BiochemValve Class
## Description
The `MIC_BiochemValve` class manages BIOCHEM flow selection valves through communication with an Arduino.
It provides functionality to open and close valves, and includes an emergency shutoff to cut power to both the valves
and a syringe pump.
## Installation Requirements
- MATLAB R2014b or later
- MATLAB Support Package for Arduino Hardware:
##NOTE
You may need to setup the Arduino you are using
specifically even if this package was installed previously.
Matlab needs to upload software onto the Arduino before
creation of an instance of this class.
**Note:** Ensure the Arduino is properly set up as MATLAB needs to upload software onto it before using this class.
## Dependencies
- `MIC_Abstract.m`
## Key Functions
- **delete()**: Deletes the object and closes connection to Arduino.
- **exportState()**: Exports the current state of the instrument.
- **gui()**: Launches a graphical user interface for the valve controller.
- **powerSwitch12V()**: Toggles power on the 12V line controlling the valves.
- **powerSwitch24V()**: Toggles power on the 24V line that powers both the syringe pump and the BIOCHEM valves after stepping down to 12V.
- **openValve(ValveNumber)**: Opens the specified valve.
- **closeValve(ValveNumber)**: Closes the specified valve.
- **unitTest(SerialPort)**: Performs a unit test of the valve controller on a specified serial port.
## Usage
```matlab
Creating an instance of the valve controller
Valves = MIC_BiochemValve();
Opening and closing a valve
Valves.openValve(3);   Open valve number 3
Valves.closeValve(3);  Close valve number 3
Managing power
Valves.powerSwitch12V();   Toggle the 12V power line
```
### CITATION: David Schodt, Lidke Lab, 2018
# Sends a signal to the Arduino to close valve ValveNumber on the BIOCHEM
flow selection valve.
INPUTS:
obj: An instance of the MIC_BiochemValve class.
ValveNumber: The number specifying which valve on the BIOCHEM flow
selection valve to close.
NOTE: this may be mapped to the relay block on the relay
module for easy verification (by viewing the wiring path).
CITATION: David Schodt, Lidke Lab, 2018
Map ValveNumber to the appropriate digital I/O pin on the Arduino.
# Graphical user interface for MIC_BiochemValve.
{
# Sends a signal to the Arduino to open valve ValveNumber on the BIOCHEM
flow selection valve.
INPUTS:
obj: An instance of the MIC_BiochemValve class.
ValveNumber: The number specifying which valve on the BIOCHEM flow
selection valve to open.
NOTE: this may be mapped to the relay block on the relay
module for easy verification (by viewing the wiring path).
CITATION: David Schodt, Lidke Lab, 2018
Map ValveNumber to the appropriate digital I/O pin on the Arduino.
