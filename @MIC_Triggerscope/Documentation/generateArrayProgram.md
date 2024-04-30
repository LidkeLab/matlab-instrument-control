
generateArrayProgram generates a program based on obj.SignalArray.
This method will generate a cell array of char arrays, with each element
being one line of an array program to be sent to the Triggerscope.  The
intention is that this method will convert the user defined SignalArray
into a program that can be sent (line-by-line) to the Triggerscope, which
will produce the desired behavior defined by the SignalArray.

NOTE: CommandSequence won't reflect the zero signals.  The Triggerscope
drives each port to 0 volts at each trigger by default.

INPUTS:
NLoops: Number of times to repeat the signals in SignalArray.
(scalar integer)(Default = 1)
Arm: Boolean to indicate whether or not an ARM command should be
attached to the end of the program.  The ARM command will cause
the program to execute immediately if the trigger signal is
already active. (boolean)(Default = true)

OUTPUTS:
CommandSequence: A list of commands to be sent to the Triggerscope to
produce the behavior defined by the signals in
SignalArray.
(cell array of char array)

Created by:
David J. Schodt (Lidke Lab, 2020)


Define default parameters if needed.
