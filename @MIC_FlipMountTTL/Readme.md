# MIC_FlipMountTTL: Matlab Instrument Control Class for the flipmount
## Description
This class controls a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M
controller.  Controller is triggered in via a TTL signal passing from the
computer to the controller through a NI-DAQ card. TTL signal lets the
flipmount to be set in up or down positions, so flipmount is regulated by
the Digital voltage output of the NI-DAQ card.
## Usage Example
Make the object by: obj = MIC_FlipMountTTL('Dev#', 'Port#/Line#') where:
Dev#  = Device number assigned to DAQ card by computer USB port of the
Port# = Port number in use on the DAQ card by your flipmount connection
Line# = Line number in use on the DAQ card by the Port
## Constructor
Example: obj = MIC_FlipMountTTL('Dev1', 'Port0/Line1');
## Key Functions: FilterIn, FilterOut, gui, exportState
## REQUIREMENTS:
MIC_Abstract.m
Data Acquisition Toolbox on MATLAB
MATLAB NI-DAQmx driver in MATLAB installed via the Support Package
Installer
type "SupportPackageInstaller" on command line to install the support
package for NI-DAQmx
### CITATION: Farzin Farzam, Lidkelab, 2017.
