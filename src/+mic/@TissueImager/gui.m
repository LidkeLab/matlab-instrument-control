function gui(obj)

    % Create the main figure
    fig = uifigure('Name', 'Microscope GUI', 'Position', [100, 100, 900, 700]);
    obj.GuiFigure = fig;

    % ==== Save Directory Section ====
    uilabel(fig, 'Position', [20 650 100 22], 'Text', 'Save Directory::');
    uieditfield(fig, 'text', 'Position', [130 650 300 22]);

    uilabel(fig, 'Position', [20 620 100 22], 'Text', 'Base Filename:');
    uieditfield(fig, 'text', 'Position', [130 620 300 22]);

    uilabel(fig, 'Position', [20 590 100 22], 'Text', 'File Type:');
    uieditfield(fig, 'text', 'Position', [130 590 300 22]);

    % ==== Light Source Section ====
    uilabel(fig, 'Text', 'White Light', 'Position', [130 540 100 22]);
    uilabel(fig, 'Text', '680 Light', 'Position', [290 540 100 22]);
    uilabel(fig, 'Text', '850 Light', 'Position', [450 540 100 22]);

    uilabel(fig, 'Text', 'On During Focus:', 'Position', [20 510 100 22]);
    uicheckbox(fig, 'Position', [150 510 22 22]);
    uicheckbox(fig, 'Position', [310 510 22 22]);
    uicheckbox(fig, 'Position', [470 510 22 22]);

    uilabel(fig, 'Text', 'Focus Power:', 'Position', [20 480 100 22]);
    uieditfield(fig, 'numeric', 'Position', [150 480 60 22]);
    uieditfield(fig, 'numeric', 'Position', [310 480 60 22]);
    uieditfield(fig, 'numeric', 'Position', [470 480 60 22]);

    uilabel(fig, 'Text', 'Acquisition Power:', 'Position', [20 450 120 22]);
    uieditfield(fig, 'numeric', 'Position', [150 450 60 22]);
    uieditfield(fig, 'numeric', 'Position', [310 450 60 22]);
    uieditfield(fig, 'numeric', 'Position', [470 450 60 22]);

    % ==== Focus: Thorlcam ====
    panel1 = uipanel(fig, 'Title', 'Focus: Thorlcam', 'Position', [20 310 400 120]);
    uilabel(panel1, 'Text', 'Camera ROI:', 'Position', [10 70 100 22]);
    uieditfield(panel1, 'text', 'Position', [100 70 250 22]);

    uilabel(panel1, 'Text', 'Exp Time Focus:', 'Position', [10 40 100 22]);
    uieditfield(panel1, 'numeric', 'Position', [100 40 100 22]);

    uilabel(panel1, 'Text', 'Center Wavelength Focus:', 'Position', [10 10 130 22]);
    uieditfield(panel1, 'numeric', 'Position', [150 10 60 22]);
    uilabel(panel1, 'Text', 'Isosbestic Wavelengths: 529,545,570,584', ...
        'Position', [220 10 170 22], 'FontSize', 10);

    uibutton(panel1, 'Text', 'Focus Thorlcam', ...
        'Position', [270 40 100 40], 'ButtonPushedFcn', @(btn,event)disp('Focus Thorlcam pressed'));

    % ==== Focus: IR Cam ====
    panel2 = uipanel(fig, 'Title', 'Focus: IR Cam', 'Position', [440 310 400 120]);
    uilabel(panel2, 'Text', 'Camera ROI:', 'Position', [10 70 100 22]);
    uieditfield(panel2, 'text', 'Position', [100 70 250 22]);

    uilabel(panel2, 'Text', 'Exp Time Focus:', 'Position', [10 40 100 22]);
    uieditfield(panel2, 'numeric', 'Position', [100 40 100 22]);

    uilabel(panel2, 'Text', 'Focus Wavelength:', 'Position', [10 10 120 22]);
    uicheckbox(panel2, 'Text', '698/70', 'Position', [130 10 80 22]);
    uicheckbox(panel2, 'Text', '835/70', 'Position', [220 10 80 22]);

    uibutton(panel2, 'Text', 'Focus IR', ...
        'Position', [310 30 80 40], 'ButtonPushedFcn', @(btn,event)disp('Focus IR pressed'));

    % ==== Data Collection: Thorlcam ====
    panel3 = uipanel(fig, 'Title', 'Data Collection: Thorlcam', 'Position', [20 160 400 120]);
    uilabel(panel3, 'Text', 'Exp Time:', 'Position', [10 70 80 22]);
    uieditfield(panel3, 'numeric', 'Position', [90 70 80 22]);

    uilabel(panel3, 'Text', 'Time per Sequence:', 'Position', [180 70 120 22]);
    uieditfield(panel3, 'numeric', 'Position', [310 70 60 22]);

    uilabel(panel3, 'Text', '# Sequences per Wavelength:', 'Position', [10 40 180 22]);
    uieditfield(panel3, 'numeric', 'Position', [200 40 60 22]);

    uilabel(panel3, 'Text', 'Time for Full Scan: 1 min', 'Position', [10 10 200 22]);

    % ==== Data Collection: IR Cam ====
    panel4 = uipanel(fig, 'Title', 'Data Collection: IR Cam', 'Position', [440 160 400 120]);
    uilabel(panel4, 'Text', 'Exp Time:', 'Position', [10 70 80 22]);
    uieditfield(panel4, 'numeric', 'Position', [90 70 80 22]);

    uilabel(panel4, 'Text', 'Time per Sequence:', 'Position', [180 70 120 22]);
    uieditfield(panel4, 'numeric', 'Position', [310 70 60 22]);

    uilabel(panel4, 'Text', '# Sequences per Wavelength:', 'Position', [10 40 180 22]);
    uieditfield(panel4, 'numeric', 'Position', [200 40 60 22]);

    uicheckbox(panel4, 'Text', 'Match Acquisition time with Thorlcam:', ...
        'Position', [10 10 300 22]);

    % ==== Isosbestic Scan Button ====
    uibutton(fig, 'Text', 'Isosbestic Scan', ...
        'Position', [350 50 200 50], ...
        'BackgroundColor', [0 1 0], ...
        'ButtonPushedFcn', @(btn,event)disp('Isosbestic Scan pressed'));
end
