
MIC_HSMLaser488: Matlab Instrument Class for 488 laser on HSM
microscope.

To use this class, you have to turn on the laser manually with its
contorlerat the top shelf of HSM table.
To control the laser, use shutter and liquid crystal controller
(LCC)in front of the laser. A filter (No:2) in front of the laser
helps to not damage the LLC.

Example: obj=MIC_HSMLaser488();
Functions: on, off, delete, shutdown, exportState, setPower

REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
MIC_Attenuator
MIC_ShutterTTL

CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
