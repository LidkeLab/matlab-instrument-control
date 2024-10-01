
MIC_RebelStarLED: Matlab Instrument Control Class for the Rebel Star LED

This class controls a Luxeon Rebel Star LED via a 700 mA 'BUCKPUCK'
model 3023-D-E-700.  The power can be set between 0 and 100 as well as
turned off or on.

The current from the LED driver is regulated by the analog voltage output
of a NI DAQ card. The Constructor requires the Device and Channel
details.

The output current, and therfore the light output follows the
relationship
C_out/C_max = (V_off - V_in)/(V_off - V_100)
Where C_out is the output current, V_in is the input voltage,
V_off is the voltage where output current drops to zero and V_100 is the
Voltage where current begins to drop from 100. V_off and V_100 must be
measured and set in the class.

Link to Driver:
http://www.luxeonstar.com/700ma-external-dimming-buckpuck-dc-driver-leaded

Example: RS = MIC_RebelStarLED('Dev1', 'ao1');
Functions: delete, setPower, on, off, exportState, shutdown

REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

CITATION: Lidkelab, 2017.
