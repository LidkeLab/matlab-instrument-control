
MIC_LinearStage_Abstract: Matlab Instrument Control abstract class
for linear stages.

This class defines a set of Abstract properties and methods that must
implemented in inheritting classes. This class also provides a simple
and intuitive GUI.
The constructor in each subclass must begin with the following line
inorder to enable the auto-naming functionality:
obj=obj@MIC_LinearStage_Abstract(~nargout);

REQUIRES:
MIC_Abstract.m
MATLAB 2014b or higher

Marjolein Meddens, Lidke Lab, 2017.
