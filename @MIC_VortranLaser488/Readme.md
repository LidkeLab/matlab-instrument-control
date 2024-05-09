# MIC_VortranLaser488: Matlab Instrument Class for Vortran Laser 488.
Controls Vortran laser module, setting power within the range of 0 to
50 mW. This is acheived by providing input voltage to the laser
controller from a NI card (range 0 to 5V).
Needs input of NI Device and AO Channel.
The "External Control" and Max Power Range" for the laser needs to
be set by connecting the laser to the computer by miniUSB-USB cable
and using the Vortran_Stradus Laser Control Software Version 4.0.0
(CD located in second draw of filing cabinet in room 118)
Example: obj=MIC_VortranLaser488('Dev1','ao1');
Functions: on, off, exportState, setPower, delete, shutdown
REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
