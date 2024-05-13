# MIC_SEQ_SRcollect SuperResolution data collection software.
## Description
Super resolution data collection class for Sequential microscope
Works with Matlab Instrument Control (MIC) classes since March 2017
## Constructor: SEQ=MIC_SEQ_SRcollect();
## Methods Overview
### Initialization and Configuration
- `MIC_SEQ_SRcollect()`: Constructor for the class that initializes the connection to all the necessary hardware components.
- `setupSCMOS()`: Sets up the main sCMOS camera used for data collection.
- `setupIRCamera()`: Configures the infrared camera used for active stabilization.
- `setupStagePiezo()`: Initializes the piezo-electric stages for precise movement control.
- `setupStageStepper()`: Sets up the stepper motors for broader range movements.
- `setupLamps()`: Configures the LED lamps used for illumination during focusing and alignment.
- `setupLasers()`: Initializes the lasers used in super-resolution imaging.
- `setupFlipMountTTL()`: Configures a flip mount for controlling laser attenuation.
- `setupShutterTTL()`: Sets up a shutter for controlling laser exposure.
- `setupAlignReg()`: Initializes alignment and registration tools for precise imaging.
### Stage and Sample Handling
- `unloadSample()`: Moves the sample stage to a higher position to facilitate sample mounting.
- `loadSample()`: Moves the sample stage to the imaging position after the sample is mounted.
- `findCoverslipFocus()`: Utilizes the lamp to help in locating the coverslip focus before starting imaging sequences.
### Imaging and Acquisition
- `autoCollect()`: Automatically handles the imaging sequence, including cell exposure and registration.
- `exposeCellROI()`: Manages the exposure settings for the region of interest where the cell is located.
- `exposeGridPoint()`: Adjusts exposure settings based on the specific grid point in a multi-well plate.
- `startSequence()`: Begins the sequence of super-resolution data collection.
- `startROILampFocus()`: Begins a focus sequence using the lamp for illumination.
- `startROILaserFocusLow()`: Initiates a low-power laser focus sequence to adjust focus before imaging.
- `startROILaserFocusHigh()`: Initiates a high-power laser focus sequence for optimal focus adjustment.
### Utility and Maintenance
- `delete()`: Cleans up the objects and hardware connections when the class instance is being destroyed.
- `exportState()`: Exports the current state of all configurations and settings for diagnostic or reproducibility purposes.
### Position Adjustments
- `moveStepperUpLarge()`, `moveStepperDownLarge()`: Moves the stepper motor a large step up or down.
- `moveStepperUpSmall()`, `moveStepperDownSmall()`: Adjusts the stepper motor position by a small increment.
- `movePiezoUpSmall()`, `movePiezoDownSmall()`: Fine-tunes the piezo position in small steps for precise z-positioning.
### Status and Alerts
- `updateStatus()`: Updates the GUI or status indicators with the current state or progress of operations.
## Requirements:
Matlab 2014b or higher
matlab-instrument-control
sma-core-alpha (if using PublishResults flag)
Citations:
First version: Sheng Liu
Second version: Farzin Farzam
MIC compatible version: Farzin Farzam
Lidke Lab 2017
old version of this code is named SeqAutoCollect.m and can be found at
documents>MATLAB>Instrumentation>development>SeqAutoCollect
# autoCollect initiates collection of SR data using saved reference data.
This method will initiate the super-resolution data collection workflow
for the MIC_SEQ_SRcollect class, acquiring data for selected cells in
the RefDir in an automated fashion.
INPUTS:
StartCell: (integer, scalar)(default = 1) Specifies the cell (of a
list of cells in RefDir) for which to start the
acquisition.
RefDir: Directory containing the cell reference .mat files.
Define default parameter values.
# Take ROI lamp image, and allow click on cell, start lamp focus
# Move to a grid point, take full cam lamp image, give figure to
click on cell.
Center the piezos.
# Registration of first cell to find offset after remounting
# Allow user to focus and indentify cell
# Ensure only one sequential microscope GUI is opened at a time.
# Take reference image and save
Update the status of the instrument to indicate we are collecting
reference data.
# startSequence collects/saves SR data for a cell specified in RefStruct.
This method will collect and save a super-resolution dataset for a cell
specified in the RefStruct.
INPUTS:
RefStruct: (structure) Structured array containing the information
needed to find/acquire data for a specific cell.
LabelID: (integer, scalar) Integer used to specify the current
label (for a sequential acquisition) being observed.
Setup directories/filenames as needed.
