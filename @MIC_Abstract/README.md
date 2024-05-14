# MIC_Abstract Matlab Instrumentation Control Abstract Class
## Description
This abstract class defines a set of properties and methods that must
be implemented in all inheritting classes.  It also provides:
1: A convienient auto-naming feature that will assign the object to a
variable name based on the InstrumentName property.
2: A method to save Attributes and Data to an HDF5 file.
## Constructor
The constructor inheritting class requires
'obj = obj@MIC_Abstract(~nargout)'
as the first line in the constructor.
## Note
All MATLAB classes for instrument control must inherit from this
class.
## REQUIRES:
MATLAB 2014b or higher.
### Citations: Lidkelab, 2015.
