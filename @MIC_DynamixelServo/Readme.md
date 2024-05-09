# MIC_DynamixelServo: Matlab Instrument Class for Dynamixel Servos
Dynamixel Servos are used to control the rotation of filter wheels
Setup instruction can be found at Z:\Lab General Info and
Documents\TIRF Microscope\Build Instructions for Filter Wheel
Setup.doc
Example: obj=MIC_DynamixelServo(ServoId,Port,Bps);
ServoId: Id of servo(is written on servo)
Port: COM port to which servo is connected (Optional)
Bps: Baud setting for port (Optional)
Functions: delete, shutdown, checkCommStatus, exportState, ping,
get.Firmware, get.GaolPosition, set.GoalPosition,
get.Led, set.Led, get.Model, get.Moving,
get.MovingSpeed, set.MovingSpeed, get.PresentPostion,
get.PresentSpeed, get.PresentTemperature,
get.PresentVoltage, get.Rotation, set.Rotation
REQUIRES:
Matlab 2014b or higher
MIC_Abstract.m
Roboplus software
Driver library for servo
Driver library for USB2Dynamixel
DynamixelSDK (most likely will be installed during installation of
Roboplus, if not it can be found on the Roboplus webpage)
All files that are not specifically for the Roboplus software should
be extracted into C:\Program Files(x86)\ROBOTIS\USB2Dynamixel
CITATION: Marjolein Meddens, Lidke Lab, 2017.
# gui Graphical User Interface to MIC_DynamixelServo
GUI has functionality to change position and set rotation speed. Also
it lets you turn the LED on and off
Marjolein Meddens, Lidke Lab 2017
Prevent opening more than one figure for same instrument
