function GuiFig = guiPiezoReconnection(obj)
% This method creates a small GUI to show piezo stage reconnection buttons.

% Define reference parameters for the GUI dimensions.
ScreenSize = get(groot, 'ScreenSize'); % size of displaying screen
XSize = 200; % width of figure
YSize = 200;
BottomLeftX = floor(ScreenSize(3)/2 - XSize/2); % ~centers figure on screen
BottomLeftY = floor(ScreenSize(4)/2 - YSize/2);

% Create the GUI figure.
GuiFig = figure('Units', 'pixels', ...
    'Position', [BottomLeftX, BottomLeftY, XSize, YSize], ...
    'MenuBar', 'none', 'ToolBar', 'none', 'Visible', 'on', ...
    'NumberTitle', 'off', 'name', 'Piezo Reconnection GUI');
GuiFig.Color = get(0, 'defaultUicontrolBackgroundColor');

% Add buttons that will reconnect specific piezo stage axes.
ReconnectXPiezo = uicontrol('Parent', GuiFig, 'Style', 'PushButton', ...
    'String', 'Reconnect X Piezo', ...
    'Position', [XSize/2 - 150/2, YSize - 50, 150, 25], ...
    'FontSize', 12, 'Callback', {@reconnectPiezo, 'X'});
ReconnectYPiezo = uicontrol('Parent', GuiFig, 'Style', 'PushButton', ...
    'String', 'Reconnect Y Piezo', ...
    'Position', [XSize/2 - 150/2, YSize - 100, 150, 25], ...
    'FontSize', 12, 'Callback', {@reconnectPiezo, 'Y'});
ReconnectZPiezo = uicontrol('Parent', GuiFig, 'Style', 'PushButton', ...
    'String', 'Reconnect Z Piezo', ...
    'Position', [XSize/2 - 150/2, YSize - 150, 150, 25], ...
    'FontSize', 12, 'Callback', {@reconnectPiezo, 'Z'});

    function reconnectPiezo(Source, ~, Axis)
        % This is a callback function for the clicking of reconnection
        % buttons for the stage piezos.  The input Axis can be 'X', 'Y', or
        % or 'Z' (case sensitive), specifying which piezo axis is to be 
        % reconnected.
        
        % Turn off the button and change it's string to indicate the
        % reconnection is being attempted. 
        OldButtonString = Source.String;
        Source.Enable = 'off';
        Source.String = 'Reconnecting...';
        
        % Delete the current instance of the piezo class for the specified
        % axis.
        PiezoObjectString = sprintf('StagePiezo%c', Axis);
        obj.StagePiezo.(PiezoObjectString).delete();
        
        % Attempt to reconnect the piezo axis which was specified. 
        SerialNumNameString = sprintf('%cPiezoSerialNums', Axis);
        SerialNumCell = obj.(SerialNumNameString); % cell array, serial num
        obj.StagePiezo.(PiezoObjectString) = MIC_TCubePiezo(...
            SerialNumCell{1}, SerialNumCell{2}, Axis);
        
        % Re-enable the button and reset its string to the previous value.
        Source.Enable = 'on';
        Source.String = OldButtonString;
    end

end