
MIC_NDFilterWheel: Matlab Instrument Control for servo operated
Filter wheel containing Neutral Density filters
Filter wheel should be controlled by Dynamixel Servos. See "Z:\Lab
General Info and Documents\TIRF Microscope\Build Instructions for
Filter Wheel Setup.doc"

This class works with an arbitrary number of filters
To create a MIC_NDFilterWheel object the position and transmittance
of each filter must be specified. The position must be given in
degrees rotation corresponding to the input of the servo. This
can be calibrated by setting the servo rotation such that the
specific filter is in the optical path. The Rotation property of the
servo gives the right position value for that filter.

Example: obj=MIC_NDFilterWheel(ServoId,FracTransmVals,FilterPos);
ServoId: Id of servo, is written on servo
FracTransmVals: N-element array of Fractional Transmittance
Values for N filters in wheel, order (linear index)
should correspond to order in FilterPos input
FilterPos: N-element array of Rotation (degrees) of servo
corresponding to filter positions, order (linear
index should correspond to order in FracTransmVals
Example for 6 filters:
FWobj = MIC_NDFilterWheel(1, [1 0.8 0.6 0.4 0.2 0], [0 60 120 180 240 300])
Functions: setFilter, exportState, setTransmittance
get.CurrentFilter, get.CurrentTransmittance

REQUIRES
Matlab 2014b or higer
MIC_Abstract.m
MIC_DynamixelServo.m

CITATION: Marjolein Meddens, Lidke Lab, 2017.
