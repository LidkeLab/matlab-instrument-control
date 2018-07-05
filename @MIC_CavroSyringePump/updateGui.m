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

% Search for GUI objects to be updated and update them.
GuiFigureChildren = findall(obj.GuiFigure.Children);
for ii = 1:numel(GuiFigureChildren)
    % Update the StatusText textbox.
    if strcmpi(GuiFigureChildren(ii).Tag, 'StatusText')
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

    % Ensure Connect Syringe Pump button is enabled/disabled
    % depending on the pump status.
    if strcmpi(GuiFigureChildren(ii).Tag, ...
            'ConnectButton')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Connect Syringe Pump button.
            GuiFigureChildren(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the Connect
            % Syringe Pump button.
            GuiFigureChildren(ii).Enable = 'off';
        end
    end

    % Ensure the Move Plunger to New Position button is
    % enabled/disabled depending on the pump status.
    if strcmpi(GuiFigureChildren(ii).Tag, ...
            'MovePlunger')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Move Plunger to New Position button.
            GuiFigureChildren(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the Move 
            % Plunger to New Position button.
            GuiFigureChildren(ii).Enable = 'off';
        end
    end

    % Ensure the Re-initialize Syringe Pump button is
    % enabled/disabled depending on the pump status.
    if strcmpi(GuiFigureChildren(ii).Tag, ...
            'InitializePump')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Re-initialize Syringe Pump button.
            GuiFigureChildren(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the 
            % Re-initialize Syringe Pump button.
            GuiFigureChildren(ii).Enable = 'off';
        end
    end
    
    % Ensure the valve control buttons are enabled/disabled depending on
    % pump status.
    if strcmpi(GuiFigureChildren(ii).Tag, ...
            'ValveInButton')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable the input
            % valve control button.
            GuiFigureChildren(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the input valve control
            % button.
            GuiFigureChildren(ii).Enable = 'off';
        end
    end
    if strcmpi(GuiFigureChildren(ii).Tag, ...
            'ValveOutButton')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable the output
            % valve control button.
            GuiFigureChildren(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the output valve control
            % button.
            GuiFigureChildren(ii).Enable = 'off';
        end
    end
end
drawnow % ensure changes to GUI happen immediately

    
end