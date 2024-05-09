# MIC_RB_PSFEng is a SuperResolution data collection software.
MIC_RB_PSFEng Explore and design PSFs on the Reflected Beam
Microscope and other PSF engineering setups. This class is designed
to interface with various hardware
components like SLM, cameras, lasers, and piezos to enable the
exploration and design of PSFs.
It includes methods for constructing the PSF, calibrating the pupil position,
and other utilities that aid in PSF engineering.
CITATION: Sandeep Pallikuth & Marjolein Meddens, Lidke Lab 2017.
Sajjad Khan, Lidkelab, 2021.
# blazeScanIntensity Calculates expected intensity during blaze scan
Function consists of 4 parts:
1. Pupil function is unblazed
2. Less than half of pupil is blazed
3. More than half of pupil is blazed
4. Pupil is completely blazed
Intensity is calculated as follows:
Icalc = Ibead * (AreaUnblazed/AreaTotal) + Ibg
where the area's are of the pupil
INPUTS:
BlazeWidth: Width of blaze (pixels)
Ibead:      Integrated intensity of bead without blaze (to be
optimized)
Ibg:        Background intensity when pupil is completely blazed
PupilPos:   Position of pupil center (pixels)
Rpupil:     Pupil radius
OUTPUTS:
I:          Expected intensity
Marjolein Meddens 2017, Lidke Lab
check input
# blazeScanObjFcn Objective function to fit blaze scan result
Objective function consists of 4 parts:
1. Pupil function is unblazed
2. Less than half of pupil is blazed
3. More than half of pupil is blazed
4. Pupil is completely blazed
Intensity is calculated as follows:
Icalc = Ibead * (AreaUnblazed/AreaTotal) + Ibg
where the area's are of the pupil
Cost parameter f is calculated as sum of squared errors
INPUTS:
X:          Vector containing parameters to be optimized:
X(1):   Integrated intensity of bead without blaze
X(2):   Background intensity when pupil is completely blazed
X(3):   Position of pupil center (pixels)
X(4):   Pupil radius (pixels)
I:          Measured integrated intensity of a bead during blaze scan
BlazeWidth: Width of blaze (pixels)
OUTPUTS:
f:          value to minimize in fminsearch
Marjolein Meddens 2017, Lidke Lab
# GUI Gui for MIC_RB_PSFEng class
Detailed explanation goes here
Prevent opening more than one figure for same instrument
# UNTITLED Summary of this function goes here
Detailed explanation goes here
number of steps during optimization
# scanBlaze scans a blaze across the SLM to measure pupil position
OUTPUTS
HInt:   Result of horizontal scan, Intensity
VInt:   Result of vertical scan, Intensity
REQUIRES
Marjolein Meddens, Lidke Lab 2017
reset SLM image
