# MIC_TIRF_SRcollect: Matlab instrument class for controlling TIRF microscope.
## Description
Super resolution data collection software for TIRF microscope. Creates
object calling MIC classes for Andor EMCCD camera, MCL NanoDrive stage,
405 nm CrystaLaser, 488 nm SpectaPhysics Laser, 561 nm Coherent Laser,
642 nm Thorlabs TCube Laser Diode, halogen lamp attached to microscope
and the registration class Reg3DTrans.
Works with Matlab Instrument Control (MIC) classes since March 2017
## Constructor
TIRF=MIC_TIRF_SRcollect();
## REQUIREMENT:
MIC_Abstract
MIC_LightSource_Abstract
MIC_AndorCamera
MIC_NewportLaser488
MIC_CrystaLaser405
MIC_CoherentLaser561
MIC_TcubeLaserDiode
MIC_IX71Lamp
MIC_MCLNanoDrive
MIC_Reg3DTrans
Matlab 2014b or higher
### CITATION:
First version: Sheng Liu
MIC compatible version Sandeep Pallikuth & Marjolein Meddens, Lidke Lab 2017. Sajjad Khan, Lidkelab, 2021.
# GUI SRcollect Gui for TIRF microscope
Detailed explanation goes here
