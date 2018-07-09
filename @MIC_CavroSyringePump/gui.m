function guiFig = gui(obj)
%Graphical user interface for MIC_CavroSyringePump.

%{
Specify general GUI behaviors. 
%}

% Prevent opening more than one figure for same instrument.
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

% Create a figure for the GUI.
ScreenSize = get(groot, 'ScreenSize'); % screen size
FigWidth = 350;
FigHeight = 350;
BottomLeftX = floor(ScreenSize(3)/2 - FigWidth/2); % ~centers the figure
BottomLeftY = floor(ScreenSize(4)/2 - FigHeight/2); % ~centers the figure
guiFig = figure('Position', ...
    [BottomLeftX, BottomLeftY, FigWidth, FigHeight], ...
    'MenuBar', 'none', 'ToolBar', 'none'); % figure handle
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = obj.InstrumentName;
handles.output = guiFig;
guidata(guiFig, handles); % associate guiFig with a handles struct

% Pass control to closeFigure callback when closing the figure.
obj.GuiFigure.CloseRequestFcn = @closeFigure;


%{ 
Create the GUI controls.
%}

% Create textboxes to display the syringe pump status/current activity.
% Also create a refresh button to force update of the status messages.
handles.CommPanel = uipanel('Parent', guiFig, ...
    'Title', 'Pump Communciations', 'Units', 'pixels', ...
    'Position', [5, 5, FigWidth-10, 75]);
handles.PumpStatus = uicontrol('Parent', handles.CommPanel, ...
    'Style', 'edit', 'Position', [5, 5, FigWidth-75, 25], ...
    'Tag', 'PumpStatus', 'Enable', 'off', ...
    'TooltipString', 'Current status/error messages for the syringe pump');
handles.PumpActivity = uicontrol('Parent', handles.CommPanel, ...
    'Style', 'edit', 'Position', [5, 30, FigWidth-75, 25], ...
    'Tag', 'PumpActivity', 'Enable', 'off');
handles.RefreshStatus = uicontrol('Parent', handles.CommPanel, ...
    'Style', 'pushbutton', 'Position', [285, 5, 50, 50], ...
    'String', 'Refresh', 'Callback', @refreshStatus);

% Create syringe pump connection controls/options.
handles.ConnectionPanel = uipanel('Parent', guiFig, ...
    'Title', 'Pump Connection', 'Units', 'pixels', ...
    'Position', [5, FigHeight-125, 160, 125]);
handles.PortList = uicontrol('Parent', handles.ConnectionPanel, ...
    'Style', 'popupmenu', 'Position', [5, 55, 150, 50], ...
    'Callback', @portListCallback);
handles.ConnectButton = uicontrol('Parent', handles.ConnectionPanel, ...
    'Style', 'pushbutton', 'Position', [5, 30, 150, 50], ...
    'String', 'Connect Syringe Pump', 'Tag', 'ConnectButton', ...
    'Callback', @connectSyringePump);
handles.InitializeButton = uicontrol('Parent', handles.ConnectionPanel, ...
    'Style', 'pushbutton', 'Position', [5, 5, 150, 25], ...
    'String', 'Re-initialize Syringe Pump', 'Tag', 'InitializePump', ...
    'Callback', @initializeSyringePump);

% Create plunger velocity controls.
handles.PlungerParamPanel = uipanel('Parent', guiFig, ...
    'Title', 'Plunger Velocity Parameters', 'Units', 'pixels', ...
    'Position', [5, FigHeight-260, 160, 125]);
handles.VelocitySlope = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'edit', 'Position', [115, 80, 40, 25], ...
    'TooltipString', 'Select integer in the range [1, 20]', ...
    'Callback', @setVelocitySlope);
handles.VSLabel = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'text', 'Position', [5, 80, 110, 20], ...
    'String', 'Velocity Slope (Hz/s)', ...
    'TooltipString', 'Select integer in the range [1, 20]', ...
    'HorizontalAlignment', 'left'); 
handles.StartVelocity = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'edit', 'Position', [115, 55, 40, 25], ...
    'TooltipString', 'Select integer in the range [50, 1000]', ...
    'Callback', @setStartVelocity); 
handles.SVLabel = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'text', 'Position', [5, 55, 100, 20], ...
    'String', 'Start Velocity (Hz)', ...
    'TooltipString', 'Select integer in the range [50, 1000]', ...
    'HorizontalAlignment', 'left'); 
handles.TopVelocity = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'edit', 'Position', [115, 30, 40, 25], ...
    'TooltipString', 'Select integer in the range [5, 5800]', ...
    'Callback', @setTopVelocity); 
handles.TVLabel = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'text', 'Position', [5, 30, 100, 20], ...
    'String', 'Top Velocity (Hz)', ...
    'TooltipString', 'Select integer in the range [5, 5800]', ...
    'HorizontalAlignment', 'left'); 
handles.CutoffVelocity = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'edit', 'Position', [115, 5, 40, 25], ...
    'TooltipString', 'Select integer in the range [50, 2700]', ...
    'Callback', @setCutoffVelocity); 
handles.CVLabel = uicontrol('Parent', handles.PlungerParamPanel, ...
    'Style', 'text', 'Position', [5, 5, 100, 20], ...
    'TooltipString', 'Select integer in the range [50, 2700]', ...
    'String', 'Cutoff Velocity (Hz)', 'HorizontalAlignment', 'left');

% Create plunger position controls.
handles.PlungerPositionPanel = uipanel('Parent', guiFig, ...
    'Title', 'Plunger Position Controls', 'Units', 'pixels', ...
    'Position', [FigWidth-175, FigHeight-260, 170, 125]);
handles.CurrentPositionDisplay = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'text', ...
    'Position', [120, 75, 50, 25]); 
handles.CurrentPositionLabel = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'text', ...
    'Position', [5, 80, 120, 20], ...
    'String', 'Current Plunger Position:', 'HorizontalAlignment', 'left');
handles.NewPositionAbsolute = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'edit', ...
    'Position', [125, 55, 40, 25], ...
    'TooltipString', 'Select integer in the range [0, 3000]');
handles.NewPositionAbsoluteLabel = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'text', ...
    'Position', [5, 55, 110, 20], 'String', 'New Plunger Position:', ...
    'HorizontalAlignment', 'left', ...
    'TooltipString', 'Select integer in the range [0, 3000]');
handles.MovePlungerButton = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'pushbutton', ...
    'Position', [5, 30, 160, 25], ...
    'String', 'Move Plunger to New Position', 'Tag', 'MovePlunger', ...
    'Callback', @movePlungerAbsolute);
handles.TerminateMoveButton = uicontrol(...
    'Parent', handles.PlungerPositionPanel, 'Style', 'pushbutton', ...
    'Position', [5, 5, 160, 25], 'String', 'Terminate Plunger Move', ...
    'Callback', @terminatePlungerMove); 

% Create syringe pump IN/OUT valve controls.
handles.ValveControlPanel = uipanel('Parent', guiFig, ...
    'Title', 'Syringe Pump Valve Controls', 'Units', 'pixels', ...
    'Position', [FigWidth-175, FigHeight-75, 170, 75]);
handles.ValveInButton = uicontrol('Parent', handles.ValveControlPanel, ...
    'Style', 'pushbutton', 'Position', [5, 30, 160, 25], ...
    'String', 'Move Valve to Input Position', 'Tag', 'ValveInButton', ...
    'Callback', {@valveControl, 1}); % send numeric 1 for input
handles.ValveOutButton = uicontrol('Parent', handles.ValveControlPanel, ...
    'Style', 'pushbutton', 'Position', [5, 5, 160, 25], ...
    'String', 'Move Valve to Output Position', 'Tag', 'ValveOutButton', ...
    'Callback', {@valveControl, 0}); % send numeric 0 for output

% Create a custom command execution box.
handles.CustomCommandPanel = uipanel('Parent', guiFig, ...
    'Title', 'Custom Command Interface', 'Units', 'pixels', ...
    'Position', [FigWidth-175, FigHeight-125, 170, 50]); 
handles.CustomCommand = uicontrol('Parent', handles.CustomCommandPanel, ...
    'Style', 'edit', 'Position', [5, 5, 100, 25], ...
    'Tag', 'CustomCommand', ...
    'TooltipString', ['Syringe pump responses will be displayed ', ...
    'in the Pump Communciations section']);
handles.ExecuteCustomCommand = uicontrol(...
    'Parent', handles.CustomCommandPanel, 'Style', 'pushbutton', ...
    'Position', [110, 5, 55, 25], ...
    'String', 'Execute', ...
    'TooltipString', ['Syringe pump responses will be displayed ', ...
    'in the Pump Communciations section'], ...
    'Callback', @executeCustomCommand);


%{
Initialize the GUI based on object properties. 
%}
properties2gui();

%{ 
Define the callback functions for the GUI controls.
%}
    function closeFigure(~,~)
        delete(obj.GuiFigure); % delete the GUI figure
    end

    function gui2properties()
        % Sets the object properties based on the GUI widgets.
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties.
        
        % Set the message text to the most recently known state of the
        % syringe pump.
        handles.PumpStatus.String = obj.ReadableStatus;
        handles.PumpActivity.String = obj.ReadableAction;

        % Provide a list of available COM ports if MATLAB version will
        % allow for it.
        if str2double(obj.MatlabRelease(1:4)) >= 2017
            % The version of MATLAB in use has the seriallist function,
            % place each serial port available in the PortList menu,
            % ensuring that obj.SerialPort is the first option shown.
            ListItems = unique([obj.SerialPort, seriallist], 'stable');
            handles.PortList.String = cellstr(ListItems); % convert to cell array
        else
            % The version of MATLAB in use does not have the seriallist
            % function, display the default port just for consistency.
            handles.PortList.String = obj.SerialPort; 
        end
        
        % Display the plunger velocity settings of the syringe pump.
        handles.VelocitySlope.String = obj.VelocitySlope; 
        handles.StartVelocity.String = obj.StartVelocity; 
        handles.TopVelocity.String = obj.TopVelocity; 
        handles.CutoffVelocity.String = obj.CutoffVelocity; 
        
        % Display the most recently known absolute plunger position.
        handles.CurrentPositionDisplay.String = obj.PlungerPosition; 
        handles.NewPositionAbsolute.String = obj.PlungerPosition;
        
        % Ensure changes are made as soon as possible.
        drawnow
    end

    function portListCallback(Source, ~)
        % Callback for the Port selection popup (dropdown) menu.
        
        % Set the serial port property based on the selection made in the
        % popup menu.
        ListItems = Source.String; % list of options given in popup menu
        
        % Set obj.SerialPort to the user selection.
        obj.SerialPort = ListItems{Source.Value};
    end

    function refreshStatus(~, ~)
        % Callback for the refresh status (query) button.
        
        % Query the syringe pump and update the GUI based on response.
        obj.querySyringePump(); 
        
        % Update GUI properties to reflect any changes to the syringe pump.
        properties2gui();
    end
    
    function connectSyringePump(~, ~)
        % Callback for the Connect Syringe Pump button.

        % Attempt to make a connection to the syringe pump.
        obj.connectSyringePump();

        % Update GUI properties to reflect any changes to the syringe pump.
        properties2gui();
    end

    function initializeSyringePump(~, ~)
        % Callback for the Re-initialize Syringe Pump button.

        % Attempt to re-initialize the syringe pump directly (without using
        % obj.executeCommand() method).
        fprintf(obj.SyringePump, ['/', num2str(obj.DeviceAddress), 'ZR']);
        obj.waitForReadyStatus();

        % Set default properties based on the (assumed) succesful 
        % initialization.
        obj.StartVelocity = 900; 
        obj.TopVelocity = 1400; 
        obj.CutoffVelocity = 900;
        obj.VelocitySlope = 14; 
        obj.PlungerPosition = 0;
        
        % Update GUI properties to reflect any changes to the syringe pump.
        properties2gui();
    end
    
    function setVelocitySlope(Source, ~)
        % Callback used to set the VelocitySlope property of the syringe
        % pump.
        
        % Retrieve the value entered by the user and ensure it is valid.
        ProposedSlope = str2double(Source.String);
        if (ProposedSlope >= 1) && (ProposedSlope <= 20)
            % Set syringe pump to new velocity slope.
            obj.executeCommand(['L', num2str(ProposedSlope)]);
            obj.waitForReadyStatus();
        else
            error('Velocity slope %g Hz is out of range (1-20 Hz/sec)', ...
                ProposedSlope); 
        end
        
        % Update GUI properties to refelct changes. 
        properties2gui();
    end

    function setStartVelocity(Source, ~)
        % Callback used to set the start velocity property of the syringe
        % pump.
        
        % Retrieve the value entered by the user and ensure it is valid. 
        ProposedStartVelocity = str2double(Source.String);
        if (ProposedStartVelocity <= 1000) && (ProposedStartVelocity >= 50)
            % User entered start velocity is in the valid range, attempt to
            % set the new start velocity.
            obj.executeCommand(['v', num2str(ProposedStartVelocity)]);
            obj.waitForReadyStatus();

            % Attempt to query the syringe pump for its start velocity
            % (instead of trusting that it was set properly).
            obj.StartVelocity = str2double(obj.reportCommand('?1'));
            obj.waitForReadyStatus();
            
            % If ProposedStartVelocity is >= than obj.TopVelocity,
            % warn the user the an error might occur (the Cavro XP3000
            % syringe pump manual is unclear about this, as p. 3-36 states
            % "...start velocity should always be less than the top 
            % velocity.", however the top velocity can be set as low as 5 
            % half-steps/second whereas the start velocity can only be set
            % as low as 50 half-steps/second). 
            if ProposedStartVelocity >= obj.TopVelocity
                warning(['Start Velocity >= Top Velocity may produce ', ...
                    'unexpected behavior.'])
            end
        else
            error('Start velocity %g Hz is out of range (50-1000 Hz)', ...
                ProposedStartVelocity)
        end
        
        % Update GUI properties to refelct changes. 
        properties2gui();
    end

    function setTopVelocity(Source, ~)
        % Callback used to set the top velocity property of the syringe
        % pump.
        
        % Retrieve the value entered by the user. 
        ProposedTopVelocity = str2double(Source.String);
        if (ProposedTopVelocity <= 5800) && (ProposedTopVelocity >= 5)
            % User entered top velocity is in the valid range, send the set
            % command.
            obj.executeCommand(['V', num2str(ProposedTopVelocity)]);
            obj.waitForReadyStatus();

            % Attempt to query the syringe pump for its top velocity
            % (instead of trusting that it was set properly).
            obj.TopVelocity = str2double(obj.reportCommand('?2'));
            obj.waitForReadyStatus();
            
            % If ProposedTopVelocity is <= obj.StartVelocity,
            % warn the user the an error might occur (the Cavro XP3000
            % syringe pump manual is unclear about this, as p. 3-36 states
            % "...start velocity should always be less than the top 
            % velocity.", however the top velocity can be set as low as 5 
            % half-steps/second whereas the start velocity can only be set
            % as low as 50 half-steps/second). 
            if ProposedTopVelocity <= obj.StartVelocity
                warning(['Top Velocity <= StartVelocity may produce ', ...
                    'unexpected behavior.'])
            end
        else
            error('Top velocity %g Hz is out of range (5-5800 Hz)', ...
                ProposedTopVelocity)
        end 
        
        % Update GUI properties to refelct changes. 
        properties2gui(); 
    end

    function setCutoffVelocity(Source, ~)
        % Callback used to set the cutoff velocity property of the syringe
        % pump.  DOESN'T SEEM TO BE WORKING! DS 7/5/18
        warning('Setting cutoff velocity not currently working');
        
        % Retrieve the value entered by the user. 
        ProposedCutoffVelocity = str2double(Source.String);
        if (ProposedCutoffVelocity <= 2700) ...
                && (ProposedCutoffVelocity >= 50)
            if ProposedCutoffVelocity < obj.TopVelocity
                % Set syringe pump to new cutoff velocity.
                obj.executeCommand(['c', num2str(ProposedCutoffVelocity)]);
                obj.waitForReadyStatus();

                % Attempt to query the syringe pump for its cutoff velocity
                % (instead of trusting that it was set properly).
                obj.CutoffVelocity = str2double(obj.reportCommand('?3'));
                obj.waitForReadyStatus();
            end
        else
            error('Cutoff velocity %g Hz out of range (50-2700 Hz)', ...
                ProposedCutoffVelocity)
        end
        
        % Update GUI properties to refelct changes. 
        properties2gui();
    end

    function movePlungerAbsolute(~, ~)
        % Callback for the Move Plunger to New Position pushbutton.
        
        % Ensure a valid position was entered, attempt to move the syringe.
        ProposedPosition = str2double(handles.NewPositionAbsolute.String); 
        if (ProposedPosition <= 3000) && (ProposedPosition >= 0)
            % A valid plunger position has been entered. 
            obj.executeCommand(['A', num2str(ProposedPosition)]);
            obj.waitForReadyStatus() 
        else
            error('Plunger position %g out of range (0-3000)', ...
                ProposedPosition)
        end
        
        % Attempt to query the syringe pump to report the plunger position
        % (instead of trusting that it went to the correct place). 
        ReportedPosition = obj.reportCommand('?'); % absolute position char
        obj.PlungerPosition = str2double(ReportedPosition);
        obj.waitForReadyStatus();
        
        % Update GUI to reflect any changes. 
        properties2gui();
    end

    function terminatePlungerMove(~, ~)
        % Callback for the Terminate Plunger Move pushbutton.
        
        % Attempt to terminate the plunger move directly (without using
        % obj.executeCommand() method).
        fprintf(obj.SyringePump, ['/', num2str(obj.DeviceAddress), 'TR']);
        obj.waitForReadyStatus();

        % Attempt to query the syringe pump to report the plunger position. 
        ReportedPosition = obj.reportCommand('?'); % absolute position char
        obj.PlungerPosition = str2double(ReportedPosition);
        obj.waitForReadyStatus();        
        
        % Update GUI to reflect any changes.
        properties2gui();
    end

    function valveControl(~, ~, ValvePosition)
        % Callback for the Move Valve to Input/Output Position buttons.
        
        % Determine which button was clicked, act accordingly.
        if ValvePosition 
            % ValvePosition==1 (True) is the Input position, send the
            % command to the syringe pump to switch valve to Input.
            obj.executeCommand('I');
            obj.waitForReadyStatus();
        else
            % ValvePosition==0 (False) is the Output position, send the
            % command to the syringe pump to switch valve to Output. 
            obj.executeCommand('O');
            obj.waitForReadyStatus();
        end
    end

    function executeCustomCommand(Source, ~)
        % Callback for the Custom Command Interface execute button.
        
        % Turn off the execute button to indicate something is happening.
        % NOTE: I'm doing this here because user entered Report commands
        % are executing too fast to allow for the PumpStatus textbox to
        % update, but too slow for the user to realize something is
        % happening...
        Source.Enable = 'off'; drawnow;
        
        % Grab the command the user has entered in the textbox.
        Command = handles.CustomCommand.String;
        
        % Attempt to execute the command.
        Datablock = obj.generalCommand(Command);
        obj.waitForReadyStatus();
        
        % Determine various plunger parameters to see if the user entered
        % command has changed them (this seems to be the simplest method
        % to ensure obj has accurate info, at the expense of additional
        % overhead). 
        obj.PlungerPosition = str2double(obj.reportCommand('?'));
        obj.StartVelocity = str2double(obj.reportCommand('?1'));
        obj.TopVelocity = str2double(obj.reportCommand('?2'));
        obj.CutoffVelocity = str2double(obj.reportCommand('?3'));
        obj.waitForReadyStatus();
        
        % If the syringe pump returned a Datablock, display the response in
        % the PumpActivity edit box.
        if ~isempty(Datablock)
            PaddedResponse = ...
                sprintf('Response to command %s was %s', ...
                Command, Datablock);
            obj.ReadableAction = PaddedResponse; 
        end
        
        % Update GUI to reflect any changes.
        properties2gui(); 
        
        % Turn on the execute button to indicate completion.
        Source.Enable = 'on'; drawnow;
    end

    
end