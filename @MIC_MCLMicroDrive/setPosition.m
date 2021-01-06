function [] = setPosition(obj, Position)
%setPosition moves the micro-stage to the specified position.
% This method will try to move the connected micro-stage to the position
% defined by the input 'Position'.  This method also displays any error
% messages returned from the micro-stage controller if needed.
%
% INPUTS:
%   Position: Position to which stage will be moved.
%             (3x1 or 1x3 numeric array)

% Created by:
%   David J. Schodt (Lidkelab, 2021)

% Determine the current position of the stage.


% Call the appropriate C function depending on the number of axes present.
if (obj.NAxes == 1)
    % This is a one axis (z only) stage, meaning we must use the MCL_MD1*
    % methods.
else
end


end