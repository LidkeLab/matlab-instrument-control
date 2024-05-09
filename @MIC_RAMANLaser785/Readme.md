# MIC_RAMANLaser785: Matlab Instrument Class for controlling 785nm
ONDAX laser used in RAMAN Lightsheet microscope
The laser connects to computer using RS232-USB connection.
Laser provides control over driver current. A calibration file is
needed for current/power conversion.
Example: RL785= MIC_RAMANLaser785(COM3)
REQUIREMENTS:
MIC_Abstract
MIC_LightSource_Abstract
MATLAB 2016b orlater
Calibration.mat with 'CurrInterpol' and 'PowerInterpol'
CITATION: Sandeep Pallikkuth, Lidkelab, 2020.
