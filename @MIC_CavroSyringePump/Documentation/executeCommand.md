
Sends a command given by Command to the Cavro syringe pump.
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
Command: A string of command(s) as summarized in the Cavro
XP 3000 syringe pump manual page G-1 or described
in detail starting on page 3-21, e.g.
Command = '/1A3000R' or Command = 'A3000'

NOTE: This method should NOT be used for report/control commands: those
commands have their own methods.

CITATION: David Schodt, Lidke Lab, 2018


Add start/end characters if needed.
