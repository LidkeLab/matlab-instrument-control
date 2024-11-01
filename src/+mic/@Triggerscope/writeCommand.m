function [] = writeCommand(obj, Command)
%writeCommand writes an ASCII command to the Triggerscope.
% This method will send the ASCII command given by Command to the
% Triggerscope. This is done using the MATLAB method writeline().
%
% INPUTS:
%   Command: Properly formatted ASCII command to be send to the
%            Triggerscope directly. (char array, string)

% Created by: 
%   David J. Schodt (Lidke Lab, 2020)


% Send the command to the Triggerscope.
writeline(obj.TriggerscopeSerialPortDev, Command);


end

