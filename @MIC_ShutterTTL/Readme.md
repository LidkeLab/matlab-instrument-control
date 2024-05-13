# MIC_ShutterTTL
Matlab Instrument Control Class for the shutter
## Description
This class controls a Thorlabs SH05 shutter via a Thorlabs KSC101
solenoid controller. KSC101 controller is triggerd in
(put the controller in trigger mode) via a TTL signal passing
from the computer to the controller through a NI-DAQ card.
TTL signal lets the shutter to be set open or close.
so shutter is regulated by the Digital voltage output of the NI-DAQ card.
Make the object by: obj=MIC_ShutterTTL('Dev#','Port#/Line#')where:
Dev# = Device number assigned to DAQ card by computer USB port of the
Port# = Port number in use on the DAQ card by your shutter connection
Line# = Line number in use on the DAQ card by the Port
## Constructor
Example: obj=MIC_ShutterTTL('Dev1','Port0','Line1');
Functions: close, open, delete, exportState
## REQUIRES:
MIC_Abstract.m
Data Acquisition Toolbox on MATLAB
MATLAB NI-DAQmx driver in MATLAB installed via the Support Package Installer
type "SupportPackageInstaller" on command line to install the
support package for NI-DAQmx use MATLAB 2014b and higher
CITATION: Farzin Farzam, Lidkelab, 2017.
