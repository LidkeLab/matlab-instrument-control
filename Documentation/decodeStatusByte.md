
Decodes a StatusByte as returned by the Cavro syringe pump.

INPUTS:
StatusByte: A base 10 decimal returned by the Cavro syringe pump.

OUTPUTS:
PumpStatus: 0 if the syringe pump is busy or 1 if the syringe pump is
ready to accept new commands.
ErrorString: A human readable string describing an error returned by
the syringe pump, based on Table 3-8 on p. 3-46 of the
Cavro XP 3000 operators manual.

CITATION: David Schodt, Lidke Lab, 2018


Capture the human readable status of the syringe pump.
NOTE: a decimal StatusByte >= 96 indicates the pump is ready
to accept commands, see Cavro XP3000 manual p. 3-46
