# # MIC_CrystaLaser405: Matlab Instrument Class for CrystaLaser 405 nm.
## Description
Controls CrystaLaser module; setting power within the range of 0 to
10 mW (The values measured on 2/23/2017 are 0.25 to 8.5 mW).
The ON/OFF funtion is controlled by a TTL pulse and the power variation
is acheived by providing analog voltage to the laser controller (range 0 to 10V).
The TTL pulse and analog voltage are provided by an NI card.
An STP CAT6 cable connection is needed from the rear board of the
laser controller to the Digital/Analog Input/Output channels of NI card. The
cable pin configuration is:
Pins 4-5: paired (for interlock); Pin 2: Analog; Pin 3: TTL; Pin6: GND.
The power range of the laser is set using the knob on front panel of
controller.
Please check the laser is turned on at the controller before calling funtions in
this class
## Usage Example
Example: obj=MIC_CrystaLaser405('Dev1','ao1','Port0/Line3');
## Key Functions:
on, off, State, setPower, delete, shutdown, unitTest
## REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
