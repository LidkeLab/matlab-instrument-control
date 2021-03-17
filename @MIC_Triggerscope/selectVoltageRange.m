function [VoltageRangeIndex] = selectVoltageRange(obj, Signal)
%selectVoltageRange determines the best voltage range for the given Signal
% This method will look at the voltage range of an analog signal 'Signal'
% and determine the smallest voltage range encompassing that signal range.
% The range options are selected from the options given in
% obj.VoltageRangeOptions.
%
% INPUTS:
%   Signal: An array whose elements represent voltages to be set on a DAC
%           port of the Triggerscope.
%           (numeric array, Nx1 or 1xN)(Units = volts)
%
% OUTPUTS:
%   VoltageRangeIndex: Index of obj.VoltageRangeOptions (or of
%                      obj.VoltageRangeChar) specifying the voltage range
%                      selected for the input 'Signal'.
%                      (scalar integer)

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Determine the min. and max. voltages present in 'Signal'.
MinVoltage = min(Signal);
MaxVoltage = max(Signal);

% Determine the max. - min. values of the available voltage ranges.
MinOfRange = min(obj.VoltageRangeOptions, [], 2);
MaxOfRange = max(obj.VoltageRangeOptions, [], 2);
RangeExtent = MaxOfRange - MinOfRange;

% Determine which voltage range options are compatible with the signal.
IsCompatible = ((MinOfRange<=MinVoltage) & (MaxOfRange>=MaxVoltage));

% Select the voltage range to be the compatible range with the smallest
% extent.
% NOTE: This seems sloppy, but this is the best way I've come up with to do
%       this so far!
RangeOptions = RangeExtent .* IsCompatible;
RangeOptions(RangeOptions == 0) = inf;
[~, VoltageRangeIndex] = min(RangeOptions);


end