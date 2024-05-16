# MIC_Reg3DTrans

## Description
This class Register a sample to a stack of transmission images Class that performs 3D registration using transmission images

## INPUT
CameraObj - camera object -- tested with MIC_AndorCamera only
StageObj - stage object -- tested with MIC_MCLNanoDrive only
LampObj - lamp object -- tested with MIC_IX71Lamp only, will work
with other lamps that inherit from
MIC_LightSource_Abstract
Calibration file (optional)

## SETTING (IMPORTANT!!)
There are several Properties that are system specific. These need
to be specified after initialization of the class, before using
any of the functionality. See Properties section for explanation
and which ones.

## REQUIREMENT
Matlab 2014b or higher
MIC_Abstract

## MICROSCOPE SPECIFIC SETTINGS
TIRF: LampPower=2; LampWait=2.5; CamShutter=true; ChangeEMgain=true;
EMgain=2; ChangeExpTime=true; ExposureTime=0.01;
### Citations: Marjolein Meddens,  Lidke Lab 2017
### Updated version:Hanieh Mazloom-Farsibaf, Lidke Lab 2018.

