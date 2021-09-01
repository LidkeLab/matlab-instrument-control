function setDefaults(obj)
%setDefaults sets some default properties on a connected Triggerscope.
% This method will send several commands to the connected Triggerscope in
% an attempt to set a "default" state (e.g., setting all DAC ranges to the
% default used in obj.setDACRange()).

% Created by:
%   David J. Schodt (Lidke Lab, 2021)


% If a Triggerscope isn't connected, there's nothing to do.
if ~obj.IsConnected
    warning('No Triggerscope has been connected!')
    return
end

% Loop through all DAC ports, set the default range, and force them to 0V.
for ii = 1:obj.IOChannels
    % NOTE: Due to a "bug"(?) on Triggerscope3B, we need to set the DAC
    %       range twice on the first pass.
    obj.setDACRange(ii);
    obj.setDACRange(ii);
    obj.setDACVoltage(ii, 0);
end

% Update obj.ActivityMessage.
obj.ActivityMessage = '';


end