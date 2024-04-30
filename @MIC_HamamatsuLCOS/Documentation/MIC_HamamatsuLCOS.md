
MIC_HamamatsuLCOS: Matlab Instrument Control of Hamamatsu LCOS SLM

This class controls a phase SLM connected through a DVI interface.
Pupil diameter is 2*NA*f, f=M/180 for olympus objectives

Example: obj = MIC_HamamatsuLCOS();
Functions: delete, gui, exportState, setupImage, displayImage,
calcZernikeImage, calcOptimPSFImage, calcPrasadImage,
calcZernikeStack, calcDisplayImage, calcBlazeImage,
displayCheckerboard

REQUIREMENTS:
MIC_Abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox

CITATION: Marjoleing Meddens, Lidkelab, 2017 & Sajjad Khan, Lidkelab,
2021.
