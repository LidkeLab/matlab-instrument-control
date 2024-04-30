
MIC_LightSource_Abstract: Matlab Instrument Abstact Class for all
light source Matlab Instrument Class

This class defines a set of abstract properties and methods that must
implemented in inheritting classes for all light source devices.
This also provides a simple and intuitive GUI interface.

The constructor in each subclass must begin with the following line
inorder to enable the auto-naming functionality:
obj=obj@MIC_LightSource_Abstract(~nargout);

REQUIREMENTS:
MIC_Abstract.m
MATLAB software version R2016b or later

CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
