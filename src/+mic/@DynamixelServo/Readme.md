# mic.DynamixelServo: Matlab Instrument Class for Dynamixel Servos

## Description
Dynamixel Servos are used to control the rotation of filter wheels
Setup instruction can be found at Z:\Lab General Info and
Documents\TIRF Microscope\Build Instructions for Filter Wheel
Setup.doc

## Class Properties

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive name for the instrument.
- **Type**: String
- **Default**: `'DynamixelServo'`

### Private Properties (Public Access)
- **`Id`**:
- **Description**: Unique servo identifier (0-255).
- **Type**: Integer
- **`Bps`**:
- **Description**: Baud rate setting for the port connection.
- **Type**: Integer
- **`Port`**:
- **Description**: The USB2Dynamixel serial port to which the servo is connected.
- **Type**: Serial Port Object

### Observable & Dependent Properties
- **`Led`**:
- **Description**: Controls the LED status on the servo for identification purposes (on/off).
- **Type**: Boolean (default is off)
- **`GoalPosition`**:
- **Description**: The desired target position for the servo.
- **Type**: Numeric
- **`MovingSpeed`**:
- **Description**: Speed at which the servo should move, ranging from 1 to 1023 (default is fastest).
- **Type**: Integer (range: 1-1023)

### Dependent Properties
- **`Model`**:
- **Description**: The model number of the servo.
- **Type**: Integer
- **`Firmware`**:
- **Description**: Firmware version of the servo.
- **Type**: Integer
- **`Moving`**:
- **Description**: Indicates whether the servo is currently moving.
- **Type**: Boolean
- **`PresentPosition`**:
- **Description**: The current position of the servo.
- **Type**: Numeric
- **`PresentSpeed`**:
- **Description**: The current speed of the servo (0 if not moving).
- **Type**: Numeric
- **`PresentTemperature`**:
- **Description**: Current temperature of the servo.
- **Type**: Numeric
- **`PresentVoltage`**:
- **Description**: Current voltage supplied to the servo.
- **Type**: Numeric
- **`Rotation`**:
- **Description**: The current rotational position of the servo in degrees.
- **Type**: Numeric

### Hidden Properties
- **`StartGUI`**:
- **Description**: Determines whether a GUI should be launched during object instantiation.
- **Type**: Boolean (default is `0`)
- **`minSpeed`**:
- **Description**: Minimum movement speed for the servo.
- **Type**: Integer (default is `1`)
- **`maxSpeed`**:
- **Description**: Maximum movement speed for the servo.
- **Type**: Integer (default is `1023`)

### Constant & Hidden Properties
- **Communication Parameters**:
- `DEFAULT_PORTNUM = 2`: Default port number (com2) for serial communication.
- `DEFAULT_BAUDNUM = 1`: Default baud rate (1 Mbps).
- `MODEL_NUMBER = 0`: Byte offset for model number.
- `VERSION_OF_FIRMWARE = 2`: Byte offset for firmware version.
- (Additional constants are available for various servo and communication settings, as listed in the full property description.)

- **Error Bit Values**:
- `ERRBIT_VOLTAGE = 1`: Indicates a voltage error.
- `ERRBIT_ANGLE = 2`: Indicates an angle error.
- (Additional error bit values listed.)

- **Communication Results**:
- `COMM_TXSUCCESS = 0`: Indicates successful transmission.
- (Additional communication results listed.)

- **Maximum Rotation**:
- `MAX_ROTATION = 300`: Maximum rotation of the actuator in degrees.

## Usage Example:
obj=mic.DynamixelServo(ServoId,Port,Bps);
ServoId: Id of servo(is written on servo)
Port: COM port to which servo is connected (Optional)
Bps: Baud setting for port (Optional)

## Key Functions:
delete, shutdown, checkCommStatus, exportState, ping,
get.Firmware, get.GaolPosition, set.GoalPosition,
get.Led, set.Led, get.Model, get.Moving,
get.MovingSpeed, set.MovingSpeed, get.PresentPostion,
get.PresentSpeed, get.PresentTemperature,
get.PresentVoltage, get.Rotation, set.Rotation

## REQUIRES:
Matlab 2014b or higher
mic.abstract.m
Roboplus software
Driver library for servo
Driver library for USB2Dynamixel
DynamixelSDK (most likely will be installed during installation of
Roboplus, if not it can be found on the Roboplus webpage)
All files that are not specifically for the Roboplus software should
be extracted into C:\Program Files(x86)\ROBOTIS\USB2Dynamixel

### CITATION: Marjolein Meddens, Lidke Lab, 2017.

