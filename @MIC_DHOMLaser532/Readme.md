# MIC_DHOMLaser532: Matlab Instrument Class for DHOM Laser 532.
## Description
This class controls DHOM laser module, setting power within the range of 0 to
400 mW (measured on 2/23/2017). The power modulation
is done by providing input analog voltage to the laser controller
from a NI card (range 0 to 5V).
Needs input of NI Device and AO Channel.
## Constructor
Example: obj=MIC_DHOMLaser532('Dev2','ao1');
## Key Functions
on, off, State, setPower, delete, shutdown, exportState
## REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
