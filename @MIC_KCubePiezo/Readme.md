# # MIC_KCubePiezo Matlab Instrument Control Class for ThorLabs Cube Piezo
## Description
This class controls a linear piezo stage using the Thorlabs KCube Piezo
controller KPZ101 and TCube strain gauge controller KSG101. It uses the Thorlabs
Kinesis C-API via pre-complied mex files.
## Key Functions
- **Constructor (`MIC_KCubePiezo(SerialNoKPZ001, SerialNoKSG001, AxisLabel)`):** Initializes the device with specific serial numbers and the designated axis. Establishes connections and calibrates the device for use.
- **`openDevices()`:** Opens connections to the KCube Piezo and Strain Gauge controllers using Thorlabs Kinesis C-API.
- **`closeDevices()`:** Safely closes the connections to the piezo and strain gauge controllers to ensure the system is properly shut down.
- **`zeroStrainGauge()`:** Sets the strain gauge to zero to ensure accurate position feedback, essential for precise operations.
- **`calibrateStrainGauge()`:** Performs a calibration of the strain gauge by measuring known positions to determine the scale and offset required for accurate positioning.
- **`setPosition(Position)`:** Moves the piezo stage to the specified position, with input validated against the stage's configured minimum and maximum range.
- **`getPosition()`:** Retrieves the current position of the piezo stage, providing feedback on the stage's location in its operational range.
- **`shutdown()`:** Completes the session by turning off the devices and ensuring all settings are reset to prevent damage or misconfiguration for future operations.
- **`exportState()`:** Exports the current operational state, including position, calibration data, and system settings, useful for session logging or debugging.
## Usage Example
PX=MIC_KCubePiezo(SerialNoKPZ001,SerialNoKSG001,AxisLabel)
PX.gui()
PX.setPosition(10);
## Kinesis Setup:
change these settings in Piezo device on Kinesis Software GUI before you create object:
1-set on "External SMA signal" (in Advanced settings: Drive Input Settings)
2-set on "Software+Potentiometer" (in Advanced settings: Input Source)
3-set on "closed loop" (in Control: Feedback Loop Settings>Loop Mode)
4-check box of "Persist Settings to the Device" (in Settings)
## REQUIRES:
MIC_Abstract.m
MIC_LinearStage_Abstract.m
Precompiled set of mex files Kinesis_KCube_PCC_*.mex64 and Kinesis_KCube_SG_*.mex64
The following dll must be in system path or same directory as mex files:
Thorlabs.MotionControl.KCube.Piezo.dll
Thorlabs.MotionControl.KCube.StrainGauge.dll
Thorlabs.MotionControl.DeviceManager.dll
Citation: Keith Lidke, LidkeLab, 2018.
