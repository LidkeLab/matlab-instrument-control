# MIC_MPBLaser Matlab Instrument Control Class for the MPB-laser.
This class controls the PMB-laser.
The constructor do not need any info about the port, it will
automatically find the available port to communicate with the
laser.
Because it is trying to find the port to communicate with the
instrument it will send messages to different ports and if the port
is not giving any feedback, which means that it's not the port that
we are looking for, it will give a timeout warning which can be
neglected.
REQUIRES:
MIC_Abstract.m
MIC_LightSource_Abstract.m
MATLAB 2014 or higher
Install the software coming with the laser.
