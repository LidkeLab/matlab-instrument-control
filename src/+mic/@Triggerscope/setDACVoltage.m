function setDACVoltage(obj, DACIndex, Voltage)
%setDACVoltage sets the specified DAC to the desired voltage.
% This method will set DAC port number 'DACIndex' to the voltage specified
% by 'Voltage'.
%
% EXAMPLE USAGE:
%   If 'TS' is a working instance of the mic.Triggerscope class (i.e., the
%   Triggerscope has already been connected successfully), you can use this
%   method to set DAC port 7 to 1.3 Volts as follows:
%       TS.setDACVoltage(7, 1.3)
%
% INPUTS:
%   DACIndex: The DAC port number you wish to change the voltage of.
%             (integer in range [1, obj.IOChannels])
%   Voltage: The voltage you wish to set DAC port number DACIndex to.
%            NOTE: If the voltage you set is outside of the current set
%                  range of DAC port number DACIndex, this method will
%                  issue an error.
%            (float in range defined by obj.VoltageRangeOptions(...
%            obj.DACStatus(DACIndex).VoltageRangeIndex, :))

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Validate the inputs.
assert((DACIndex>=1) && (DACIndex<=obj.IOChannels), ...
    sprintf(['DAC port %i does not exist: ''DACIndex'' ', ...
    'must be in the range [1, obj.IOChannels]'], DACIndex))
VoltageRange = obj.VoltageRangeOptions(...
    obj.DACStatus(DACIndex).VoltageRangeIndex, :);
assert((Voltage>=VoltageRange(1)) && (Voltage<=VoltageRange(2)), ...
    sprintf(['Input Voltage = %g out of current range: DAC port %i ', ...
    'range currently set to [%i, %i]'], Voltage, DACIndex, VoltageRange))

% Convert the input voltage to the appropriate bit level.
[BitLevel] = obj.convertVoltageToBitLevel(Voltage, VoltageRange, ...
    obj.DACResolution);

% Set the desired DAC port to the output given by 'BitLevel'.
obj.executeCommand(sprintf('DAC%i,%i', DACIndex, BitLevel));


end
