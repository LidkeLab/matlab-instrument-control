function [] = moveDistance(obj, Distance)
%moveDistance moves the specified distance with the given velocity.
% This method will move an amount specified by 'Distance' at the speed
% defined in obj.Velocity
%
% INPUTS:
%   Distance: Distance the stage will be moved (millimeters)

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Set defaults if needed.
if isnan(obj.Velocity)
    obj.Velocity = max(obj.VelocityBounds(2)/4, ...
        obj.VelocityBounds(1));
end

% Validate the input parameters.
if ((obj.Velocity<obj.VelocityBounds(1)) ...
        || (obj.Velocity>obj.VelocityBounds(2)))
    error(['mic.linearstage.MCLMicroDrive.moveDistance(): invalid velocity %g ', ...
        'um/s - velocity must be within %g um/s and %g um/s'], ...
        obj.Velocity, obj.VelocityBounds(1), obj.VelocityBounds(2));
end
Distance = double(Distance);
if (isnan(Distance) || isinf(Distance))
    error('mic.linearstage.MCLMicroDrive.moveDistance(): invalid distance %g', ...
        Distance)
end

% Move the stage the specified distance.
ErrorCode = calllib('MicroDrive', 'MCL_MD1MoveProfile', ...
    obj.Velocity, Distance, 0, obj.DeviceHandle);
obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
obj.displayLastError()


end
