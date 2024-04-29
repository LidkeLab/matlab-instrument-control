
MIC_Triggerscope contains methods to control a Triggerscope.
This class is designed for the control of a Triggerscope (written for
Triggerscope 3B and 4). All functionality present in the Triggerscope
documentation should be included.

EXAMPLE USAGE:
TS = MIC_Triggerscope('COM3', [], true);
This will create an instance of the class and automatically
attempt to connect to serial port COM3.

REQUIRES:
Triggerscope 3B, Triggerscope 4 (https://arc.austinblanco.com/)
connected via an accessible serial port
MATLAB 2019b or later (for updated serial communications, e.g.,
serialport())
Windows operating system recommended (Unix based systems might
require changes to, e.g., usage/definition of obj.SerialPort,
or perhaps more serious changes)
TeensyDuino serial communication driver installed
http://www.pjrc.com/teensy/serial_install.exe

Created by:
David J. Schodt (Lidke Lab, 2020)
