function guiFig = gui(obj)
%gui Graphical User Interface to mic.NDFilterWheel
%   GUI has functionality to change which filter is used

%   Marjolein Meddens, Lidke Lab 2017


%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

numFilters = numel(obj.FilterPos);
buttonWidth = 150;
buttonHeight = 30;
titleHeight = 30;
moveHeight = 20;

%Open figure
guiFig = figure('Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 600 buttonWidth+50 (buttonHeight*numFilters)+titleHeight+moveHeight+50]);
handles.output = guiFig;
guidata(guiFig,handles);

% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = [obj.InstrumentName ' Id:' num2str(obj.Servo.Id)];
obj.GuiFigure.NumberTitle = 'off';

% Make Buttons
handles.buttonGroup = uibuttongroup('Parent',guiFig,'Position',[0 0 1 1],...
    'Tag','buttonGroup','SelectionChangedFcn',@selectFilter);
for ii = 1 : numFilters
    buttonString = sprintf('%i: Transmittance %0.3f',ii,obj.TransmissionValues(ii));
    uicontrol(handles.buttonGroup,'Style','radiobutton','String',buttonString,...
        'Position',[25 25+moveHeight+buttonHeight*(numFilters-ii) buttonWidth buttonHeight],...
        'Tag',num2str(ii));
end

% Make Text
handles.topText = uicontrol('Parent',guiFig, 'Style', 'text',...
    'Position',[10 25+moveHeight+(buttonHeight*numFilters) buttonWidth titleHeight],...
    'String','Select Filter:','FontSize',12);
handles.moveText = uicontrol('Parent',guiFig, 'Style', 'text',...
    'Position',[25 20 buttonWidth moveHeight],...
    'String','At selected filter','FontSize',10, 'BackgroundColor',[0 1 0]);

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%Initialize GUI properties
properties2gui();

%% functions

    function closeFigure(~,~)
        delete(obj.GuiFigure);
    end

    function properties2gui()
        % set the selected filter to the current filter
        tagCellStr = {handles.buttonGroup.Children.Tag};
        tagCellNum = cellfun(@(x) str2double(x),tagCellStr,'UniformOutput',false);
        tagNum = cell2mat(tagCellNum);
        handles.buttonGroup.SelectedObject = handles.buttonGroup.Children(tagNum == obj.CurrentFilter);
    end

    function selectFilter(~,event)
        handles.moveText.String = 'Moving';
        handles.moveText.BackgroundColor = [1 0 0];
        drawnow();
        obj.setFilter(str2double(event.NewValue.Tag));
        handles.moveText.String = 'At selected filter';
        handles.moveText.BackgroundColor = [0 1 0];
    end


end
