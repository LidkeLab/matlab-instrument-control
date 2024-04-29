
Sends a command given by Command to the Cavro syringe pump.
This function will take some input Command, inspects the command to
determine whether it should be sent via obj.executeCommand or
obj.reportCommand (determined based on whether or not the command expects
a response from the syringe pump), and finally passes execution to one of
those two functions.
NOTE: This method is designed only to take single commands, i.e. Command
should only contain one syringe pump command to be executed.

INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
Command: A single command string as summarized in the Cavro XP 3000
syringe pump operators manual page G-1 or described in detail
starting on page 3-21, e.g. Command = '/1A3000R'.

OUTPUTS:
Datablock: A human readable version of the data block byte(s) returned
by the Cavro syringe pump (see page 3-8 in the Cavro XP 3000
syringe pump manual), given as a character array for
debugging purposes.

CITATION: David Schodt, Lidke Lab, 2018


Determine the first command character in the Command string (if multiple
commands were entered in one string, the behavior from here onward will
continue based on the first command in the string).
