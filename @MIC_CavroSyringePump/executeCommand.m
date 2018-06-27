function executeCommand(obj, Command)
%Sends a command given by Command to the Cavro syringe pump.
% INPUTS: 
%   obj: An instance of the MIC_CavroSyringePump class.
%   Command: A string of command(s) as summarized in the Cavro
%            XP 3000 syringe pump manual page G-1 or described 
%            in detail starting on page 3-21, e.g. 
%            Command = '/1A3000R' or Command = 'A3000'
%
% NOTE: This method should NOT be used for report/control commands: those 
% commands have their own methods. 
%
% CITATION: David Schodt, Lidke Lab, 2018


% Add start/end characters if needed. 
if strcmp(Command(1), '/') ...
        && strcmp(Command(2), num2str(obj.DeviceAddress)) ...
        && strcmp(Command(end), 'R')
    % Command is formatted correctly, do nothing. 
else
    % Add the start character, device number, and execute
    % character. 
    Command = ['/', num2str(obj.DeviceAddress), Command, 'R']; 
end

% Send the command to the syringe pump. 
fprintf(obj.SyringePump, Command);

% Do not exit this method until the syringe pump is ready to accept new
% commands (presumably because the current command was executed). 
% NOTE: Once a GUI is implemented, this functionality will likely be 
% shifted to a superclass calling upon this one. 
QueryNumber = 1; 
while (obj.StatusByte < 96) || (QueryNumber == 1)
    % If obj.StatusByte < 96, the syringe pump is busy and we should query
    % the device (which internally updates obj.StatusByte).  The OR
    % condition ensures that at least one query is performed before
    % exiting this method call. 
    obj.querySyringePump; 
    QueryNumber = QueryNumber + 1; 
end
    
    
end