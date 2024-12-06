function [] = connectStage(obj)
%connectStage attempts to connect to the stage.
% This method will use the MCL libraries to attempt to connect to an MCL
% micro-drive stage attached to the calling computer.

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Attempt to make the connection.
obj.DeviceHandle = calllib('MicroDrive', 'MCL_InitHandle');
obj.LastError = obj.ErrorCodes(9*(~obj.DeviceHandle) + 1);

% Request some device information from the micro-stage.
obj.SerialNumber = calllib('MicroDrive', ...
    'MCL_GetSerialNumber', obj.DeviceHandle);
[obj.DLLVersion, obj.DLLRevision] = ...
    calllib('MicroDrive', 'MCL_DLLVersion', 0, 0);
[ErrorCode, ~, obj.StepSize, ...
    obj.VelocityBounds(2), obj.VelocityBounds(1)] = ...
    calllib('MicroDrive', 'MCL_MicroDriveInformation', ...
    0, 0, 0, 0, obj.DeviceHandle);
obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
obj.displayLastError()


end