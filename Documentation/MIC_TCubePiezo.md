
MIC_TCubePiezo Matlab Instrument Control Class for ThorLabs TCube Piezo

This class controls a linear piezo stage using the Thorlabs TCube Piezo
controller TPZ001 and TCube strain gauge controller TSG001. It uses the Thorlabs
Kinesis C-API via pre-complied mex files.

USAGE:
PX=MIC_TCubePiezo(SerialNoTPZ001,SerialNoTSG001,AxisLabel)
PX.gui()
PX.setPosition(10);

Kinesis Setup:
change these settings in Piezo device on Kinesis Software GUI before you create object:
1-set on "External SMA signal" (in Advanced settings: Drive Input Settings)
2-set on "Software+Potentiometer" (in Advanced settings: Input Source)
3-set on "closed loop" (in Control: Feedback Loop Settings>Loop Mode)
4-check box of "Persist Settings to the Device" (in Settings)

REQUIRES:
MIC_Abstract.m
MIC_LinearStage_Abstract.m
Precompiled set of mex files Kinesis_PCC_*.mex64 and Kinesis_SG_*.mex64
The following dll must be in system path or same directory as mex files:
Thorlabs.MotionControl.TCube.Piezo.dll
Thorlabs.MotionControl.TCube.StrainGauge.dll
Thorlabs.MotionControl.DeviceManager.dll

CITATION: Keith Lidke, LidkeLab, 2017.
