
MIC_GalvoAnalog: Matlab Instrument Class for controlling Galvo Mirror

Controls the Galvo mirror. The galvo mirror is controlled
via output voltage of NI card. The operating range is -10:10 Volts

Example: obj=MIC_GalvoAnalog('Dev1','ao1');
Functions: delete, exportState, setVoltage

REQUIREMENTS:
MIC_Abstract.m
MATLAB NI-DAQmx driver installed via the Support Package Installer

CITATION: Marjolein Meddens, Lidke Lab 2017
