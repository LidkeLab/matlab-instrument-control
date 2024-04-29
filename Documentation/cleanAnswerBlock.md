
Checks to see if an ASCII answer block is a valid response from the Cavro
syringe pump and cleans up the message if needed.
INPUTS:
RawASCIIMessage: A numeric array of integers 0-255 corresponding to
8-bit ASCII codes read from the serial port.

OUTPUTS:
ASCIIMessage: A numeric array with each element being an 8-bit ASCII
code (0-255) in the correct Answer Block order as
specified in the Cavro XP 3000 syringe pump manual on
page 3-8.
IsValid: 1 if the cleaned up ASCIIMessage is determined to be a valid
answer block returned from a Cavro syringe pump, 0 otherwise.


Define the default outputs in case this function returns to the invoking
function before completion.
