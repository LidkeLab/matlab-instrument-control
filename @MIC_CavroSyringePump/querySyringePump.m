function querySyringePump(obj)
%Queries an initialized Cavro syringe pump and returns the received message
% INPUTS:
%   obj: An instance of the MIC_CavroSyringePump class.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Query the syringe pump and read the response, repeating until a valid
% query response is received (a valid Answer Block in response to a query
% has exactly 6 bytes, i.e. no Data Block is returned for a query request) 
% or the timeout has been exceeded. 
IsQueryResponse = 0; 
tic % start a timer
while toc < obj.DeviceResponseTimeout
    % Query the syringe pump for status and error codes. 
    if ~isempty(obj.SyringePump)
        % A syringe pump serial object exists, attempt the query.
        fprintf(obj.SyringePump, ['/', num2str(obj.DeviceAddress), 'Q']);
    else
        % No syringe pump serial object exists, tell the user they need to
        % establish a connection.
        error('Syringe pump not connected.')
    end

    % Read the message returned by the Cavro syringe pump in response to 
    % the query request.
    [RawASCIIMessage, ~] = obj.readAnswerBlock();
    [ASCIIMessage, IsValid] = obj.cleanAnswerBlock(RawASCIIMessage); 
    if numel(ASCIIMessage)==6 && IsValid
        % Valid query response received, break out of the loop.
        IsQueryResponse  = 1;
        break
    end
    pause(1) % pause before retrying
end

% Throw an error if no valid query response was found within
% obj.DeviceResponseTime . 
if ~IsQueryResponse
    error('Valid message not returned within DeviceResponseTimeout = %g s \n', ...
        obj.DeviceResponseTimeout)
end

% Grab the StatusByte for code readability and update obj.PumpStatus. 
obj.StatusByte = ASCIIMessage(3); 


end