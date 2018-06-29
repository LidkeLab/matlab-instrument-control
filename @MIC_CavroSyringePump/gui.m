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
FigWidth = 600; 
FigHeight = 400; 
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

% Create a textbox to display the status of the syringe pump.
StatusText = uicontrol('Parent', guiFig, 'Style', 'edit', ...
    'Position', [0, 0, FigWidth, 25], 'Tag', 'StatusText');

% Create a popupmenu to allow for selection of the COM port the syringe pump
% is connected to. 
PortList = uicontrol('Parent', guiFig, 'Style', 'popupmenu', ...
    'Position', [0, 325, 150, 50], 'Callback', @portListCallback);

% Create a Connect Syringe Pump button to make a serial connection with the
% pump.
ConnectButton = uicontrol('Parent', guiFig, 'Style', 'pushbutton', ...
    'String', 'Connect Syringe Pump', 'Position', [0, 300, 150, 50], ...
    'Callback', @connectSyringePump);

% Create a pushbutton to query the syringe pump and return the answer.



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
        
        % Set the message text to the most recently known state of the
        % syringe pump.
        StatusText.String = obj.ReadableStatus;

        % Provide a list of available COM ports if MATLAB version will
        % allow for it.
        if str2double(obj.MatlabRelease(1:4)) >= 2017
            % The version of MATLAB in use has the seriallist function,
            % place each serial port available in the PortList menu,
            % ensuring that obj.SerialPort is the first option shown.
            ListItems = unique([obj.SerialPort, seriallist], 'stable');
            PortList.String = cellstr(ListItems); % convert to cell array
        else
            % The version of MATLAB in use does not have the seriallist
            % function, display the default port just for consistency.
            PortList.String = obj.SerialPort; 
        end
    end

    function portListCallback(Source, ~)
        % Callback for the Port selection popup (dropdown) menu.
        
        % Set the serial port property based on the selection made in the
        % popup menu.
        ListItems = Source.String; % list of options given in popup menu
        
        % Set obj.SerialPort to the user selection.
        obj.SerialPort = ListItems{Source.Value};
    end

    function connectSyringePump(~, ~)
        % Callback for the Connect Syringe Pump button.
        
        % Attempt to make a connection to the syringe pump.
        obj.connectSyringePump();
        
        % Update GUI properties to reflect any changes to the syringe pump.
        properties2gui();
    end
end