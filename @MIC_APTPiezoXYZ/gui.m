function gui_piezo=gui(obj)
h = findall(0,'tag','gui_Piezo.gui');
if ~(isempty(h))
    figure(h);
    return;
end
%%
xsz=350;
ysz=250;
xst=100;
yst=100;
pw=.95;
psep=.01;
staticst=10;
editst=110;
ph=0.2;
php = ph*ysz;
%refh=refh-ph-psep;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SRcollect.gui','HandleVisibility','off','name','PiezoStage.gui','CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);
refh=1;

handles.Button_xMinusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','X-','Enable','on','Position', [staticst+95 php+120 60 60],'BackgroundColor',[1 0.4 0],'Callback',@xMinusLarge);
handles.Button_yMinusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Y-','Enable','on','Position', [staticst+170 php+45 60 60],'BackgroundColor',[1 0.4 0],'Callback',@yMinusLarge);
handles.Button_yPlusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Y+','Enable','on','Position', [staticst+20 php+45 60 60],'BackgroundColor',[1 0.4 0],'Callback',@yPlusLarge);
handles.Button_xPlusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','X+','Enable','on','Position', [staticst+95 php-30 60 60],'BackgroundColor',[1 0.4 0],'Callback',@xPlusLarge);
handles.Button_xMinusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','x-','Enable','on','Position', [staticst+110 php+90 30 30],'BackgroundColor',[0.1 .6 .6],'Callback',@xMinusSmall);
handles.Button_yMinusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','y-','Enable','on','Position', [staticst+140 php+60 30 30],'BackgroundColor',[0.1 0.6 0.6],'Callback',@yMinusSmall);
handles.Button_yPlusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','y+','Enable','on','Position', [staticst+80 php+60 30 30],'BackgroundColor',[0.1 0.6 0.6],'Callback',@yPlusSmall);
handles.Button_xPlusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','x+','Enable','on','Position', [staticst+110 php+30 30 30],'BackgroundColor',[0.1 .6 .6],'Callback',@xPlusSmall);
handles.Button_zMinusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Z-','Enable','on','Position', [staticst+255 php-20 60 60],'BackgroundColor',[1 0.4 0],'Callback',@zMinusLarge);
handles.Button_zPlusLarge=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','Z+','Enable','on','Position', [staticst+255 php+100 60 60],'BackgroundColor',[1 0.4 0],'Callback',@zPlusLarge);
handles.Button_zMinusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','z-','Enable','on','Position', [staticst+270 php+40 30 30],'BackgroundColor',[0 0.7 0.7],'Callback',@zMinusSmall);
handles.Button_zPlusSmall=uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String','z+','Enable','on','Position', [staticst+270 php+70 30 30],'BackgroundColor',[0 0.7 0.7],'Callback',@zPlusSmall);

    function gui2properties()
        % Sets the object properties based on the GUI widgets
    end

    function properties2gui()
 
    end

% X
    function xMinusLarge(~,~)
        X=obj.Position;
        Xstep=[obj.PiezoLargeStep 0 0]
        obj.setPosition(X-Xstep)
        properties2gui()
    end

    function xMinusSmall(~,~)
        X=obj.Position;
        Xstep=[obj.PiezoSmallStep 0 0]
        obj.setPosition(X-Xstep)
        properties2gui()
    end

    function xPlusLarge(~,~)
        X=obj.Position;
        Xstep=[obj.PiezoLargeStep 0 0]
        obj.setPosition(X+Xstep)
        properties2gui()
    end

    function xPlusSmall(~,~)
        X=obj.Position;
        Xstep=[obj.PiezoSmallStep 0 0]
        obj.setPosition(X+Xstep)
        properties2gui()
    end
% Y
    function yMinusLarge(~,~)
        Y=obj.Position;
        Ystep=[0 obj.PiezoLargeStep 0]
        obj.setPosition(Y-Ystep)
        properties2gui()
    end

    function yMinusSmall(~,~)
        Y=obj.Position;
        Ystep=[0 obj.PiezoSmallStep 0]
        obj.setPosition(Y-Ystep)
        properties2gui()
    end

    function yPlusLarge(~,~)
        Y=obj.Position;
        Ystep=[0 obj.PiezoLargeStep 0]
        obj.setPosition(Y+Ystep)
        properties2gui()
    end

    function yPlusSmall(~,~)
        Y=obj.Position;
        Ystep=[0 obj.PiezoSmallStep 0]
        obj.setPosition(Y+Ystep)
        properties2gui()
    end
% Z
    function zMinusLarge(~,~)
        Z=obj.Position;
        Zstep=[0 0 obj.PiezoLargeStep]
        obj.setPosition(Z-Zstep)
        properties2gui()
    end

    function zPlusLarge(~,~)
        Z=obj.Position;
        Zstep=[0 0 obj.PiezoLargeStep]
        obj.setPosition(Z+Zstep)
        properties2gui()
    end

    function zMinusSmall(~,~)
        Z=obj.Position;
        Zstep=[0 0 obj.PiezoSmallStep]
        obj.setPosition(Z-Zstep)
        properties2gui()
    end

    function zPlusSmall(~,~)
        Z=obj.Position;
        Zstep=[0 0 obj.PiezoSmallStep]
        obj.setPosition(Z+Zstep)
        properties2gui()
    end

    function figureClose(~,~)
       % gui2properties();
        delete(guiFig);
    end
end