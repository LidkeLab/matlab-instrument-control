# MIC_ThorlabsLED Matlab Instrument Class for control of the Thorlabs LED
This class controls a LED lamp with different wavelength from Thorlabs.
Requires TTL input from the Analogue Input/Output channel of NI card
to turn the laser ON/OFF as well as set the power remotely.
BNC cable is needed to connect to device.
Set Trig=MOD on control device for Lamp and turn on knob manually
more than zero to control from computer.
Example: obj=MIC_ThorlabsLED('Dev1','ao1');
Functions: on, off, delete, shutdown, exportState, setPower
REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
