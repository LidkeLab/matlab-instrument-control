# MIC_ThorlabsIR Matlab Instrument Class for control of Thorlabs IR Camera (Model:DCC1545M)
## Description
This class controls the DCxCamera via a USB port. It is required to
install the software from the following link
https://www.thorlabs.com/software_pages/viewsoftwarepage.cfm?code=ThorCam
and make sure 'uc480DotNet.dll' is in this directory:
'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet'
to initialize the camera
For the first time it is required to load the directory of .dll file
from Program Files.
## Constructor
Example: obj=MIC_ThorlabsIR();
## Key Function: initialize, abort, delete, shutdown, getlastimage, getdata, setup_acquisition, start_focus, start_capture, start_sequence, set.ROI, get_properties, exportState, unitTest
## REQUIREMENTS:
MIC_Abstract.m
MIC_Camera_Abstract.m
MATLAB software version R2016b or later
uc480DotNet.dll file downloaded from the Thorlabs website for DCx cameras
CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
