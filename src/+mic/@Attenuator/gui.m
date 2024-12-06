function guiFig = gui(obj)
%gui Graphical User Interface foe attenuator

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end


%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 200 450 190]);

%Construct the components
handles.output = guiFig;
guidata(guiFig,handles);

minTransmission=obj.MinTransmission;
maxTransmission=obj.MaxTransmission;
unitTransmission=obj.TransmissionUnit;

handles.sliderTransmission=uicontrol('Parent',guiFig,'Style','slider','Min',minTransmission,...
    'Max',maxTransmission,'Value',minTransmission,'SliderStep',[0.1 0.1],...
    'Position', [118 60 200 35],'Callback',@sliderfn);
handles.textMinTransmission = uicontrol('Style','text','String','Min',...
    'Position',[35 80,80,15],'FontSize',10);
handles.valueMinTransmission = uicontrol('Style','text','String',[num2str(minTransmission),' ','%'],...
    'Position',[48 60,70,20]);
handles.textMaxTransmission = uicontrol('Style','text','String','Max',...
    'Position',[325 80,80,15],'FontSize',10);
handles.valueMaxTransmission = uicontrol('Style','text','String',[num2str(maxTransmission),' ','%'],...
   'Position',[337 60,70,20]);
handles.textSetTransmission = uicontrol('Style','text','String','Set Transmission',...
    'Position',[50 120,150,15],'FontSize',10);
handles.SetTransmission = uicontrol('Style','edit',...
    'Position',[190 113,80,25],'FontSize',10,'Callback',@setTransmission);
handles.textTransmissionUnit=uicontrol('Style','text','String',unitTransmission,...
    'Position',[270 120,50,15],'FontSize',10);

align([handles.textMinTransmission,handles.valueMinTransmission],'Center','None');
align([handles.textMaxTransmission,handles.valueMaxTransmission],'Center','None');
align([handles.sliderTransmission,handles.SetTransmission],'Center','None');

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
        gui2properties();
        delete(obj.GuiFigure);
    end

%Callback function for slider
    function sliderfn(~,~)
        sliderValue=get(handles.sliderTransmission,'Value');
        set(handles.SetTransmission,'String',num2str(sliderValue))
        obj.setTransmission(sliderValue)
        gui2properties();
    end
%Callback function to set Transmission
    function setTransmission(~,~)
        textValue=str2double(get(handles.SetTransmission,'String'));
        if textValue > obj.MaxTransmission || isnan(textValue)
            error('Choose a number for Transmission between [MinTransmission,MaxTransmission]')
        end
        set(handles.sliderTransmission,'Value',textValue)
        obj.setTransmission(textValue)
        gui2properties()
    end


%%  All figure have these functions but will be different contents

    function gui2properties()
        obj.Transmission=str2double(get(handles.SetTransmission,'String'));
    end

    function properties2gui()
        if isempty(obj.Transmission) || isnan(obj.Transmission)
            obj.Transmission=obj.MinTransmission;
        end
        set(handles.sliderTransmission,'Value',obj.Transmission)
        set(handles.SetTransmission,'String',num2str(obj.Transmission));
    end
end

