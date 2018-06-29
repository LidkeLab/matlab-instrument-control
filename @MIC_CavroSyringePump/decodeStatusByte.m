function [PumpStatus, ErrorString] = decodeStatusByte(StatusByte)
%Decodes a StatusByte as returned by the Cavro syringe pump.
%
% INPUTS: 
%   StatusByte: A base 10 decimal returned by the Cavro syringe pump.
%
% OUTPUTS: 
%   PumpStatus: 0 if the syringe pump is busy or 1 if the syringe pump is
%               ready to accept new commands. 
%   ErrorString: A human readable string describing an error returned by
%                the syringe pump, based on Table 3-8 on p. 3-46 of the 
%                Cavro XP 3000 operators manual.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Capture the human readable status of the syringe pump.
% NOTE: a decimal StatusByte >= 96 indicates the pump is ready
% to accept commands, see Cavro XP3000 manual p. 3-46
if StatusByte >= 96
    % The syringe pump is ready to accept new commands.
    PumpStatus = 'ready'; 
elseif StatusByte == 0
    % The syringe pump has not been connected yet. 
    PumpStatus = 'Not connected'; 
else
    % The syringe pump is busy.
    PumpStatus = 'busy';
end

% Decode the StatusByte based on Table 3-8 on page 3-46 of the 
% Cavro XP3000 syringe pump manual.
% (see Table 3-7 on page 3-44 of the Cavro XP 3000 syringe pump
% manual for detailed error code descriptions)
switch StatusByte
    case {0, 64, 96}
        % Note that StatusByte==0 means no device is connected.
        ErrorString = 'No error';
    case {65, 97}
        ErrorString = 'Error Code 1: Initialization error'; 
    case {66, 98}
        ErrorString = 'Error Code 2: Invalid Command'; 
    case {67, 99}
        ErrorString = 'Error Code 3: Invalid Operand';
    case {68, 100}
        ErrorString = 'Error Code 4: Invalid Command Sequence';
    case {69, 101}
        ErrorString = 'Error Code 5: Fluid Detection'; 
    case {70, 102}
        ErrorString = 'Error Code 6: EEPROM Failure';
    case {71, 103}
        ErrorString = 'Error Code 7: Device Not Initialized'; 
    case {73, 105}
        ErrorString = 'Error Code 9: Plunger Overload';  
    case {74, 106}
        ErrorString = 'Error Code 10: Valve Overload'; 
    case {75, 107}
        ErrorString = 'Error Code 11: Plunger Move Not Allowed';
    case {79, 111}
        ErrorString = 'Error Code 15: Command Overflow';
    otherwise
        ErrorString = ...
            sprintf('Unknown Error: Status Byte is %i \n', StatusByte);
end
            
            
end