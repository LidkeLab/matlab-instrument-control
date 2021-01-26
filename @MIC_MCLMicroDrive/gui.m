function gui(obj, GUIParent)
%gui is the GUI method for the MIC_MCLMicroDrive class.
% This GUI has several elements which can be used to control a (single
% axis) Mad City Labs micro-drive stage.
%
% INPUTS:
%   GUIParent: The 'Parent' of this GUI, e.g., a figure handle.
%              (Default = figure(...))

% Created by:
%   David J. Schodt (Lidke lab, 2021)


% Create a figure handle for the GUI if needed.
if ~(exist('GUIParent', 'var') && ~isempty(GUIParent) ...
        && isgraphics(GUIParent))
    DefaultFigurePosition = get(0, 'defaultFigurePosition');
    GUIParent = figure('MenuBar', 'none', ...
        'Name', 'MCL micro-drive GUI', 'NumberTitle', 'off', ...
        'Units', 'pixels', ...
        'Position', DefaultFigurePosition .* [1, 1, 1, 1]);
end

% Add some basic positioning controls.
ButtonPos = [0, 0, 0.15, 0.15];
uicontrol(GUIParent, 'Style', 'pushbutton', ...
    'String', '-', 'FontUnits', 'normalized', 'FontSize', 1, ...
    'Units', 'normalized', ...
    'Position', ButtonPos, ...
    'Callback', {@moveSingleStepCallback, -1});
uicontrol(GUIParent, 'Style', 'pushbutton', ...
    'String', '+', 'FontUnits', 'normalized', 'FontSize', 1, ...
    'Units', 'normalized', ...
    'Position', ButtonPos + [0, ButtonPos(3), 0, 0], ...
    'Callback', {@moveSingleStepCallback, 1});

    function moveSingleStepCallback(~, ~, Direction)
        % Callback for the single step movement buttons.
        obj.moveSingleStep(Direction)
    end


end