function [] = moveSingleStep(obj, Direction)
%moveSingleStep moves a single step in the specified direction.
% This method will take the smallest possible step size of the connected
% MCL micro-drive stage in the direction specified by 'Direction'.
%
% INPUTS:
%   Direction: Direction in which the stage will take a single step.
%              (integer, 1 or -1)

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Ensure 'Direction' makes sense.
if (abs(Direction) ~= 1)
    error(['MIC_MCLMicroDrive.moveSingleStep(): input ''Direction'' ', ...
        'must be either 1 or -1'])
end

% Move the stage in the specified direction.
ErrorCode = calllib('MicroDrive', 'MCL_MD1SingleStep', ...
    Direction, obj.DeviceHandle);
obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
obj.displayLastError()


end