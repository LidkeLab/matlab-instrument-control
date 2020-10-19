function [Response] = executeCommand(obj, Command)
%executeCommand executes the input Command on obj.Triggerscope.
% This method will take the command given by Command and attempt to execute
% it on the serial port object obj.Triggerscope. The intention is that this
% method will do some checks on Command before sending to obj.Triggerscope,
% e.g., ensuring it's a valid command.
%
% INPUTS:
%   Command: An ASCII command to be send to the Triggerscope.
%            (char array, string)
%
% OUTPUTS:
%   Response: An ASCII response to Command sent by the Triggerscope.
%             (string)

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Ensure the input Command is present in obj.CommandList (even if Command
% has additional pre/suffixes, e.g., 'TTL1,1' would be considered valid
% since 'TTL' is present in obj.CommandList).
assert(any(contains(Command, obj.CommandList)), ...
    sprintf('Command ''%s'' not listed in obj.CommandList. ', Command));

% Execute the command and check for a response.
obj.ActivityMessage = sprintf('Writing command ''%s'' ', ...
    'to Triggerscope on serial port ''%s''', Command, obj.SerialPort);
obj.writeCommand(Command);
obj.ActivityMessage = sprintf('Reading response to command ''%s'' ', ...
    'from Triggerscope on serial port ''%s''', Command, obj.SerialPort);
[Response] = obj.readResponse();
obj.ActivityMessage = Response;


end