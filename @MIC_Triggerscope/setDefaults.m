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

% Loop through all DAC ports and set the default range.
for ii = 1:obj.IOChannels
    setDACRange(obj, ii);
end

% Update obj.ActivityMessage.
obj.ActivityMessage = '';


end