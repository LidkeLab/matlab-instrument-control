# MIC_RB_SRcollect SuperResolution data collection software.
Super resolution data collection class for RB microscope
Works with Matlab Instrument Control (MIC) classes
usage: SRC=MIC_RB_SRcollect();
REQUIRES:
Matlab 2014b or higher
MIC_Abstract
MIC_LightSource_Abstract
MIC_TCubeLaserDiode
MIC_VortranLaser488
MIC_CrystaLaser561
MIC_CameraAbstract
MIC_HamamatsuCamera
MIC_RebelStarLED
MIC_OptotuneLens
MIC_GalvoAnalog
Marjolein Meddens, Lidke Lab 2017
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
# GUI SRcollect Gui for RB microscope
Detailed explanation goes here
# GUIPSF Gui for PSF engineering and acquisition for MIC_SR_CollectRB class
Detailed explanation goes here
Prevent opening more than one figure for same instrument
