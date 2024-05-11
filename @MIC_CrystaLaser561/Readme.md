# # MIC_CrystaLaser561: Matlab Instrument Class for control of CrystaLaser 561 nm.
## Description:
This class Controls CrystaLaser module; can switch the laser ON/OFF, but cannot
set power. Power for this laser is set using the knob on the front
panel of controller.
Requires TTL input from the Digital Input/Output channel of NI card
to turn the laser ON/OFF remotely. STP CAT6 cable connection from
rear board of laser controller to the NI card should have pin
configuration: Pins 4-5: paired (for interlock); Pin 3: TTL;
Pin6: GND.
## Usage Example
Example: obj=MIC_CrystaLaser561('Dev1','Port0/Line0:1');
Functions: on, off, delete, shutdown, exportState, setPower
## REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Sandeep Pallikkuth, LidkeLab, 2017.
