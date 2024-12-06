function [BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution)
%convertVoltageToBitLevel converts a voltage to a bit level.
% This method converts a voltage to the appropriate bit level defined by 
% Range and Resolution.
%
% EXAMPLE USAGE:
%   Voltage = 2.3; % volts
%   Range = [0, 5]; % 0-5 volts
%   Resolution = 16; % 16 bit resolution
%   [BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution);
%   BitLevel is calculated as 
%       BitLevel = round(((2^Resolution-1) / abs(diff(Range))) * Voltage)
%       -> BitLevel = 30146
%
% INPUTS:
%   Voltage: Voltage that is to be converted to a bit level.
%            (numeric array, values must be in Range)
%   Range: Range of voltages spanned by the bits defined by Resolution.
%          (2x1 array, inclusive bounds)
%   Resolution: Number of bits used to span the range defined by Range.
%               (scalar integer >= 1)
%
% OUTPUTS:
%   BitLevel: BitLevel associated with the input Voltage in Range spanned
%             by Resolution. (scalar integer >= 0)

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Validate inputs arguments.
assert(all((Voltage>=min(Range)) & (Voltage<=max(Range))), ...
    'Input ''Voltage'' must be in the range defined by input ''Range''')
assert(Resolution >= 1, ...
    'Input ''Resolution'' must be a non-negative integer')

% Rescale the voltage based on the given Range.
Voltage = Voltage - min(Range);

% Compute the BitLevel.
BitLevel = round(((2^Resolution-1) / abs(diff(Range))) * Voltage);


end