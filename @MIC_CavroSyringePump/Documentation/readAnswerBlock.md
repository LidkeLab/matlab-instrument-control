
Performs a serial read on obj.Port in search of message from the syringe
pump.

INPUTS:
obj: An instance of the CavroSyringePump class.

OUTPUTS:
ASCIIMessage: numeric array of integers 0-255 corresponding to 8-bit
ASCII codes.
DataBlock: A human readable version of the data block byte(s) returned
by the Cavro syringe pump (see page 3-8 in the Cavro XP 3000
syringe pump manual), given as a character array for
debugging purposes.


Serial read at the port with which the SyringePump serial object is
associated.
