function [ToggleSignal] = generateToggleSignal(TriggerSignal, ...
    SignalPeriod, TriggerModeInt)
%generateToggleSignal generates a toggling signal array.
% This method generates a toggle signal, which is a signal whose "hot"
% (true) values indicate a toggle.  A toggle event occurs when a trigger
% event occurs at the same time that an odd square wave with period
% SignalPeriod toggles from 0 to 1.  For example, if 
% TriggerSignal = [1, 0, 1, 0, 1, 0, 1], SignalPeriod = 4, and the trigger
% is a rising edge (TriggerModeInt = 1), then 
% ToggleSignal = [1, 0, 0, 0, 1, 0, 0] (note that I treat the first 1 as a
% rising edge since doing so makes sense as far as hardware is concerned).
%
% INPUTS:
%   TriggerSignal: Triggering signal which must be formatted s.t.
%                  each element alternates (e.g., [1, 0, 1, 0], or
%                  [0, 1, 0, 1, 0, 1, 0]).
%   SignalPeriod: "Period" of the output signal with respect to the
%                 triggering events. For example, SignalPeriod = 2
%                 means that every triggering event toggles
%                 OutputSignal, whereas SignalPeriod = 4 means
%                 every other triggering event toggles
%                 OutputSignal.
%   TriggerModeInt: Integer specifying the triggering mode.
%                   1: Rising edge
%                   2: Falling edge
%                   3: Change
%
% OUTPUTS:
%   ToggleSignal: A binary signal with entries of 1 indicating a
%                 trigger event happened at the same time as an odd
%                 square wave with period SignalPeriod would have
%                 toggled from 0 to 1, and with all other entries
%                 set to 0.

% Define the toggle signal from the input TriggerSignal. This
% will be an array with a 1 at each point the output signal should
% be toggled, and a 0 at the rest of the points.
NPoints = numel(TriggerSignal);
XArray = (1:NPoints);
if (size(TriggerSignal, 1) > size(TriggerSignal, 2))
    XArray = XArray.';
end
EventNumber = floor(XArray / 2);
if (TriggerModeInt == 1)
    % For rising edge triggers, we want to ensure that the trigger
    % is indeed HIGH, and that it is HIGH in a manner consistent
    % with the expected trigger (in this case, every other element,
    % thus the mod(XArray, 2) terms).
    IsEvent = TriggerSignal ...
        .* (TriggerSignal(1)*mod(XArray, 2) ...
        + ~(TriggerSignal(1)+mod(XArray, 2)));
elseif (TriggerModeInt == 2)
    % For falling edge triggers, we want to ensure that the trigger
    % is indeed LOW, and that it is LOW in a manner consistent
    % with the expected trigger (in this case, every other element,
    % thus the mod(XArray, 2) terms).
    IsEvent = ~TriggerSignal ...
        .* (~TriggerSignal(1)*mod(XArray, 2) ...
        + TriggerSignal(1)*~mod(XArray, 2));
elseif (TriggerModeInt == 3)
    % For change type triggers, any change from HIGH->LOW,
    % LOW->HIGH counts, no matter where it appears in the array,
    % with the first element always assumed to be a change.
    IsEvent = [1, logical(diff(TriggerSignal))];
end
ToggleSignal = (IsEvent ...
    & ~mod(EventNumber, round(SignalPeriod/2)));


end