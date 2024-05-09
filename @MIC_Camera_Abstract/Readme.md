# MIC_Camera_Abstract Matlab Instrument Control Camera Class
The class gives a common interface for all cameras.
These are not abstract so we can give set functions
# GUI  gui for Camera class
EXAMPLES:
CamObj = guiTest; create empty test gui object
camObj.gui; initialize gui
See also CameraClass, guiTest
Created by Peter Relich (November 2013)
main GUI figure
# Display sub gui for Camera class
Dshould be called from the display button in the gui
main camera param gui figure
# general version, knows nothing about camera specifics
requires obj.GuiDialog structure to generate options
certain properties can trigger regeneration of options by calling
obj.build_Guidialog via a callback
main camera param gui figure
