function disconnectTriggerscope(obj)
%disconnectTriggerscope disconnects the serialport object obj.Triggerscope
% This method will delete the serial port object defined by
% obj.Triggerscope.

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Update obj.ActivityMessage.
obj.ActivityMessage = ...
    sprintf('Disconnecting device at serial port ''%s''...', ...
    obj.SerialPort);

% Delete obj.Triggerscope.
delete(obj.Triggerscope)

% Update obj.ActivityMessage.
obj.ActivityMessage = '';


end