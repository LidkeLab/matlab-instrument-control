function gui(obj)
% gui: Graphical user interface for MIC_MCLNanoDrive
%

h = findall(0,'tag','MIC_MCLNanoDrive_gui');
if ~(isempty(h))
    figure(h);
    return;
end



xsz=300;
ysz=400;
xst=100;
yst=100;
bszx=75;
bszy=30;
txsz = 75;
txszy = 20;
etxsz = 50;

guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,...
    'Tag','MIC_MCLNanoDrive_gui','HandleVisibility','off');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground)

guiFig.WindowButtonDownFcn=@properties2gui;


%top
uicontrol('Parent',guiFig, 'Style', 'text', 'String', ...
    'X Position (um)','Position', [10 ysz-(bszy+10) txsz bszy]);
uicontrol('Parent',guiFig, 'Style', 'text', 'String', ...
    'Y Position (um)','Position', [10 ysz-2*(bszy+10) txsz bszy]);
uicontrol('Parent',guiFig, 'Style', 'text', 'String', ...
    'Z Position (um)','Position', [10 ysz-3*(bszy+10) txsz bszy]);

handles.edit_XCurrent = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [15+txsz ysz-(bszy+10)+10 etxsz txszy],'enable','off');
handles.edit_YCurrent = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [15+txsz ysz-2*(bszy+10)+10 etxsz txszy],'enable','off');
handles.edit_ZCurrent = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [15+txsz ysz-3*(bszy+10)+10 etxsz txszy],'enable','off');

handles.edit_XSet = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [50+txsz+etxsz ysz-(bszy+10)+10 etxsz txszy],'BackgroundColor',[1 1 1]);
handles.edit_YSet = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [50+txsz+etxsz ysz-2*(bszy+10)+10 etxsz txszy],'BackgroundColor',[1 1 1]);
handles.edit_ZSet = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [50+txsz+etxsz ysz-3*(bszy+10)+10 etxsz txszy],'BackgroundColor',[1 1 1]);

properties2gui();

%Step Size
uicontrol('Parent',guiFig, 'Style', 'text', 'String', ...
    'Step Size (um)','Position', [10 ysz-4*(bszy+10) txsz bszy]);
handles.edit_StepSize = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '0.1','Position', [10 ysz-5*(bszy+10)+20 etxsz txszy]);

%Set
handles.button_SetPosition = uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', ...
    'Set Position','Position', [50+txsz+etxsz ysz-5*(bszy+10)+20 bszx bszy],...
    'Callback',@(hObject,eventdata)set_pushbutton_Callback);

%XY
handles.panel_XY = uipanel(...
    'Parent',guiFig,...
    'Units','characters',...
    'Title','X Y position',...
    'Clipping','on',...
    'Position',[6 0.769230769230762 30.4 11.6153846153846],...
    'Tag','xy_uipanel');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)left_pushbutton_Callback,...
    'FontSize',9,...
    'FontWeight','bold',...
    'Position',[6.00000000000001 4.15384615384616 6 2.5],...
    'String','<',...
    'Tag','left_pushbutton');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)right_pushbutton_Callback,...
    'FontSize',10,...
    'FontWeight','bold',...
    'Position',[17.6 4.15384615384616 6 2.53846153846154],...
    'String','>',...
    'Tag','right_pushbutton');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)down_pushbutton_Callback,...
    'FontSize',10,...
    'FontWeight','bold',...
    'Position',[11.6000000000001 1.6923076923077 6 2.5],...
    'String','\/',...
    'Tag','down_pushbutton');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)up_pushbutton_Callback,...
    'FontSize',10,...
    'FontWeight','bold',...
    'Position',[11.8 6.61538461538463 6 2.53846153846154],...
    'String','/\',...
    'Tag','up_pushbutton');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Position',[0.8 4.84615384615385 5 1.23076923076923],...
    'String','x(-)',...
    'Style','text',...
    'Tag','text8');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Position',[12.2 9.23076923076924 5 1.23076923076923],...
    'String','y(-)',...
    'Style','text',...
    'Tag','text9');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Position',[12 0.461538461538462 5 1.23076923076923],...
    'String','y(+)',...
    'Style','text',...
    'Tag','text10');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Position',[24.4 4.92307692307693 5 1.23076923076923],...
    'String','x(+)',...
    'Style','text',...
    'Tag','text11');

uicontrol(...
    'Parent',handles.panel_XY,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)center_pushbutton_Callback,...
    'Position',[11.8 4.15384615384616 6 2.538],...
    'String','cen',...
    'TooltipString','Center stage in range of travel',...
    'Tag','center_pushbutton');

%Z
handles.panel_Z = uipanel(...
    'Parent',guiFig,...
    'Units','characters',...
    'Title','Z Position',...
    'UserData',[],...
    'Clipping','on',...
    'Position',[40.0000000000001 1.53846153846153 15.8 10.2307692307692],...
    'Tag','z_uipanel');

uicontrol(...
    'Parent',handles.panel_Z,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)zdown_pushbutton_Callback,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Position',[5.00000000000001 1.76923076923077 6 2.53846153846154],...
    'String','\/',...
    'Tag','zdown_pushbutton');

uicontrol(...
    'Parent',handles.panel_Z,...
    'Units','characters',...
    'Callback',@(hObject,eventdata)zup_pushbutton_Callback,...
    'FontSize',12,...
    'FontWeight','bold',...
    'Position',[5 4.92307692307693 6 2.5],...
    'String','/\',...
    'Tag','zup_pushbutton');

uicontrol(...
    'Parent',handles.panel_Z,...
    'Units','characters',...
    'Position',[5.2 7.61538461538462 5 1.23076923076923],...
    'String','z(-)',...
    'Style','text',...
    'Tag','text12');

uicontrol(...
    'Parent',handles.panel_Z,...
    'Units','characters',...
    'Position',[5.2 0.461538461538462 5 1.23076923076923],...
    'String','z(+)',...
    'Style','text',...
    'Tag','text13');


guiFig.WindowScrollWheelFcn=@gui_ZScroll; %Use mouse wheel for piezo focus

obj.GuiFigure=guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

guidata(guiFig,handles)

    function gui2properties(~,~)
        % Sets the object properties based on the GUI widgets
    end

    function properties2gui(~,~)
        % Set the GUI widgets based on the object properties
        X=obj.Position();
        set(handles.edit_XCurrent,'String',num2str(X(1)));
        set(handles.edit_YCurrent,'String',num2str(X(2)));
        set(handles.edit_ZCurrent,'String',num2str(X(3)));
        set(handles.edit_XSet,'String',num2str(X(1)));
        set(handles.edit_YSet,'String',num2str(X(2)));
        set(handles.edit_ZSet,'String',num2str(X(3)));
    end

    function set_pushbutton_Callback(~,~)
        X(1)=str2double(get(handles.edit_XSet,'String'));
        X(2)=str2double(get(handles.edit_YSet,'String'));
        X(3)=str2double(get(handles.edit_ZSet,'String'));
        obj.setPosition(X);
        properties2gui()
    end

    function center_pushbutton_Callback(~,~)
        obj.center();
        properties2gui()
    end

    function left_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(1)=X(1)-d;
        obj.setPosition(X);
        properties2gui()
    end

    function right_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(1)=X(1)+d;
        obj.setPosition(X);
        properties2gui()
    end

    function up_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(2)=X(2)+d;
        obj.setPosition(X);
        properties2gui()
    end

    function down_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(2)=X(2)-d;
        obj.setPosition(X);
        properties2gui()
    end

    function zup_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(3)=X(3)+d;
        obj.setPosition(X);
        properties2gui()
    end

    function zdown_pushbutton_Callback(~,~)
        X = obj.Position;
        d = str2double(get(handles.edit_StepSize,'String'));
        X(3)=X(3)-d;
        obj.setPosition(X);
        properties2gui()
    end

    function gui_ZScroll(~,Callbackdata)
        if Callbackdata.VerticalScrollCount>0 %Move Down
            zdown_pushbutton_Callback()
        else %Move up
            zup_pushbutton_Callback()
        end
    end



end

