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

minWavelength=obj.MinWavelength;
maxWavelength=obj.MaxWavelength;
Nstep = maxWavelength-minWavelength-1;

handles.sliderWavelength=uicontrol('Parent',guiFig,'Style','slider','units','pixels','Min',minWavelength,...
    'Max',maxWavelength,'Value',minWavelength,'SliderStep',[1/Nstep 1/Nstep],...
    'Position', [118 44 200 35],'Callback',@sliderfn);
handles.textminWavelength = uicontrol('Style','text','String','Min',...
    'Position',[35 60,80,20],'FontSize',10);
handles.valueminWavelength = uicontrol('Style','text','String',[num2str(minWavelength),' ','nm'],...
    'Position',[48 40,70,20]);
handles.textmaxWavelength = uicontrol('Style','text','String','Max',...
    'Position',[325 60,80,20],'FontSize',10);
handles.valuemaxWavelength = uicontrol('Style','text','String',[num2str(maxWavelength),' ','nm'],...
   'Position',[337 40,70,20]);
handles.textSetWavelength = uicontrol('Style','text','String','Set Wavelength',...
    'Position',[50 100,150,20],'FontSize',10);
handles.SetWavelength = uicontrol('Style','edit','String',num2str(minWavelength),...
    'Position',[190 97,80,25],'FontSize',10,'Callback',@setWavelength);
handles.textWavelengthUnit=uicontrol('Style','text','String','nm',...
    'Position',[270 100,50,20],'FontSize',10);

handles.textSetBWmode = uicontrol('Style','text','String','Set Bandwidth Mode',...
    'Position',[50 130,150,20],'FontSize',10);
handles.SetBWMode = uicontrol('Style','popupmenu','String',obj.BWModes,...
    'Position',[190 127,120,25],'FontSize',10,'Callback',@setBWmode);


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

    function sliderfn(h,~)
        sliderValue=round(get(h,'Value'));
        set(handles.SetWavelength,'String',num2str(sliderValue))
        obj.setWavelength(sliderValue)
        %gui2properties();
    end

    function setWavelength(h,~)
        textValue=str2double(get(h,'String'));
        set(handles.sliderWavelength,'Value',textValue)
        obj.setWavelength(textValue)
        %gui2properties()
    end

    function setBWmode(h,~)
        idx = get(h,'value');
        obj.setBWmode(obj.BWModes{idx})
    end

%%  All figure have these functions but will be different contents

    function gui2properties()
        %obj.Wavelength=str2double(get(handles.SetWavelength,'String'));
    end

    function properties2gui()
        if isempty(obj.Wavelength) || isnan(obj.Wavelength)
            obj.Wavelength=obj.MinWavelength;
        end
        idx = find(strcmp(obj.BWModes, obj.BandwidthMode));
        set(handles.SetBWMode,'value',idx)
        set(handles.sliderWavelength,'Value',obj.Wavelength)
        set(handles.SetWavelength,'String',num2str(obj.Wavelength));
    end
end