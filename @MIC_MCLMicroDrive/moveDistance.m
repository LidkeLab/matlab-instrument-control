function [] = moveDistance(obj, Distance, Velocity)
%moveDistance moves the specified distance with the given velocity.
% This method will move an amount specified by 'Distance' at the given
% speed 'Velocity'.
%
% INPUTS:
%   Distance: Distance the stage will be moved (millimeters)
%   Velocity: Velocity of the movement 
%             (millimeters/second)(Default set bassed on velocity bounds)

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Set defaults if needed.
if (~exist('Velocity', 'var') || isempty(Velocity))
    obj.Velocity = max(obj.VelocityBounds(2)/4, ...
        obj.VelocityBounds(1));
end

% Validate the input parameters.
if ((Velocity<obj.VelocityBounds(1)) || (Velocity>obj.VelocityBounds(2)))
    error(['MIC_MCLMicroDrive.moveDistance(): invalid velocity %g ', ...
        'um/s - velocity must be within %g um/s and %g um/s'], ...
        Velocity, obj.VelocityBounds(1), obj.VelocityBounds(2));
end
Distance = double(Distance);
Velocity = double(Velocity);

% Move the stage the specified distance.
ErrorCode = calllib('MicroDrive', 'MCL_MD1MoveProfile', ...
    Velocity, Distance, 0, obj.DeviceHandle);
obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
obj.displayLastError()


end