# Class to control Benchtop stepper motor.

## Description
This device might also be cotroled using the kinesis software.
This class give you access to some of the functions in the long list
of functions to control this device.
To change the setting user need to use the kinesis software, except
the jog step size.
Please check if you have the following setting on the kinesis
software. Open the kinesis software and on all the windows for each
motor you should have this setting:
Setting, Device Startup Setting, klick on the botton in the Select
Actuator Type box, from the popup menu in the top select the device
that you wish to control (it could be either HS NanoMax 300 X Axis,
HS NanoMax 300 Y Axis or HS NanoMax 300 Z Axis), then OK and Save.

## Properties

### Protected Properties

#### `InstrumentName`
- **Description:** Name of the instrument.
- **Default Value:** `'StepperMotor'`

### Public Properties

#### `StartGUI`
- **Description:** Indicates if the GUI should be started.

#### `SerialN`
- **Description:** Serial number of the stepper motor controller. This number can be found on the back of the controller.
- **Example Value:** For SEQ controller, `70850323`.

## Constructor
M = mic.StepperMotor(70850323)

## Key Functions:
constructor(), goHome(), getPosition(), getStatus(),
getStatus(), moveJog(), moveToPosition(), setJogStep()
getJogStep(), closeSBC(), delete(), exportState()

## REQUIREMENTS:
MATLAB 2014 or higher
Kinesis software from thorlabs
Abstract class.
Access to the mexfunctions for this device. (kinesis_SBC_function).

### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

