function [ASCIIMessage, DataBlock] = readAnswerBlock(obj)
%Performs a serial read on obj.Port in search of message from the syringe
%pump.
% 
% INPUTS: 
%   obj: An instance of the CavroSyringePump class.
% 
% OUTPUTS:
%   ASCIIMessage: numeric array of integers 0-255 corresponding to 8-bit
%                 ASCII codes. 
%   DataBlock: A human readable version of the data block byte(s) returned 
%              by the Cavro syringe pump (see page 3-8 in the Cavro XP 3000 
%              syringe pump manual), given as a character array for 
%              debugging purposes. 


% Serial read at the port with which the SyringePump serial object is
% associated.
warning('off', 'MATLAB:serial:fread:unsuccessfulRead') % suppress warnings
RawASCIIMessage = fread(obj.SyringePump);
[ASCIIMessage, IsValid] = obj.cleanAnswerBlock(RawASCIIMessage);
warning('on', 'MATLAB:serial:fread:unsuccessfulRead') 

% If a valid message was received, retrieve the DataBlock.  If the message
% was not deemed valid, DataBlock is returned as an empty character array.
if IsValid
    DataBlock = ASCIIMessage(4:end-3); 
    DataBlock = char(DataBlock).'; % conversion from decimal to ASCII
else
    DataBlock = ''; 
end
    
    
end