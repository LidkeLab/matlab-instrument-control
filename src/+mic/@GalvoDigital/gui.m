% gui: Graphical User Interface to mic.GalvoDigital
%
% Functions: gui2properties, properties2gui, closeFigure, CalAngle,
%            setAngle_Button, setParameters_Button, ToggleGalvo
%
% REQUIREMENTS:
%    mic.abstract.m
%    MATLAB NI-DAQmx driver installed via the Support Package Installer
%
% CITATION: Hanieh Mazloom-Farsibaf, Lidlelab, 2017.

function guiFig = gui(obj)
%gui Graphical User Interface to MIC_LightSource_Abstract

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 300 500 310]);

%Construct the components
handles.output = guiFig;
guidata(guiFig,handles);



% Scanning Parametes
rangeAngle = sprintf('Angle [%g, %g] ',-obj.Range,obj.Range);
textangle = uicontrol('Style','text','String',rangeAngle,...
    'Position',[10 250,180,25],'FontSize',10);
textScanningParameters = uicontrol('Style','text','String','Scanning Parameters',...
    'Position',[10 200,180,25],'FontSize',11,'FontWeight','bold');
textNoStepsPerScan = uicontrol('Style','text','String','Number of Steps Per Scan',...
    'Position',[10 160,180,20],'FontSize',10);
textNoScan = uicontrol('Style','text','String','Number of Scans',...
    'Position',[10 120,180,20],'FontSize',10);
textStepSize = uicontrol('Style','text','String','Step Size',...
    'Position',[10 80,180,20],'FontSize',10);
textOffset = uicontrol('Style','text','String','Starting Position (offset)',...
    'Position',[10 40,180,20],'FontSize',10);

handles.edit_angle = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Position', [210 250 80 25],'Tag','EditAngle','Callback',@CalAngle);
handles.edit_NoStepsPerScan = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Tag','EditNSteps','Position', [210 160 80 25]);
handles.edit_NoScan = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Tag','EditNScans','Position', [210 120 80 25]);
handles.edit_StepSize = uicontrol('Parent',guiFig,'Style', 'edit', 'String', ...
    '','Tag','EditStepsize','Position', [210 80 80 25]);
handles.edit_Offset = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    '','Tag','EditOffset','Position', [210 40 80 25]);

handles.setAngle=uicontrol('Style', 'pushbutton', 'String', 'Set Angle',...
    'Position', [350 250 80 30], 'Callback', @setAngle_Button);

handles.setParameters=uicontrol('Style', 'pushbutton', 'String', 'Set Parameters',...
    'Position', [350 130 110 30], 'Callback', @setParameters_Button);

handles.Toggle_EnableGalvo=uicontrol('Style','togglebutton',...
    'String','Disable','Position',[350 50 65,50],...
    'BackgroundColor',[0.8  0.8  0.8],'Tag','positionToggle','Callback',@ToggleGalvo);
%
align([textNoStepsPerScan,textNoScan,textStepSize,textOffset,textScanningParameters],'Center','None');
align([handles.edit_NoStepsPerScan,handles.edit_NoScan,handles.edit_StepSize...
    ,handles.edit_Offset],'Center','None');

align([handles.Toggle_EnableGalvo,handles.setParameters,handles.setAngle],'Center','None');


% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%Initialize GUI properties
properties2gui();

    function gui2properties()
        
    end

    function properties2gui()
        if ~isempty(obj.N_Step) || ~isempty(obj.N_Scan)|| ~isempty(obj.StepSize)|| ~isempty(obj.Offset)
            set(handles.edit_NoStepsPerScan,'Value',obj.N_Step)
            set(handles.edit_NoScan,'Value',obj.N_Scan);
            set(handles.edit_StepSize,'Value',obj.StepSize);
            set(handles.edit_Offset,'Value',obj.Offset);
        end
        set(handles.Toggle_EnableGalvo,'Value',obj.IsEnable);
        if ~isempty(obj.Angle)
            if isempty(obj.Word)
                obj.angle2word(obj.Angle)
            end
            set(handles.edit_angle,'Value',obj.Angle)
        else
            obj.Angle=0;
            set(handles.edit_angle,'Value',obj.Angle)
            obj.angle2word(obj.Angle)
        end
        
        if obj.IsEnable==1
            set(handles.Toggle_EnableGalvo,'String','Enable');
            set(handles.Toggle_EnableGalvo,'BackgroundColor','green');
        else
            set(handles.Toggle_EnableGalvo,'String','Disable');
            set(handles.Toggle_EnableGalvo,'BackgroundColor',[.8 .8 .8]);
        end
        
        
        
    end

    function closeFigure(~,~)
        %        gui2properties();
        %         obj.clear; Ask Keith
        delete(obj.GuiFigure);
        
    end

%calculate word based on input angle
    function CalAngle(~,~)
        Angle=str2double(get(handles.edit_angle,'String'));
        if isnan(Angle)
            error('Enter a valid angle')
        end
        obj.angle2word(Angle);
        state=get(handles.Toggle_EnableGalvo,'Value');
        % turn off the togglebutton if it is already on
        if state
            set(handles.Toggle_EnableGalvo,'Value',0);
            set(handles.Toggle_EnableGalvo,'BackgroundColor',[0.8  0.8  0.8]);%,[0.6 0.8 0])
            set(handles.Toggle_EnableGalvo,'String','Disable')
        end
    end
%Callback function to set angle
    function setAngle_Button(~,~)
        
        Angle=str2double(get(handles.edit_angle,'String'));
        if isnan(Angle)
            error('Enter a valid angle')
        end
        
        obj.setAngle();
        
    end
%Callback function to set Sequence
    function setParameters_Button(~,~)
        %take Scanning Parameters
        N_Step=str2double(get(handles.edit_NoStepsPerScan,'String'));
        N_Scan=str2double(get(handles.edit_NoScan,'String'));
        StepSize=str2double(get(handles.edit_StepSize,'String'));
        Offset=str2double(get(handles.edit_Offset,'String'));
        
        if isnan(N_Step) || isnan(N_Scan)|| isnan(StepSize)|| isnan(Offset)
            error('Choose proper values for Scanning Parameters')
        end
        
        % set Scanning Parameters
        obj.N_Step=N_Step;
        obj.N_Scan=N_Scan;
        obj.StepSize=StepSize;
        obj.Offset=Offset;
        
        %set the sequence of Words to move the Galvo Mirror
        obj.setSequence();
    end

%Callback function for toggle button
    function ToggleGalvo(~,~)
        state=get(handles.Toggle_EnableGalvo,'Value');
        %
        %         N_Step=str2double(get(handles.edit_NoStepsPerScan,'String'));
        %         N_Scan=str2double(get(handles.edit_NoScan,'String'));
        %         StepSize=str2double(get(handles.edit_StepSize,'String'));
        %         Offset=str2double(get(handles.edit_Offset,'String'));
        %
        %         if isnan(N_Step) || isnan(N_Scan)|| isnan(StepSize)|| isnan(Offset)
        %             error('Choose proper values for Scanning Parameters')
        %         end
        
        if state
            %   obj.Power=str2double(get(handles.SetPower,'String'));
            set(handles.Toggle_EnableGalvo,'BackgroundColor','green');%,[0.6 0.8 0])
            set(handles.Toggle_EnableGalvo,'String','Enable')
            obj.enable();
        else
            set(handles.Toggle_EnableGalvo,'BackgroundColor',[0.8  0.8  0.8])
            set(handles.Toggle_EnableGalvo,'String','Disable')
            obj.disable();
        end
    end

end

