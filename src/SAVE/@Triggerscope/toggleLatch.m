function [OutputSignal] = toggleLatch(ToggleSignal, InPhase)
%toggleLatch simulates a toggle latch circuit.
% This method simulates a toggle latch, meaning that any "hot" (true) value
% of ToggleSignal will toggle the value of OutputSignal.
%
% INPUTS:
%   ToggleSignal: A signal consisting of 0's and 1's, where the 1's
%                 direct a state change in OutputSignal.
%   InPhase: Boolean indicating whether or not the output is "in
%            phase" (maybe an abuse of terminology here) with the
%            input trigger, i.e., OutputSignal(1) = double(InPhase)
%
% OUTPUTS:
%   OutputSignal: Square wave of 0's and 1's with period
%                 SignalPeriod and length matching TriggerSignal.


% Simulate the toggle latch to produce our output signal.
NPoints = numel(ToggleSignal);
OutputSignal = zeros(1, NPoints);
OutputSignal(1) = double(InPhase);
for ii = 2:NPoints
    OutputSignal(ii) = ToggleSignal(ii)*~OutputSignal(ii-1) ...
        + ~ToggleSignal(ii)*OutputSignal(ii-1);
end
if (size(ToggleSignal, 1) > size(ToggleSignal, 2))
    OutputSignal = OutputSignal.';
end


end