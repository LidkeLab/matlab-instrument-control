function [CommandSequence] = generateArrayProgram(obj, NLoops)
%generateArrayProgram generates a program based on obj.SignalArray.
% This method will generate a cell array of char arrays, with each element
% being one line of an array program to be sent to the Triggerscope.  The
% intention is that this method will convert the user defined SignalArray
% into a program that can be sent (line-by-line) to the Triggerscope, which
% will produce the desired behavior defined by the SignalArray.
%
% NOTE: CommandSequence won't reflect the zero signals.  The Triggerscope
%       drives each port to 0 volts at each trigger by default.
%
% INPUTS:
%   NLoops: Number of times to repeat the signals in SignalArray.
%           (scalar integer)(Default = 1)
%   
% OUTPUTS:
%   CommandSequence: A list of commands to be sent to the Triggerscope to
%                    produce the behavior defined by the signals in
%                    SignalArray.
%                    (cell array of char array)

% Created by:
%   David J. Schodt (Lidke Lab, 2020)

% Define default parameters if needed.
if (~exist('NLoops', 'var') || isempty(NLoops))
    NLoops = 1;
end

% Convert the trigger mode to the appropriate integer needed by the
% Triggerscope.
TriggerModeInt = 1*strcmpi(obj.TriggerMode, 'Low') ...
    + 2*strcmpi(obj.TriggerMode, 'High') ...
    + 3*strcmpi(obj.TriggerMode, 'Rising') ...
    + 4*strcmpi(obj.TriggerMode, 'Falling') ...
    + 5*strcmpi(obj.TriggerMode, 'Change');
if ~TriggerModeInt
    error('Unknown trigger mode ''%s''', obj.TriggerMode)
end

% Determine which signals need to be programmed.
NonZeroIndices = find(any(obj.SignalArray, 2));
DACIndices = NonZeroIndices(NonZeroIndices > obj.IOChannels);

% Generate commands to set the voltage ranges of the appropriate DAC ports
% (after storing some other initializer commands).
NProgramLines = size(obj.SignalArray, 2);
NSignals = numel(NonZeroIndices);
NDACSignals = numel(DACIndices);
NInitializerCommands = 2;
VoltageRangeIndex = ones(2*obj.IOChannels, 1);
CommandSequence = cell(...
    NProgramLines*NSignals + NDACSignals + NInitializerCommands, 1);
CommandSequence{1} = sprintf('TRIGMODE,%i', TriggerModeInt);
CommandSequence{2} = sprintf('TIMECYCLES,%i', NLoops);
for ii = 1:NDACSignals
    % Determine the ideal voltage range setting for this signal (i.e., the
    % range which accomodates the signal, but has the smallest extent).
    VoltageRangeIndex(DACIndices(ii)) = ...
        obj.selectVoltageRange(obj.SignalArray(DACIndices(ii), :));
    
    % Store the command which will set the appropriate voltage range.
    CommandSequence{ii + NInitializerCommands} = sprintf('RANGE%i,%i', ...
        DACIndices(ii), ...
        VoltageRangeIndex(ii+obj.IOChannels));
end

% Loop through all of the non-zero signals and define the associated
% commands.
for ii = 1:NProgramLines
    for jj = 1:NSignals
        % TTL port numbers directly match their row index in 
        % obj.SignalArray, but DAC signals are stored in the row given by
        % PortNumber + obj.IOChannels.
        CurrentIndex = NonZeroIndices(jj);
        IsDAC = (CurrentIndex > obj.IOChannels);
        PortNumber = CurrentIndex - IsDAC*obj.IOChannels;
        if IsDAC
            VoltageRange = obj.VoltageRangeOptions(...
                VoltageRangeIndex(CurrentIndex), :);
            BitLevel = obj.convertVoltageToBitLevel(...
                obj.SignalArray(CurrentIndex, ii), ...
                VoltageRange, ...
                obj.DACResolution);
            CommandSequence{NInitializerCommands + NDACSignals ...
                + (ii-1)*NSignals + jj} = ...
                sprintf('PROG_DAC,%i,%i,%i', ...
                ii, PortNumber, BitLevel);
        else
            CommandSequence{NInitializerCommands + NDACSignals ...
                + (ii-1)*NSignals + jj} = ...
                sprintf('PROG_TTL,%i,%i,%i', ...
                ii, PortNumber, obj.SignalArray(CurrentIndex, ii));
        end
    end
end


end