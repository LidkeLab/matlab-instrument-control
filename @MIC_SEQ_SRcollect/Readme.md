# MIC_SEQ_SRcollect SuperResolution data collection software.
Super resolution data collection class for Sequential microscope
Works with Matlab Instrument Control (MIC) classes since March 2017
usage: SEQ=MIC_SEQ_SRcollect();
REQUIRES:
Matlab 2014b or higher
matlab-instrument-control
sma-core-alpha (if using PublishResults flag)
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
