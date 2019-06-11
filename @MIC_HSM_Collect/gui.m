
function gui(obj)
% Create and then hide the UI as it is being constructed.

h = findall(0,'tag','HSM-Collect.gui');
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
    'HSM-Collect.gui','HandleVisibility','off','name','HSMcollect.gui','CloseRequestFcn',@FigureClose);

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

FlieDir=uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String', 'Save Directory:','Enable','off','Position', [staticst php-40 100 20]);
Edit_FileDir= uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 250 20]);
FileName=uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String', 'Base FileName:','Enable','off','Position', [staticst php-65 100 20]);
Edit_FileName= uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','Set Auto','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-65 250 20]);
FileType = uicontrol('Parent',hFilePanel, 'Style', 'edit', 'String','File type:','Enable','off','Position', [staticst php-90 100 20]);
Edit_saveFileType = uicontrol('Parent',hFilePanel, 'Style', 'popupmenu', 'String',{'.mat','.h5'},'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-90 250 20],'CallBack',@saveFile);


% Camera Panel
ph=0.3;
php = ph*ysz;
hCameraPanel = uipanel('Parent',guiFig,'Title','CAMERA','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

Y_Range = uicontrol('Parent',hCameraPanel, 'Style', 'text', 'String','Y Range:','Enable','off','Position', [staticst php-60 100 20]);
Y_Range = uicontrol('Parent',hCameraPanel, 'Style', 'popupmenu', 'String',{'32','64','128','256','405'},'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-60 250 20],'CallBack',@setmap);

ExposureTime = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Exp. Time Focus:','Enable','off','Position', [staticst php-100 140 20]);
Edit_ExposureTime = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Position', [editst+40 php-100 50 20]);
CameraExpTimeFocusActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Actual:','Enable','off','Position', [215 php-100 140 20]);
Edit_CameraExpTimeFocusActual = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','','Enable','off','Position', [330 php-100 50 20]);

ScansPerSecond = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Scans per second:','Enable','off','Position', [staticst php-130 140 20]);
Edit_ScansPerSecond = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','0.01','Enable','off','BackgroundColor',[1 1 1],'Position', [editst+40 php-130 50 20]);

NSeqBeforeRegistration = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','N_Seq Before Reg','Enable','off','Position', [215 php-130 140 20]);
Edit_NSeqBeforeRegistration = uicontrol('Parent',hCameraPanel, 'Style', 'edit','Enable','on','Position', [330 php-130 50 20]);

NumberofSteps = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Number of Steps per Scan:','Enable','off','Position', [staticst php-160 140 20]);
Edit_NumberofSteps = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','200','Enable','on','BackgroundColor',[1 1 1],'Position', [editst+40 php-160 50 20]);

NumberofScans = uicontrol('Parent',hCameraPanel, 'Style', 'edit', 'String','Number of Scans:','Enable','off','Position', [215 php-160 140 20]);
Edit_NumberofScans = uicontrol('Parent',hCameraPanel, 'Style','edit','Enable','on','BackgroundColor',[1 1 1],'Position', [330 php-160 50 20]);



% Registration Panel
ph=0.09;
php = ph*ysz;
hRegPanel = uipanel('Parent',guiFig,'Title','REGISTRATION','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;

CameraCalibration = uicontrol('Parent',hRegPanel, 'Style', 'toggle', 'String','Calibrate Camera:','Enable','on','Position', [staticst php-40 100 20],'Callback',{@CameraCalibration_Callback});

WavelengthCalibration =uicontrol('Parent',hRegPanel, 'Style', 'toggle',...
    'String','Calibrate Wavelength','Enable','on',...
    'Position', [staticst php-70 100 20],'Callback',{@WavelengthCalibration_Callback});



% LIGHTSOURCE Panel
ph=0.3;
hLampPanel = uipanel('Parent',guiFig,'Title','LIGHT SOURCE','Position',[(1-pw)/2 refh-ph-psep pw ph]);
refh=refh-ph-psep;


h488Panel=uipanel(hLampPanel,'Title','Laser 488 nm','Position',[1/6 1/6 1/6 5/6]);

Edit_LaserPower = uicontrol(h488Panel,'Style','edit',...
    'Position',[23 190 130 20]);

uicontrol(h488Panel,'Style','text','String','[0.08 - 3.274mW]',...
    'Position',[23 160 130 20]);


hlambdaPanel=uipanel(hLampPanel,'Title','Wavelength','Position',[2/6 1/6 1/6 5/6]);
Wavelength = uicontrol(hlambdaPanel,'Style','edit',...
    'Position',[23 190 130 20]);
Wavelength_info= uicontrol(hlambdaPanel,'Style','text','String','[500 800nm]',...
    'Position',[23 160 130 20]);


% CONTROL Panel
ph=0.190;
hControlPanel = uipanel('Parent',guiFig,'Title','CONTROL','Position',[(1-pw)/2 refh-ph-psep pw ph]);
php = ph*ysz;
Toggle_LaserLamp=uicontrol('Parent',hControlPanel,'Style', 'toggle', 'String','Lamp','Enable','on','Position',...
    [staticst php-60 150 40],'BackgroundColor',[1 1 .8],'Callback',{@ToggleLamp_Callback});
Toggle_Laser=uicontrol('Parent',hControlPanel,'Style', 'toggle', 'String','Laser','Enable','on','Position',...
    [staticst+200 php-60 150 40],'BackgroundColor',[1 1 .8],'Callback',{@ToggleLaser_Callback});
ScanFocus = uicontrol('Parent',hControlPanel,'Style', 'toggle', 'String', 'Scan Focus','Enable','on','Position',...
    [staticst php-110 150 40],'BackgroundColor',[1 1 .8],'Callback',{@scanFocus_Callback});

StartSequence = uicontrol('Parent',hControlPanel,'Style', 'toggle', 'String', 'Start Sequence','Enable','on','Position',...
    [staticst+200 php-110 150 40],'BackgroundColor',[1 1 .8],'Callback',{@single_scan_sequence_Callback});
LucaLive = uicontrol('Parent',hControlPanel,'Style', 'toggle', 'String', 'Luca Live','Enable','on','Position',...
    [staticst php-158 150 40],'BackgroundColor',[1 1 .8],'Callback',{@start_focus_Callback});


% Make the UI visible.
guiFig.Visible = 'on';


%% Setup GUI Values

properties2gui();

%% Figure Callbacks
%
% function y_range_set(~,~)
% str = obj.String;
% val = obj.Value;
% % Set current data to the selected data set.
% switch str{val};
%     case '32' % User selects Peaks.
%         current_data = peaks_data;
%     case '64' % User selects Membrane.
%         current_data = membrane_data;
%     case '128' % User selects Sinc.
%         current_data = sinc_data;
%     case '256' % User selects Sinc.
%         current_data = sinc_data;
%
%     case '405' % User selects Sinc.
%         current_data = sinc_data;
% end
% end
%
    function ToggleLaser_Callback(~,~)
        gui2properties();
        if obj.LaserObj.IsOn == 0
            obj.LaserObj.setPower(obj.LaserObj.MaxPower)
            obj.LaserObj.on();
        else
            obj.LaserObj.off
            properties2gui();
        end
    end

    function ToggleLamp_Callback(~,~)
        gui2properties();
        stateLamp1=get(Toggle_LaserLamp,'Value');
        if stateLamp1
            obj.LampObj.setPower(obj.LampPower);
            obj.LampObj.on;
        else
            obj.LampObj.off;
            %            pause(obj.LampWait);
            properties2gui();
        end
    end


    function scanFocus_Callback(~,~)
        gui2properties();
        if obj.LaserObj.IsOn ==1
            obj.LaserObj.off
            obj.scanFocus();
        else
        obj.scanFocus();
        properties2gui();
        end
    end

    function start_focus_Callback(~,~)
        gui2properties();
        obj.CameraLuca.DisplayZoom = 1;
        obj.CameraLuca.start_focus;
        properties2gui();
    end

    function single_scan_sequence_Callback(~,~)
        gui2properties();
        obj.LaserObj.setPower(obj.LaserObj.MaxPower)
        obj.single_scan_sequence();
        properties2gui();
    end

%      function export_data_Callback(~,~)
%         gui2properties();
%         obj.export_data();
%     end
%
%     function CameraCalibration_Callback(~,~)
%         gui2properties();
%         obj.CameraCalibration();
%     end
%
%     function WavelenghtCalibration_Callback(~,~)
%         gui2properties();
%         obj.WavelenghtCalibration();
%     end
% %
% %     function SaveReference(~,~)
% %         obj.saveref();
% %         properties2gui();
% %     end
%



    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end


%
    function gui2properties()
        %         %Get GUI values and update to object properties
        
        obj.NSteps=str2double(get(Edit_NumberofSteps,'string'));
        obj.NSeqBeforeRegistration=str2double(get(Edit_NSeqBeforeRegistration,'string'));
        obj.Nsequences=str2double(get(Edit_NumberofScans,'string'));
        %         obj.SaveDir=get(Edit_FileDirectory,'String');
        
        
        
        %         obj.BaseFileName=get(Edit_FileName,'String');
        %         obj.ExpTime_Focus_Set=str2double(get(Edit_CameraExpTimeFocusSet,'string'));
        %         obj.ExpTime_Sequence_Set=str2double(get(Edit_CameraExpTimeSeqSet,'string'));
        %         obj.NumFrames=str2double(get(Edit_CameraNumFrames,'string'));
        %         obj.NumberofSteps=str2double(get(Edit_ControlNSequence,'string'));
        %         obj.RegType=get(get(ButtonGroup_RegCollectType,'SelectedObject'),'Tag');
        
    end

    function properties2gui()
        %         %Set GUI values from object properties
        %         set(Edit_FileDirectory,'String',obj.SaveDir);
        %         set(Edit_FileName,'String',obj.BaseFileName);
        %
        %         set(Edit_CameraExpTimeFocusSet,'string',num2str(obj.ExpTime_Focus_Set));
        %         set(Edit_CameraExpTimeSeqSet,'string',num2str(obj.ExpTime_Sequence_Set));
        %          set(Edit_LaserPower,'string',num2str(obj.Laserobj.MaxPower));
        %         set(Edit_CameraNumFrames,'string',num2str(obj.NumFrames));
        %         set(Edit_RegFileName,'string',obj.R3DObj.RefImageFile);
        %
        %         set(IX71LampPower,'string',obj.LampPower);
        %
        %         set(FocusIX71Lamp,'value',obj.focusLampFlag);
        %         set(Edit_ControlNSequence,'string',num2str(obj.NumSequences));
        %         set(Edit_CameraExpTimeSeqActual,'String',num2str(obj.CameraObj.SequenceCycleTime));
        %
        %         switch obj.RegType
        %             case 'None'
        %                 set(ButtonGroup_RegCollectType,'SelectedObject',b1);
        %             case 'Self'
        %                 set(ButtonGroup_RegCollectType,'SelectedObject',b2);
        %             case 'Ref'
        %                 set(ButtonGroup_RegCollectType,'SelectedObject',b3);
    end
end
