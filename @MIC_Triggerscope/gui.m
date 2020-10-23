function gui(obj, GUIParent)
%gui is the GUI method for the MIC_Triggerscope class.
% This GUI has several elements which can be used to control a Triggerscope
% (see MIC_Triggerscope.m for details).
%
% INPUTS:
%   GUIParent: The 'Parent' of this GUI, e.g., a figure handle.
%              (Default = figure(...))

% Created by:
%   David J. Schodt (Lidke lab, 2020)


% Create a figure handle for the GUI if needed.
if ~(exist('GUIParent', 'var') && ~isempty(GUIParent) ...
        && isgraphics(GUIParent))
    DefaultFigurePosition = get(0, 'defaultFigurePosition');
    GUIParent = figure('MenuBar', 'none', ...
        'Name', 'Triggerscope Control GUI', 'NumberTitle', 'off', ...
        'Units', 'pixels', ...
        'Position', DefaultFigurePosition .* [0.5, 1, 1.3, 1]);
end
obj.GUIParent = GUIParent;

% Generate some panels to help organize the GUI.
ConnectionPanel = uipanel(GUIParent, 'Title', 'Connection', ...
    'Units', 'normalized', 'Position', ...
    [0, 0.9, 1, 0.1]);
TTLDACPanel = uipanel(GUIParent, 'Title', 'TTL/DAC Control', ...
    'Units', 'normalized', 'Position', [0, 0.2, 1, 0.7]);
CommandPanel = uipanel(GUIParent, 'Title', 'Custom Commands', ...
    'Units', 'normalized', 'Position', [0, 0.1, 1, 0.1]);
StatusPanel = uipanel(GUIParent, 'Title', 'Status', ...
    'Units', 'normalized', 'Position', [0, 0, 1, 0.1]);

% Add controls to the ConnectionPanel.
TextPos = [0, 0, 0.15, 1];
PopupPos = [TextPos(3), 0, 0.1, 1];
ButtonPos = [PopupPos(1)+PopupPos(3), 0, 0.2, 1];
SerialPortMessage = ...
    sprintf(['Serial port Triggerscope is connected to.\n', ...
    'This list always includes obj.SerialPort, even if not found.\n', ...
    'Note that changing this outside of the GUI may result in\n', ...
    'undefined behavior']);
uicontrol(ConnectionPanel, 'Style', 'text', ...
    'String', 'Serial port: ', ...
    'FontUnits', 'normalized', 'FontSize', 0.5, ...
    'Tooltip', SerialPortMessage, ...
    'Units', 'normalized', 'Position', TextPos, ...
    'HorizontalAlignment', 'right');
ControlHandles.SerialPortPopup = uicontrol(ConnectionPanel, ...
    'Style', 'popupmenu', ...
    'String', unique([obj.SerialPort, serialportlist()]), ...
    'FontUnits', 'normalized', 'FontSize', 0.4, ...
    'Tooltip', SerialPortMessage, ...
    'Units', 'normalized', 'Position', PopupPos, ...
    'Callback', @guiToProperties);
uicontrol(ConnectionPanel, 'Style', 'pushbutton', ...
    'String', obj.convertLogicalToStatus(obj.IsConnected, ...
    {'Disconnect Triggerscope', 'Connect Triggerscope'}), ...
    'FontUnits', 'normalized', 'FontSize', 0.4, ...
    'Units', 'normalized', 'Position', ButtonPos, ...
    'BackgroundColor', ...
    obj.convertLogicalToStatus(obj.IsConnected, {'green', 'red'}), ...
    'Callback', @toggleConnection, ...
    'Tag', 'ToggleConnectionButton');

% Add some controls to the TTLDACPanel.
NColumns = 4;
NRows = ceil(obj.IOChannels / NColumns);
BlockSize = 1 ./ [NRows, NColumns];
UIControlInitPos = [0.01, 0.95, 0, 0];
ButtonPos = [0, 0, 0.65/NColumns, 0.3/NRows];
TextPos = [0, 0, 0.25/NColumns, 0.25/NRows];
EditPos = ButtonPos .* [1, 1, 0.25, 1];
PopupPos = ButtonPos .* [1, 1, 0.5, 1];
ControlHandles.TTLPushbutton = cell(obj.IOChannels, 1);
ControlHandles.DACEdit = cell(obj.IOChannels, 1);
ControlHandles.DACPopup = cell(obj.IOChannels, 1);
for pp = 1:obj.IOChannels
    % Determine which "row" and "column" of the panel the controls for this
    % TTL(DAC) should be.
    PanelRow = ceil(pp / NColumns);
    PanelColumn = pp - NColumns*(PanelRow-1);
    
    % Add a text uicontrol to specify which pushbutton belongs to which
    % TTL port.
    RowColumnOffset = [(PanelColumn-1) * BlockSize(2), ...
        (1-PanelRow) * BlockSize(1)];
    TTLTextPosition = UIControlInitPos ...
        + [RowColumnOffset, 0, 0] ...
        + TextPos + [0, -TextPos(4), 0, 0];
    uicontrol(TTLDACPanel, 'Style', 'text', ...
        'FontUnits', 'normalized', 'FontSize', 0.6, ...
        'FontWeight', 'bold', ...
        'String', sprintf('TTL%i', pp), ...
        'Units', 'normalized', ...
        'Position', TTLTextPosition, 'HorizontalAlignment', 'left')
    
    % Add a pushbutton to drive the TTL HIGH or LOW.
    OnOffButtonPos = TTLTextPosition.*[1, 1, 0, 0] ...
        + [TTLTextPosition(3), 0, 0, 0] ...
        + ButtonPos;
    ControlHandles.TTLPushbutton{pp} = uicontrol(TTLDACPanel, ...
        'Style', 'pushbutton', ...
        'FontUnits', 'normalized', 'FontSize', 0.5, ...
        'FontWeight', 'bold', ...
        'String', obj.convertLogicalToStatus(...
        obj.TTLStatus(pp).Value, {'HIGH', 'LOW'}), ...
        'BackgroundColor', obj.convertLogicalToStatus(...
        obj.TTLStatus(pp).Value, {'green', 'red'}), ...
        'Units', 'normalized', 'Position', OnOffButtonPos, ...
        'Callback', {@toggleTTL, pp});
    
    % Add a text uicontrol to specify which DAC control belongs to which
    % DAC port.
	DACTextPosition = TTLTextPosition.*[1, 1, 0, 0] ...
        + [0, -1.5*TTLTextPosition(4), 0, 0] ...
        + TextPos;
    uicontrol(TTLDACPanel, 'Style', 'text', ...
        'FontUnits', 'normalized', 'FontSize', 0.6, ...
        'FontWeight', 'bold', ...
        'String', sprintf('DAC%i', pp), ...
        'Units', 'normalized', ...
        'Position', DACTextPosition, 'HorizontalAlignment', 'left')
    
    % Add an edit box to set the output of the DAC port.
    DACEditPos = DACTextPosition.*[1, 1, 0, 0] ...
        + [DACTextPosition(3), 0, 0, 0] ...
        + EditPos;
    ControlHandles.DACEdit{pp} = uicontrol(TTLDACPanel, ...
        'Style', 'edit', ...
        'FontUnits', 'normalized', 'FontSize', 0.5, ...
        'String', num2str(obj.DACStatus(pp).Value), ...
        'Units', 'normalized', 'Position', DACEditPos, ...
        'Callback', {@setDACOutput, pp});
    
    % Add a text uicontrol to specify the display the units of the DAC 
    % output.
    VoltageTextPos = DACEditPos.*[1, 1, 0, 0] ...
        + [DACEditPos(3), 0, 0, 0] ...
        + TextPos.*[1, 1, 0.7, 1];
    uicontrol(TTLDACPanel, 'Style', 'text', ...
        'FontUnits', 'normalized', 'FontSize', 0.5, ...
        'FontWeight', 'bold', 'String', 'Volts', ...
        'HorizontalAlignment', 'left', ...
        'Units', 'normalized', 'Position', VoltageTextPos);
    
    % Add a popup menu to select the voltage range of the DAC output.
    VoltageRangePopupPos = VoltageTextPos.*[1, 1, 0, 0] ...
        + [VoltageTextPos(3), 0, 0, 0] ...
        + PopupPos; 
    ControlHandles.DACPopup{pp} = uicontrol(TTLDACPanel, ...
        'Style', 'popupmenu', ...
        'String', obj.VoltageRangeChar, ...
        'Value', obj.DACStatus(pp).VoltageRangeIndex, ...
        'FontUnits', 'normalized', 'FontSize', 0.5, ...
        'Tooltip', SerialPortMessage, ...
        'Units', 'normalized', ...
        'Position', VoltageRangePopupPos, ...
        'Callback', {@setVoltageRange, pp});
end

% Add some controls to the CommandPanel.
TextPos = [0, 0, 0.15, 1];
EditPos = [TextPos(3), 0, 0.3, 1];
ButtonPos = [EditPos(1)+EditPos(3), 0, 0.2, 1];
CustomCommandTooltip = sprintf(...
    ['Custom commands from the Triggerscope documentation can be\n', ...
    'entered and executed here.  Command responses will be\n', ...
    'displayed (when applicable) as a status message elsewhere in\n', ...
    'the GUI.  Commands are executed using obj.executeCommand().']);
uicontrol(CommandPanel, 'Style', 'text', ...
    'String', 'Command: ', 'FontUnits', 'normalized', 'FontSize', 0.5, ...
    'Tooltip', CustomCommandTooltip, ...
    'Units', 'normalized', 'Position', TextPos, ...
    'HorizontalAlignment', 'right');
ControlHandles.CommandEdit = uicontrol(CommandPanel, 'Style', 'edit', ...
    'FontUnits', 'normalized', 'FontSize', 0.5, ...
    'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', EditPos, ...
    'Callback', @executeCommandFromGUI);
uicontrol(CommandPanel, 'Style', 'pushbutton', ...
    'String', 'Execute command', ...
    'FontUnits', 'normalized', 'FontSize', 0.5, ...
    'Units', 'normalized', 'Position', ButtonPos, ...
    'Callback', @executeCommandFromGUI);

% Add a status display to the status panel.
StatusTooltip = sprintf(...
    ['This status bar will display various messages related to the\n', ...
    'Triggerscope activities.  These messages may include commands\n', ...
    'sent to the Triggerscope, responses from the Triggerscope,\n', ...
    'error messages, etc.']);
uicontrol(StatusPanel, 'Style', 'text', ...
    'FontWeight', 'bold', 'FontUnits', 'normalized', 'FontSize', 0.6, ...
    'String', obj.convertLogicalToStatus(...
    obj.IsConnected, {'Connected', 'Not connected'}), ...
    'BackgroundColor', obj.convertLogicalToStatus(...
    obj.IsConnected, {'green', 'red'}), ...
    'Units', 'normalized', 'Position', [0, 0.2, 0.15, 0.7], ...
    'Enable', 'off', 'Tag', 'ConnectionDisplay');
uicontrol(StatusPanel, 'Style', 'text', ...
    'String', 'Triggerscope activity: ', ...
    'FontUnits', 'normalized', 'FontSize', 0.55, ...
    'Units', 'normalized', 'Position', [0.18, 0, 0.2, 0.8], ...
    'HorizontalAlignment', 'right', ...
    'Tooltip', StatusTooltip);
uicontrol(StatusPanel, 'Style', 'edit', ...
    'String', obj.ActivityMessage, ...
    'FontUnits', 'normalized', 'FontSize', 0.4, ...
    'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', [0.38, 0, 0.62, 1], ...
    'Enable', 'off', 'Tag', 'ActivityDisplay');

% Call propertiesToGUI() just to be safe.
propertiesToGUI();


    function propertiesToGUI()
        % This function takes properties in obj and updates the GUI to
        % reflect those property values.
        
        % Update the serial port popup menu.
        ControlHandles.SerialPortPopup.Value = ...
            find(strcmp(obj.SerialPort, ...
            ControlHandles.SerialPortPopup.String));
        
        % Update the TTL buttons.
        for ii = 1:numel(obj.TTLStatus)
            ControlHandles.TTLPushbutton{pp}.String = ...
                obj.convertLogicalToStatus(...
                obj.TTLStatus(pp).Value, {'HIGH', 'LOW'});
            ControlHandles.TTLPushbutton{pp}.BackgroundColor = ...
                obj.convertLogicalToStatus(...
                obj.TTLStatus(pp).Value, {'green', 'red'});
        end
        
        % Update the DAC setting controls.
        for ii = 1:numel(obj.DACStatus)
            ControlHandles.DACEdit{pp}.String = ...
                num2str(obj.DACStatus(pp).Value);
            ControlHandles.DACPopup{pp}.Value = ...
                obj.DACStatus(pp).VoltageRangeIndex;
        end
    end

    function guiToProperties()
        % This function updates properties in obj based on changes made to
        % controls in this GUI.
        
        % Update the serial port popup menu.
        obj.SerialPort = ControlHandles.SerialPortPopup.String;
        
        % Update the status of the TTL channels.
        for ii = 1:numel(obj.TTLStatus)
            obj.TTLStatus(pp).Value = ...
                strcmp(ControlHandles.TTLPushbutton{pp}.String, 'HIGH');
        end
        
        % Update the status of the DAC channels.
        for ii = 1:numel(obj.DACStatus)
            % Update the voltage range.
            obj.DACStatus(pp).VoltageRangeIndex = ...
                ControlHandles.DACPopup{pp}.Value;
            
            % Update the driving voltage.
            obj.DACStatus(pp).Value = ...
                str2double(ControlHandles.DACEdit{pp});
        end
        
    end

    function toggleConnection(~, ~)
        % This is a callback for the "Connect Triggerscope" button.
        if obj.IsConnected
            obj.disconnectTriggerscope()
        else
            obj.connectTriggerscope()
        end
    end

    function toggleTTL(Source, ~, TTLIndex)
        % This is a callback for the TTL on/off buttons.
        % This function will toggle the state of the TTL port defined by
        % TTLIndex.
        
        % Toggle the state of the TTL.
        % NOTE: Omitting the second input to setTTLState() toggles the
        %       state.
        obj.setTTLState(TTLIndex)
        
        % Check the new state of this TTL port.
        NewState = obj.TTLStatus(TTLIndex).Value;
                
        % Update the 'String' and the 'BackgroundColor' of the pushbutton.
        Source.String = obj.convertLogicalToStatus(...
            NewState, {'HIGH', 'LOW'});
        Source.BackgroundColor = obj.convertLogicalToStatus(...
            NewState, {'green', 'red'});
        
        % Update the class properties to reflect these changes (slower, but
        % easier, to just call GUIToProperties() here).
        guiToProperties();
    end

    function setDACOutput(Source, ~, DACIndex)
        % This is a callback for the DAC output edit box.
        % This function will take the number typed into Source.String and
        % attempt to set the output voltage of DAC port DACIndex to the
        % value specified.
        
        % Attempt to set the specified DAC output voltage.
        obj.setDACVoltage(DACIndex, str2double(Source.String));
        
        % Update the class properties to reflect these changes (slower, but
        % easier, to just call GUIToProperties() here).
        guiToProperties();
    end

    function setVoltageRange(Source, ~, DACIndex)
        % This is a callback for the voltage range popup menu.
        % This function will attempt to set the voltage range setting of
        % DAC port DACIndex to the range given by the selected popup menu
        % item.
        % NOTE: This function only works if we keep the order of
        %       obj.VoltageRangeChar in line with the Triggerscope
        %       documentation!
        
        % Attempt to change the DAC voltage range for this port.
        obj.setDACRange(obj, DACIndex, Source.Value)
        
        % Force reset the DAC output to 0 (it seemed that changing the
        % range might sometimes cause undefined behavior of the output, so
        % doing this seemed to be the safest option).
        ControlHandles.DACEdit{DACIndex}.String = 0;
        obj.setDACVoltage(DACIndex, 0);
        
        % Update the class properties to reflect these changes (slower, but
        % easier, to just call GUIToProperties() here).
        guiToProperties();
    end

    function executeCommandFromGUI(Source, ~)
        % This is a callback for the custom command execution uicontrols.
        % Running this callback will update a few things in the GUI for
        % display purposes and then attempt to execute the command typed in
        % the custom command editbox.
        
        % Disable the source uicontrol so that it's not calling this
        % callback multiple times by mistake.
        Source.Enable = 'off';
        
        % Attempt to execute the command.
        try
            obj.executeCommand(ControlHandles.CommandEdit.String);
        catch ME
            % We should re-enable the uicontrol before throwing the error.
            Source.Enable = 'on';
            rethrow(ME);
        end
        Source.Enable = 'on';
    end


end