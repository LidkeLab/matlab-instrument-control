function guilaser(obj)
xsz=400;
ysz=300;
xst=200;
yst=100;
pw=.2;
ph=0.1;
px=0.1;
py=0.85;
guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SeqSRcollect.guilaser','HandleVisibility','off','name','SRcollect.guilaser','CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);


lasertag=obj.LaserObj.LaserTag;

for ii=1:length(lasertag)
    handles.(['CBox_Laser',lasertag{ii}])=uicontrol('Parent',guiFig,'Style','checkbox','String',['Laser ',lasertag{ii}],'Value',0,'Units','normalized','Position',[px,py-ii*ph,pw,ph]);
    handles.(['Edit_Laser',lasertag{ii}])=uicontrol('Parent',guiFig,'Style','edit','Enable','on','BackgroundColor',[1 1 1],'String','0','Units','normalized','position',[px+pw+0.05,py-ii*ph,pw/2,ph]);
end
uicontrol('Parent',guiFig,'Style','text','String','power','Units','normalized','position',[px+pw+0.05,py,pw/2,ph])
uicontrol('Parent',guiFig,'Style','text','String','Ex Laser','Units','normalized','position',[px+1.5*pw+0.05,py,pw,ph])
handles.Pop_ExLaser=uicontrol('Parent',guiFig,'Style', 'popupmenu', 'String',lasertag,'Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+1.5*pw+0.1 py-ph pw ph]);
handles.Button_LaserOn=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','on/off','Enable','on','BackgroundColor',[0.8 0.8 1],'Units','normalized','Position', [px 0.1 pw ph],'Callback',@ToggleLaser);

properties2gui();
    function properties2gui(~,~)
        N=length(lasertag);
        if ~isempty(obj.LaserState)
            for n=1:N
                set(handles.(['CBox_Laser',lasertag{n}]),'Value',obj.LaserState(n));
                set(handles.(['Edit_Laser',lasertag{n}]),'String',num2str(obj.LaserPower(n)));
            end
            set(handles.Pop_ExLaser,'Value',obj.ExLaser);
        end
    end
    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end

    function ToggleLaser(~,~)
        gui2properties();
        state=get(handles.Button_LaserOn,'Value');
        if state
            obj.LaserObj.SetPower(obj.LaserState,obj.LaserPower);
        else
            laserpower=zeros(size(obj.LaserPower));
            obj.LaserObj.SetPower(obj.LaserState,laserpower);
        end
    end

    function gui2properties(~,~)
        N=length(lasertag);
        laserstate=zeros(N,1);
        laserpower=zeros(N,1);
        for n=1:N
            state=get(handles.(['CBox_Laser',lasertag{n}]),'Value');
            power=str2double(get(handles.(['Edit_Laser',lasertag{n}]),'String'));
            laserstate(n)=state;
            laserpower(n)=power;
        end
        obj.LaserPower=laserpower;
        obj.LaserObj.LaserPowers=laserpower;
        obj.LaserState=laserstate;
        obj.ExLaser=get(handles.Pop_ExLaser,'Value');
    end
end