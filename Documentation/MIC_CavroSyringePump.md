
WARNING: This is a prototype class and is not ready for use.
MIC class for control of the Cavro syringe pump PN 20740556 -D.

This class is used to control a Cavro syringe pump via USB.  This
class may work for a wide range of Cavro brand syringe pumps, however
it has only been tested for pump PN 20740556 -D .  It can perform any
syringe pump operation described in the Cavro XP3000 operators manual
(e.g. in Appendix G - Command Quick Reference).

Example: Pump = MIC_CavroSyringePump();
Functions: delete, exportState, updateGui, gui, connectSyringePump,
readAnswerBlock, executeCommand, reportCommand,
querySyringePump, cleanAnswerBlock, decodeStatusByte,
unitTest

REQUIREMENTS:
Windows operating system (should work with unix systems with
modifications only to serial port behaviors)
MATLAB 2014b or later required.
MATLAB R2017a or later recommended.
MIC_Abstract.m

CITATION: David Schodt, Lidke Lab, 2018
