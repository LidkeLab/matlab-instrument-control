# by Gert-Jan based on ShutterTLL (by Farzin)
MIC_ShutterELL6 Matlab Instrument Control Class for the 2-position
slider ELL6, which can be used as a shutter (or filter slider).
This class controls an Elliptec ELL6 shutter, which is USB
connected via a rs232-to-USB2.0 board.  The shutter and the board are
delivered as a package, see the Thorlabs catalog, # ELL6K.
Make the object by: obj=MIC_ShutterELL6('COM#',Shutter#)where:
COM# = the number string of the RS232 com port reserved for the shutter;
Shutter# = the address string of the shutter motor, default '0', it
can be between 0 and F.
REQUIRES:
MIC_Abstract.m
Data Acquisition Toolbox on MATLAB
use MATLAB 2014b and higher
