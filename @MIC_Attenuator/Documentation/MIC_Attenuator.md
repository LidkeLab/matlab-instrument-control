
MIC_Attenuator Matlab Instrument Control Class for Attenuator.

Controls the Attenuator, can change the attenuation. You can also use
the power meter to callibrate the attenuator for a new setup and then
use it. Note that the attenuator does not block the beam completely.
The laser damage threshold for this attenuator is 1 W/cm2. The
operation wavelength is 420-700 nm.
The current from the LED driver is regulated by the analog voltage
output (0 to 5 V) of a NI DAQ card. The Constructor requires the
Device and Channel details.

Example: A=MIC_Attenuator('Dev1','ao1')
Functions: constructor(), loadCalibration(), delete(), setVoltage()
setTransmission(), exportState(), shutdown(), updateGui()
findMaxPower(), calibration()

REQUIREMENTS:
MIC_Abstract.m
MATLAB 2014 or higher.
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer

CITATION: Mohamadreza Fazel, Lidkelab, 2017.
