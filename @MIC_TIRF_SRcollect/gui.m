
function gui(obj)
% GUI SRcollect Gui for TIRF microscope
%   Detailed explanation goes here

h = findall(0,'tag','TIRF-SRcollect.gui');
if ~(isempty(h))
    figure(h);
    return;
end
%%
xsz=400;
ysz=1060;
xst=100;
yst=100;
pw=.95;
psep=.001;
staticst=10;
editst=110;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'TIRF-SRcollect.gui','HandleVisibility','off','name','SRcollect.gui','CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);

refh=1;

% File Panel
ph=0.09;
php = ph*ysz;
hFilePanel = uipanel('Parent',guiFig,'Title','FILE','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String', 'Save Directory:','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_FileDirectory = uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 250 20]);
uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String', 'Base FileName:','Enable','off','Position', [staticst php-65 100 20]);
handles.Edit_FileName = uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-65 250 20]);
uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','File type:','Enable','off','Position', [staticst php-90 100 20]);
handles.saveFileType = uicontrol('Parent',hFilePanel, 'Style', 'popupmenu', 'String',{'.mat','.h5'},'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-90 250 20],'CallBack',@saveFile);

% Camera Panel
ph=0.17;
php = ph*ysz;
hCameraPanel = uipanel('Parent',guiFig,'Title','CAMERA','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera Gain:','Enable','off','Position', [staticst php-40 100 20]);
handles.Popup_CameraGain = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',{'Low (Alexa647)','High (FAP/FP)'},'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 250 20],'CallBack',@gain_set);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera ROI:','Enable','off','Position', [staticst php-70 100 20]);
ROIlist={'Full','Left','Right','Left Center','Right Center','Center Horizontally','Left Top','Left Bottom','Right Top','Right Bottom','Top','Bottom','Center256'};
handles.Popup_CameraROI = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',ROIlist,'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 250 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Exp. Time Focus:','Enable','off','Position', [staticst php-100 100 20]);
handles.Edit_CameraExpTimeFocusSet = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-100 50 20]);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Actual:','Enable','off','Position', [175 php-100 100 20]);
handles.Edit_CameraExpTimeFocusActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','','Enable','off','Position', [250 php-100 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Exp. Time Seq.:','Enable','off','Position', [staticst php-130 100 20]);
handles.Edit_CameraExpTimeSeqSet = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-130 50 20],'CallBack',@sequence_set);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Actual:','Enable','off','Position', [175 php-130 100 20]);
handles.Edit_CameraExpTimeSeqActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String',num2str(obj.CameraObj.SequenceCycleTime),'Enable','off','Position', [250 php-130 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Num Frames:','Enable','off','Position', [staticst php-160 100 20]);
handles.Edit_CameraNumFrames = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','2000','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-160 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Zoom:','Enable','off','Position', [175 php-160 100 20]);
handles.Popup_CameraDispZoom = uicontrol('Parent',hCameraPanel, 'Style','popupmenu','String',{'50%','100%','200%','400%','1000%'},'Value',4,'Enable','on','BackgroundColor',[1 1 1],'Position', [250 php-160 50 20],'CallBack',@zoom_set);

% Registration Panel
ph=0.213;
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


BGh=100;
handles.ButtonGroup_RegCollectType=uibuttongroup('Parent',hRegPanel, 'Position', [.02 (php-130-BGh+30)/php .96 BGh/php]);
b1=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio', 'tag','None','String','No Registration','Enable','on','Position', [staticst BGh-30 250 20]);
b2=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio','tag','Self', 'String','Align to Self (Takes/Saves Reference Image)','Enable','on','Position', [staticst BGh-60 250 20]);
b3=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio','tag','Ref','String','Align to Reference','Enable','on','Position', [staticst BGh-90 250 20]);

% LIGHTSOURCE Panel
ph=0.3;
hLampPanel = uipanel('Parent',guiFig,'Title','LIGHT SOURCE','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;
uicontrol(hLampPanel,'Style','text','String','On during Focus',...
    'Position',[-3 240,60,25]);
uicontrol(hLampPanel,'Style','text','String','On during Aquisition',...
    'Position',[-3 180,60,28]);
uicontrol(hLampPanel,'Style','text','String','Low Power',...
    'Position',[0 120,60,25]);
uicontrol(hLampPanel,'Style','text','String','High Power',...
    'Position',[0 70,60,25]);
uicontrol(hLampPanel,'Style','text','String','[MinPower,MaxPower]',...
    'Position',[-1 5,60,35]);

h405Panel=uipanel(hLampPanel,'Title','405 nm','Position',[1/6 1/6 1/6 5/6]);
handles.Focus405 = uicontrol(h405Panel,'Style','checkbox',...
                'Value',0,'Position',[23 190 130 20]);
handles.Aquisition405 = uicontrol(h405Panel,'Style','checkbox',...
                'Value',0,'Position',[23 130 130 20]);
handles.LP405 = uicontrol(h405Panel,'Style','edit',...
                'Position',[15 80 30 20],'Callback',@setLaser405Low);
handles.HP405 = uicontrol(h405Panel,'Style','edit',...
                'Position',[15 25 30 20]);
powerString405 = sprintf('[%g, %g] (%s)',obj.Laser405.MinPower,obj.Laser405.MaxPower, obj.Laser405.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString405,...
    'Position',[64, 5,60,35]);

h488Panel=uipanel(hLampPanel,'Title','488 nm','Position',[2/6 1/6 1/6 5/6]);
handles.Focus488 = uicontrol(h488Panel,'Style','checkbox',...
                'Value',0,'Position',[23 190 130 20]);
handles.Aquisition488 = uicontrol(h488Panel,'Style','checkbox',...
                'Value',0,'Position',[23 130 130 20]);
handles.LP488 = uicontrol(h488Panel,'Style','edit',...
                'Position',[15 80 30 20],'Callback',@setLaser488Low);
handles.HP488 = uicontrol(h488Panel,'Style','edit',...
                'Position',[15 25 30 20]);
powerString488 = sprintf('[%g, %g] (%s)',obj.Laser488.MinPower,obj.Laser488.MaxPower, obj.Laser488.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString488,...
    'Position',[125 5,60,35]);

h561Panel=uipanel(hLampPanel,'Title','561 nm','Position',[3/6 1/6 1/6 5/6]);
handles.Focus561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[23 190 130 20]);
handles.Aquisition561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[23 130 130 20]);
handles.LP561 = uicontrol(h561Panel,'Style','edit',...
                'Position',[15 80 30 20],'Callback',@setLaser561Low);
handles.HP561 = uicontrol(h561Panel,'Style','edit',...
                'Position',[15 25 30 20]);
powerString561 = sprintf('[%g, %g] (%s)',obj.Laser561.MinPower,obj.Laser561.MaxPower, obj.Laser561.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString561,...
    'Position',[190 5,60,35]);

h642Panel=uipanel(hLampPanel,'Title','642 nm','Position',[4/6 1/6 1/6 5/6]);
handles.Focus642 = uicontrol(h642Panel,'Style','checkbox',...
                'Value',0,'Position',[23 190 130 20]);
handles.Aquisition642 = uicontrol(h642Panel,'Style','checkbox',...
                'Value',0,'Position',[23 130 130 20]);
handles.LP642 = uicontrol(h642Panel,'Style','edit',...
                'Position',[15 80 30 20],'Callback',@setLaser642Low);
handles.HP642 = uicontrol(h642Panel,'Style','edit',...
                'Position',[15 25 30 20]);
powerString642 = sprintf('[%g, %g] (%s)',obj.Laser642.MinPower,obj.Laser642.MaxPower, obj.Laser642.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString642,...
    'Position',[250 5,60,35]);

hX71Panel=uipanel(hLampPanel,'Title','Lamp','Position',[5/6 1/6 1/6 5/6]);
handles.FocusIX71Lamp = uicontrol(hX71Panel,'Style','checkbox',...
                'Value',0,'Position',[23 190 130 20]);
handles.AquisitionIX71Lamp = uicontrol(hX71Panel,'Style','checkbox',...
                'Value',0,'Position',[23 130 130 20]);
handles.IX71LampPower = uicontrol(hX71Panel,'Style','edit',...
                'Position',[15 80 30 20],'Callback',@SetLampPower);
powerStringLamp = sprintf('[%g, %g] (%s)',obj.LampObj.MinPower,obj.LampObj.MaxPower, obj.LampObj.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerStringLamp,...
    'Position',[315 5,60,35]);


% CONTROL Panel
ph=0.190;
hControlPanel = uipanel('Parent',guiFig,'Title','CONTROL','Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','Number of Sequences:','Enable','off','Position', [staticst php-40 150 20]);
handles.Edit_ControlNSequence = uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','20','Enable','on','BackgroundColor',[1 1 1],'Position', [editst+50 php-40 50 20]);
handles.Button_ControlFocusLamp=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Lamp','Enable','on','Position', [staticst php-90 150 40],'BackgroundColor',[1 1 .8],'Callback',@FocusLamp);
handles.Button_ControlFocusLaserLow=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (Low)','Enable','on','Position', [staticst+200 php-90 150 40],'BackgroundColor',[1 .8 .8],'Callback',@FocusLow);
handles.Toggle_LaserLamp=uicontrol('Parent',hControlPanel, 'Style', 'toggle', 'String','Lamp','Enable','on','Position', [staticst php-138 150 40],'BackgroundColor',[1 1 .8],'Callback',@ToggleLamp);
handles.Button_ControlStart=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','START','Enable','on','Position', [staticst php-175 150 30],'BackgroundColor',[0 1 0],'Callback',@Start);
handles.Button_ControlFocusLaserHigh=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (High)','Enable','on','Position', [staticst+200 php-138 150 40],'BackgroundColor',[1 0 0],'Callback',@FocusHigh);
handles.Button_ControlAbort=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','ABORT','Enable','on','Position', [staticst+200 php-175 150 30],'BackgroundColor',[1 0 1],'Callback',@Abort);

%% Setup GUI Values

properties2gui();


%% Figure Callbacks

    function saveFile(~,~)
        file_val=get(handles.saveFileType,'value');
        switch file_val
            case 1
                obj.SaveFileType='mat';
            case 2
                obj.SaveFileType='h5';
        end
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

    function ToggleLamp(~,~)
        gui2properties();
        stateLamp1=get(handles.Toggle_LaserLamp,'Value');
        if stateLamp1
            obj.LampObj.setPower(obj.LampPower);
            obj.LampObj.on;
        else
            obj.LampObj.off;
%            pause(obj.LampWait);
        end
    end


    function FocusLamp(~,~)
        gui2properties();
        obj.focusLamp();
    end

    function FocusLow(~,~)
        gui2properties();
        obj.focusLow();
    end

    function FocusHigh(~,~)
        gui2properties();
        obj.focusHigh();
    end

    function Abort(~,~)
        obj.AbortNow=1; 
        set(handles.Button_ControlStart, 'String','START','Enable','on');
    end

    function Start(~,~)
        gui2properties();
        set(handles.Button_ControlStart, 'String','Acquiring','Enable','off');
        obj.StartSequence(handles);
        set(handles.Button_ControlStart, 'String','START','Enable','on');
    end 
    
    function SetLampPower(~,~)
        gui2properties();
        obj.setLampPower();  
    end
    
    function setLaser405Low(~,~)
        obj.Laser405.setPower(str2double(handles.LP405.String));
    end

    function setLaser488Low(~,~)
        obj.Laser405.setPower(str2double(handles.LP488.String));
    end

    function setLaser561Low(~,~)
        obj.Laser405.setPower(str2double(handles.LP561.String));
    end

    function setLaser642Low(~,~)
        obj.Laser405.setPower(str2double(handles.LP642.String));
    end

    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end

    function zoom_set(~,~)
        zoom_val = get(handles.Popup_CameraDispZoom,'Value');
        switch zoom_val
            case 1
                obj.CameraObj.DisplayZoom = 0.5;
            case 2
                obj.CameraObj.DisplayZoom = 1;
            case 3
                obj.CameraObj.DisplayZoom = 2;
            case 4
                obj.CameraObj.DisplayZoom = 4;
            case 5
                obj.CameraObj.DisplayZoom = 10;
        end
        
    end

    function gain_set(~,~)
        gain_val=get(handles.Popup_CameraGain,'value');
        switch gain_val
            case 1
                obj.CameraEMGainHigh=100;
            case 2
                obj.CameraEMGainHigh=200;
        end
    end

    function sequence_set(~,~)
        gui2properties();
        obj.CameraObj.ExpTime_Sequence = obj.ExpTime_Sequence_Set;        
        obj.CameraObj.AcquisitionType = 'sequence';
        obj.CameraObj.setup_acquisition;
        set(handles.Edit_CameraExpTimeSeqActual,'String',num2str(obj.CameraObj.SequenceCycleTime));
    end

    function gui2properties()
        %Get GUI values and update to object properties
        obj.SaveDir=get(handles.Edit_FileDirectory,'String');
        obj.BaseFileName=get(handles.Edit_FileName,'String');
        obj.CameraGain=get(handles.Popup_CameraGain,'value');
        obj.CameraROI=get(handles.Popup_CameraROI,'value');
        obj.ExpTime_Focus_Set=str2double(get(handles.Edit_CameraExpTimeFocusSet,'string'));
        obj.ExpTime_Sequence_Set=str2double(get(handles.Edit_CameraExpTimeSeqSet,'string'));
        obj.NumFrames=str2double(get(handles.Edit_CameraNumFrames,'string'));
        obj.R3DObj.ExposureTime=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.R3DObj.RefImageFile=get(handles.Edit_RegFileName,'string');
        obj.focus405Flag=get(handles.Focus405,'Value');
        obj.focus488Flag=get(handles.Focus488,'Value');
        obj.focus561Flag=get(handles.Focus561,'Value');
        obj.focus642Flag=get(handles.Focus642,'Value');
        obj.focusLampFlag=get(handles.FocusIX71Lamp,'Value');
        obj.Laser405Low=str2double(handles.LP405.String);
        obj.Laser488Low=str2double(handles.LP488.String);
        obj.Laser561Low=str2double(handles.LP561.String);
        obj.Laser642Low=str2double(handles.LP642.String);
        obj.Laser405High=str2double(handles.HP405.String);
        obj.Laser488High=str2double(handles.HP488.String);
        obj.Laser561High=str2double(handles.HP561.String);
        obj.Laser642High=str2double(handles.HP642.String);
        obj.LampPower=str2double(handles.IX71LampPower.String);
        obj.Laser405Aq=handles.Aquisition405.Value;
        obj.Laser488Aq=handles.Aquisition488.Value;
        obj.Laser561Aq=handles.Aquisition561.Value;
        obj.Laser642Aq=handles.Aquisition642.Value;
        obj.LampAq=handles.AquisitionIX71Lamp.Value;
        obj.NumSequences=str2double(get(handles.Edit_ControlNSequence,'string')); 
        obj.RegType=get(get(handles.ButtonGroup_RegCollectType,'SelectedObject'),'Tag'); 
        
    end
   
    function properties2gui()
        %Set GUI values from object properties
        set(handles.Edit_FileDirectory,'String',obj.SaveDir);
        set(handles.Edit_FileName,'String',obj.BaseFileName);
        set(handles.Popup_CameraGain,'value',obj.CameraGain);
        set(handles.Popup_CameraROI,'value',obj.CameraROI);
        set(handles.Edit_CameraExpTimeFocusSet,'string',num2str(obj.ExpTime_Focus_Set));
        set(handles.Edit_CameraExpTimeSeqSet,'string',num2str(obj.ExpTime_Sequence_Set));
        set(handles.Edit_RegExpTime,'string',num2str(obj.R3DObj.ExposureTime));
        set(handles.Edit_CameraNumFrames,'string',num2str(obj.NumFrames));
        set(handles.Edit_RegFileName,'string',obj.R3DObj.RefImageFile);
        set(handles.LP405,'string',obj.Laser405Low);
        set(handles.LP488,'string',obj.Laser488Low);
        set(handles.LP561,'string',obj.Laser561Low);
        set(handles.LP642,'string',obj.Laser642Low);
        set(handles.HP405,'string',obj.Laser405High);
        set(handles.HP488,'string',obj.Laser488High);
        set(handles.HP561,'string',obj.Laser561High);
        set(handles.HP642,'string',obj.Laser642High);
        set(handles.IX71LampPower,'string',obj.LampPower);
        set(handles.Focus405,'value',obj.focus405Flag);
        set(handles.Focus488,'value',obj.focus488Flag);
        set(handles.Focus561,'value',obj.focus561Flag);
        set(handles.Focus642,'value',obj.focus642Flag);
        set(handles.FocusIX71Lamp,'value',obj.focusLampFlag);
        set(handles.Edit_ControlNSequence,'string',num2str(obj.NumSequences));
        set(handles.Edit_CameraExpTimeSeqActual,'String',num2str(obj.CameraObj.SequenceCycleTime));

        switch obj.RegType
            case 'None'
                set(handles.ButtonGroup_RegCollectType,'SelectedObject',b1); 
            case 'Self'
                set(handles.ButtonGroup_RegCollectType,'SelectedObject',b2); 
            case 'Ref'
                set(handles.ButtonGroup_RegCollectType,'SelectedObject',b3); 
        end    
    end
   
    



end

