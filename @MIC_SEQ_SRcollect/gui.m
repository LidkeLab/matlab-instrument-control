function guiFig = gui(obj) % new SEQAutoCollect
%gui Graphical User Interface to ExampleInstrument
%   Must contain gui2properties() and properties2gui() functions

% Ensure only one sequential microscope GUI is opened at a time.
h = findall(0,'tag','SeqSRcollect.gui');
if ~(isempty(h))
    figure(h);
    return;
end

xsz=600;
ysz=600;
xst=200;
yst=200;
pw=.9;
psep=.03;
staticst=30;
editst=120;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SeqSRcollect.gui','HandleVisibility','off','name','SeqAutoCollect.gui');%,'CloseRequestFcn',@FigureClose);

obj.GuiFigureMain=guiFig;
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);

% File Panel
ph=0.2;
php = ph*ysz*1;
%hFilePanel = uipanel('Parent',guiFig,'Title','FILE','Position',[(1-pw)/2 (refh-ph-psep)*1 pw*1 ph*1]);
%refh=refh-ph-psep;

uicontrol('Parent',guiFig, 'Style', 'edit', 'String', 'Save Directory:','Enable','off','Position', [staticst php-10 100 20]);
handles.Edit_SaveDirectory = uicontrol('Parent',guiFig, 'Style', 'edit', 'String','','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-10 350 20]);
uicontrol('Parent',guiFig, 'Style', 'edit', 'String', 'Coverslip Name:','Enable','off','Position', [staticst php-40 100 20]);
handles.Edit_CoverSlipName = uicontrol('Parent',guiFig, 'Style', 'edit', 'String','','Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-40 350 20]);
uicontrol('Parent',guiFig, 'Style', 'edit', 'String', 'Label Number:','Enable','off','Position', [staticst php-70 100 20]);
handles.Edit_LabelNumber = uicontrol('Parent',guiFig, 'Style', 'popupmenu', 'String',{'1','2','3','4','5','6','7','8'},'Enable','on','BackgroundColor',[1 1 1],'Position', [editst php-70 350 20]);

handles.Button_Loadsample=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Load Sample','Enable','on','Position', [editst-90 php+30 70 30],'BackgroundColor',[1 1 0],'Callback',@loadsample);
handles.Button_Unloadsample=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Unload Sample','Enable','on','Position', [editst-15 php+30 100 30],'BackgroundColor',[1 1 0],'Callback',@unloadsample);
handles.Button_ControlFocusLaserHigh=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Reset SCMOS','Enable','on','Position', [editst+90 php+30 100 30],'BackgroundColor',[1 0 0],'Callback',@resetSCMOS);
handles.Button_FindCoverslip=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','FindCoverslip','Enable','on','Position', [editst+195 php+30 70 30],'BackgroundColor',[0.5 0.9 0],'Callback',@findCoverslip);
handles.Button_Abort=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Abort','Enable','on','Position', [editst-90 php+75 70 30],'BackgroundColor',[0.3 0.3 1],'Callback',@abort);
handles.Button_PhotoBleach=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Photobleach','Enable','on','Position', [editst-15 php+75 100 30],'BackgroundColor',[1 0 1],'Callback',@photobleach);
handles.Button_AutoCollect=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', 'Autocollect','Enable','on','Position', [editst+90 php+75 100 30],'BackgroundColor',[1 1 1],'Callback',@autocollect);
handles.Button_PSFcollect=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', 'PSFcollect','Enable','on','Position', [editst+195 php+75 100 30],'BackgroundColor',[0.5 0.5 1],'Callback',@PSFcollect);
handles.Button_SCMOSgui=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', 'SCMOS gui','Enable','on','Position', [editst+300 php+75 100 30],'BackgroundColor',[0.5 1 0.5],'Callback',@SCMOSgui);


for ii=1:10
    for jj=1:10
        % create  100 pushbuttons with callback functions
        S=sprintf('%d,%d',ii,jj);
        uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String',S,'Enable','on','BackgroundColor',[0 1 0],'Position',[editst-20+33*10-33*jj php+125+32*10-32*ii 35 35],'Callback',@exposeGridPoint);
    end
end

properties2gui()

    function exposeGridPoint(Source,~)
        gui2properties();
        A=sscanf(Source.String,'%d,%d');
        obj.CurrentGridIdx=A';
        obj.exposeGridPoint();
    end

    function autocollect(~,~)
        gui2properties();
        obj.autoCollect()
    end
 
    function findCoverslip(~,~) 
       obj.findCoverSlipFocus() 
    end

    function loadsample(~,~)
       % checkLiveview();
        gui2properties();
        obj.loadSample;
    end

    function unloadsample(~,~)
     %   checkLiveview();
        gui2properties();
        obj.unloadSample();
    end

    function resetSCMOS(~,~)
      %  checkLiveview();
      obj.CameraSCMOS.reset();
    end

    function abort(~,~)
       obj.CameraSCMOS.abort(); 
    end

    function photobleach(~,~)
       obj.Use405=1;
       obj.LaserPower405Activate=5;
       obj.IsBleach=1;
       obj.autoCollect(1)   
       obj.IsBleach=0;
    end

    function PSFcollect(~,~)
       obj.PSFcollect();  
    end

    function SCMOSgui(~,~)
       obj.CameraSCMOS.gui; 
    end
%  All figure have these functions but will be different contents

    function gui2properties()
        % Sets the object properties based on the GUI widgets
        obj.TopDir=handles.Edit_SaveDirectory.String;
        obj.CoverslipName=handles.Edit_CoverSlipName.String;
        obj.LabelIdx=handles.Edit_LabelNumber.Value;
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties
        handles.Edit_SaveDirectory.String=obj.TopDir;
        handles.Edit_CoverSlipName.String=obj.CoverslipName;
        handles.Edit_LabelNumber.Value=obj.LabelIdx;
    end

end

