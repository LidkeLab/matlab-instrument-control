# mic.CavroSyringePump Class

## Description
The `mic.CavroSyringePump` class controls a Cavro syringe pump via USB, specifically designed for
pump PN 20740556 -D. This class may work with other Cavro brand syringe pumps but has only been tested with the
specified model. It can perform any operation described in the Cavro XP3000 operators manual (e.g. in Appendix G - Command Quick Reference).

## Installation Requirements
- MATLAB R2014b or later (R2017a or later recommended)
- Operating System: Windows (modifications required for UNIX systems, particularly in serial port behaviors)
- Dependency: `mic.abstract.m`

## Class Properties

### Public Properties
- **`DeviceAddress`**:
- **Description**: ASCII address of the connected syringe pump.
- **Type**: Integer
- **Default**: `1`
- **`DeviceSearchTimeout`**:
- **Description**: Timeout duration (in seconds) for searching for the syringe pump during initialization.
- **Type**: Integer
- **Default**: `10` seconds
- **`DeviceResponseTimeout`**:
- **Description**: Timeout duration (in seconds) for awaiting a response from the syringe pump.
- **Type**: Integer
- **Default**: `10` seconds
- **`SerialPort`**:
- **Description**: Serial port to which the syringe pump is connected.
- **Type**: String
- **Default**: `'COM3'`

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive name of the instrument.
- **Type**: String
- **Default**: `'CavroSyringePump'`
- **`SyringePump`**:
- **Description**: Serial object representing the connected syringe pump.
- **Type**: Object
- **`PlungerPosition`**:
- **Description**: Current absolute position of the plunger, ranging from 0 to 3000.
- **Type**: Integer
- **`ReadableAction`**:
- **Description**: Description of the pump's current activity or response to a report command.
- **Type**: String
- **`VelocitySlope`**:
- **Description**: Slope used for ramping the plunger velocity from the start to the top.
- **Type**: Numeric
- **`StartVelocity`**:
- **Description**: Starting velocity of the plunger, specified in half-steps per second.
- **Type**: Numeric
- **`TopVelocity`**:
- **Description**: Maximum velocity of the plunger in half-steps per second.
- **Type**: Numeric
- **`CutoffVelocity`**:
- **Description**: Stop velocity of the plunger, specified in half-steps per second.
- **Type**: Numeric

### Observable Properties
- **`StatusByte`**:
- **Description**: Status byte representing the connection status of the pump. A value of `0` indicates that the pump is not connected.
- **Type**: Integer

### Hidden Properties
- **`MatlabRelease`**:
- **Description**: The version of MATLAB that is using this class.
- **Type**: String
- **`StartGUI`**:
- **Description**: Boolean flag indicating whether a graphical user interface (GUI) should be started.
- **Type**: Boolean
- **Default**: `false`

### Dependent Properties
- **`ReadableStatus`**:
- **Description**: Provides a human-readable status of the syringe pump, derived on demand.
- **Type**: String

##  Functions:
delete, exportState, updateGui, gui, connectSyringePump,
readAnswerBlock, executeCommand, reportCommand,
querySyringePump, cleanAnswerBlock, decodeStatusByte, funcTest

## Usage
```matlab
Create an instance of the Cavro syringe pump controller
Pump = mic.CavroSyringePump();
Connect to the pump
[Message, Status] = Pump.connectSyringePump();
Execute a command to move the plunger
Pump.executeCommand('Move Plunger to 1000');
Check the pump's status
Pump.querySyringePump();
Disconnect and cleanup
delete(Pump);
```
### CITATION: David Schodt, Lidke Lab, 2018

