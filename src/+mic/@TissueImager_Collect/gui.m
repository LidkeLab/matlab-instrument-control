function gui(obj)

    % Create the main figure
    fig = uifigure('Name', 'Microscope GUI', 'Position', [100, 100, 900, 700]);
    obj.GuiFigure = fig;

    % ==== Save Directory Section ====

    uilabel(fig, 'Position', [20 650 100 22], 'Text', 'Save Directory:');
    saveDirField = uieditfield(fig, 'text', 'Position', [130 650 300 22], ...
        'Value', obj.SaveDir, ...
        'ValueChangedFcn', @(src,~) set(obj, 'SaveDir', src.Value));

    uilabel(fig, 'Position', [20 620 100 22], 'Text', 'Base Filename:');
    baseNameField = uieditfield(fig, 'text', 'Position', [130 620 300 22], ...
        'Value', obj.BaseFileName, ...
        'ValueChangedFcn', @(src,~) set(obj, 'BaseFileName', src.Value));

    uilabel(fig, 'Position', [20 590 100 22], 'Text', 'File Type:');
    fileTypeDropdown = uidropdown(fig, ...
        'Position', [130 590 100 22], ...
        'Items', {'.mat', '.h5'}, ...
        'Value', ['.' obj.SaveFileType], ...
        'ValueChangedFcn', @(src,~) set(obj, 'SaveFileType', src.Value(2:end)));

    % ==== Light Source Section ====
    uilabel(fig, 'Text', 'LEDs', 'Position', [150 540 100 22]);

    uilabel(fig, 'Text', 'On During Focus:', 'Position', [20 510 100 22]);
    focusCheckbox = uicheckbox(fig, 'Position', [150 510 22 22], ...
        'Value', true);

    uilabel(fig, 'Text', 'Focus Power:', 'Position', [20 480 100 22]);
    focusPowerField = uieditfield(fig, 'numeric', 'Position', [150 480 60 22], 'Value', 20);

    uilabel(fig, 'Text', 'Acquisition Power:', 'Position', [20 450 120 22]);
    uieditfield(fig, 'numeric', 'Position', [150 450 60 22]);

    % ==== Focus: Thorcam ====
    panel1 = uipanel(fig, 'Title', 'Focus: Thorcam', 'Position', [20 280 400 160]);

    uilabel(panel1, 'Text', 'Camera ROI:', 'Position', [10 100 100 22]);
    uieditfield(panel1, 'text', 'Position', [100 100 250 22]);

    uilabel(panel1, 'Text', 'Exp Time Focus:', 'Position', [10 70 100 22]);
    uieditfield(panel1, 'numeric', 'Position', [100 70 100 22]);

    uilabel(panel1, 'Text', 'Center Wavelength Focus:', 'Position', [10 40 130 22]);
    uieditfield(panel1, 'numeric', 'Position', [150 40 60 22]);

    uilabel(panel1, 'Text', 'Isosbestic Wavelengths: 529,545,570,584', ...
    'Position', [220 40 170 22], 'FontSize', 10);

    uibutton(panel1, ...
        'Text', 'Focus Thorcam', ...
        'Position', [140 5 100 30], ...
        'BackgroundColor', [1 1 0.5], ...
        'ButtonPushedFcn', @(btn, event) ...
            collectObj.focusThorcam(focusCheckbox.Value, focusPowerField.Value));




    % ==== Focus: IR Cam ====
    panel2 = uipanel(fig, 'Title', 'Focus: IR Cam', 'Position', [440 280 400 160]);

    uilabel(panel2, 'Text', 'Camera ROI:', 'Position', [10 100 100 22]);
    uieditfield(panel2, 'text', 'Position', [100 100 250 22]);

    uilabel(panel2, 'Text', 'Exp Time Focus:', 'Position', [10 70 100 22]);
    uieditfield(panel2, 'numeric', 'Position', [100 70 100 22]);

    uilabel(panel2, 'Text', 'Focus Wavelength:', 'Position', [10 40 120 22]);
    uicheckbox(panel2, 'Text', '698/70', 'Position', [130 40 80 22]);
    uicheckbox(panel2, 'Text', '835/70', 'Position', [220 40 80 22]);

    uibutton(panel2, ...
        'Text', 'Focus IR', ...
        'Position', [150 5 80 30], ...
        'BackgroundColor', [1 1 0.5], ...
        'ButtonPushedFcn', @(btn,event)disp('Focus IR pressed'));


    % ==== Data Collection: Thorcam ====
    panel3 = uipanel(fig, 'Title', 'Data Collection: Thorcam', 'Position', [20 160 400 120]);
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

    uicheckbox(panel4, 'Text', 'Match Acquisition time with Thorcam:', ...
        'Position', [10 10 300 22]);

    % ==== Isosbestic Scan Button ====
    uibutton(fig, 'Text', 'Isosbestic Scan', ...
        'Position', [350 50 200 50], ...
        'BackgroundColor', [0 1 0], ...
        'ButtonPushedFcn', @(btn,event)disp('Isosbestic Scan pressed'));
end
