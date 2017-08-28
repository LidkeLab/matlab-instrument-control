function guiLUT(obj)
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
    'SeqSRcollect.guiLUT','HandleVisibility','off','name','SRcollect.guiLUT','CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);

handles.Toggle_AutoScale=uicontrol('Parent',guiFig,'Style', 'Toggle', 'Value',0,'Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+1.5*pw+0.1 py-ph pw ph],'Callback',@ToggleAuto);
handles.Edit_LUTLow=uicontrol('Parent',guiFig,'Style', 'Edit', 'String','on/off','Enable','on','BackgroundColor',[0.8 0.8 1],'Units','normalized','Position', [px 0.1 pw ph],'Callback',@EditCallback);
handles.Edit_LUTHigh=uicontrol('Parent',guiFig,'Style', 'Edit', 'String','on/off','Enable','on','BackgroundColor',[0.8 0.8 1],'Units','normalized','Position', [px+3*pw 0.1 pw ph],'Callback',@EditCallback);

set(handles.Toggle_AutoScale,'String','Autoscale')
properties2gui();

    function properties2gui(~,~)
        set(handles.Toggle_AutoScale,'Value',obj.CameraObj.AutoScale);
        set(handles.Edit_LUTLow,'String',num2str(obj.CameraObj.LUTScale(1)));
        set(handles.Edit_LUTHigh,'String',num2str(obj.CameraObj.LUTScale(2)));
    end

    function gui2properties(~,~)
        obj.CameraObj.AutoScale=get(handles.Toggle_AutoScale,'Value');
        LUTL=str2double(get(handles.Edit_LUTLow,'String'));
        LUTH=str2double(get(handles.Edit_LUTHigh,'String'));
        obj.CameraObj.LUTScale=[LUTL, LUTH];
    end

    function FigureClose(~,~)
        gui2properties();
        delete(guiFig);
    end

    function ToggleAuto(~,~)
        gui2properties();
        state=get(handles.Toggle_AutoScale,'Value');
        obj.CameraObj.AutoScale=state;
    end

    function EditCallback(~,~)
       gui2properties(); 
    end
end