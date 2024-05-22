function hsmviewer(obj)
h = findall(0,'tag','HSM-Viewer.gui');
if ~(isempty(h))
    figure(h);
    return;
end
%%
dispFig = figure('Units','pixels','Position',[100 100 900 600],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag','HSM-Viewer.gui','CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');


set(dispFig,'Color',defaultBackground)
handles.output = dispFig;
guidata(dispFig,handles)

obj.HsmViewer = handles;
% display panel components
handles.Axis_imag = axes('Parent',dispFig,'Units','Normalized','Position',[.0 .15 .65 .8],'Color',[0 0 0]);
setappdata(handles.Axis_imag,'imgs',[])
set(handles.Axis_imag,'Ydir','reverse');

handles.Axis_spec = axes('Parent',dispFig,'Units','Normalized','Position',[.71 .15 .27 .4],'Color',[1 1 1]);
set(handles.Axis_spec,'FontSize',9);

handles.Edit_zscale = uicontrol('Parent',dispFig,'Style','edit','String','[100, 120]','Units','Normalized','Position',...
    [0.0 .95 .11 .05],'FontSize',12,'BackgroundColor',defaultBackground,'ForegroundColor',[0,0,0],'CallBack',@setZscale);

handles.Checkbox_autoscale=uicontrol('Parent',dispFig,'Style', 'checkbox', 'String','auto scale','Enable','on','Value',1,'Units','Normalized','Position',...
    [0.12 0.95 0.1 0.05],'FontSize',11,'BackgroundColor',defaultBackground);

handles.Text_framerate = uicontrol('Parent',dispFig,'Style','text','String','0.00 fps','Units','Normalized','Position',...
    [0.22 .95 .11 .04],'FontSize',12,'BackgroundColor',defaultBackground,'ForegroundColor',[0,0,0]);

handles.Push_abort=uicontrol('Parent',dispFig,'Style', 'push', 'String','Abort','Enable','on','Units','Normalized','Position',...
    [0.05 0.05 0.1 0.05],'BackgroundColor',[0.8 0.8 .8],'Callback',@abort);



obj.HsmViewer = handles;
dispFig.Visible = 'on';
properties2gui()

    function setZscale(h,~)
        gui2properties()
        
    end

    function abort(h,~)
        obj.abort();
    end

    function gui2properties()
        %Get GUI values and update to object properties
        
        obj.Zscale=str2num(get(handles.Edit_zscale,'string'));
        
    end
    function properties2gui()
        %Set GUI values from object properties
        set(handles.Edit_zscale,'String',num2str(obj.Zscale));
        
    end

    

    function FigureClose(~,~)
        gui2properties();
        delete(dispFig);
        obj.abort();
    end
end