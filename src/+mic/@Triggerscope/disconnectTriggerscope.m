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
delete(obj.TriggerscopeSerialPortDev)

% Reset the class instance obj (even if the user doesn't want this, it's
% probably best that we do so to avoid misleading information/behavior of
% the GUI).
obj.reset()

% Update obj.ActivityMessage and obj.IsConnected.
obj.ActivityMessage = '';
obj.IsConnected = false;


end
