function gui(obj)
% GUI SRcollect Gui for RB microscope
%   Detailed explanation goes here

if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end
%%
xsz=400;
ysz=1008;
xst=17;
yst=42;
pw=.95;
psep=.01;
staticst=10;
editst=110;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'RB_SRcollect.gui','HandleVisibility','off','name',...
    'SRcollect.gui','CloseRequestFcn',@FigureClose);
obj.GuiFigure = guiFig;

% update gui when window is selected
%guiFig.WindowButtonDownFcn = @properties2gui;

% mouse over TL slider wheel control
guiFig.WindowScrollWheelFcn = @wheel;

refh=1;

% File Panel
ph=0.095;
php = ph*ysz;
hFilePanel = uipanel('Parent',guiFig,'Title','FILE',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String',...
    'Save Directory:','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_FileDirectory = uicontrol('Parent',hFilePanel,...
    'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',...
    [1 1 1],'Position', [editst php-40 250 20]);
uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String',...
    'Base FileName:','Enable','off','Position', [staticst php-65 100 20]);
handles.Edit_FileName = uicontrol('Parent',hFilePanel, 'Style', 'edit',...
    'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst php-65 250 20]);
uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','File type:',...
    'Enable','off','Position', [staticst php-90 100 20]);
handles.saveFileType = uicontrol('Parent',hFilePanel, 'Style',...
    'popupmenu', 'String',{'h5','mat'},'Enable','on','BackgroundColor',...
    [1 1 1],'Position', [editst php-90 250 20]);

% Camera Panel
ph=0.095;
php = ph*ysz;
hCameraPanel = uipanel('Parent',guiFig,'Title','CAMERA',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera ROI:',...
    'Enable','off','Position', [staticst php-40 100 20]);
ROIlist={'center 128','center 256','center 512','center 1024','full'};
handles.Popup_CameraROI = uicontrol('Parent',hCameraPanel, 'Style',...
    'popupmenu', 'String',ROIlist,'Enable','on','BackgroundColor',...
    [1 1 1],'Position', [editst php-40 80 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Display zoom:',...
    'Enable','off','Position', [staticst+200 php-40 100 20]);
handles.Popup_CameraDispZoom = uicontrol('Parent',hCameraPanel, 'Style',...
    'popupmenu','String',{'50%','100%','200%','400%','1000%'},'Value',4,...
    'Enable','on','BackgroundColor',[1 1 1],'Position',...
    [editst+200 php-40 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String',...
    'Exp. Time:','Enable','off','Position', [staticst php-65 100 20]);
handles.Edit_CameraExpTime = uicontrol('Parent',hCameraPanel,...
    'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',...
    [1 1 1],'Position', [editst php-65 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Num Frames:',...
    'Enable','off','Position', [staticst+200 php-65 100 20]);
handles.Edit_CameraNumFrames = uicontrol('Parent',hCameraPanel, 'Style', ...
    'edit', 'String','2000','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst+200 php-65 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Read out:',...
    'Enable','off','Position', [staticst php-90 100 20]);
handles.Edit_CameraReadOut = uicontrol('Parent',hCameraPanel, 'Style', ...
    'popupmenu', 'String',{'Slow','Fast'},'BackgroundColor',[1 1 1],...
    'Position', [editst php-90 80 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Defect correction:',...
    'Enable','off','Position', [staticst+200 php-90 100 20]);
handles.Edit_CameraDefCor = uicontrol('Parent',hCameraPanel, 'Style', ...
    'popupmenu', 'String',{'OFF','ON'},'BackgroundColor',[1 1 1],...
    'Position', [editst+200 php-90 50 20]);

% Registration Panel
ph=0.12;
php = ph*ysz;
hRegPanel = uipanel('Parent',guiFig,'Title','REGISTRATION','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hRegPanel, 'Style', 'edit', 'String','Exp. Time Reg.:','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_RegExpTime = uicontrol('Parent',hRegPanel, 'Style', 'edit', ...
    'String','0.01','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst php-40 50 20]);
handles.Button_RegLoadRef=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton',...
    'String','Load Reference','Enable','on',...
    'Position', [staticst php-70 100 20],'Callback',@LoadRef);
handles.Edit_RegFileName = uicontrol('Parent',hRegPanel, 'Style', 'edit', ...
    'String','File Name','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst php-70 250 20]);
handles.Button_RegAlign=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton',...
    'String','Align','Enable','on','Position', ...
    [staticst php-100 80 20],'Callback',@Align);
handles.Button_RegShowRef=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', ...
    'String','Show Reference','Enable','on','Position', ...
    [staticst+80 php-100 100 20],'Callback',@ShowRef);
handles.Button_RegTakeCurrent=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton',...
    'String','Take Current','Enable','on','Position', ...
    [staticst+180 php-40 90 20],'Callback',@TakeCurrent);
handles.Button_RegCenterStage=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', ...
    'String','Center Stage','Enable','on','Position', ...
    [staticst+270 php-40 90 20],'Callback',@CenterStage);
handles.Button_RegTakeReference=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton',...
    'String','Take Reference','Enable','on','Position', ...
    [staticst+180 php-100 90 20],'Callback',@TakeReference);
handles.Button_RegSaveReference=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', ...
    'String','Save Reference','Enable','on','Position', ...
    [staticst+270 php-100 90 20],'Callback',@SaveReference);


% LIGHTSOURCE Panel
ph=0.21;
hLampPanel = uipanel('Parent',guiFig,'Title','LIGHT SOURCE',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;
uicontrol(hLampPanel,'Style','text','String','On during Focus',...
    'Position',[-3 160,60,25]);
uicontrol(hLampPanel,'Style','text','String','On during Acquisition',...
    'Position',[-3 120,60,28]);
uicontrol(hLampPanel,'Style','text','String','Low Power',...
    'Position',[0 80,60,25]);
uicontrol(hLampPanel,'Style','text','String','High Power',...
    'Position',[0 50,60,25]);
uicontrol(hLampPanel,'Style','text','String','[MinPower,MaxPower]',...
    'Position',[-1 5,60,35]);

h405Panel=uipanel(hLampPanel,'Title','405 nm','Position',[1/6 1/5 1/6 4/5]);
handles.Focus405 = uicontrol(h405Panel,'Style','checkbox',...
                'Value',0,'Position',[23 120 130 20]);
handles.Acquisition405 = uicontrol(h405Panel,'Style','checkbox',...
                'Value',0,'Position',[23 90 130 20]);
handles.LP405 = uicontrol(h405Panel,'Style','edit',...
                'Position',[15 45 30 20],'Callback',@setLaser405Low);
handles.HP405 = uicontrol(h405Panel,'Style','edit',...
                'Position',[15 15 30 20]);
powerString405 = sprintf('[%g, %g] (%s)',obj.Laser405.MinPower,...
    obj.Laser405.MaxPower, obj.Laser405.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString405,...
    'Position',[64, 5,60,35]);

h488Panel=uipanel(hLampPanel,'Title','488 nm','Position',[2/6 1/5 1/6 4/5]);
handles.Focus488 = uicontrol(h488Panel,'Style','checkbox',...
                'Value',0,'Position',[23 120 130 20]);
handles.Acquisition488 = uicontrol(h488Panel,'Style','checkbox',...
                'Value',0,'Position',[23 90 130 20]);
handles.LP488 = uicontrol(h488Panel,'Style','edit',...
                'Position',[15 45 30 20],'Callback',@setLaser488Low);
handles.HP488 = uicontrol(h488Panel,'Style','edit',...
                'Position',[15 15 30 20]);
powerString488 = sprintf('[%g, %g] (%s)',obj.Laser488.MinPower,...
    obj.Laser488.MaxPower, obj.Laser488.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString488,...
    'Position',[125 5,60,35]);

h561Panel=uipanel(hLampPanel,'Title','561 nm','Position',[3/6 1/5 1/6 4/5]);
handles.Focus561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[23 120 130 20]);
handles.Acquisition561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[23 90 130 20]);
uicontrol(h561Panel,'Style','text','String','Set power manually',...
                'Position',[5 20 50 40]);
powerString561 = sprintf('[%g, %g] (%s)',obj.Laser561.MinPower,...
    obj.Laser561.MaxPower, obj.Laser561.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString561,...
    'Position',[190 5,60,35]);

h642Panel=uipanel(hLampPanel,'Title','642 nm','Position',[4/6 1/5 1/6 4/5]);
handles.Focus642 = uicontrol(h642Panel,'Style','checkbox',...
                'Value',0,'Position',[23 120 130 20]);
handles.Acquisition642 = uicontrol(h642Panel,'Style','checkbox',...
                'Value',0,'Position',[23 90 130 20]);
handles.LP642 = uicontrol(h642Panel,'Style','edit',...
                'Position',[15 45 30 20],'Callback',@setLaser642Low);
handles.HP642 = uicontrol(h642Panel,'Style','edit',...
                'Position',[15 15 30 20]);
powerString642 = sprintf('[%g, %g] (%s)',obj.Laser642.MinPower,...
    obj.Laser642.MaxPower, obj.Laser642.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString642,...
    'Position',[250 5,60,35]);

hLEDPanel=uipanel(hLampPanel,'Title','Lamp','Position',[5/6 1/5 1/6 4/5]);
handles.FocusLED = uicontrol(hLEDPanel,'Style','checkbox',...
                'Value',0,'Position',[23 120 130 20]);
handles.AcquisitionLED = uicontrol(hLEDPanel,'Style','checkbox',...
                'Value',0,'Position',[23 90 130 20]);
handles.LEDPower = uicontrol(hLEDPanel,'Style','edit',...
                'Position',[15 30 30 20],'Callback',@SetLEDPower);
powerStringLED = sprintf('[%g, %g] (%s)',obj.LED.MinPower,...
    obj.LED.MaxPower, obj.LED.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerStringLED,...
    'Position',[315 5,60,35]);

% PIEZO Panel
ph = 0.12;
hPiezoPanel = uipanel('Parent',guiFig,'Title','PIEZO',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
refh=refh-ph-psep;
uicontrol('Parent',hPiezoPanel, 'Style', 'edit', 'String','Position:',...
    'Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_PositionPiezo = uicontrol('Parent',hPiezoPanel, 'Style', 'edit', ...
    'BackgroundColor',[1 1 1],'Position', [editst php-40 80 20],...
    'Callback',@setPiezoPosition);
uicontrol('Parent',hPiezoPanel, 'Style', 'edit', 'String','Step size:',...
    'Enable','off','Position', [staticst+190 php-40 100 20]);
handles.Edit_StepSizePiezo = uicontrol('Parent',hPiezoPanel, 'Style', 'edit',...
    'String','0.25','BackgroundColor',[1 1 1],...
    'Position', [editst+190 php-40 60 20]);

uicontrol('Parent',hPiezoPanel, 'Style', 'pushbutton', ...
    'String','UP','Position', [staticst php-65 50 20],...
    'Callback',@jogUpPiezo);
uicontrol('Parent',hPiezoPanel, 'Style', 'pushbutton', ...
    'String','DOWN','Position', [staticst+70 php-65 50 20],...
    'Callback',@jogDownPiezo);

uicontrol('Parent',hPiezoPanel, 'Style', 'edit', 'String','Acquire Z stack:',...
    'Enable','off','Position', [staticst+190 php-65 100 20]);
handles.Piezo_Zstack = uicontrol('Parent',hPiezoPanel, 'Style', 'checkbox',...
    'Position', [editst+210 php-65 60 20]);

uicontrol('Parent',hPiezoPanel, 'Style', 'edit', 'String','Start Z stack',...
    'Enable','off','Position', [staticst php-90 100 20]);
handles.Edit_Zstart = uicontrol('Parent',hPiezoPanel, 'Style', 'edit', ...
    'BackgroundColor',[1 1 1],'Position', [editst php-90 80 20]);
uicontrol('Parent',hPiezoPanel, 'Style', 'pushbutton', ...
    'String','Set to current position','Position', [editst+100 php-90 150 20],...
    'Callback',@setZstartToCurrent);

uicontrol('Parent',hPiezoPanel, 'Style', 'edit', 'String','End Z stack',...
    'Enable','off','Position', [staticst php-115 100 20]);
handles.Edit_Zend = uicontrol('Parent',hPiezoPanel, 'Style', 'edit', ...
    'BackgroundColor',[1 1 1],'Position', [editst php-115 80 20]);
uicontrol('Parent',hPiezoPanel, 'Style', 'pushbutton', ...
    'String','Set to current position','Position', [editst+100 php-115 150 20],...
    'Callback',@setZendToCurrent);

% GALVO Panel
ph = 0.07;
hGalvoPanel = uipanel('Parent',guiFig,'Title','GALVO',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
refh=refh-ph-psep;
uicontrol('Parent',hGalvoPanel, 'Style', 'edit', 'String','Position:',...
    'Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_PositionGalvo = uicontrol('Parent',hGalvoPanel, 'Style', 'edit', ...
    'BackgroundColor',[1 1 1],'Position', [editst php-40 80 20],...
    'Callback',@setGalvoPosition);
uicontrol('Parent',hGalvoPanel, 'Style', 'edit', 'String','Step size:',...
    'Enable','off','Position', [staticst+190 php-40 100 20]);
handles.Edit_StepSizeGalvo = uicontrol('Parent',hGalvoPanel, 'Style', 'edit',...
    'String','0.1','BackgroundColor',[1 1 1],'Position', [editst+190 php-40 60 20]);

uicontrol('Parent',hGalvoPanel, 'Style', 'pushbutton', ...
    'String','LEFT','Position', [staticst php-65 50 20],...
    'Callback',@jogLeftGalvo);
uicontrol('Parent',hGalvoPanel, 'Style', 'pushbutton', ...
    'String','RIGHT','Position', [staticst+70 php-65 50 20],...
    'Callback',@jogRightGalvo);

uicontrol('Parent',hGalvoPanel, 'Style', 'edit', 'String','Mirror position',...
    'Enable','off','Position', [staticst+190 php-65 100 20]);
handles.Edit_GalvoMirrorPos = uicontrol('Parent',hGalvoPanel,...
    'Style', 'popupmenu',...
    'String',{'left','right'},'BackgroundColor',[1 1 1],...
    'Position', [editst+190 php-65 60 20]);

% TUNABLE LENS panel
ph=0.07;
hTunLensPanelPos = [(1-pw)/2 refh-ph-psep pw ph];
hTunLensPanel = uipanel('Parent',guiFig,'Title','TUNABLE LENS',...
    'Position',hTunLensPanelPos);
php = ph*ysz;
refh=refh-ph-psep;
uicontrol('Parent',hTunLensPanel, 'Style', 'edit', 'String','Focal Power (dpt):',...
    'Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_FocalPowerTL = uicontrol('Parent',hTunLensPanel, 'Style', 'edit', ...
    'BackgroundColor',[1 1 1],'Position', [editst php-40 80 20],...
    'Callback',@editTL);
uicontrol('Parent',hTunLensPanel, 'Style', 'edit', 'String','Step size (dpt):',...
    'Enable','off','Position', [staticst+190 php-40 100 20]);
handles.Edit_StepSizeTL = uicontrol('Parent',hTunLensPanel, 'Style', 'edit',...
    'String','0.1','BackgroundColor',[1 1 1],'Position', [editst+190 php-40 60 20],...
    'Callback',@TLstepSize);

uicontrol('Parent',hTunLensPanel, 'Style', 'text', 'String',num2str(obj.TunableLens.MinFocalPower),...
    'Position', [staticst php-67 50 20]);
uicontrol('Parent',hTunLensPanel, 'Style', 'text', 'String',num2str(obj.TunableLens.MaxFocalPower),...
    'Position', [editst+220 php-67 50 20]);
SliderPos = [staticst+50 php-65 270 20];
handles.Slider_TL = uicontrol('Parent',hTunLensPanel, 'Style', 'slider',...
        'Min',obj.TunableLens.MinFocalPower,...
        'Max',obj.TunableLens.MaxFocalPower,...
        'Value',0,'SliderStep',[0.01 0.1],'Position', SliderPos,...
        'Callback',@TLslider,'KeyPressFcn' ,@TLslider);

% CONTROL Panel
ph=0.175;
hControlPanel = uipanel('Parent',guiFig,'Title','CONTROL',...
    'Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
b_width = 110;
uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String',...
    'Number of Sequences:','Enable','off',...
    'Position', [staticst php-40 120 20]);
handles.Edit_ControlNSequence = uicontrol('Parent',hControlPanel, ...
    'Style', 'edit', 'String','20','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst+20 php-40 40 20]);
uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String',...
    'Number of Z repeats:','Enable','off',...
    'Position', [staticst+200 php-40 120 20]);
handles.Edit_ControlNZrepeats = uicontrol('Parent',hControlPanel, ...
    'Style', 'edit', 'String','1','Enable','on','BackgroundColor',[1 1 1],...
    'Position', [editst+220 php-40 40 20]);
handles.Button_ControlFocusLamp=uicontrol('Parent',hControlPanel, ...
    'Style', 'pushbutton', 'String','Focus Lamp','Enable','on',...
    'Position', [staticst php-90 b_width 35],'BackgroundColor',[1 1 .8],...
    'Callback',@focusLamp);
handles.Button_ControlFocusLaserLow=uicontrol('Parent',hControlPanel,...
    'Style', 'pushbutton', 'String','Focus Laser (Low)','Enable','on',...
    'Position', [staticst+b_width+15 php-90 b_width 35],'BackgroundColor',[1 .8 .8],...
    'Callback',@focusLow);
handles.Toggle_LED=uicontrol('Parent',hControlPanel, 'Style',...
    'toggle', 'String','Lamp','Enable','on','Position', ...
    [staticst php-133 b_width 35],'BackgroundColor',[1 1 .8],...
    'Callback',@toggleLED);
handles.Button_ControlStart=uicontrol('Parent',hControlPanel, ...
    'Style', 'pushbutton', 'String','START','Enable','on','Position',...
    [staticst php-170 b_width 30],'BackgroundColor',[0 1 0],'Callback',@start);
handles.Button_ControlFocusLaserHigh=uicontrol('Parent',hControlPanel, ...
    'Style', 'pushbutton', 'String','Focus Laser (High)','Enable','on',...
    'Position', [staticst+b_width+15 php-133 b_width 35],'BackgroundColor',[1 0 0],...
    'Callback',@focusHigh);
handles.Button_ControlAbort=uicontrol('Parent',hControlPanel, 'Style',...
    'pushbutton', 'String','ABORT','Enable','on','Position',...
    [staticst+b_width+15 php-170 b_width 30],'BackgroundColor',[1 0 1],'Callback',@abort);
handles.Button_StartPSFgui=uicontrol('Parent',hControlPanel,...
    'Style', 'pushbutton', 'String','PSF gui','Enable','on',...
    'Position', [staticst+b_width*2+30 php-90 b_width 35],'BackgroundColor',[.8 .8 .8],...
    'Callback',@psfGui);

%% Setup GUI Values

properties2gui();
setDefaults();

%% Figure Callbacks

    function setPiezoPosition(~,~)
        Pos = str2double(handles.Edit_PositionPiezo.String);
        Pos = min(max(Pos,obj.Piezo.MinPosition),obj.Piezo.MaxPosition);
        obj.Piezo.setPosition(Pos);
        handles.Edit_PositionPiezo.String = num2str(Pos);
    end

    function jogUpPiezo(~,~)
        oldPos = obj.Piezo.getPosition();
        newPos = oldPos + str2double(handles.Edit_StepSizePiezo.String);
        handles.Edit_PositionPiezo.String = newPos;
        setPiezoPosition();
    end

    function jogDownPiezo(~,~)
        oldPos = obj.Piezo.getPosition();
        newPos = oldPos - str2double(handles.Edit_StepSizePiezo.String);
        handles.Edit_PositionPiezo.String = num2str(newPos);
        setPiezoPosition();
    end

    function setZstartToCurrent(~,~)
        Pos = obj.Piezo.getPosition();
        handles.Edit_Zstart.String = num2str(Pos);
        gui2properties();
    end

    function setZendToCurrent(~,~)
        Pos = obj.Piezo.getPosition();
        handles.Edit_Zend.String = num2str(Pos);
        gui2properties();
    end

    function setGalvoPosition(~,~)
        Pos = str2double(handles.Edit_PositionGalvo.String);
        minPos = obj.Galvo.MaxVoltage/obj.PosToV;
        maxPos = obj.Galvo.MinVoltage/obj.PosToV;
        Pos = min(max(Pos,minPos),maxPos);
        PosV = Pos*obj.PosToV;
        obj.Galvo.setVoltage(PosV);
        handles.Edit_PositionGalvo.String = num2str(Pos);
    end

    function jogLeftGalvo(~,~)
        oldPos = str2double(handles.Edit_PositionGalvo.String);
        newPos = oldPos - str2double(handles.Edit_StepSizeGalvo.String);
        handles.Edit_PositionGalvo.String = num2str(newPos);
        minPos = obj.Galvo.MaxVoltage/obj.PosToV;
        maxPos = obj.Galvo.MinVoltage/obj.PosToV;
        newPos = min(max(newPos,minPos),maxPos);
        PosV = newPos*obj.PosToV;
        obj.Galvo.setVoltage(PosV);
        handles.Edit_PositionGalvo.String = num2str(newPos);
    end

    function jogRightGalvo(~,~)
        oldPos = str2double(handles.Edit_PositionGalvo.String);
        newPos = oldPos + str2double(handles.Edit_StepSizeGalvo.String);
        handles.Edit_PositionGalvo.String = num2str(newPos);
        minPos = obj.Galvo.MaxVoltage/obj.PosToV;
        maxPos = obj.Galvo.MinVoltage/obj.PosToV;
        newPos = min(max(newPos,minPos),maxPos);
        PosV = newPos*obj.PosToV;
        obj.Galvo.setVoltage(PosV);
        handles.Edit_PositionGalvo.String = num2str(newPos);
    end

    function toggleLED(~,~)
        gui2properties();
        if handles.Toggle_LED.Value
            obj.LED.setPower(obj.LEDPower);
            obj.LED.on;
        else
            obj.LED.off;
        end
    end

    function TLslider(~,~)
        Value=handles.Slider_TL.Value;
        obj.TunableLens.setFocalPower(Value);
        handles.Edit_FocalPowerTL.String = num2str(Value);
    end

    function TLstepSize(~,~)
        SliderRange = handles.Slider_TL.Max - handles.Slider_TL.Min;
        StepSize = str2double(handles.Edit_StepSizeTL.String);
        StepFrac = StepSize/SliderRange;
        handles.Slider_TL.SliderStep = [StepFrac,StepFrac*10];
    end

    function editTL(~,~)
        Value=str2double(handles.Edit_FocalPowerTL.String);
        obj.TunableLens.setFocalPower(Value);
        handles.Slider_TL.Value = Value;
    end

    function wheel(~,Event)
        point = guiFig.CurrentPoint;
        Left = hTunLensPanelPos(1)*xsz;
        Right = (hTunLensPanelPos(1)+hTunLensPanelPos(3))*xsz;
        Top = (hTunLensPanelPos(2)+hTunLensPanelPos(4))*ysz;
        Bottom = hTunLensPanelPos(2)*ysz;
        % do nothing if cursor is not over tunable lens panel
        if point(1) < Left || point(1) > Right || ...
                point(2) < Bottom || point(2) > Top
            return
        end
        StepSign = Event.VerticalScrollCount;
        StepSize = str2double(handles.Edit_StepSizeTL.String);
        FPold = obj.TunableLens.FocalPower;
        FPnew = FPold + StepSign*StepSize;
        obj.TunableLens.setFocalPower(FPnew);
        handles.Edit_FocalPowerTL.String = num2str(FPnew);
        handles.Slider_TL.Value = FPnew;
    end

    function LoadRef(~,~)
        obj.loadref();
        set(handles.Edit_RegFileName,'String',obj.R3DObj.RefImageFile);
    end

    function Align(~,~)
        gui2properties();
        obj.align();
    end

    function ShowRef(~,~)
        obj.showref();
    end

    function TakeCurrent(~,~)
        gui2properties();
        obj.takecurrent();
    end

    function CenterStage(~,~)
        obj.StageObj.center();
    end

    function TakeReference(~,~)
        gui2properties();
        obj.takeref();
    end

    function SaveReference(~,~)
        obj.saveref();
        properties2gui();
    end

    function focusLamp(~,~)
        gui2properties();
        obj.focusLamp();
    end

    function focusLow(~,~)
        gui2properties();
        obj.focusLow();
    end

    function focusHigh(~,~)
        gui2properties();
        obj.focusHigh();
    end

    function abort(~,~)
        obj.AbortNow=1; 
        set(handles.Button_ControlStart, 'String','START','Enable','on');
    end

    function start(~,~)
        gui2properties();
        obj.AbortNow = 0;
        set(handles.Button_ControlStart, 'String','Acquiring','Enable','off');
        obj.StartSequence(handles);
        set(handles.Button_ControlStart, 'String','START','Enable','on');
    end 

    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end

    function gui2camera(~,~)
        % set camera properties
        
        % ROI
        switch handles.Popup_CameraROI.Value
            case 1
                obj.Camera.ROI=[961 1088 961 1088];% center 128
            case 2
                obj.Camera.ROI=[897 1152 897 1152];% center 256
            case 3
                obj.Camera.ROI=[769 1280 769 1280];% center 512
            case 4
                obj.Camera.ROI=[513 1536 513 1536]; % center 1024
            case 5
                obj.Camera.ROI=[1 2048 1 2048]; % full 2048
        end
        % Display zoom
        switch handles.Popup_CameraDispZoom.Value
            case 1 % 50%
                obj.Camera.DisplayZoom = 0.5;
            case 2 % 100%
                obj.Camera.DisplayZoom = 1;
            case 3 % 200%
                obj.Camera.DisplayZoom = 2;
            case 4 % 400%
                obj.Camera.DisplayZoom = 4;
            case 5 % 1000%
                obj.Camera.DisplayZoom = 10;
        end
        % Exposure time
        Value=str2double(handles.Edit_CameraExpTime.String);
        obj.Camera.ExpTime_Capture = Value;
        obj.Camera.ExpTime_Focus = Value;
        obj.Camera.ExpTime_Sequence = Value;
        % Number of frames
        obj.Camera.SequenceLength = str2double(handles.Edit_CameraNumFrames.String);
        % Read out and defect correction
        obj.Camera.GuiDialog.ScanMode.curVal = handles.Edit_CameraReadOut.Value;
        obj.Camera.GuiDialog.DefectCorrection.curVal = handles.Edit_CameraDefCor.Value;
        obj.Camera.apply_camSetting();
        obj.Camera.setCamProperties(obj.Camera.CameraSetting);
    end

    function psfGui(~,~)
        % open PSF gui
        obj.guiPSF();
    end

    function gui2properties()
        %Get GUI values and update to object properties
        % FILE
        obj.SaveDir = handles.Edit_FileDirectory.String;
        obj.BaseFileName = handles.Edit_FileName.String;
        obj.SaveType = handles.saveFileType.String{handles.saveFileType.Value};
        % CAMERA
        gui2camera()
        obj.CameraROI = ...
            handles.Popup_CameraROI.String{handles.Popup_CameraROI.Value};
        obj.ExpTime = str2double(handles.Edit_CameraExpTime.String);
        obj.NumFrames = str2double(handles.Edit_CameraNumFrames.String);
        obj.CameraReadoutMode = ...
            handles.Edit_CameraReadOut.String{handles.Edit_CameraReadOut.Value};
        obj.CameraDefectCorrection = ...
            handles.Edit_CameraDefCor.String{handles.Edit_CameraDefCor.Value};
        % REGISTRATION
        obj.R3DObj.ExposureTime=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.ExpTimeReg=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.R3DObj.RefImageFile=get(handles.Edit_RegFileName,'string');
        
        % LIGHT SOURCE
        obj.Laser405Focus = handles.Focus405.Value;
        obj.Laser488Focus = handles.Focus488.Value;
        obj.Laser561Focus = handles.Focus561.Value;
        obj.Laser642Focus = handles.Focus642.Value;
        obj.LEDFocus = handles.FocusLED.Value;
        obj.Laser405Low=str2double(handles.LP405.String);
        obj.Laser488Low=str2double(handles.LP488.String);
        obj.Laser642Low=str2double(handles.LP642.String);
        obj.Laser405High=str2double(handles.HP405.String);
        obj.Laser488High=str2double(handles.HP488.String);
        obj.Laser642High=str2double(handles.HP642.String);
        obj.LEDPower=str2double(handles.LEDPower.String);
        obj.Laser405Aq=handles.Acquisition405.Value;
        obj.Laser488Aq=handles.Acquisition488.Value;
        obj.Laser561Aq=handles.Acquisition561.Value;
        obj.Laser642Aq=handles.Acquisition642.Value;
        obj.LEDAq=handles.AcquisitionLED.Value;
        % PIEZO
        obj.PiezoStepSize = str2double(handles.Edit_StepSizePiezo.String); 
        obj.StartZStack = str2double(handles.Edit_Zstart.String);
        obj.EndZStack = str2double(handles.Edit_Zend.String);
        obj.Zstack = handles.Piezo_Zstack.Value;
        % GALVO
        obj.GalvoStepSize = str2double(handles.Edit_StepSizeGalvo.String); 
        obj.MirrorPosition = ...
            handles.Edit_GalvoMirrorPos.String{handles.Edit_GalvoMirrorPos.Value};
        % CONTROL
        obj.NumSequences=str2double(handles.Edit_ControlNSequence.String);
        obj.NumZRepeats=str2double(handles.Edit_ControlNZrepeats.String);
    end
   
    function properties2gui(~,~)
        %Set GUI values from object properties
        
        % FILE
        handles.Edit_FileDirectory.String = obj.SaveDir;
        handles.Edit_FileName.String = obj.BaseFileName;
        handles.saveFileType.Value = ...
            find(strcmp(handles.saveFileType.String,obj.SaveType));
        % CAMERA
        if all(obj.Camera.ROI == [1 2048 1 2048])
            obj.CameraROI = 'full';
        elseif all(obj.Camera.ROI == [513 1536 513 1536])
            obj.CameraROI = 'center 1024';
        elseif all(obj.Camera.ROI == [769 1280 769 1280])
            obj.CameraROI = 'center 512';
        elseif all(obj.Camera.ROI == [897 1152 897 1152])
            obj.CameraROI = 'center 256';
        elseif all(obj.Camera.ROI == [961 1088 961 1088])
            obj.CameraROI = 'center 128';
        else
            obj.Camera.ROI = [1 2048 1 2048];
            obj.CameraROI = 'full';
        end
        handles.Popup_CameraROI.Value = ...
            find(strcmp(handles.Popup_CameraROI.String,obj.CameraROI));
        obj.ExpTime = obj.Camera.ExpTime_Sequence;
        obj.Camera.ExpTime_Focus = obj.Camera.ExpTime_Sequence;
        handles.Edit_CameraExpTime.String = num2str(obj.ExpTime);
        obj.NumFrames = obj.Camera.SequenceLength;
        handles.Edit_CameraNumFrames.String = num2str(obj.NumFrames);
        obj.CameraReadoutMode = ...
            obj.Camera.GuiDialog.ScanMode.Desc{obj.Camera.ScanMode};
        handles.Edit_CameraReadOut.Value = ...
            find(strcmp(handles.Edit_CameraReadOut.String,obj.CameraReadoutMode));
        obj.CameraDefectCorrection = ...
            obj.Camera.GuiDialog.DefectCorrection.Desc{obj.Camera.DefectCorrection};
        handles.Edit_CameraDefCor.Value = ...
            find(strcmp(handles.Edit_CameraDefCor.String,obj.CameraDefectCorrection));
        % REGISTRATION
        set(handles.Edit_RegExpTime,'string',num2str(obj.R3DObj.ExposureTime));
        set(handles.Edit_RegFileName,'string',obj.R3DObj.RefImageFile);
        % LIGHT SOURCE
        handles.LP405.String = obj.Laser405Low;
        handles.LP488.String = obj.Laser488Low;
        handles.LP642.String = obj.Laser642Low;
        handles.HP405.String = obj.Laser405High;
        handles.HP488.String = obj.Laser488High;
        handles.HP642.String = obj.Laser642High;
        handles.LEDPower.String = obj.LEDPower;
        if ~isempty(obj.Laser405Focus)
            handles.Focus405.Value = obj.Laser405Focus;
        end
        if ~isempty(obj.Laser488Focus)
            handles.Focus488.Value = obj.Laser488Focus;
        end
        if ~isempty(obj.Laser561Focus)
            handles.Focus561.Value = obj.Laser561Focus;
        end
        if ~isempty(obj.Laser642Focus)
            handles.Focus642.Value = obj.Laser642Focus;
        end
        if ~isempty(obj.LEDFocus)
            handles.FocusLED.Value = obj.LEDFocus;
        end
        if ~isempty(obj.Laser405Aq)
            handles.Acquisition405.Value = obj.Laser405Aq;
        end
        if ~isempty(obj.Laser488Aq)
            handles.Acquisition488.Value = obj.Laser488Aq;
        end
        if ~isempty(obj.Laser561Aq)
            handles.Acquisition561.Value = obj.Laser561Aq;
        end
        if ~isempty(obj.Laser642Aq)
            handles.Acquisition642.Value = obj.Laser642Aq;
        end
        if ~isempty(obj.LEDAq)
            handles.AcquisitionLED.Value = obj.LEDAq;
        end
        
        % PIEZO
        handles.Edit_PositionPiezo.String = num2str(obj.StageObj.StagePiezoZ.getPosition());
        handles.Edit_StepSizePiezo.String = num2str(obj.PiezoStepSize); 
        handles.Edit_Zstart.String = num2str(obj.StartZStack);
        handles.Edit_Zend.String = num2str(obj.EndZStack);
        if ~isempty(obj.Zstack)
            handles.Piezo_Zstack.Value= obj.Zstack;
        end
        % GALVO
        handles.Edit_PositionGalvo.String = num2str(obj.Galvo.Voltage/obj.PosToV);
        handles.Edit_StepSizeGalvo.String = num2str(obj.GalvoStepSize); 
        handles.Edit_GalvoMirrorPos.Value = ...
            find(strcmp(handles.Edit_GalvoMirrorPos.String,obj.MirrorPosition));
        % TUNABLE LENS
        handles.Edit_FocalPowerTL.String = num2str(obj.TunableLens.FocalPower);
        handles.Slider_TL.Value = obj.TunableLens.FocalPower;
        % CONTROL
        handles.Edit_ControlNSequence.String = num2str(obj.NumSequences); 
        handles.Edit_ControlNZrepeats.String = num2str(obj.NumZRepeats); 
    end
   
    function setDefaults()
        handles.Edit_FileDirectory.String = 'Y:\Marjolein';
        handles.Edit_FileName.String = 'Cell01';
        handles.Popup_CameraROI.Value = 1;
        handles.Popup_CameraDispZoom.Value = 4;
        handles.Edit_CameraExpTime.String = '0.01';
        handles.Edit_CameraNumFrames.String = '2000';
        handles.Edit_CameraReadOut.Value = 1;
        handles.Edit_CameraDefCor.Value = 1;
        handles.Edit_RegExpTime.String = '0.01';
        handles.LP405.String = num2str(obj.Laser405.MaxPower/10);
        handles.LP488.String = num2str(obj.Laser488.MaxPower/10);
        handles.LP642.String = num2str(obj.Laser642.MaxPower/10);
        handles.HP405.String = num2str(obj.Laser405.MaxPower);
        handles.HP488.String = num2str(obj.Laser488.MaxPower);
        handles.HP642.String = num2str(obj.Laser642.MaxPower);
        handles.LEDPower.String = '10';
        handles.Edit_StepSizePiezo.String = '0.25';
        handles.Edit_StepSizeGalvo.String = '0.1';
        handles.Edit_ControlNSequence.String = '20';
        handles.Edit_StepSizeTL.String = '0.1';
        editTL();
        gui2properties();
    end

end

