function setTTLState(obj, TTLIndex, State)
%setTTLState sets the specified TTL to the desired state.
% This method will set TTL port number 'TTLIndex' to the state specified by
% 'State'.
%
% EXAMPLE USAGE:
%   If 'TS' is a working instance of the MIC_Triggerscope class (i.e., the
%   Triggerscope has already been connected successfully), you can use this
%   method to set TTL port 13 HIGH (true, on, hot, ...) with any of 
%   the following commands:
%       TS.setTTLState(13, 'HIGH')
%       TS.setTTLState(13, true)
%       TS.setTTLState(13, 1)
%   Similarly, you can set TTL port 13 LOW (false, off, cold, ...) with any
%   of the following commands:
%       TS.setTTLState(13, 'LOW')
%       TS.setTTLState(13, false)
%       TS.setTTLState(13, 0)
%   You can also toggle the state of TTL port 13 by excluding the second
%   input:
%       TS.setTTLState(13)
%
% INPUTS:
%   TTLIndex: The TTL port number you wish to change the state of.
%             (integer in range [1, obj.IOChannels])
%   State: The state you wish to set TTL port number TTLIndex to.
%          (char array 'LOW', 'HIGH', or any input that can be cast to true
%          or false)

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Validate the TTLIndex.
% NOTE: I'm doing this first to help with the default setting for 'State'.
assert((TTLIndex>=1) && (TTLIndex<=obj.IOChannels), ...
    sprintf(['TTL port %i does not exist: TTLIndex ', ...
    'must be in the range [1, obj.IOChannels]'], TTLIndex))

% Set a value for 'State' if not provided (omitting this input allows the
% user to toggle the state).
if (~exist('State', 'var') || isempty(State))
    State = ~obj.TTLStatus(TTLIndex).Value;
end

% Validate the 'State' variable and convert from char/string if needed.
if (ischar(State) || isstring(State))
    % We should first make sure 'State' is either 'HIGH' or 'LOW' (we don't
    % want a typo doing something unexpected!).
    assert(ismember(State, {'HIGH', 'LOW'}), ...
        'Input State = %s is not valid: must be ''HIGH'' or ''LOW''')
    
    % Convert the char array/string to a logical.
    State = strcmp(State, 'HIGH');
elseif (~(isnumeric(State) || islogical(State)) ...
        || isnan(State) || ~isreal(State))
    % All of these conditions might lead to unexpected behavior if met.
    error('Input ''State'' must be convertible to integer 1 or 0')
end

% Set the specified TTL port to the desired state.
obj.executeCommand(sprintf('TTL%i,%i', TTLIndex, State));


end