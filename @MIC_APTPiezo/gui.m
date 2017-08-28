function gui(obj)
% main GUI figure
guiFig = figure('Resize','off','Units','pixels','Position',[100 800 300 200],'MenuBar','none','ToolBar','none','Visible','on','NumberTitle','off','Name','APT Piezo Control','UserData',0);
defaultBackground=get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground)
handles.output=guiFig;
guidata(guiFig,handles)


handles.StepSize_txt = uicontrol('Parent',guiFig,'Style','text','String','step size (um):','HorizontalAlignment','left','Units','Normalized','Position',[.1 .64 .2 .2]);
handles.StepSize_edit = uicontrol('Parent',guiFig,'Style','edit','String','','Units','Normalized','Position',[.3 .71 .1 .1],'BackgroundColor',[1 1 1],'Callback',@SetStepSize);

handles.Jogup_butt=uicontrol('Parent',guiFig,'Style','pushbutton','String','z+','Units','normalized','Position',[.7 .81 .1 .1],'Callback',@Jogup);
handles.Jogdown_butt=uicontrol('Parent',guiFig,'Style','pushbutton','String','z-','Units','normalized','Position',[.7 .61 .1 .1],'Callback',@Jogdown);
handles.Top_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','top','Units','normalized','Position',[.5 .86 .15 .1],'Callback',@TopZ);
handles.Center_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','center','Units','normalized','Position',[.5 .71 .15 .1],'Callback',@CenterZ);
handles.Bottom_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','bottom','Units','normalized','Position',[.5 .56 .15 .1],'Callback',@BottomZ);
handles.GetControlMode_butt = uicontrol('Parent',guiFig,'Style','togglebutton','String','get current control mode:','Units','Normalized','Position',[.1 .1 .45 .1],'Callback',@GetMode);
handles.GetControlMode_txt = uicontrol('Parent',guiFig,'Style','text','String','','Units','Normalized','Position',[.57 .09 .35 .1]);
handles.SetZero_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','set zero','Units','normalized','Position',[.1 .45 .2 .1],'Callback',@guiSetZero);
handles.CloseLoop_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','close loop control','Units','normalized','Position',[.1 .27 .35 .1],'Callback',@SetCloseLoop);
handles.OpenLoop_butt=uicontrol('Parent',guiFig,'Style','togglebutton','String','open loop control','Units','normalized','Position',[.5 .27 .35 .1],'Callback',@SetOpenLoop);
initialize
    function initialize(~,~)
        obj.getStatus;
        set(handles.StepSize_edit,'String',num2str(obj.StepSize));
        zPos=double(obj.MaxTravel)/2+2;
        obj.setPosition(zPos)
    end

    function SetStepSize(src,eventdata)
        obj.StepSize=str2double(get(handles.StepSize_edit,'String'));
    end

    function Jogup(src,eventdata)
        Stepsize=str2double(get(handles.StepSize_edit,'String'));
        Stepnumber=1;
        zPos=obj.CurrentPosition+Stepnumber*Stepsize;
        obj.setPosition(zPos)
    end

    function Jogdown(src,eventdata)
        Stepsize=str2double(get(handles.StepSize_edit,'String'));
        Stepnumber=1;
        zPos=obj.CurrentPosition-Stepnumber*Stepsize;
        obj.setPosition(zPos)
    end

    function BottomZ(src,eventdata)
        
        zPos=2;
        obj.setPosition(zPos)
    end

    function CenterZ(src,eventdata)
        obj.center()
    end

    function TopZ(src,eventdata)
        
        zPos=23;
        obj.setPosition(zPos)
    end

    function guiSetZero(src,eventdata)
        obj.setZero;
    end

    function GetMode(src,eventdata)
        obj.getStatus
        set(handles.GetControlMode_txt,'String',obj.PiezoStatus);
    end

    function SetCloseLoop(src,eventdata)
        obj.ControlMode=2;
        obj.setup;
    end

    function SetOpenLoop(src,eventdata)
        obj.ControlMode=1;
        obj.setup;
    end

end