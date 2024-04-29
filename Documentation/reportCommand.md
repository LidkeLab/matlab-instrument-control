
Queries the syringe pump with a report command and returns the
decoded DataBlock.
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
Command: A string containing a Cavro Report Command from
the table on page G-3 of the Cavro XP 3000 syringe
pump manual, e.g. Command = '/1?' or
Command = '?'
OUTPUTS:
DataBlock: A human readable version of the data block byte(s) returned
by the Cavro syringe pump (see page 3-8 in the Cavro XP 3000
syringe pump manual), given as a character array for
debugging purposes.
NOTE: This method should only be used for report commands.

CITATION: David Schodt, Lidke Lab, 2018


Add start characters if needed.
