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
for ii = 1:numel(obj.GuiFigure.Children)
    % Update the StatusText textbox.
    if strcmpi(obj.GuiFigure.Children(ii).Tag, 'StatusText')
        % This is the textbox displaying the pumps status,
        % update the status.
        obj.GuiFigure.Children(ii).String = obj.ReadableStatus;
    end

    % Ensure Connect Syringe Pump button is enabled/disabled
    % depending on the pump status.
    if strcmpi(obj.GuiFigure.Children(ii).Tag, ...
            'ConnectButton')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Connect Syringe Pump button.
            obj.GuiFigure.Children(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the Connect
            % Syringe Pump button.
            obj.GuiFigure.Children(ii).Enable = 'off';
        end
    end

    % Ensure the Move Plunger to New Position button is
    % enabled/disabled depending on the pump status.
    if strcmpi(obj.GuiFigure.Children(ii).Tag, ...
            'MovePlunger')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Move Plunger to New Position button.
            obj.GuiFigure.Children(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the Move 
            % Plunger to New Position button.
            obj.GuiFigure.Children(ii).Enable = 'off';
        end
    end

    % Ensure the Re-initialize Syringe Pump button is
    % enabled/disabled depending on the pump status.
    if strcmpi(obj.GuiFigure.Children(ii).Tag, ...
            'InitializePump')
        if obj.StatusByte >= 96
            % The syringe pump is ready for commands, enable
            % the Re-initialize Syringe Pump button.
            obj.GuiFigure.Children(ii).Enable = 'on';
        else
            % The syringe pump is busy, disable the 
            % Re-initialize Syringe Pump button.
            obj.GuiFigure.Children(ii).Enable = 'off';
        end
    end
    drawnow % ensure changes happen immediately
end
    
    
 end