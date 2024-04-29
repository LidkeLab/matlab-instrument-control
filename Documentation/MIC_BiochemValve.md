
WARNING: This is a prototype class and is not ready for use.
Class used for control of the BIOCHEM flow selection valves.

This class controls (indirectly) the BIOCHEM flow selection valves
via communication with an Arduino.  It can open and close specific
valves as well as cut power to both the valves and the syringe pump
(this functionality is given here as an emergency shutoff, the
shutting down of the syringe pump is just a side effect of the
emergency shutdown to the valves).

Example: Valves = MIC_BiochemValve();
Functions: delete, exportState, gui, powerSwitch12V, powerSwitch24V,
openValve, closeValve, unitTest

REQUIREMENTS:
MATLAB R2014b or later.
MATLAB Support Package for Arduino Hardware installed
NOTE: You may need to setup the Arduino you are using
specifically even if this package was installed previously.
Matlab needs to upload software onto the Arduino before
creation of an instance of this class.
MIC_Abstract.m

CITATION: David Schodt, Lidke Lab, 2018
