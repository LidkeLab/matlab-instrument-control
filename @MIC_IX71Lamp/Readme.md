# MIC_IX71Lamp Matlab Instrument Control Class for the MPB-laser.
Controls the Olympus lamp, can turn it off and on and change the
power.
Example: RS=MIC_IX71Lamp('Dev1','ao0','Port0/Line0');
Functions: constructor(), setPower(), on(), off(), exportState(),
shutdown()
REQUIREMENTS:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB 2014 or higher.
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION:
Mohamadreza Fazel and Hanieh Mazloom-Farsibaf, Lidkelab, 2017
