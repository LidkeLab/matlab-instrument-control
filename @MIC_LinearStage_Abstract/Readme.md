# # MIC_LinearStage_Abstract: Matlab Instrument Control abstract class for linear stages.
## Description
This class defines a set of Abstract properties and methods that must
implemented in inheritting classes. This class also provides a simple
and intuitive GUI.
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
## Core Methods
- **Constructor (`MIC_LinearStage_Abstract(AutoName)`):** Initializes a new instance of a subclass, incorporating auto-naming functionality inherited from `MIC_Abstract`.
- **`center()`:** Moves the stage to its center position, calculated as the midpoint between `MinPosition` and `MaxPosition`.
- **`updateGui()`:** Refreshes the GUI elements to reflect current properties like position, ensuring the display is up-to-date with the stage's status.
Citation: Marjolein Meddens, Lidke Lab, 2017.
# gui: Graphical User Interface to MIC_LinearStage_Abstract
Functionality:
Move the stage by moving the slider or clicking the jog buttons
Outside jog buttons (C) are for coarse steps
Inside jog buttons (F) are for fine steps
Fine and Coarse step sizes can be specified
Mouse scroll wheel will move stage when mouse is over slider
Mouse wheel action can be set to Fine or Coarse with toggle button
Position to which stage should move can be set in edit box
Note: Updating gui from higher level class
To update gui from higher level class the uicontrol objects can be
accessed via obj.GuiFigure.Children
To identify the children which need updating they are given tags:
Slider has tag "positionSlider"
Set position edit box has tag "positionEdit"
For example see MIC_Example_LinearStage
Marjolein Meddens, Lidke Lab 2017
Prevent opening more than one figure for same instrument
