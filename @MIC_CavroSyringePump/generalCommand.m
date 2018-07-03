function generalCommand(obj, Command)
%Sends a command given by Command to the Cavro syringe pump.
% This function will take some input Command, inspects the command to
% determine whether it should be sent via obj.executeCommand or
% obj.reportCommand (determined based on whether or not the command expects
% a response from the syringe pump), and finally passes execution to one of 
% those two functions.
% NOTE: This method is designed only to take single commands, i.e. Command 
%       should only contain one syringe pump command to be executed.
%
% INPUTS: 
%   obj: An instance of the MIC_CavroSyringePump class.
%   Command: A single command string as summarized in the Cavro XP 3000 
%            syringe pump operators manual page G-1 or described in detail 
%            starting on page 3-21, e.g. Command = '/1A3000R'.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Determine the first command character in the Command string (if multiple
% commands were entered in one string, the behavior from here onward will
% continue based on the first command in the string).
if strcmp(Command(1), '/')
    % Assume the '/' was meant to be a Start command character
    CommandCharacter = Command(3); % e.g. in '/1A0R' command character is A
else
    % Assume the command was given directly, e.g. 'A0' instead of '/1A0R'. 
    CommandCharacter = Command(1);
end

% Pass Command to obj.executeCommand or obj.reportCommand based on
% CommandCharacter and the Command Quick Reference of Appendix G in the XP
% 3000 syringe pump operators manual.
% NOTE: not all commands are contained here, those not checked are passed
%       through obj.executeCommand and thus may not work as expected.
switch CommandCharacter
    case {'Z', 'Y', 'W', 'A', 'P', 'D', 'I', 'O', 'B', 'E', '^', 'S', ...
            'V', 'v', 'C', 'c', 'L', 'K', 'k', 'N'}
        % These commands don't expect a response, use obj.executeCommand().
        obj.executeCommand(Command);
    case {'Q', '?', 'F', '&', '#'}
        % These commands expect a response, use obj.reportCommand().
        obj.reportCommand(Command);
    otherwise
        % Attempt to send the unknown Command using obj.executeCommand().
        warning('Attempting execution of unrecognized command %s', ...
            Command)
        obj.executeCommand(Command);
end

    
end