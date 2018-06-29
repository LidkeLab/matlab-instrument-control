function guiFig = gui(obj)
%Graphical user interface for MIC_BiochemValve.

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
FigWidth = 150; 
FigHeight = 350; 
BottomLeftX = floor(ScreenSize(3)/2 - FigWidth/2); % ~centers the figure
BottomLeftY = floor(ScreenSize(4)/2 - FigHeight/2); % ~centers the figure
guiFig = figure('Position', ...
    [BottomLeftX, BottomLeftY, FigWidth, FigHeight], ...
    'MenuBar', 'none', 'ToolBar', 'none'); % figure handle
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

% Prevent closing after a 'close' or 'close all' command.
obj.GuiFigure.HandleVisibility = 'off';

% Pass control to closeFigure callback when closing the figure.
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%{ 
Create the GUI controls.
%}

% Create an emergency shutdown button that will attempt to cut both the 12V
% and 24V power lines.
EmergencyShutdown = uicontrol('Parent', guiFig, 'Style', 'pushbutton', ...
    'FontWeight', 'bold', 'Position', [0, 300, 150, 50], ...
    'BackgroundColor', 'r', 'Callback', @emergencyShutdown); 

% Create "power buttons" that will switch the 24V/12V lines on/off.
% NOTE: The valves are controlled by the 12V line, however the 12V is
% controlled by the 24V line (the 24V is tapped by a regulator that steps
% it down to 12V for the valves), thus both the 12V and 24V lines must be
% activated to operate the valves. 
PowerButton12V = uicontrol('Parent', guiFig, 'Style', 'pushbutton', ...
   'Position', [0, 225, 150, 50], 'BackgroundColor', 'g', ...
   'Callback', @powerSwitch12V);
PowerButton24V = uicontrol('Parent', guiFig, 'Style', 'pushbutton', ...
    'Position', [0, 175, 150, 50], 'BackgroundColor', 'g', ...
    'Callback', @powerSwitch24V);

% Create the controls for each of the six valves on the BIOCHEM flow
% selection device. 
Valve1Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 125, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 1});
Valve2Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 100, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 2});
Valve3Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 100, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 3});
Valve4Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 100, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 4});
Valve5Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 100, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 5});
Valve6Control = uicontrol('Parent', guiFig, 'Style', 'togglebutton', ...
    'Position', [0, 100, 150, 25], 'BackgroundColor', 'g', ...
    'Callback', {@valveControl, 6});
ValveControlHandles = {Valve1Control, Valve2Control, Valve3Control, ...
    Valve4Control, Valve5Control, Valve6Control}; % must be ordered!!!

%{
Initialize the GUI based on object properties. 
%}
properties2gui();

%{ 
Define the callback functions for the GUI controls.
%}
    function closeFigure(~,~)
        gui2properties(); % update object properties based on GUI
        delete(obj.GuiFigure); % delete the GUI figure
    end

    function gui2properties()
        % Sets the object properties based on the GUI widgets.
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties.
        
        % Set the 12V Power Switch background color: red ON, green OFF
        % (red was chosen for on to emphasize a live circuit!)
        if obj.PowerState12V % 12V line is active
            PowerButton12V.String = '12V Line Activated';
            PowerButton12V.BackgroundColor = 'r'; 
        else % 12V line is not active
            PowerButton12V.String = '12V Line Deactivated';
            PowerButton12V.BackgroundColor = 'g';
        end
        
        % Set the 24V Power Switch background color: red ON, green OFF
        % (red was chosen for on to emphasize a live circuit!)
        if obj.PowerState24V % 24V line is active
            PowerButton24V.String = '24V Line Activated';
            PowerButton24V.BackgroundColor = 'r'; 
        else % 24V line is not active
            PowerButton24V.String = '24V Line Deactivated';
            PowerButton24V.BackgroundColor = 'g';
        end
        
        % Set the valve control togglebuttons to the appropriate state.
        for ii = 1:numel(ValveControlHandles)
            % Determine the appropriate state. 
            if obj.ValveState(ii) % the ii-th valve is open
                % The ii-th valve is open. 
                ValveControlHandles{ii}.Value = ...
                    ValveControlHandles{ii}.Max; % depress the button
                ValveControlHandles{ii}.BackgroundColor = 'r'; 
                ValveControlHandles{ii}.String = ...
                    sprintf('Valve %i OPEN', ii);
            else
                % The ii-th valve is closed.
                ValveControlHandles{ii}.Value = ...
                    ValveControlHandles{ii}.Min; % un-toggle button
                ValveControlHandles{ii}.BackgroundColor = 'g'; 
                ValveControlHandles{ii}.String = ...
                    sprintf('Valve %i CLOSED', ii);
            end
        end
    end
    
    function powerSwitch12V(~, ~)
        % Callback for the 12V button used to switch the 12V line on/off. 
        % NOTE: The 12V line powers the valves, however the 12V line itself
        % is powered by the 24V line. 
        
        % Switch the 12V line control relay.
        obj.powerSwitch12V()
        
        % Update the GUI to reflect the changes in the power.
        properties2gui();
    end

    function powerSwitch24V(~, ~)
        % Callback for the 24V button used to switch the 24V line on/off. 
        % NOTE: The 24V line controls both the Cavro syringe pump and the
        % BIOCHEM flow selection valves. 
        
        % Switch the 24V line control relay.
        obj.powerSwitch24V()
        
        % Update the GUI to reflect the changes in the power.
        properties2gui();
    end
    
    function emergencyShutdown(~, ~)
        % Callback for an emergency shutdown button, which will attempt to
        % cut both the 24V and 12V lines.
        % NOTE: The 12V line is actually controlled by the 24V line but I
        %       figured it's best to try and cut it anyways.
        
        % Attempt to switch off the 24V line (which is active LOW).
        PowerPin24V = sprintf('D%i', obj.IN1Pin); 
        writeDigitalPin(obj.Arduino, PowerPin24V, 1);
        
        % Attempt to switch off the 12V line (which is active LOW).
        PowerPin12V = sprintf('D%i', obj.IN1Pin+1);
        writeDigitalPin(obj.Arduino, PowerPin12V, 1);
        
        % Ensure the valve control relays receive a HIGH (valve closed)
        % signal so that when powered back on, the valves are closed.
        for ii = 1:6
            obj.closeValve(ii); 
        end
            
        % Update the object properties to reflect our switches.
        obj.PowerState24V = 0; 
        obj.PowerState12V = 0; 
        
        % Update the GUI to reflect the above changes.
        properties2gui();
    end

    function valveControl(Source, ~, ValveNumber)
        % Open/close valve ValveNumber based on state of a togglebutton.
        ButtonState = Source.Value; % state of toggle button
        if ButtonState == Source.Max % togglebutton depressed
            % Update the text on the button to state the valve is open.
            Source.String = sprintf('Valve %i OPEN', ValveNumber); 

            % Set background color to red to emphasize valve is active!
            Source.BackgroundColor = 'r'; 
            
            % Send the command to open the valve.
            obj.openValve(ValveNumber)
        else
            % Update the text on the button to state the valve is closed.
            Source.String = sprintf('Valve %i CLOSED', ValveNumber);

            % Set background color back to green to emphasize closure.
            Source.BackgroundColor = 'g'; 
            
            % Send the command to close the valve.
            obj.closeValve(ValveNumber)
        end
    end

end