
blazeScanIntensity Calculates expected intensity during blaze scan

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
