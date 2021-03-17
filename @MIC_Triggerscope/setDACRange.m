function setDACRange(obj, DACIndex, VoltageRange)
%setDACRange sets the specified DAC port to the desired voltage range.
% This method will set DAC port number 'DACIndex' to the voltage range
% specified by 'VoltageRange'.
%
% INPUTS:
%   DACIndex: The DAC port number you wish to change the voltage of.
%             (integer in range [1, obj.IOChannels])
%   VoltageRange: The desired voltage range to be set for DAC port
%                 DACIndex.
%                 (1x2 numeric array which is one of the rows of 
%                 obj.VoltageRangeOptions, or scalar defining the index
%                 of the row in obj.VoltageRangeOptions)(Default = [0, 5])

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Validate the inputs/convert VoltageRange to the format needed for sending
% to the Triggerscope.
assert((DACIndex>=1) && (DACIndex<=obj.IOChannels), ...
    sprintf(['DAC port %i does not exist: ''DACIndex'' ', ...
    'must be in the range [1, obj.IOChannels]'], DACIndex))
if isscalar(VoltageRange)
    VoltageRangeIndex = VoltageRange;
    assert((VoltageRangeIndex>=1) ...
        && (VoltageRangeIndex<=size(obj.VoltageRangeOptions, 1)), ...
        sprintf(['If input ''VoltageRange'' is given as a scalar, ', ...
        'it must be between 1 and ', ...
        'size(obj.VoltageRangeOptions, 1) = %i'], ...
        size(obj.VoltageRangeOptions, 1)))
else
    VoltageRange = [min(VoltageRange), max(VoltageRange)];
    VoltageRangeIndex = find(...
        all(VoltageRange == obj.VoltageRangeOptions, 2), ...
        1);
    assert(~isempty(VoltageRangeIndex), ...
    sprintf(['Input VoltageRange = [%g, %g] not valid: ', ...
        'must be one of the rows in the (Hidden) class property ', ...
        'obj.VoltageRangeOptions'], VoltageRange))
end

% Set the desired voltage range for the specified DAC port.
obj.executeCommand(sprintf('RANGE%i,%i', DACIndex, VoltageRangeIndex));
obj.DACStatus(DACIndex).VoltageRangeIndex = VoltageRangeIndex;


end