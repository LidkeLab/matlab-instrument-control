# MIC_LinearStage_Abstract: Matlab Instrument Control abstract class for linear stages.

## Description
This class defines a set of Abstract Properties and methods that must
implemented in inheritting classes. This class also provides a simple
and intuitive GUI.

## Constructor
The constructor in each subclass must begin with the following line
inorder to enable the auto-naming functionality:
obj=obj@MIC_LinearStage_Abstract(~nargout);

## REQUIRES:
MIC_Abstract.m
MATLAB 2014b or higher

## Abstract Properties
- **PositionUnit:** Units of the position parameter (e.g., um, mm), specific to the stage's measurement.
- **CurrentPosition:** Current position of the stage.
- **MinPosition:** Minimum limit of the stage's range.
- **MaxPosition:** Maximum limit of the stage's range.
- **Axis:** Indicates the stage axis (X, Y, or Z) that the class controls.

## Methods
- **Constructor (`MIC_LinearStage_Abstract(AutoName)`):** Initializes a new instance of a subclass, incorporating auto-naming functionality inherited from `MIC_Abstract`.
- **`center()`:** Moves the stage to its center position, calculated as the midpoint between `MinPosition` and `MaxPosition`.
- **`updateGui()`:** Refreshes the GUI elements to reflect current Properties like position, ensuring the display is up-to-date with the stage's status.

### Citation: Marjolein Meddens, Lidke Lab, 2017.

