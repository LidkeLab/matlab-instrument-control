# # MIC_GalvoDigital: Matlab instrument class to control Galvo Mirror using digital input
## Description
This class controls the galvo mirror (Cambridge Technology)on the
HSM microscope.It changes the angle of galvo mirror to scan the
sample. Input voltage [-10,10] to change the angle in [-15,15],
is sent by 16 channels on NI card. There are 4 more
channels to make the galvo enable to move.
## Usage Example
Example: obj=MIC_GalvoDigital('Dev1','Port0/Line0:31');
Funtions: delete, clearSession, enable, disable, reset, setSequence,
angle2word, word2angle, get.Angle, setAngle, exportState,
set.Voltage, get.Voltage,G. updateGui
## REQUIREMENTS:
MIC_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
# gui: Graphical User Interface to MIC_GalvoDigital
Functions: gui2properties, properties2gui, closeFigure, CalAngle,
setAngle_Button, setParameters_Button, ToggleGalvo
REQUIREMENTS:
MIC_Abstract.m
MATLAB NI-DAQmx driver installed via the Support Package Installer
CITATION: Hanieh Mazloom-Farsibaf, Lidlelab, 2017.
