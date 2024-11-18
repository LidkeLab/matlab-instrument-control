### Matlab Instrument Control classes

|**MIC** classes|description|
-------------|---
[mic.ActiveReg3D](../src/+mic/@ActiveReg3D/Readme.md) | active 3D registration using camera and stage control via piezoelectric actuators
[mic.H5](../src/+mic/@H5/Readme.md) | static methods for working with HDF5 files
[mic.Joystick](../src/+mic/@Joystick/Readme.md) | control the TIRF stage with a joystick
[mic.abstract](../src/+mic/@abstract/Readme.md) | Matlab Instrument Control abstract class
&nbsp;&nbsp;&nbsp;[mic.camera.abstract](../src/+mic/+camera/@abstract/Readme.md) | common interface for all cameras
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.example](../src/+mic/+camera/@example/Readme.md) | template for implementing classes inheriting from mic.camera.abstract
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.AndorCamera](../src/+mic/+camera/@AndorCamera/Readme.md) | control an Andor camera
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.AndorCameraZyla](../src/+mic/+camera/@AndorCameraZyla/Readme.md) | control an Andor camera
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.DCAM4Camera](../src/+mic/+camera/@DCAM4Camera/Readme.md) | control a Hamamatsu camera using the DCAM4 API
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.HamamatsuCamera](../src/+mic/+camera/@HamamatsuCamera/Readme.md) | control a Hamamatsu camera
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.Imaq](../src/+mic/+camera/@Imaq/Readme.md) | class designed for camera control using the Image Acquisition Toolbox
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.IMGSourceCamera](../src/+mic/+camera/@IMGSourceCamera/Readme.md) | control an ImagingSource camera
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.PyDcam](../src/+mic/+camera/@PyDcam/Readme.md) | control a camera through a Python interface
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.ThorlabsIR](../src/+mic/+camera/@ThorlabsIR/Readme.md) | control a Thorlabs IR camera
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.ThorlabsSICamera](../src/+mic/+camera/@ThorlabsSICamera/Readme.md) | control a Thorlabs Scientific Camera via a USB port
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.camera.IRSyringPump](../src/+mic/+camera/@IRSyringPump/Readme.md) | use the Syringe Pump at the same time data is taken with IRCamera
&nbsp;&nbsp;&nbsp;[mic.lightsource.abstract](../src/+mic/+lightsource/@abstract/Readme.md) | abstract class for all light source devices
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.example](../src/+mic/+lightsource/@example/Readme.md) | template for implementing classes inheriting from mic.lightsource.abstract
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.CoherentLaser561](../src/+mic/+lightsource/@CoherentLaser561/Readme.md) | coherent Sapphire laser 561
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.CrystaLaser405](../src/+mic/+lightsource/@CrystaLaser405/Readme.md) | CrystaLaser 405 nm
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.CrystaLaser561](../src/+mic/+lightsource/@CrystaLaser561/Readme.md) | CrystaLaser 561 nm
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.DHOMLaser532](../src/+mic/+lightsource/@DHOMLaser532/Readme.md) | DHOM Laser 532
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.HSMLaser488](../src/+mic/+lightsource/@HSMLaser488/Readme.md) | 488 laser on HSM microscope
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.IX71Lamp](../src/+mic/+lightsource/@IX71Lamp/Readme.md) | control the Olympus lamp for the MPB-laser
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.MPBLaser](../src/+mic/+lightsource/@MPBLaser/Readme.md) | control the MPB-laser
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.RAMANLaser785](../src/+mic/+lightsource/@RAMANLaser785/Readme.md) | control 785nm ONDAX laser used in RAMAN Lightsheet microscope
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.RebelStarLED](../src/+mic/+lightsource/@RebelStarLED/Readme.md) | control the Luxeon Rebel Star LED
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.TCubeLaserDiode](../src/+mic/+lightsource/@TCubeLaserDiode/Readme.md) | control Laser Diode through USB via ThorLabs TCube Laser Diode Driver TLD001
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.ThorlabsLED](../src/+mic/+lightsource/@ThorlabsLED/Readme.md) | control a LED lamp with different wavelengths from Thorlabs
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.TIRFLaser488](../src/+mic/+lightsource/@TIRFLaser488/Readme.md) | control Newport Cyan Laser 488 on the TIRF microscope
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.lightsource.VortranLaser488](../src/+mic/+lightsource/@VortranLaser488/Readme.md) | control Vortran Laser 488
&nbsp;&nbsp;&nbsp;[mic.linearstage.abstract](../src/+mic/+linearstage/@abstract/Readme.md) | abstract class for linear stages
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.linearstage.example](../src/+mic/+linearstage/@example/Readme.md) | template for implementing classes inheriting from mic.linearstage.abstract
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.linearstage.KCubePiezo](../src/+mic/+linearstage/@KCubePiezo/Readme.md) | control a Thorlabs KCube Piezo stage
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.linearstage.MCLMicroDrive](../src/+mic/+linearstage/@MCLMicroDrive/Readme.md) | control a Mad City Labs Micro Stage
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.linearstage.TCubePiezo](../src/+mic/+linearstage/@TCubePiezo/Readme.md) | control a Thorlabs TCube Piezo stage
&nbsp;&nbsp;&nbsp;[mic.powermeter.abstract](../src/+mic/+powermeter/@abstract/Readme.md) | control a power meter (PM100D)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.powermeter.example](../src/+mic/+powermeter/@example/Readme.md) | template for implementing classes inheriting from mic.powermeter.abstract
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.powermeter.PM100D](../src/+mic/+powermeter/@PM100D/Readme.md) | control the power meter PM100D
&nbsp;&nbsp;&nbsp;[mic.stage3D.abstract](../src/+mic/+stage3D/@abstract/Readme.md) | abstract class for all stages
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.stage3D.example](../src/+mic/+stage3D/@example/Readme.md) | template for implementing classes inheriting from mic.stage3D.abstract
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.stage3D.MCLNanoDrive](../src/+mic/+stage3D/@MCLNanoDrive/Readme.md) | control a 3D Peizo stage from Mad City Labs
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[mic.stage3D.NanoMaxPiezos](../src/+mic/+stage3D/@NanoMaxPiezos/Readme.md) | in a Thorlabs NanoMax stage
&nbsp;&nbsp;&nbsp;[mic.Attenuator](../src/+mic/@Attenuator/Readme.md) | control the Attenuator
&nbsp;&nbsp;&nbsp;[mic.BiochemValve](../src/+mic/@BiochemValve/Readme.md) | control the BIOCHEM flow selection valves
&nbsp;&nbsp;&nbsp;[mic.CavroSyringePump](../src/+mic/@CavroSyringePump/Readme.md) | control the Cavro syringe pump PN 20740556 -D
&nbsp;&nbsp;&nbsp;[mic.DMP40](../src/+mic/@DMP40/Readme.md) | control the Deformable Mirror
&nbsp;&nbsp;&nbsp;[mic.DynamixelServo](../src/+mic/@DynamixelServo/Readme.md) | Dynamixel Servos are used to control the rotation of filter wheels
&nbsp;&nbsp;&nbsp;[mic.simulated_Instrument](../src/+mic/@simulated_Instrument/Readme.md) | template for implementing classes inheriting from mic.abstract
&nbsp;&nbsp;&nbsp;[mic..simulated_Camera](../src/+mic/@simulated_Camera/Readme.md) | template for implementing classes inheriting from mic.camera.abstract
&nbsp;&nbsp;&nbsp;[mic..simulated_LightSource](../src/+mic/@simulated_LightSource/Readme.md) | template for implementing classes inheriting from mic.lightsource.abstract
&nbsp;&nbsp;&nbsp;[mic..simulated_LinearStage](../src/+mic/@simulated_LinearStage/Readme.md) | template for implementing classes inheriting from mic.linearstage.abstract
&nbsp;&nbsp;&nbsp;[mic..simulated_PowerMeter](../src/+mic/@simulated_PowerMeter/Readme.md) | template for implementing classes inheriting from mic.powermeter.abstract
&nbsp;&nbsp;&nbsp;[mic..simulated_Stage3D](../src/+mic/@simulated_Stage3D/Readme.md) | template for implementing classes inheriting from mic_stage3D.abstract
&nbsp;&nbsp;&nbsp;[mic.FlipMountLaser](../src/+mic/@FlipMountLaser/Readme.md) | control a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M controller
&nbsp;&nbsp;&nbsp;[mic.FlipMountTTL](../src/+mic/@FlipMountTTL/Readme.md) | control a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M controller
&nbsp;&nbsp;&nbsp;[mic.GalvoAnalog](../src/+mic/@GalvoAnalog/Readme.md) | control the Galvo mirror
&nbsp;&nbsp;&nbsp;[mic.GalvoDigital](../src/+mic/@GalvoDigital/Readme.md) | control the Cambridge Technology galvo mirror on the HSM microscope
&nbsp;&nbsp;&nbsp;[mic.HamamatsuLCOS](../src/+mic/@HamamatsuLCOS/Readme.md) | control a phase SLM connected through a DVI interface
&nbsp;&nbsp;&nbsp;[mic.NanoMax](../src/+mic/@NanoMax/Readme.md) | control NanoMax stage
&nbsp;&nbsp;&nbsp;[mic.NDFilterWheel](../src/+mic/@NDFilterWheel/Readme.md) | servo operated Filter wheel containing Neutral Density filters
&nbsp;&nbsp;&nbsp;[mic.OptotuneLens](../src/+mic/@OptotuneLens/Readme.md) | control Optotune Electrical Lens
&nbsp;&nbsp;&nbsp;[mic.Reg3DTrans](../src/+mic/@Reg3DTrans/Readme.md) | register a sample to a stack of transmission images
&nbsp;&nbsp;&nbsp;[mic.ShutterELL6](../src/+mic/@ShutterELL6/Readme.md) | control slider ELL6, which can be used as a shutter (or filter slider)
&nbsp;&nbsp;&nbsp;[mic.ShutterTTL](../src/+mic/@ShutterTTL/Readme.md) | control a Thorlabs SH05 shutter via a Thorlabs KSC101 solenoid controller
&nbsp;&nbsp;&nbsp;[mic.StepperMotor](../src/+mic/@StepperMotor/Readme.md) | control Benchtop stepper motor
&nbsp;&nbsp;&nbsp;[mic.SyringePump](../src/+mic/@SyringePump/Readme.md) | control Syringe Pump by kdScientific (Model: LEGATO100)
&nbsp;&nbsp;&nbsp;[mic.Triggerscope](../src/+mic/@Triggerscope/Readme.md) | control a Triggerscope (written for 3B and 4)
