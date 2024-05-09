# WARNING: This is a prototype class and is not ready for use.
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
# Sends a signal to the Arduino to close valve ValveNumber on the BIOCHEM
flow selection valve.
INPUTS:
obj: An instance of the MIC_BiochemValve class.
ValveNumber: The number specifying which valve on the BIOCHEM flow
selection valve to close.
NOTE: this may be mapped to the relay block on the relay
module for easy verification (by viewing the wiring path).
CITATION: David Schodt, Lidke Lab, 2018
Map ValveNumber to the appropriate digital I/O pin on the Arduino.
# Graphical user interface for MIC_BiochemValve.
{
# Sends a signal to the Arduino to open valve ValveNumber on the BIOCHEM
flow selection valve.
INPUTS:
obj: An instance of the MIC_BiochemValve class.
ValveNumber: The number specifying which valve on the BIOCHEM flow
selection valve to open.
NOTE: this may be mapped to the relay block on the relay
module for easy verification (by viewing the wiring path).
CITATION: David Schodt, Lidke Lab, 2018
Map ValveNumber to the appropriate digital I/O pin on the Arduino.
