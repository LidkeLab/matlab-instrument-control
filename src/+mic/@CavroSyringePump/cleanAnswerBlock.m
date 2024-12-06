function [ASCIIMessage, IsValid] = cleanAnswerBlock(RawASCIIMessage)
%Checks to see if an ASCII answer block is a valid response from the Cavro
%syringe pump and cleans up the message if needed.
% INPUTS: 
%   RawASCIIMessage: A numeric array of integers 0-255 corresponding to 
%                    8-bit ASCII codes read from the serial port.
% 
% OUTPUTS:
%   ASCIIMessage: A numeric array with each element being an 8-bit ASCII
%                 code (0-255) in the correct Answer Block order as
%                 specified in the Cavro XP 3000 syringe pump manual on
%                 page 3-8. 
%   IsValid: 1 if the cleaned up ASCIIMessage is determined to be a valid
%            answer block returned from a Cavro syringe pump, 0 otherwise. 


% Define the default outputs in case this function returns to the invoking
% function before completion.
ASCIIMessage = RawASCIIMessage; 
IsValid = 0; 

% Ensure RawASCIIMessage is non-empty and at least 6 elements long (answer
% blocks from the Cavro syringe pump are at least 6 elements long).
if isempty(RawASCIIMessage) || numel(RawASCIIMessage) < 6
    return % no need to perform the other checks
end
    
% Determine the index within the raw ASCII message array that might
% correspond to the start of a message.
% NOTES: 
%        1. The Start Answer byte of the message block is ASCII for 
%           '/', or decimal 47.
%        2. The first instance of a Start Answer byte should be chosen
%           because this gives us the best chance of picking out a 
%           complete message. 
StartAnswerIndex = find(RawASCIIMessage == 47, 1);
if isempty(StartAnswerIndex)
    return % no need to perform the other checks
end

% Shift the raw ASCII message such that the Start Answer byte is the
% first element of the array. NOTE: the -1 is to account for Matlab 
% arrays starting at 1 instead of 0. 
NBytesShift = StartAnswerIndex - 1;
RawASCIIMessage = circshift(RawASCIIMessage, -NBytesShift); 

% Search for the end of the message block (ASCII linefeed, decimal 10) 
% and truncate the ASCII message to ignore incomplete/additional 
% transmissions.
EndAnswerIndex = find(RawASCIIMessage == 10, 1); 
if isempty(EndAnswerIndex)
    return % no need to perform the other checks
end
ASCIIMessage = RawASCIIMessage(1:EndAnswerIndex);

% Ensure that the message is complete, i.e. it contains an entire answer
% block as specified on page 3-8 in the Cavro XP 3000 syringe pump manual.
if sum(ASCIIMessage==47) == 1 ...
        && sum(ASCIIMessage==3) == 1 ...
        && sum(ASCIIMessage==13) == 1 ...
        && sum(ASCIIMessage==10) == 1
    % If only one of each of the answer block characters were found, assume 
    % a valid and complete message was received.
    IsValid = 1; 
end


end