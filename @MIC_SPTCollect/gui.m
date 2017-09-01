
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
ysz=1000;
xst=100;
yst=50;
pw=.95;
psep=.001;
staticst=10;
editst=110;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SPTCollect.gui','HandleVisibility','off','name','SPTcollect.gui','CloseRequestFcn',@FigureClose);

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
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera ROI:','Enable','off','Position', [staticst php-70 80 20]);
ROIlist={'Full','Left','Right','Left Center','Right Center','Center Horizontally','Center Horizontally Half'};
handles.Popup_CameraROI = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',ROIlist,'Enable','on','BackgroundColor',[1 1 1],'Position', [90 php-70 85 20]);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','IRCamera ROI:','Enable','off','Position', [staticst+180 php-70 80 20]);
ROIlist={'Full','Left','Right','Left Center','Right Center','Center Horizontally','Center Horizontally Half'};
handles.Popup_IRCameraROI = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',ROIlist,'Enable','on','BackgroundColor',[1 1 1],'Position', [90+180 php-70 85 20]);

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

h561Panel=uipanel(hLampPanel,'Title','561 nm','TitlePosition','centertop',...
    'Position',[1/5 1/5 1/5 4/5]);
handles.Focus561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[29 185 130 20]);
handles.Aquisition561 = uicontrol(h561Panel,'Style','checkbox',...
                'Value',0,'Position',[29 130 130 20]);
handles.LP561 = uicontrol(h561Panel,'Style','edit',...
                'Position',[21 80 30 20],'Callback',@setLaser561Low);
handles.HP561 = uicontrol(h561Panel,'Style','edit',...
                'Position',[21 25 30 20]);
% powerString561 = sprintf('[%g, %g] (%s)',obj.Laser561Obj.MinPower,obj.Laser561Obj.MaxPower, obj.Laser561.PowerUnit);
% uicontrol(hLampPanel,'Style','text','String',powerString561,...
%     'Position',[75, 5,60,35]);

h638Panel=uipanel(hLampPanel,'Title','638 nm','TitlePosition','centertop',...
    'Position',[2/5 1/5 1/5 4/5]);
handles.Focus638 = uicontrol(h638Panel,'Style','checkbox',...
                'Value',0,'Position',[29 185 130 20]);
handles.Aquisition638 = uicontrol(h638Panel,'Style','checkbox',...
                'Value',0,'Position',[29 130 130 20]);
handles.LP638 = uicontrol(h638Panel,'Style','edit',...
                'Position',[21 80 30 20],'Callback',@setLaser638Low);
handles.HP638 = uicontrol(h638Panel,'Style','edit',...
                'Position',[21 25 30 20]);
powerString638 = sprintf('[%g, %g] (%s)',obj.Laser638Obj.MinPower,obj.Laser638Obj.MaxPower, obj.Laser638Obj.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString638,...
    'Position',[160 5,60,35]);

hlamp850Panel=uipanel(hLampPanel,'Title','Lamp 850 nm','TitlePosition','centertop',...
    'Position',[3/5 1/5 1/5 4/5]);
handles.Focuslamp850 = uicontrol(hlamp850Panel,'Style','checkbox',...
                'Value',0,'Position',[29 185 130 20]);
handles.Aquisitionlamp850 = uicontrol(hlamp850Panel,'Style','checkbox',...
                'Value',0,'Position',[29 130 130 20]);
handles.LED850lLampPower = uicontrol(hlamp850Panel,'Style','edit',...
                'Position',[21 80 30 20],'Callback',@setLamp850Power);
powerString850 = sprintf('[%g, %g] (%s)',obj.Lamp850Obj.MinPower,obj.Lamp850Obj.MaxPower, obj.Lamp850Obj.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerString850,...
    'Position',[235 5,60,35]);

hX71Panel=uipanel(hLampPanel,'Title','Lamp','TitlePosition','centertop',...
    'Position',[4/5 1/5 1/5 4/5]);
handles.FocusIX71Lamp = uicontrol(hX71Panel,'Style','checkbox',...
                'Value',0,'Position',[29 185 130 20]);
handles.AquisitionIX71Lamp = uicontrol(hX71Panel,'Style','checkbox',...
                'Value',0,'Position',[29 130 130 20]);
handles.IX71LampPower = uicontrol(hX71Panel,'Style','edit',...
                'Position',[21 80 30 20],'Callback',@setLampPower);
powerStringLamp = sprintf('[%g, %g] (%s)',obj.LampObj.MinPower,obj.LampObj.MaxPower, obj.LampObj.PowerUnit);
uicontrol(hLampPanel,'Style','text','String',powerStringLamp,...
    'Position',[310 5,60,35]);

% CONTROL Panel
ph=0.190;
hControlPanel = uipanel('Parent',guiFig,'Title','CONTROL','Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','Number of Sequences:','Enable','off','Position', [staticst php-40 150 20]);
handles.Edit_ControlNSequence = uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','20','Enable','on','BackgroundColor',[1 1 1],'Position', [editst+50 php-40 50 20]);
handles.Button_ControlFocusLamp=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Lamp','Enable','on','Position', [staticst php-90 103 35],'BackgroundColor',[1 1 .8],'Callback',@FocusLamp);
handles.Button_ControlFocusLaserLow=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (Low)','Enable','on','Position', [staticst+123 php-90 103 35],'BackgroundColor',[1 .8 .8],'Callback',@FocusLow);
handles.Button_ControlFocusLamp850=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Lamp 850','Enable','on','Position', [staticst+246 php-90 103 35],'BackgroundColor',[1 1 .8],'Callback',@FocusLamp850);
handles.Toggle_LaserLamp=uicontrol('Parent',hControlPanel, 'Style', 'toggle', 'String','Lamp','Enable','on','Position', [staticst php-138 103 35],'BackgroundColor',[1 1 .8],'Callback',@ToggleLamp);
handles.Button_ControlStart=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','START (SR)','Enable','on','Position', [staticst php-186 103 35],'BackgroundColor',[0 1 0],'Callback',@Start);
handles.Button_ControlFocusLaserHigh=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (High)','Enable','on','Position', [staticst+123 php-138 103 35],'BackgroundColor',[1 0 0],'Callback',@FocusHigh);
handles.Button_ControlAbort=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','ABORT','Enable','on','Position', [staticst+123 php-186 103 35],'BackgroundColor',[1 0 1],'Callback',@Abort);
handles.Button_ControlStart_SPT=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','START (SPT+SR)','Enable','on','Position', [staticst+246 php-186 103 35],'BackgroundColor',[0 1 0],'Callback',@Start_SPT);

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
  function FocusLamp850(~,~)
        gui2properties();
        obj.focusLamp850();
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
        set(handles.Button_ControlStart, 'String','START (SR)','Enable','on');
        set(handles.Button_ControlStart_SPT, 'String','START (SPT+SR)','Enable','on');
    end

    function Start(~,~)
        gui2properties();
        [temp status]=obj.CameraObj.call_temperature
        if status==2
        error('Camera is still cooling down! Please wait for a few mintues!')
        end 
        set(handles.Button_ControlStart, 'String','Acquiring','Enable','off');
        obj.sequenceType='SRCollect';
        obj.StartSequence(handles);
        set(handles.Button_ControlStart, 'String','START (SR)','Enable','on');
    end 

     function Start_SPT(~,~)
        gui2properties();
        [temp status]=obj.CameraObj.call_temperature
        if status==2
        error('Camera is cooling down! Please wait for a few mintues!')
        end 
        set(handles.Button_ControlStart, 'String','Acquiring','Enable','off');
        obj.sequenceType='Tracking+SRCollect';
        obj.StartSequence(handles);
        set(handles.Button_ControlStart, 'String','START (SPT+SR)','Enable','on');
    end 
    
    function setLampPower(~,~)
        gui2properties();
        obj.setLampPower();  
    end

    function setLamp850Power(~,~)
        gui2properties();
        obj.setLampPower();
    end

    function setLaser561Low(~,~)
        obj.Laser561Obj.setPower(str2double(handles.LP561.String));
    end

    function setLaser638Low(~,~)
        obj.Laser638Obj.setPower(str2double(handles.LP638.String));
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
        obj.IRCameraROI=get(handles.Popup_IRCameraROI,'value');
        obj.ExpTime_Focus_Set=str2double(get(handles.Edit_CameraExpTimeFocusSet,'string'));
        obj.ExpTime_Sequence_Set=str2double(get(handles.Edit_CameraExpTimeSeqSet,'string'));
        obj.NumFrames=str2double(get(handles.Edit_CameraNumFrames,'string'));
        obj.R3DObj.ExposureTime=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.R3DObj.RefImageFile=get(handles.Edit_RegFileName,'string');
        obj.focus561Flag=get(handles.Focus561,'Value');
        obj.focus638Flag=get(handles.Focus638,'Value');
        obj.focusLampFlag=get(handles.FocusIX71Lamp,'Value');
        obj.focusLamp850Flag=get(handles.Focuslamp850,'Value');
        obj.Laser561Low=str2double(handles.LP561.String);
        obj.Laser638Low=str2double(handles.LP638.String);
        obj.Laser561High=str2double(handles.HP561.String);
        obj.Laser638High=str2double(handles.HP638.String);
        obj.LampPower=str2double(handles.IX71LampPower.String);
        obj.Lamp850Power=str2double(handles.LED850lLampPower.String);
        obj.Laser561Aq=handles.Aquisition561.Value;
        obj.Laser638Aq=handles.Aquisition638.Value;
        obj.LampAq=handles.AquisitionIX71Lamp.Value;
        obj.Lamp850Aq=handles.Aquisitionlamp850.Value;
        obj.NumSequences=str2double(get(handles.Edit_ControlNSequence,'string')); 
        obj.RegType=get(get(handles.ButtonGroup_RegCollectType,'SelectedObject'),'Tag'); 
        
    end
   
    function properties2gui()
        %Set GUI values from object properties
        set(handles.Edit_FileDirectory,'String',obj.SaveDir);
        set(handles.Edit_FileName,'String',obj.BaseFileName);
        set(handles.Popup_CameraGain,'value',obj.CameraGain);
        set(handles.Popup_CameraROI,'value',obj.CameraROI);
        set(handles.Popup_IRCameraROI,'value',obj.IRCameraROI);
        set(handles.Edit_CameraExpTimeFocusSet,'string',num2str(obj.ExpTime_Focus_Set));
        set(handles.Edit_CameraExpTimeSeqSet,'string',num2str(obj.ExpTime_Sequence_Set));
        set(handles.Edit_RegExpTime,'string',num2str(obj.R3DObj.ExposureTime));
        set(handles.Edit_CameraNumFrames,'string',num2str(obj.NumFrames));
        set(handles.Edit_RegFileName,'string',obj.R3DObj.RefImageFile);
        set(handles.LP561,'string',obj.Laser561Low);
        set(handles.LP638,'string',obj.Laser638Low);
        set(handles.HP561,'string',obj.Laser561High);
        set(handles.HP638,'string',obj.Laser638High);
        set(handles.IX71LampPower,'string',obj.LampPower);
        set(handles.LED850lLampPower,'string',obj.Lamp850Power);
        set(handles.Focus561,'value',obj.focus561Flag);
        set(handles.Focus638,'value',obj.focus638Flag);
        set(handles.FocusIX71Lamp,'value',obj.focusLampFlag);
        set(handles.Focuslamp850,'value',obj.focusLamp850Flag);
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

