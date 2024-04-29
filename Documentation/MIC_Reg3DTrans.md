
MIC_Reg3DTrans Register a sample to a stack of transmission images
Class that performs 3D registration using transmission images

INPUT
CameraObj - camera object -- tested with MIC_AndorCamera only
StageObj - stage object -- tested with MIC_MCLNanoDrive only
LampObj - lamp object -- tested with MIC_IX71Lamp only, will work
with other lamps that inherit from
MIC_LightSource_Abstract
Calibration file (optional)

SETTING (IMPORTANT!!)
There are several properties that are system specific. These need
to be specified after initialization of the class, before using
any of the functionality. See properties section for explanation
and which ones.

REQUIRES
Matlab 2014b or higher
MIC_Abstract

MICROSCOPE SPECIFIC SETTINGS
TIRF: LampPower=?; LampWait=2.5; CamShutter=true; ChangeEMgain=true;
EMgain=2; ChangeExpTime=true; ExposureTime=0.01;

created by
Marjolein Meddens,  Lidke Lab 2017
Update:Hanieh Mazloom-Farsibaf, Lidke Lab 2018
