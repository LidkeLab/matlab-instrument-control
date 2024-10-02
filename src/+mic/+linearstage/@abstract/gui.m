function guiFig = gui(obj)
% gui: Graphical User Interface to mic.linearstage.abstract
% Functionality:
%   Move the stage by moving the slider or clicking the jog buttons
%   Outside jog buttons (C) are for coarse steps
%   Inside jog buttons (F) are for fine steps
%   Fine and Coarse step sizes can be specified
%   Mouse scroll wheel will move stage when mouse is over slider
%   Mouse wheel action can be set to Fine or Coarse with toggle button
%   Position to which stage should move can be set in edit box
%
% Note: Updating gui from higher level class
%   To update gui from higher level class the uicontrol objects can be
%   accessed via obj.GuiFigure.Children
%   To identify the children which need updating they are given tags:
%   Slider has tag "positionSlider"
%   Set position edit box has tag "positionEdit"
%   For example see mic.linearstage.example
%
% Marjolein Meddens, Lidke Lab 2017


%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[600 100 450 300]);
% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = sprintf('%s %s', obj.InstrumentName, obj.Axis);
%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';
%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;
%Mouse scroll wheel callback
obj.GuiFigure.WindowScrollWheelFcn = @wheel;

%Construct the components
handles.output = guiFig;
guidata(guiFig,handles);

minPos=obj.MinPosition;
maxPos=obj.MaxPosition;
posUnit=obj.PositionUnit;

% step size defaults
fineStepFrac = 0.01;
coarseStepFrac = 0.1;
fineStep = (maxPos-minPos)*fineStepFrac;
coarseStep = (maxPos-minPos)*coarseStepFrac;

% slider
sliderVertPos = 230;
sliderLeft = 118;
sliderBottom = sliderVertPos;
sliderWidth = 230;
sliderHeight = 35;
handles.sliderPosition=uicontrol('Parent',guiFig,'Style','slider','Min',minPos,...
    'Max',maxPos,'Value',minPos,'SliderStep',[fineStepFrac fineStepFrac],...
    'Position', [sliderLeft sliderBottom sliderWidth sliderHeight],...
    'Tag','positionSlider','Callback',@positionSlider);
handles.sliderPosition.KeyPressFcn = @sliderKey;
handles.valueMinPos = uicontrol('Parent',guiFig,'Style','text','String',[num2str(minPos),' ',posUnit],...
    'Position',[sliderLeft+15 sliderVertPos+35,70,20],'HorizontalAlignment','left','FontSize',10);
handles.valueMaxPos = uicontrol('Parent',guiFig,'Style','text','String',[num2str(maxPos),' ',posUnit],...
   'Position',[sliderLeft+sliderWidth-85 sliderVertPos+35,70,20],'HorizontalAlignment','right','FontSize',10);
handles.f1 = uicontrol('Parent',guiFig,'Style','text','String','F',...
    'Position',[sliderLeft sliderVertPos-25,20,20],'HorizontalAlignment','center','FontSize',10);
handles.f2 = uicontrol('Parent',guiFig,'Style','text','String','F',...
    'Position',[sliderLeft+sliderWidth-20 sliderVertPos-25,20,20],'HorizontalAlignment','center','FontSize',10);

% coarse buttons
jogHeight = sliderBottom;
handles.buttonJogDown = uicontrol('Parent',guiFig,'Style','pushbutton','String','<',...
    'Position',[sliderLeft-40 jogHeight,20,sliderHeight],'FontSize',16,'Callback',@jogDown);
handles.buttonJogUp = uicontrol('Parent',guiFig,'Style','pushbutton','String','>',...
    'Position',[sliderLeft+sliderWidth+20 jogHeight,20,sliderHeight],'FontSize',16,'Callback',@jogUp);
handles.c1 = uicontrol('Parent',guiFig,'Style','text','String','C',...
    'Position',[sliderLeft-40 sliderVertPos-25,20,20],'HorizontalAlignment','center','FontSize',10);
handles.c2 = uicontrol('Parent',guiFig,'Style','text','String','C',...
    'Position',[sliderLeft+sliderWidth+20 sliderVertPos-25,20,20],'HorizontalAlignment','center','FontSize',10);

% step size edit
handles.textFineJog = uicontrol('Parent',guiFig,'Style','text','String','Fine step size',...
    'Position',[140 jogHeight-45,100,20],'FontSize',10,'HorizontalAlignment','right');
handles.editFineJog = uicontrol('Parent',guiFig,'Style','edit','String',num2str(fineStep),...
    'Position',[250 jogHeight-45,50,20],'FontSize',10,'Callback',@setFineStepSize);
handles.textFineUnit = uicontrol('Parent',guiFig,'Style','text','String',posUnit,...
    'Position',[310 jogHeight-45,30,20],'FontSize',10,'HorizontalAlignment','left');
handles.textCoarseJog = uicontrol('Parent',guiFig,'Style','text','String','Coarse step size',...
    'Position',[140 jogHeight-75,100,20],'FontSize',10,'HorizontalAlignment','right');
handles.editCoarseJog = uicontrol('Parent',guiFig,'Style','edit','String',num2str(coarseStep),...
    'Position',[250 jogHeight-75,50,20],'FontSize',10);
handles.textFineUnit = uicontrol('Parent',guiFig,'Style','text','String',posUnit,...
    'Position',[310 jogHeight-75,30,20],'FontSize',10,'HorizontalAlignment','left');

% toggle mousewheel fine/coarse
mwHeight = 100;
handles.textWheelToggle = uicontrol('Parent',guiFig,'Style','text','String','Mouse wheel fine/coarse',...
    'Position',[100 mwHeight,150,20],'FontSize',10,'HorizontalAlignment','left');
handles.buttonWheelToggle = uicontrol('Parent',guiFig,'Style','togglebutton',...
    'Position',[260 mwHeight-3,50,26],'FontSize',10,'HorizontalAlignment','left',...
    'Value',1, 'String','Fine', 'Callback',@wheelToggle);

% edit box
editHeight = 60;
handles.textSetPos = uicontrol('Parent',guiFig,'Style','text','String','Set Position',...
    'Position',[90 editHeight,100,15],'FontSize',10);
handles.editSetPos = uicontrol('Parent',guiFig,'Style','edit','Tag','positionEdit',...
    'Position',[190 editHeight-7,80,25],'FontSize',10,'Callback',@setPos);
handles.textPosUnit=uicontrol('Parent',guiFig,'Style','text','String',posUnit,...
    'Position',[280 editHeight,50,15],'FontSize',10,'HorizontalAlignment','left');

%Initialize GUI properties
properties2gui();

%%
    function closeFigure(~,~)
        delete(obj.GuiFigure);
    end

    function positionSlider(~,~)
        Value=handles.sliderPosition.Value;
        obj.setPosition(Value)
        handles.editSetPos.String = num2str(Value);
    end

    function setFineStepSize(~,~)
        stepSize=str2double(handles.editFineJog.String);
        stepPercent = stepSize/(obj.MaxPosition-obj.MinPosition);
        handles.sliderPosition.SliderStep = [stepPercent stepPercent];
    end

    function setPos(~,~)
        Value=str2double(handles.editSetPos.String);
        if Value < obj.MinPosition 
            warning('mic.linearstage.abstract:GuiInvPos',...
                'Invalid Position (%i %s) Position cannot be smaller then %i %s, moving to minimum position',...
                Value, obj.PositionUnit, obj.MinPosition, obj.PositionUnit);
            Value = obj.MinPosition;
        end
        if Value > obj.MaxPosition 
            warning('mic.linearstage.abstract:GuiInvPos',...
                'Invalid Position (%i %s) Position cannot be larger then %i %s, moving to maximum position',...
                Value, obj.PositionUnit, obj.MaxPosition, obj.PositionUnit);
            Value = obj.MaxPosition;
        end
        obj.setPosition(Value)
        handles.sliderPosition.Value = Value;
    end

    function wheel(~,Event)
        point = guiFig.CurrentPoint;
        % check whether mouse is over slider
        if point(1) < sliderLeft || point(1) > sliderLeft+sliderWidth ...
                || point(2) < sliderBottom || point(2) > sliderBottom+sliderHeight
            return
        end
        if handles.buttonWheelToggle.Value
            stepSize = str2double(handles.editFineJog.String);
        else
            stepSize = str2double(handles.editCoarseJog.String);
        end
        step = Event.VerticalScrollCount*-stepSize;
        newPos = obj.CurrentPosition + step;
        if newPos < obj.MinPosition || newPos > obj.MaxPosition
            return
        end
        obj.setPosition(newPos);
        properties2gui()
    end

    function wheelToggle(~,~)
        if handles.buttonWheelToggle.Value
            handles.buttonWheelToggle.String = 'Fine';
        else
            handles.buttonWheelToggle.String = 'Coarse';
        end
    end
        
    function jogUp(~,~)
        stepSize = str2double(handles.editCoarseJog.String);
        newPos = obj.CurrentPosition + stepSize;
        if newPos > obj.MaxPosition
            warning('Position outside range, moving to maximum position')
            newPos = obj.MaxPosition;
        end
        obj.setPosition(newPos);
        properties2gui()
    end

    function jogDown(~,~)
        stepSize = str2double(handles.editCoarseJog.String);
        newPos = obj.CurrentPosition - stepSize;
        if newPos < obj.MinPosition
            warning('Position outside range, moving to minimum position')
            newPos = obj.MinPosition;
        end
        obj.setPosition(newPos);
        properties2gui()
    end

    function properties2gui()
        if isempty(obj.CurrentPosition) || isnan(obj.CurrentPosition)
            obj.getPosition;
        end
        handles.sliderPosition.Value = obj.CurrentPosition;
        handles.editSetPos.String = num2str(obj.CurrentPosition);
    end
end

