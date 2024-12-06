function updateGui(obj)
%Updates the mic.CavroSyringePump GUI.
% This method will update the GUI for the mic.CavroSyringePump class
% based on the current status of the syringe pump.
% INPUTS:
%   obj: An instance of the mic.CavroSyringePump class.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Check to see if a GUI exists.
if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
    return
end

% Search for GUI objects with non-empty tags, i.e. the regular expression 
% [^''] will match all tags that contain any character(s) besides '.
GuiFigureChildren = findall(obj.GuiFigure.Children, ...
    '-regexp', 'Tag', '[^'']');

% Determine if we need to enable/disable tagged objects based on
% obj.StatusByte. 
if (obj.StatusByte >= 96) || (obj.StatusByte == 0)
    % The pump is either ready to accept new commands or is not yet 
    % connected.  Ensure tagged graphics objects are enabled.
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
        if (obj.StatusByte >= 96) || (obj.StatusByte == 0)
            % The syringe pump is either ready for commands, or has not 
            % been connected, set the PumpActivity string to empty.
            GuiFigureChildren(ii).String = ''; 
        else
            % The syringe pump is busy, display the most recently known
            % activity of the syringe pump.
            GuiFigureChildren(ii).String = obj.ReadableAction; 
        end
    end
end
drawnow; % ensure changes to GUI happen immediately

    
end
