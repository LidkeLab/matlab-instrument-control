
executeArrayProgram sends a list of commands to the Triggerscope.
This method will loop through a set of commands in 'CommandSequence' and
attempt to execute them sequentially.  The primary intention is that
'CommandSequence' will be a cell array of commands generated by the
method obj.generateArrayProgram().

INPUTS:
CommandSequence: A list of commands to be sent to the Triggerscope to
produce the behavior defined by the signals in
obj.SignalArray. (cell array of char array)
FastMode: If used, commands are sent as fast as possible to the
Triggerscope, without pausing or waiting for a response.
(Default = false)

OUTPUTS:
Response: A cell array of char arrays, with each element corresponding
to the Triggerscope's response to a command in
CommandSequence (i.e., Response{ii} is the response from
CommandSequence{ii}). (cell array)

Created by:
David J. Schodt (Lidke Lab, 2021)


Set defaults if needed.