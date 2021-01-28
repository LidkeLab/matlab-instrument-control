function [] = executeArrayProgram(obj, CommandSequence)
%executeArrayProgram sends a list of commands to the Triggerscope.
% This method will loop through a set of commands in 'CommandSequence' and
% attempt to execute them sequentially.  The primary intention is that
% 'CommandSequence' will be a cell array of commands generated by the
% method obj.generateArrayProgram().
%
% INPUTS:
%   CommandSequence: A list of commands to be sent to the Triggerscope to
%                    produce the behavior defined by the signals in
%                    obj.SignalArray. (cell array of char array)

% Created by:
%   David J. Schodt (Lidke Lab, 2021)


% Loop through all commands and execute them.
for cc = 1:numel(CommandSequence)
    obj.executeCommand(obj, CommandSequence{cc});
end


end