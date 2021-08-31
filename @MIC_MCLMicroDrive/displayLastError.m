function [] = displayLastError(obj)
%displayLastError displays the last error message received from the stage
% This method will take the struct in obj.LastError and display it in a
% more user friendly way in the Command Window.  If the "error" code
% returned was 0 (success), no message will be displayed (for the sake of
% avoiding CommandWindow clutter).

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Attempt to display the error.
if (obj.LastError.ErrorCode ~= 0)
    warning('Error code %i ''%s'' received from stage: %s\n', ...
        obj.LastError.ErrorCode, obj.LastError.ErrorName, ...
        obj.LastError.ErrorInfo);
end


end