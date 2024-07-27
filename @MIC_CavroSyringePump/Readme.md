# MIC_CavroSyringePump Class

## Description
The `MIC_CavroSyringePump` class controls a Cavro syringe pump via USB, specifically designed for
pump PN 20740556 -D. This class may work with other Cavro brand syringe pumps but has only been tested with the
specified model. It can perform any operation described in the Cavro XP3000 operators manual (e.g. in Appendix G - Command Quick Reference).

## Installation Requirements
- MATLAB R2014b or later (R2017a or later recommended)
- Operating System: Windows (modifications required for UNIX systems, particularly in serial port behaviors)
- Dependency: `MIC_Abstract.m`

##  Functions:
delete, exportState, updateGui, gui, connectSyringePump,
readAnswerBlock, executeCommand, reportCommand,
querySyringePump, cleanAnswerBlock, decodeStatusByte, unitTest

## Usage
```matlab
Create an instance of the Cavro syringe pump controller
Pump = MIC_CavroSyringePump();
Connect to the pump
[Message, Status] = Pump.connectSyringePump();
Execute a command to move the plunger
Pump.executeCommand('Move Plunger to 1000');
Check the pump's status
Pump.querySyringePump();
Disconnect and cleanup
delete(Pump);
```
### CITATION: David Schodt, Lidke Lab, 2018

