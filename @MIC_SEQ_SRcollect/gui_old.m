
function gui(obj)
%GUI Summary of this function goes here
%   Detailed explanation goes here

h = findall(0,'tag','SeqSRcollect.gui');
if ~(isempty(h))
    figure(h);
    return;
end
%%
xsz=400;
ysz=1000;
xst=100;
yst=100;
pw=.95;
psep=.01;
staticst=10;
editst=110;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SeqSRcollect.gui','HandleVisibility','off','name','SeqSRcollect.gui');%,'CloseRequestFcn',@FigureClose);

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
uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String', 'Base FileName:','Enable','off','Position', [staticst php-70 100 20]);
handles.Edit_FileName = uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 250 20]);

% Camera Panel
ph=0.18;
php = ph*ysz;
hCameraPanel = uipanel('Parent',guiFig,'Title','CAMERA','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera Gain:','Enable','off','Position', [staticst php-40 100 20]);
handles.Popup_CameraGain = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',{'Low (Alexa647)','High (FAP/FP)'},'Enable','off','BackgroundColor',[1 1 1],'Position', [editst php-40 250 20]);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Camera ROI:','Enable','off','Position', [staticst php-70 100 20]);
ROIlistIR={'Full(IR) 1024x768','Left(IR)','Right(IR)','Center(IR) 512x384','Center(IR) 256x192','Center(IR) 128x96'};
handles.Popup_CameraROIIR = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',ROIlistIR,'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 125 20]);
ROIlist={'Full 2048x2048','Left','Right','Center 1024x1024','Center 512x512','Center 256x256','Center 128x128','Center 128x64','Center 128x32','Center 128x16'};
handles.Popup_CameraROI = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',ROIlist,'Enable','on','BackgroundColor',[1 1 1],'Position', [editst+125 php-70 125 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Exp. Time Focus:','Enable','off','Position', [staticst php-100 100 20]);
handles.Edit_CameraExpTimeFocusSet = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-100 50 20]);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Actual:','Enable','off','Position', [175 php-100 100 20]);
handles.Edit_CameraExpTimeFocusActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','','Enable','off','Position', [250 php-100 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Exp. Time Seq.:','Enable','off','Position', [staticst php-130 100 20]);
handles.Edit_CameraExpTimeSeqSet = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-130 50 20],'CallBack',@sequence_set);
uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Actual:','Enable','off','Position', [175 php-130 100 20]);
handles.Edit_CameraExpTimeSeqActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String',num2str(obj.IRCameraObj.SequenceCycleTime),'Enable','off','Position', [250 php-130 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Num Frames:','Enable','off','Position', [staticst php-160 100 20]);
handles.Edit_CameraNumFrames = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','2000','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-160 50 20]);

uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Zoom:','Enable','off','Position', [175 php-160 100 20]);
handles.Popup_CameraDispZoom = uicontrol('Parent',hCameraPanel, 'Style','popupmenu','String',{'50%','100%','200%','400%','1000%'},'Value',1,'Enable','on','BackgroundColor',[1 1 1],'Position', [250 php-160 50 20],'CallBack',@zoom_set);

% Registration Panel
ph=0.293;
php = ph*ysz;
hRegPanel = uipanel('Parent',guiFig,'Title','REGISTRATION','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

uicontrol('Parent',hRegPanel, 'Style', 'edit', 'String','Exp. Time:','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_RegExpTime = uicontrol('Parent',hRegPanel, 'Style', 'edit', 'String','0.05','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 50 20]);
handles.Button_RegLoadRef=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Load Reference','Enable','on','Position', [staticst php-70 100 20],'Callback',@LoadRef);
handles.Edit_RegFileName = uicontrol('Parent',hRegPanel, 'Style', 'edit', 'String','File Name','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 250 20]);
handles.Button_RegAlign=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Align','Enable','on','Position', [staticst php-100 100 20],'Callback',@Align);
handles.Button_RegShowRef=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Show Reference','Enable','on','Position', [staticst php-130 100 20],'Callback',@ShowRef);
handles.Button_RegTakeCurrent=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Take Current','Enable','on','Position', [staticst php-160 100 20],'Callback',@TakeCurrent);
handles.Button_RegTakeReference=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Take Reference','Enable','on','Position', [staticst+120 php-160 100 20],'Callback',@TakeReference);
handles.Button_RegCenterStage=uicontrol('Parent',hRegPanel, 'Style', 'pushbutton', 'String','Center Stage','Enable','on','Position', [staticst php-190 100 20],'Callback',@CenterStage);

handles.ActReg_check=uicontrol('Parent',hRegPanel,'Style','checkbox','String','Active Stabilization','Position',[editst+20 php-190 150 20],'Value',1);

BGh=100;
handles.ButtonGroup_RegCollectType=uibuttongroup('Parent',hRegPanel, 'Position', [.02 (php-220-BGh+30)/php .96 BGh/php]);
b1=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio', 'tag','None','String','No Registration','Enable','on','Position', [staticst BGh-30 250 20]);
b2=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio','tag','Self', 'String','Align to Self (Takes/Saves Reference Image)','Enable','on','Position', [staticst BGh-60 250 20]);
b3=uicontrol('Parent',handles.ButtonGroup_RegCollectType, 'Style', 'radio','tag','Ref','String','Align to Reference','Enable','on','Position', [staticst BGh-90 250 20]);

% LAMP Panel
ph=0.09;
php = ph*ysz;
hLampPanel = uipanel('Parent',guiFig,'Title','LAMP/LASER','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;
uicontrol('Parent',hLampPanel, 'Style', 'edit', 'String','Laser (Low):','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_LaserLow = uicontrol('Parent',hLampPanel, 'Style', 'edit', 'String','3.5','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 50 20]);
uicontrol('Parent',hLampPanel, 'Style', 'edit', 'String','Laser (High):','Enable','off','Position', [staticst php-70 100 20]);
handles.Edit_LaserHigh = uicontrol('Parent',hLampPanel, 'Style', 'edit', 'String','10','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 50 20]);
handles.Toggle_LaserLamp=uicontrol('Parent',hLampPanel, 'Style', 'toggle', 'String','Lamp','Enable','on','Position', [staticst+160 php-70 60 50],'BackgroundColor',[1 1 0],'Callback',@ToggleLamp);
handles.Toggle_IRLamp=uicontrol('Parent',hLampPanel, 'Style', 'toggle', 'String','IR Lamp','Enable','on','Position', [staticst+160+65 php-70 60 50],'BackgroundColor',[1 1 0],'Callback',@ToggleIRLamp);
handles.Toggle_LaserSet=uicontrol('Parent',hLampPanel, 'Style', 'pushbutton', 'String','Laser Setup','Enable','on','Position', [staticst++160+2*65 php-70 70 50],'BackgroundColor',[0.8 0.8 1],'Callback',@setLaser);

% CONTROL Panel
ph=0.2675;
dp=50;
dp0=0;
hControlPanel = uipanel('Parent',guiFig,'Title','CONTROL','Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','Number of Sequences:','Enable','off','Position', [staticst php-dp 150 20]);
handles.Edit_ControlNSequence = uicontrol('Parent',hControlPanel, 'Style', 'edit', 'String','20','Enable','on','BackgroundColor',[1 1 1],'Position', [editst+50 php-dp 50 20]);
handles.Button_ControlMotor=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Motor Control','Enable','on','Position', [staticst php-2*dp 85 40],'BackgroundColor',[0.5 1 1],'Callback',@MotorGui);
handles.Button_ControlFocusLampIR=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Lamp IR','Enable','on','Position', [staticst php-3*dp 85 40],'BackgroundColor',[1 1 .8],'Callback',@FocusLampIR);
handles.Button_ControlFocusLamp=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Lamp','Enable','on','Position', [staticst+90 php-3*dp 85 40],'BackgroundColor',[1 1 .8],'Callback',@FocusLamp);

handles.Button_ControlFocusLaserLow=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (Low)','Enable','on','Position', [staticst+200 php-3*dp 150 40],'BackgroundColor',[1 .8 .8],'Callback',@FocusLow);
handles.Button_ControlStart=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','START','Enable','on','Position', [staticst php-4*dp 150 40],'BackgroundColor',[0 1 0],'Callback',@Start);
handles.Button_ControlFocusLaserHigh=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','Focus Laser (High)','Enable','on','Position', [staticst+200 php-4*dp 150 40],'BackgroundColor',[1 0 0],'Callback',@FocusHigh);
handles.Button_ControlAbort=uicontrol('Parent',hControlPanel, 'Style', 'pushbutton', 'String','ABORT','Enable','on','Position', [staticst+100 php-5*dp 150 30],'BackgroundColor',[1 0 1],'Callback',@Abort);

%% Setup GUI Values

properties2gui();
CenterStage;

%% Figure Callbacks

    function LoadRef(~,~)
        obj.R3DObj.gui_getimagefile();
        set(handles.Edit_RegFileName,'String',obj.R3DObj.ImageFile);
    end

    function Align(~,~)
        gui2properties();
        obj.LampObj660.SetPower(obj.LampPower);
        pause(obj.LampWait);
        obj.CameraObj.ExpTime_Capture=obj.ExpTime_Capture; %need to update when changing edit box
        obj.CameraObj.AcquisitionType = 'capture';
        obj.CameraObj.setup_acquisition();
        obj.R3DObj.align2imageFit();
        obj.LampObj660.SetPower(0);
    end

    function ShowRef(~,~)
        obj.R3DObj.gui_showrefimage();
    end

    function TakeReference(~,~)
        gui2properties();
        if ~exist(obj.SaveDir,'dir');mkdir(obj.SaveDir);end
        timenow=clock;
        s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];

        obj.LampObj660.SetPower(obj.LampPower);
        pause(obj.LampWait);
        obj.R3DObj.takerefimage();
        obj.LampObj660.SetPower(0);
        pause(obj.LampWait);
        f=fullfile(obj.SaveDir,[obj.BaseFileName s '_ReferenceImage']);
        Image_Reference=obj.R3DObj.Image_Reference;
        obj.MotorObj.get_position;
        cellpos=obj.MotorObj.Position;
        save(f,'Image_Reference','cellpos');        
    end

    function TakeCurrent(~,~)
        gui2properties();
        obj.CameraObj.ROI=obj.getROI('R');
        obj.CameraObj.ExpTime_Capture=obj.ExpTime_Capture; %need to update when changing edit box
        obj.CameraObj.AcquisitionType = 'capture';
        obj.CameraObj.setup_acquisition();
        obj.LampObj660.SetPower(obj.LampPower);
        pause(obj.LampWait);
        obj.R3DObj.getcurrentimage();
        obj.LampObj660.SetPower(0);
    end

    function CenterStage(~,~)
        obj.StageObj.center();
    end

    function ToggleLamp(~,~)
        state=get(handles.Toggle_LaserLamp,'Value');
        if state
            obj.LampObj660.SetPower(obj.LampPower);
        else
            obj.LampObj660.SetPower(0);
        end
    end

    function ToggleIRLamp(~,~)
        state=get(handles.Toggle_LaserLamp,'Value');
        if state
            obj.LampObj850.SetPower(obj.IRLampPower);
        else
            obj.LampObj850.SetPower(0);
        end
    end
    
    function MotorGui(~,~)
        obj.guiMotor;
    end

    function setLaser(~,~)
        obj.guilaser;
    end
    function FocusLampIR(~,~)
        checkLiveview();
        gui2properties();
        obj.LampObj850.SetPower(obj.IRLampPower);
        obj.IRCameraObj.ROI=obj.getROI('IR');
        obj.IRCameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
        obj.IRCameraObj.AcquisitionType = 'focus';
        obj.IRCameraObj.setup_acquisition();
        obj.IRCameraObj.start_focus();
        %dipshow(out);
        obj.LampObj850.SetPower(0);
    end

    function FocusLamp(~,~)
        checkLiveview();
        gui2properties();
        obj.LampObj660.SetPower(obj.LampPower);
        obj.CameraObj.ROI=obj.getROI('R');
        obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
        obj.CameraObj.AcquisitionType = 'focus';
        obj.CameraObj.setup_acquisition();
        obj.CameraObj.start_focus();
        %dipshow(out);
        obj.LampObj660.SetPower(0);
    end

    function FocusLow(~,~)
        checkLiveview();
        gui2properties();
        obj.LaserSetup('on','low');
        obj.CameraObj.ROI=obj.getROI('R');
        obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
        obj.CameraObj.AcquisitionType = 'focus';
        obj.CameraObj.setup_acquisition();
        out=obj.CameraObj.start_focus();
        dipshow(out);
        obj.LaserSetup('off',[]);
    end

    function FocusHigh(~,~)
        checkLiveview();
        gui2properties();
        obj.LaserSetup('on','high');
        obj.CameraObj.ROI=obj.getROI('R');
        obj.CameraObj.ExpTime_Focus=obj.ExpTime_Focus_Set;
        obj.CameraObj.AcquisitionType = 'focus';
        obj.CameraObj.setup_acquisition();
        out=obj.CameraObj.start_focus();
        dipshow(out);
        obj.LaserSetup('off',[]);
    end

    function Abort(~,~)
        obj.AbortNow=1; 
    end

    function Start(~,~)
        checkLiveview();
        gui2properties();
        obj.StartSequence();
    end

    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end

    function zoom_set(~,~)
        zoom_val = get(handles.Popup_CameraDispZoom,'Value');
        switch zoom_val
            case 1
                obj.IRCameraObj.DisplayZoom = 0.5;
                obj.CameraObj.DisplayZoom = 0.5;
            case 2
                obj.IRCameraObj.DisplayZoom = 1;
                obj.CameraObj.DisplayZoom = 1;
            case 3
                obj.IRCameraObj.DisplayZoom = 2;
                obj.CameraObj.DisplayZoom = 2;
            case 4
                obj.IRCameraObj.DisplayZoom = 4;
                obj.CameraObj.DisplayZoom = 4;
            case 5
                obj.IRCameraObj.DisplayZoom = 10;
                obj.CameraObj.DisplayZoom = 10;
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
        obj.CameraROIIR=get(handles.Popup_CameraROIIR,'value');
        obj.ExpTime_Focus_Set=str2double(get(handles.Edit_CameraExpTimeFocusSet,'string'));
        obj.ExpTime_Sequence_Set=str2double(get(handles.Edit_CameraExpTimeSeqSet,'string'));
        obj.ExpTime_Capture=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.NumFrames=str2double(get(handles.Edit_CameraNumFrames,'string'));
        obj.ExpTime_Capture=str2double(get(handles.Edit_RegExpTime,'string'));
        obj.ReferenceFile=get(handles.Edit_RegFileName,'string');
        obj.LaserPowerLow=str2double(get(handles.Edit_LaserLow,'string'));
        obj.LaserPowerHigh=str2double(get(handles.Edit_LaserHigh,'string'));
        obj.NumSequences=str2double(get(handles.Edit_ControlNSequence,'string'));
        obj.RegType=get(get(handles.ButtonGroup_RegCollectType,'SelectedObject'),'Tag'); 
        obj.ActiveRegCheck=get(handles.ActReg_check,'Value');
    end
    function checkLiveview()
        figH=findobj('Type','figure');
        for ii=1:numel(figH)
            if strcmp(get(figH(ii),'name'),'CameraLive')
                close(get(figH(ii),'name'),'CameraLive')
                %error('Camera live view window is open, please close to proceed.');
            end
        end
    end
    function properties2gui()
        %Set GUI values from object properties
        set(handles.Edit_FileDirectory,'String',obj.SaveDir);
        set(handles.Edit_FileName,'String',obj.BaseFileName);
        set(handles.Popup_CameraGain,'value',obj.CameraGain);
        set(handles.Popup_CameraROI,'value',obj.CameraROI);
        set(handles.Popup_CameraROIIR,'value',obj.CameraROIIR);
        set(handles.Edit_CameraExpTimeFocusSet,'string',num2str(obj.ExpTime_Focus_Set));
        set(handles.Edit_CameraExpTimeSeqSet,'string',num2str(obj.ExpTime_Sequence_Set));
        set(handles.Edit_RegExpTime,'string',num2str(obj.ExpTime_Capture));
        set(handles.Edit_CameraNumFrames,'string',num2str(obj.NumFrames));
        set(handles.Edit_RegExpTime,'string',num2str(obj.ExpTime_Capture));
        set(handles.Edit_RegFileName,'string',obj.ReferenceFile);
        set(handles.Edit_LaserLow,'string',num2str(obj.LaserPowerLow));
        set(handles.Edit_LaserHigh,'string',num2str(obj.LaserPowerHigh));
        set(handles.Edit_ControlNSequence,'string',num2str(obj.NumSequences));
        set(handles.Edit_CameraExpTimeSeqActual,'String',num2str(obj.IRCameraObj.SequenceCycleTime));
        set(handles.ActReg_check,'Value',obj.ActiveRegCheck);
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

