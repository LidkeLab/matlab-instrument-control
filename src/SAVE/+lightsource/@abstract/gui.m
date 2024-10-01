function guiFig = gui(obj)
%gui Graphical User Interface to MIC_LightSource_Abstarct

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 100 450 300]);

%Construct the components
handles.output = guiFig;
guidata(guiFig,handles);

%set the basic prameters
minPower=obj.MinPower;
maxPower=obj.MaxPower;
unitPower=obj.PowerUnit;

handles.sliderPower=uicontrol('Parent',guiFig,'Style','slider','Min',minPower,...
    'Max',maxPower,'Value',minPower,'SliderStep',[0.1 0.1],...
    'Position', [118 220 200 35],'Tag','positionSlider','Callback',@sliderfn);
handles.textMinPower = uicontrol('Style','text','String','Min Power',...
    'Position',[35 240,80,15],'FontSize',10);
handles.valueMinPower = uicontrol('Style','text','String',[num2str(minPower),' ',unitPower],...
    'Position',[48 220,70,20]);
handles.textMaxPower = uicontrol('Style','text','String','Max Power',...
    'Position',[325 240,80,15],'FontSize',10);
handles.valueMaxPower = uicontrol('Style','text','String',[num2str(maxPower),' ',unitPower],...
   'Position',[337 220,70,20]);
handles.textSetPower = uicontrol('Style','text','String','Set Power',...
    'Position',[90 150,100,15],'FontSize',10);
handles.SetPower = uicontrol('Style','edit',...
    'Position',[190 143,80,25],'FontSize',10,'Tag','positionEdit','Callback',@setPower);
handles.textPowerUnit=uicontrol('Style','text','String',unitPower,...
    'Position',[260 150,50,15],'FontSize',10);
handles.Toggle_Light=uicontrol('Style','togglebutton',...
    'String','Off','Position',[185 50,70,50],...
    'BackgroundColor',[0.8  0.8  0.8],'Tag','positionButton','Callback',@ToggleLight);

align([handles.textMinPower,handles.valueMinPower],'Center','None');
align([handles.textMaxPower,handles.valueMaxPower],'Center','None');
align([handles.sliderPower,handles.SetPower,handles.Toggle_Light],'Center','None');


% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%Initialize GUI properties
properties2gui();

    function closeFigure(~,~)
        %close the figure
        gui2properties();
        delete(obj.GuiFigure);
    end

%Callback function for slider
    function sliderfn(~,~)
        % drag the slider
        sliderValue=get(handles.sliderPower,'Value');
        set(handles.SetPower,'String',num2str(sliderValue))
        obj.setPower(sliderValue)
    end

%Callback function to set Power
    function setPower(~,~)
        %set the power
        textValue=str2double(get(handles.SetPower,'String'));
        if textValue > obj.MaxPower || isnan(textValue)
            error('Choose a number for Power between [MinPower,MaxPower]')
        end
        set(handles.sliderPower,'Value',textValue)
         obj.setPower(textValue)
    end

%Callback function for toggle button
    function ToggleLight(~,~)
        %change On/Off buttom
        state=get(handles.Toggle_Light,'Value');
        if state
         %   obj.Power=str2double(get(handles.SetPower,'String'));
            obj.on();
            set(handles.Toggle_Light,'BackgroundColor','red');%,[0.6 0.8 0])
            set(handles.Toggle_Light,'String','On')
            if isempty(str2double(get(handles.SetPower,'String')))
                error('Choose a proper value for Power to turn on Light Source')
            end
        else
            set(handles.Toggle_Light,'BackgroundColor',[0.8  0.8  0.8])
            set(handles.Toggle_Light,'String','Off')
            obj.off();
        end
    end


    function gui2properties()
        % update properties from gui
        obj.Power=str2double(get(handles.SetPower,'String'));
        % change LightState for obj
        state=get(handles.Toggle_Light,'Value');
        if state
            obj.IsOn=1;
        else
            obj.IsOn=0;
        end
    end

    function properties2gui()
        % update gui from properties
        if isempty(obj.Power) || isnan(obj.Power)
            obj.Power=obj.MinPower;
        end
        set(handles.sliderPower,'Value',obj.Power)
        set(handles.SetPower,'String',num2str(obj.Power));
        set(handles.Toggle_Light,'Value',obj.IsOn);
        if obj.IsOn==1
            set(handles.Toggle_Light,'String','On');
            set(handles.Toggle_Light,'BackgroundColor','red');
        else
            set(handles.Toggle_Light,'String','Off');
            set(handles.Toggle_Light,'BackgroundColor',[.8 .8 .8]);
        end
    end
end

