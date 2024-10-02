function guiFig = gui(obj)
%gui Graphical User Interface to mic.DynamixelServo
%   GUI has functionality to change position and set rotation speed. Also
%   it lets you turn the LED on and off

%   Marjolein Meddens, Lidke Lab 2017


%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 100 450 350]);

handles.output = guiFig;
guidata(guiFig,handles);
minRotation = 0;
maxRotation = obj.MAX_ROTATION;
textOutlineLeft = 35;

% LED
ledVertPos = 300;
handles.ledText = uicontrol('Parent',guiFig,'Style','text','String',...
    'LED on/off','Position',[textOutlineLeft ledVertPos 150 25],...
    'HorizontalAlignment', 'left','Fontsize',12);
handles.ledToggleButton = uicontrol('Parent',guiFig,'Style','togglebutton',...
    'Position',[textOutlineLeft+150 ledVertPos 100 25],...
    'Value',obj.Led,'Callback',@toggleLED);

% current position
curPosVertPos = 240;
curPosString = sprintf('%.3f deg',obj.Rotation);
handles.curPosText = uicontrol('Parent',guiFig,'Style','text','String',...
    'Current position','Position',[textOutlineLeft curPosVertPos 150 25],...
    'HorizontalAlignment', 'left','Fontsize',12);
handles.curPosValue = uicontrol('Parent',guiFig,'Style','text','String',...
    curPosString,'Position',[textOutlineLeft+150 curPosVertPos 100 25],...
    'HorizontalAlignment', 'center','Fontsize',12,'BackgroundColor',[0.94 0.94 0.5]);
handles.curMovValue = uicontrol('Parent',guiFig,'Style','text','String',...
    'at set position','Position',[textOutlineLeft+300 curPosVertPos 100 25],...
    'HorizontalAlignment', 'center','Fontsize',12,'BackgroundColor',[0 1 0]);

% position slider
slidVertPos = 90;
minRotStr = sprintf('%i deg',minRotation);
maxRotStr = sprintf('%i deg',maxRotation);
handles.sliderTitle=uicontrol('Parent',guiFig,'Style','text','String',...
    'Rotational position','Position',[textOutlineLeft slidVertPos+40 150 30],...
    'HorizontalAlignment', 'left','Fontsize',12);
handles.rotationSlider=uicontrol('Parent',guiFig,'Style','slider','Min',minRotation,...
    'Max',maxRotation,'Value',minRotation,...
    'Position', [118 slidVertPos 200 35],'Callback',@rotationSlider);
handles.textMinRotation = uicontrol('Style','text','String',minRotStr,...
    'Position',[textOutlineLeft slidVertPos+10 80 20],'FontSize',10);
handles.textMaxRotation = uicontrol('Style','text','String',maxRotStr,...
    'Position',[325 slidVertPos+10,80,20],'FontSize',10);

% edit position
setVertPos = 190;
handles.editPosition = uicontrol('Style','edit','String',num2str(0),...
    'Position',[170,setVertPos,100,25],'FontSize',10);
handles.textEditPosition = uicontrol('Style','text','String','Set Position',...
    'Position',[textOutlineLeft setVertPos,100,25],'FontSize',12,...
    'HorizontalAlignment', 'left');
handles.goToPosition = uicontrol('Style','pushbutton','String', 'GO',...
    'FontSize',12,'Position', [300 setVertPos 50 25],...
    'Callback', @goToPos);

% set moving speed
movVertPos = 20;
minSpeedStr = sprintf('%i',obj.minSpeed);
maxSpeedStr = sprintf('%i',obj.maxSpeed);
handles.textMove=uicontrol('Parent',guiFig,'Style','text','String',...
    'Moving speed','Position',[textOutlineLeft movVertPos+30 150 30],...
    'HorizontalAlignment', 'left','Fontsize',12);
handles.speedSlider=uicontrol('Parent',guiFig,'Style','slider','Min',obj.minSpeed,...
    'Max',obj.maxSpeed,'Value',obj.maxSpeed,'SliderStep',[0.001 0.1],...
    'Position', [118 movVertPos 200 35],'Callback',@speedSlider);
handles.textMinSpeed = uicontrol('Style','text','String',minSpeedStr,...
    'Position',[textOutlineLeft movVertPos+10 80 20],'FontSize',10);
handles.textMaxSpeed= uicontrol('Style','text','String',maxSpeedStr,...
    'Position',[325 movVertPos+10,80,20],'FontSize',10);

% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = [obj.InstrumentName ' Id:' num2str(obj.Id)];
obj.GuiFigure.NumberTitle = 'off';

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%Initialize GUI properties
properties2gui();

%% functions

    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigure);
    end

    function gui2properties()
        % Sets the object properties based on the GUI widgets
        obj.Rotation = str2double(handles.editPosition.String);
        obj.MovingSpeed = handles.speedSlider.Value;
        obj.Led = handles.ledToggleButton.Value;
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties
        handles.curPosValue.String = sprintf('%.3f deg',obj.Rotation);
        handles.rotationSlider.Value = obj.Rotation;
        handles.editPosition.String = num2str(obj.Rotation);
        handles.speedSlider.Value = obj.MovingSpeed;
        handles.ledToggleButton.Value = obj.Led;
        if handles.ledToggleButton.Value
            handles.ledToggleButton.String = 'ON';
            handles.ledToggleButton.BackgroundColor = [1 0 0];
        else
            handles.ledToggleButton.String = 'OFF';
            handles.ledToggleButton.BackgroundColor = [0.94 0.94 0.94];
        end
    end

    function toggleLED(~,~)
        if handles.ledToggleButton.Value
            handles.ledToggleButton.String = 'ON';
            handles.ledToggleButton.BackgroundColor = [1 0 0];
        else
            handles.ledToggleButton.String = 'OFF';
            handles.ledToggleButton.BackgroundColor = [0.94 0.94 0.94];
        end
        gui2properties()
    end

    function rotationSlider(~,~)
        obj.Rotation = handles.rotationSlider.Value;
        while obj.Moving
            handles.curMovValue.String = 'moving';
            handles.curMovValue.BackgroundColor = [1 0 0];
            drawnow;
        end
        handles.curMovValue.String = 'at set position';
        handles.curMovValue.BackgroundColor = [0 1 0];
        properties2gui();
    end

    function goToPos(~,~)
        obj.Rotation = str2double(handles.editPosition.String);
        while obj.Moving
            handles.curMovValue.String = 'moving';
            handles.curMovValue.BackgroundColor = [1 0 0];
            drawnow;
        end
        handles.curMovValue.String = 'at set position';
        handles.curMovValue.BackgroundColor = [0 1 0];
        properties2gui();
    end

    function speedSlider(~,~)
        obj.MovingSpeed = handles.speedSlider.Value;
        properties2gui();
    end

end
