# mic.NDFilterWheel: Matlab Instrument Control for servo operated Filter wheel containing Neutral Density filters

## Description
Filter wheel should be controlled by Dynamixel Servos. See "Z:\Lab
General Info and Documents\TIRF Microscope\Build Instructions for
Filter Wheel Setup.doc"
This class works with an arbitrary number of filters
To create a mic.NDFilterWheel object the position and transmittance
of each filter must be specified. The position must be given in
degrees rotation corresponding to the input of the servo. This
can be calibrated by setting the servo rotation such that the
specific filter is in the optical path. The Rotation property of the
servo gives the right position value for that filter.

## Class Properties

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive name of the instrument.
- **Type**: String
- **Default**: `'NDFilterWheel'`

- **`Servo`**:
- **Description**: Servo object responsible for rotating the filter wheel.
- **Type**: Object

- **`FilterPos`**:
- **Description**: Array representing the rotation angles (in degrees) of the servo corresponding to filter positions.
- **Type**: Numeric Array

- **`TransmissionValues`**:
- **Description**: Array containing fractional transmission values (0 to 1) for each filter position.
- **Type**: Numeric Array

### Dependent Properties
- **`CurrentFilter`**:
- **Description**: Represents the current filter number in use.
- **Type**: Numeric

