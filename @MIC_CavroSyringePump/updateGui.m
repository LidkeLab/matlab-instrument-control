function updateGui(obj)
%Updates the MIC_CavroSyringePump GUI.
% This method will update the GUI for the MIC_CavroSyringePump class
% based on the current status of the syringe pump.
% INPUTS:
%   obj: An instance of the MIC_CavroSyringePump class.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Check to see if a GUI exists.
if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
    return
end

% Search for GUI objects with non-empty tags, i.e. the regular expression 
% [^''] will match any tag that contains any character(s) besides '.
GuiFigureChildren = findobj('-regexp', 'Tag', '[^'']');

% Determine if we need to enable/disable tagged objects based on
% obj.StatusByte. 
if obj.StatusByte >= 96
    % The pump is ready to accept new commands, ensure tagged graphics
    % objects are enabled.
    set(GuiFigureChildren, 'Enable', 'on'); 
else
    % The pump is busy, disable tagged graphics objects.
    set(GuiFigureChildren, 'Enable', 'off');
end

% Loop through the tagged objects to perform special actions as needed.
for ii = 1:numel(GuiFigureChildren)
    % Update the PumpStatus textbox.
    if strcmpi(GuiFigureChildren(ii).Tag, 'PumpStatus')
        % This is the textbox displaying the pumps status,
        % update the status.
        GuiFigureChildren(ii).String = obj.ReadableStatus;
    end
    
    % Update the PumpActivity textbox.
    if strcmpi(GuiFigureChildren(ii).Tag, 'PumpActivity')
        % This is the textbox displaying the pumps current activity, update
        % to most recently known action being made.
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, no activity is in
            % progress.
            GuiFigureChildren(ii).String = ''; 
        else
            % The syringe pump is busy, display the most recently known
            % activity of the syringe pump.
            GuiFigureChildren(ii).String = obj.ReadableAction; 
        end
    end
end
drawnow % ensure changes to GUI happen immediately

    
end