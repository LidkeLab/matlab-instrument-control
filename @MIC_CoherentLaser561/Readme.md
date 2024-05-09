# .  MIC_CoherentLaser561: Matlab Instrument Class for Coherent Sapphire Laser 561
The laser connects to computer using USB connection.
This class requies FilterWheel and Shutter class to control power.
Minpower on the laser controller is 10 mW but by using Filter and
Shutter it provides continuous variation from 0 to 100 mW.
Example: CL561= MIC_CoherentLaser561(COM3)
REQUIREMENTS:
.  MIC_Abstract
.  MIC_LightSource_Abstract
MIC_FilterWheel
MIC_DynamixelServo
MIC_ShutterTTL
.  MATLAB 2016b orlater
CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
