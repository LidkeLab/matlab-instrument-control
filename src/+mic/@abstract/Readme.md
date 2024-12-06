# mic.abstract Matlab Instrumentation Control Abstract Class

## Description
This abstract class defines a set of Properties and methods that must
be implemented in all inheritting classes.  It also provides:
1: A convienient auto-naming feature that will assign the object to a
variable name based on the InstrumentName property.
2: A method to save Attributes and Data to an HDF5 file.

### Public Abstract Properties
- **`InstrumentName`**:
- **Description**: A descriptive name for the instrument. This name must be a valid MATLAB variable name. It provides a clear identification for the instrument within the system.
- **Type**: String (Set as an abstract, protected property, it must be defined by any subclass inheriting from this base class).

### Hidden Abstract Properties
- **`StartGUI`**:
- **Description**: Defines the mode in which the GUI starts. When set to `true`, the GUI is launched upon the creation of the instrument object. This property is abstract, meaning that any subclass must provide its implementation.
- **Type**: Boolean (Hidden property)

## Non-Abstract Hidden Properties

### Hidden Properties
- **`GuiFigure`**:
- **Description**: Contains the GUI Figure object associated with the instrument, if applicable. This allows for GUI management and access within the class structure.
- **Type**: GUI Figure Object (Hidden)

- **`UniqueID`**:
- **Description**: Reserved for future use. Intended for unique identification purposes of instrument instances. This property can be used for distinguishing different instrument objects within a system.
- **Type**: Unique Identifier (Hidden)

## Constructor
The constructor inheritting class requires
'obj = obj@mic.abstract(~nargout)'
as the first line in the constructor.

## Note
All MATLAB classes for instrument control must inherit from this class.

## REQUIRES:
MATLAB 2014b or higher.

### Citations: Lidkelab, 2015.

