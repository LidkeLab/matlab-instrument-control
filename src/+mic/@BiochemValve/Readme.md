# mic.BiochemValve Class

## Description
The `mic.BiochemValve` class manages BIOCHEM flow selection valves through communication with an Arduino.
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
- `mic.abstract.m`

## Class Properties

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive name of the instrument.
- **Type**: String
- **Default**: `'BiochemValve'`
- **`Arduino`**:
- **Description**: Serial object for communicating with the connected Arduino.

### Hidden Properties
- **`StartGUI`**:
- **Description**: Boolean flag indicating whether a graphical user interface (GUI) should be started for the instrument.
- **Type**: Boolean
- **Default**: `false`

### Public Properties
- **`PowerState12V`**:
- **Description**: Indicates the state of the 12V power line. A value of `1` indicates the line is active, and `0` indicates it is inactive.
- **Type**: Integer (0 or 1)
- **Default**: `0`
- **`PowerState24V`**:
- **Description**: Indicates the state of the 24V power line. A value of `1` indicates the line is active, and `0` indicates it is inactive.
- **Type**: Integer (0 or 1)
- **Default**: `0`
- **`DeviceSearchTimeout`**:
- **Description**: Timeout duration (in seconds) for searching for the USB device (Arduino).
- **Type**: Integer
- **Default**: `10` seconds
- **`DeviceResponseTimeout`**:
- **Description**: Timeout duration (in seconds) for awaiting a response from the device (Arduino).
- **Type**: Integer
- **Default**: `10` seconds
- **`IN1Pin`**:
- **Description**: The digital pin on the Arduino that is connected to relay IN1.
- **Type**: Integer
- **Default**: `2`
- **`SerialPort`**:
- **Description**: The serial port used to communicate with the Arduino. This should match the connected port.
- **Type**: String
- **`Board`**:
- **Description**: Name of the Arduino board being used (e.g., 'Uno', 'Mega').
- **Type**: String
- **Default**: `'Uno'`
- **`ValveState`**:
- **Description**: Array representing the states of six valves, where `0` indicates closed and `1` indicates open.
- **Type**: Array of six integers (each 0 or 1)
- **Default**: `[0, 0, 0, 0, 0, 0]`

## Key Functions
- **delete()**: Deletes the object and closes connection to Arduino.
- **exportState()**: Exports the current state of the instrument.
- **gui()**: Launches a graphical user interface for the valve controller.
- **powerSwitch12V()**: Toggles power on the 12V line controlling the valves.
- **powerSwitch24V()**: Toggles power on the 24V line that powers both the syringe pump and the BIOCHEM valves after stepping down to 12V.
- **openValve(ValveNumber)**: Opens the specified valve.
- **closeValve(ValveNumber)**: Closes the specified valve.
- **funcTest(SerialPort)**: Performs a unit test of the valve controller on a specified serial port.

## Usage
```matlab
Creating an instance of the valve controller
Valves = mic.BiochemValve();

Opening and closing a valve
Valves.openValve(3);  % Open valve number 3
Valves.closeValve(3); % Close valve number 3

Managing power
Valves.powerSwitch12V();  % Toggle the 12V power line
```
### CITATION: David Schodt, Lidke Lab, 2018

