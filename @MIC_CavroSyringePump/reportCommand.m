function [DataBlock] = reportCommand(obj, Command)
%Queries the syringe pump with a report command and returns the
%decoded DataBlock. 
% INPUTS: 
%   obj: An instance of the MIC_CavroSyringePump class.
%   Command: A string containing a Cavro Report Command from
%            the table on page G-3 of the Cavro XP 3000 syringe 
%            pump manual, e.g. Command = '/1?' or 
%            Command = '?'
% OUTPUTS:
%   DataBlock: A human readable version of the data block byte(s) returned 
%              by the Cavro syringe pump (see page 3-8 in the Cavro XP 3000 
%              syringe pump manual), given as a character array for 
%              debugging purposes.
% NOTE: This method should only be used for report commands. 
%
% CITATION: David Schodt, Lidke Lab, 2018


% Add start characters if needed. 
if strcmp(Command(1), '/') ...
        && strcmp(Command(2), num2str(obj.DeviceAddress)) ...
    % Command is formatted correctly, do nothing. 
else
    % Add the start character, device number, and execute
    % character. 
    Command = ['/', num2str(obj.DeviceAddress), Command]; 
end

% Send the command to the syringe pump. 
fprintf(obj.SyringePump, Command);

% Catch the message returned by the Cavro syringe pump, repeating until a
% valid response is returned or the timeout is reached. 
DataBlock = '';
tic % start a timer
while toc < obj.DeviceResponseTimeout   
    % Read the response from the syringe pump.
    [~, DataBlock] = obj.readAnswerBlock(); 
    
    % If a non-empty data block was returned, break out of the loop.
    if ~isempty(DataBlock)
        break
    end
end

% Throw an error if a data block was not returned within
% obj.DeviceResponseTimeout .
if isempty(DataBlock)
    error('Valid response not returned within DeviceResponseTimeout = %g s \n', ... 
        obj.DeviceResponseTimeout)
end


end