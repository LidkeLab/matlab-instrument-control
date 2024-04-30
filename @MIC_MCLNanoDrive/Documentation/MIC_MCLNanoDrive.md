
MIC_MCLNanoDrive controls the Mad City Labs 3D Piezo Stage

This class controls a 3D Peizo stage from Mad City Labs.  The class
uses 'calllib' to directly call funtions from the madlib.dll. The instument
is attached via USB.

The first time an object of this class is created, the user must
direct the object to the 'madlib.h' header file.  This is usually
located here:  C:\Program Files\Mad City Labs\NanoDrive

REQUIRES:
MATLAB 2014b or higher
MCL Drivers installed on system.

Update:Hanieh Mazloom-Farsibaf, Lidke Lab 2018
