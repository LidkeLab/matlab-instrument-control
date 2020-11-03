function [ArrayProgram] = generateArrayProgram(SignalArray)
%generateArrayProgram generates a program based on SignalArray.
% This method will generate a cell array of char arrays, with each element
% being one line of an array program to be sent to the Triggerscope.  The
% intention is that this method will convert the user defined SignalArray
% into a program that can be sent (line-by-line) to the Triggerscope, which
% will produce the desired behavior defined by the SignalArray.
%
% INPUTS:
%   SignalArray: A numeric array containing the signals to be produced when
%                triggered. This array is formatted to be 2*obj.IOChannels
%                rows by max. signal length columns, with each row 
%                corresponding to a TTL/DAC port (1-16 are TTL ports 1-16, 
%                17-32 are DAC ports 1-16). Each column represents the
%                logic value/voltage of a TTL/DAC port at each trigger
%                event. 
%   
% OUTPUTS:
%   ArrayProgram: A list of commands to be sent to the Triggerscope to
%                 produce the behavior defined by the signals in
%                 SignalArray.
%                 (cell array of char array)
end