# WARNING: This is a prototype class and is not ready for use.
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
# Checks to see if an ASCII answer block is a valid response from the Cavro
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
# Connects to a Cavro syringe pump and returns messages from the device.
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
MATLAB R2017a or later recommended for this method.
CITATION: David Schodt, Lidke Lab, 2018
Ensure that no COM object exists for the user specified port.
# Decodes a StatusByte as returned by the Cavro syringe pump.
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
# Sends a command given by Command to the Cavro syringe pump.
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
# Sends a command given by Command to the Cavro syringe pump.
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
# Graphical user interface for MIC_CavroSyringePump.
{
# Queries an initialized Cavro syringe pump and returns the received message
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
CITATION: David Schodt, Lidke Lab, 2018
Query the syringe pump and read the response, repeating until a valid
query response is received (a valid Answer Block in response to a query
has exactly 6 bytes, i.e. no Data Block is returned for a query request)
or the timeout has been exceeded.
# Performs a serial read on obj.Port in search of message from the syringe
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
# Queries the syringe pump with a report command and returns the
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
# WARNING!!! This unitTest should only be run in two scenarios:
1) The syringe has been removed from the syringe pump.
2) The In, BP, and Out ports of the syringe pump are fed to/from fluid
reservoirs containing test fluid, e.g. the ports are fed to/from
reservoirs of water.
Perform a unit test for the CavroSyringePump class.  If the unit test
completes without any errors, the unit test was a success.
INPUTS:
SerialPort: (optional) String specifying the serial port to which a
Cavro syringe pump is connected, e.g. SerialPort = 'COM3'
is the default setting.
CITATION: David Schodt, Lidke Lab, 2018
Create a syringe pump object.
# Updates the MIC_CavroSyringePump GUI.
This method will update the GUI for the MIC_CavroSyringePump class
based on the current status of the syringe pump.
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.
CITATION: David Schodt, Lidke Lab, 2018
Check to see if a GUI exists.
