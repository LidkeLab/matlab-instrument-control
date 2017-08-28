function gui( obj )
%GUI Gui for MIC_RB_PSFEng class
%   Detailed explanation goes here

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[70 600 450 400]);
% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = sprintf('%s', obj.InstrumentName);
%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';
%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;
%Mouse scroll wheel callback
obj.GuiFigure.WindowScrollWheelFcn = @wheel;

% Laser control
minPower=obj.Laser642.MinPower;
maxPower=obj.Laser642.MaxPower;
unitPower=obj.Laser642.PowerUnit;

% File name and save dir
handles.FilePanel = uipanel(guiFig,'Title','File','FontSize',8,...
             'Units','Pixels','Position',[10 280 210 120]);
uicontrol(handles.FilePanel,'Style','text','String','Save Directory',...
    'Position',[5,85,130,15],'FontSize',8,'HorizontalAlignment','left'); 
handles.editSaveDir = uicontrol(handles.FilePanel,'Style','edit',...
    'Position',[5,65,200,20],'FontSize',8);
uicontrol(handles.FilePanel,'Style','text','String','File name',...
    'Position',[5,50,130,15],'FontSize',8,'HorizontalAlignment','left'); 
handles.editFileName = uicontrol(handles.FilePanel,'Style','edit',...
    'Position',[5,30,200,20],'FontSize',8);
uicontrol(handles.FilePanel,'Style','text','String','Save type',...
    'Position',[5,5,130,15],'FontSize',8,'HorizontalAlignment','left'); 
handles.editSaveType = uicontrol(handles.FilePanel,'Style','popup','String',...
    {'mat','h5'},'Position',[75,5,100,20],'FontSize',8);

% laser control
handles.LaserPanel = uipanel(guiFig,'Title','Laser','FontSize',8,...
             'Units','Pixels','Position',[10 210 210 70]);
uicontrol(handles.LaserPanel,'Style','text','String',...
    ['Power limits ' num2str(minPower) ' - ' num2str(maxPower) ' ' unitPower],...
    'Position',[5,35,130,15],'FontSize',8,'HorizontalAlignment','left');
uicontrol(handles.LaserPanel,'Style','text','String','Set Power',...
    'Position',[5,10,60,15],'FontSize',8,'HorizontalAlignment','left');
handles.SetLaserPower = uicontrol(handles.LaserPanel,'Style','edit',...
    'Position',[70 10,60,15],'FontSize',8,'Callback',@setPower);
handles.Toggle_Laser=uicontrol(handles.LaserPanel,'Style','togglebutton',...
    'String','Off','Position',[150,10,40,40],...
    'BackgroundColor',[0.8  0.8  0.8],'Tag','LaserPowerButton','Callback',@toggleLaser);

% Camera control
handles.CameraPanel = uipanel(guiFig,'Title','Camera','FontSize',8,...
             'Units','Pixels','Position',[10 10 210 200]);
handles.CamFocus = uicontrol(handles.CameraPanel,'Style','pushbutton',...
    'String','Focus','Position',[5,5,50,30],'FontSize',8,'Callback',@focusCamera);
handles.CamFocusWithI = uicontrol(handles.CameraPanel,'Style','pushbutton',...
    'String','Focus with Intensity feedback','Position',[60,5,145,30],'FontSize',8,'Callback',@focusCameraWithFeedback);
uicontrol(handles.CameraPanel,'Style','text','String',...
    'ROI','Position',[5,165,50,15],'FontSize',8,'HorizontalAlignment','left');
handles.CamROIpopup = uicontrol(handles.CameraPanel,'Style','popup','String',...
    {'center 128','center 256','center 512','center 1024','full'},...
    'Position', [60 165 130 15],'FontSize',8,'Callback',@setROI);
uicontrol(handles.CameraPanel,'Style','text','String',...
    'Zoom','Position',[5,135,50,15],'FontSize',8,'HorizontalAlignment','left');
handles.CamZoom_popup = uicontrol(handles.CameraPanel,'Style','popupmenu',...
    'String',{'50%','100%','200%','400%','1000%'},'Value',4,...
    'Position', [60 135 130 15],'FontSize',8,'CallBack',@setZoom);
uicontrol(handles.CameraPanel,'Style','text','String',...
    'Acquisition time (s)','Position',[5,100,100,15],'FontSize',8,...
    'HorizontalAlignment','left');
handles.CamAcqTime = uicontrol(handles.CameraPanel,'Style','edit',...
    'Position',[120,100,70,15],'FontSize',8,'Tag','CamAcqEdit',...
    'Callback',@setAcqTime);

% Piezo control
handles.PiezoPanel = uipanel(guiFig,'Title','Piezo','FontSize',8,...
             'Units','Pixels','Position',[230 300 210 100]);
minPos=obj.Piezo.MinPosition;
maxPos=obj.Piezo.MaxPosition;
posUnit=obj.Piezo.PositionUnit;
fineStepFrac = 0.01;
coarseStepFrac = 0.1;
fineStep = (maxPos-minPos)*fineStepFrac;
coarseStep = (maxPos-minPos)*coarseStepFrac;
% slider
sliderVertPos = 50;
sliderLeft = 40;
sliderWidth = 130;
sliderHeight = 20;
handles.sliderPosition=uicontrol(handles.PiezoPanel,'Style','slider','Min',minPos,...
    'Max',maxPos,'Value',minPos,'SliderStep',[fineStepFrac fineStepFrac],...
    'Position', [sliderLeft sliderVertPos sliderWidth sliderHeight],...
    'Tag','positionSlider','Callback',@positionSlider);
handles.sliderPosition.KeyPressFcn = @sliderKey;
uicontrol(handles.PiezoPanel,'Style','text','String',...
    [num2str(minPos),' ',posUnit],'Position',...
    [sliderLeft+15 sliderVertPos+25,30,12],'HorizontalAlignment','left',...
    'FontSize',8);
uicontrol(handles.PiezoPanel,'Style','text','String',...
    [num2str(maxPos),' ',posUnit],'Position',...
    [sliderLeft+80 sliderVertPos+25,40,12],'HorizontalAlignment','left',...
    'FontSize',8);
uicontrol(handles.PiezoPanel,'Style','text','String','F','Position',...
    [sliderLeft sliderVertPos+25,10,12],'HorizontalAlignment','left',...
    'FontSize',8);
uicontrol(handles.PiezoPanel,'Style','text','String','F','Position',...
    [sliderLeft+sliderWidth-10 sliderVertPos+25,10,12],'HorizontalAlignment','left',...
    'FontSize',8);
% coarse buttons
jogHeight = sliderVertPos;
handles.buttonJogDown = uicontrol(handles.PiezoPanel,'Style','pushbutton','String','<',...
    'Position',[sliderLeft-25 jogHeight,20,sliderHeight],'FontSize',16,'Callback',@jogDown);
handles.buttonJogUp = uicontrol(handles.PiezoPanel,'Style','pushbutton','String','>',...
    'Position',[sliderLeft+sliderWidth+5 jogHeight,20,sliderHeight],'FontSize',16,'Callback',@jogUp);
uicontrol(handles.PiezoPanel,'Style','text','String','C','Position',...
    [sliderLeft-20 sliderVertPos+25,10,12],'HorizontalAlignment','left',...
    'FontSize',8);
uicontrol(handles.PiezoPanel,'Style','text','String','C','Position',...
    [sliderLeft+sliderWidth+10 sliderVertPos+25,10,12],'HorizontalAlignment','left',...
    'FontSize',8);
% set step size and position
uicontrol(handles.PiezoPanel,'Style','text','String','Step size  Fine','Position',...
    [5 sliderVertPos-20,90,12],'HorizontalAlignment','left',...
    'FontSize',8);
handles.editFineStep = uicontrol(handles.PiezoPanel,'Style','edit',...
    'Position',[80,sliderVertPos-22,30,15],'FontSize',8,...
    'String',num2str(fineStep),'Callback',@setFineStepSize);
uicontrol(handles.PiezoPanel,'Style','text','String','Coarse','Position',...
    [125 sliderVertPos-20,40,12],'HorizontalAlignment','left',...
    'FontSize',8);
handles.editCoarseStep = uicontrol(handles.PiezoPanel,'Style','edit',...
    'Position',[170,sliderVertPos-22,30,15],'FontSize',8,...
    'String',num2str(coarseStep));
uicontrol(handles.PiezoPanel,'Style','text','String','Set position','Position',...
    [5 sliderVertPos-45,90,12],'HorizontalAlignment','left',...
    'FontSize',8);
handles.editPosition = uicontrol(handles.PiezoPanel,'Style','edit',...
    'Position',[80,sliderVertPos-48,60,15],'FontSize',8,'Callback',@setPosition);

% set SLM
handles.SLMPanel = uipanel(guiFig,'Title','SLM','FontSize',8,...
     'Units','Pixels','Position',[230 160 210 140]);
handles.calPupilPos = uicontrol(handles.SLMPanel,'Style','pushbutton',...
    'String','Cal Pupil Position','Position',[5,5,100,30],'FontSize',8,'Callback',@calPupilPos);
handles.optimPSF = uicontrol(handles.SLMPanel,'Style','pushbutton',...
    'String','Optimize PSF','Position',[105,5,100,30],'FontSize',8,'Callback',@optimPupil);
uicontrol(handles.SLMPanel,'Style','text','String','# zernike coef to optimize',...
    'Position',[5,40,150,15],'FontSize',8);
handles.editNumCoef = uicontrol(handles.SLMPanel,'Style','edit','String','13',...
    'Position',[160,40,40,15],'FontSize',8);
    
% acquire PSF
handles.AcqPanel = uipanel(guiFig,'Title','Acquire PSF','FontSize',8,...
    'Units','Pixels','Position',[230 10 210 150]);
uicontrol(handles.AcqPanel,'Style','text','String','Z range ([min step max])',...
    'Position',[5,110,140,15],'FontSize',8,'HorizontalAlignment','left');
handles.editZrange = uicontrol(handles.AcqPanel,'Style','edit','String','-1 0.25 1',...
    'Position',[140,110,60,15],'FontSize',8,'HorizontalAlignment','center');
uicontrol(handles.AcqPanel,'Style','text','String','Frames per Z position',...
    'Position',[5,90,140,15],'FontSize',8,'HorizontalAlignment','left');
handles.editNumFrames = uicontrol(handles.AcqPanel,'Style','edit','String','100',...
    'Position',[140,90,60,15],'FontSize',8,'HorizontalAlignment','center');
handles.startZstack = uicontrol(handles.AcqPanel,'Style','pushbutton',...
    'String','Start','Position',[5,5,60,30],'FontSize',8,...
    'Callback',@startZstack);

% Initialize GUI properties
properties2gui();
% Change some defaults
handles.CamROIpopup.Value = 1;
handles.CamZoom_popup.Value = 4;
handles.CamAcqTime.String = '0.01';
handles.SetLaserPower.String = 1;
gui2properties();

%% callback functions

    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigure);
    end

    function properties2gui()
        % update gui with object properties
        
        % laser
        handles.SetLaserPower.String = obj.Laser642.Power;
        set(handles.Toggle_Laser,'Value',obj.Laser642.IsOn);
        if obj.Laser642.IsOn==1
            set(handles.Toggle_Laser,'String','On');
            set(handles.Toggle_Laser,'BackgroundColor','red');
        else
            set(handles.Toggle_Laser,'String','Off');
            set(handles.Toggle_Laser,'BackgroundColor',[.8 .8 .8]);
        end
        
        % camera
        handles.CamAcqTime.String = obj.Camera.ExpTime_Focus;
        
        % piezo
        if isempty(obj.Piezo.CurrentPosition) || isnan(obj.Piezo.CurrentPosition)
            obj.Piezo.getPosition;
        end
        handles.sliderPosition.Value = obj.Piezo.CurrentPosition;
        handles.editPosition.String = num2str(obj.Piezo.CurrentPosition);
    end

    function gui2properties()
        setPower();
        setROI();
        setZoom();
        setAcqTime();
        
    end

    function setPower(~,~)
        textValue=str2double(get(handles.SetLaserPower,'String'));
        if textValue > obj.Laser642.MaxPower || isnan(textValue)
            error('Choose a number for Power between [MinPower,MaxPower]');
        end
         obj.Laser642.setPower(textValue);
    end

    function toggleLaser(~,~)
        state=get(handles.Toggle_Laser,'Value');
        if state
            obj.Laser642.on();
            set(handles.Toggle_Laser,'BackgroundColor','red');
            set(handles.Toggle_Laser,'String','On')
        else
            set(handles.Toggle_Laser,'BackgroundColor',[0.8  0.8  0.8])
            set(handles.Toggle_Laser,'String','Off')
            obj.Laser642.off();
        end
    end

    function focusCamera(~,~)
        obj.Laser642.on();
        obj.Camera.start_focus;
        obj.Laser642.off();
    end

function focusCameraWithFeedback(~,~)
        obj.Laser642.on();
        obj.Camera.start_focusWithFeedback;
        obj.Laser642.off();
    end

function setROI(~,~)
        roi_val = handles.CamROIpopup.Value;
        switch roi_val
            % given as [Xstart Xend Ystart Yend]
            case 1
                ROI=[961 1088 961 1088];% center 128
            case 2
                ROI=[897 1152 897 1152];% center 256
            case 3
                ROI=[769 1280 769 1280];% center 512
            case 4
                ROI=[513 1536 513 1536]; % center 1024
            case 5
                ROI=[1 2048 1 2048]; % full 2048
        end
        obj.Camera.ROI = ROI;
    end
    
    function setZoom(~,~)
        zoom_val = handles.CamZoom_popup.Value;
        switch zoom_val
            case 1 % 50%
                obj.Camera.DisplayZoom = 0.5;
            case 2 % 100%
                obj.Camera.DisplayZoom = 1;
            case 3 % 200%
                obj.Camera.DisplayZoom = 2;
            case 4 % 400%
                obj.Camera.DisplayZoom = 4;
            case 5 % 1000%
                obj.Camera.DisplayZoom = 10;
        end
    end

    function setAcqTime(~,~)
        Value=str2double(get(handles.CamAcqTime,'String'));
        obj.Camera.ExpTime_Capture = Value;
        obj.Camera.ExpTime_Focus = Value;
        obj.Camera.ExpTime_Sequence = Value;
    end

    function positionSlider(~,~)
        Value=handles.sliderPosition.Value;
        obj.Piezo.setPosition(Value)
        handles.editPosition.String = num2str(Value);
    end

    function jogUp(~,~)
        stepSize = str2double(handles.editCoarseStep.String);
        newPos = obj.Piezo.CurrentPosition + stepSize;
        if newPos > obj.Piezo.MaxPosition
            warning('Position outside range, moving to maximum position')
            newPos = obj.Piezo.MaxPosition;
        end
        obj.Piezo.setPosition(newPos);
        properties2gui()
    end

    function jogDown(~,~)
        stepSize = str2double(handles.editCoarseStep.String);
        newPos = obj.Piezo.CurrentPosition - stepSize;
        if newPos < obj.Piezo.MinPosition
            warning('Position outside range, moving to minimum position')
            newPos = obj.Piezo.MinPosition;
        end
        obj.Piezo.setPosition(newPos);
        properties2gui()
    end

    function setFineStepSize(~,~)
        stepSize=str2double(handles.editFineStep.String);
        stepPercent = stepSize/(obj.Piezo.MaxPosition-obj.Piezo.MinPosition);
        handles.sliderPosition.SliderStep = [stepPercent stepPercent];
    end

    function setPosition(~,~)
        Value=str2double(handles.editPosition.String);
        if Value < obj.Piezo.MinPosition 
            warning('MIC_LinearStage_Abstract:GuiInvPos',...
                'Invalid Position (%i %s) Position cannot be smaller then %i %s, moving to minimum position',...
                Value, obj.Piezo.PositionUnit, obj.Piezo.MinPosition, obj.Piezo.PositionUnit);
            Value = obj.Piezo.MinPosition;
        end
        if Value > obj.Piezo.MaxPosition 
            warning('MIC_LinearStage_Abstract:GuiInvPos',...
                'Invalid Position (%i %s) Position cannot be larger then %i %s, moving to maximum position',...
                Value, obj.Piezo.PositionUnit, obj.Piezo.MaxPosition, obj.Piezo.PositionUnit);
            Value = obj.Piezo.MaxPosition;
        end
        obj.Piezo.setPosition(Value)
        handles.sliderPosition.Value = Value;
    end

    function wheel(~,Event)
        point = guiFig.CurrentPoint;
        % check whether mouse is over slider
        if point(1) < sliderLeft || point(1) > sliderLeft+sliderWidth ...
                || point(2) < sliderBottom || point(2) > sliderVertPos+sliderHeight
            return
        end
        stepSize = str2double(handles.editCoarseJog.String);
        step = Event.VerticalScrollCount*-stepSize;
        newPos = obj.Piezo.CurrentPosition + step;
        if newPos < obj.Piezo.MinPosition || newPos > obj.Piezo.MaxPosition
            return
        end
        obj.Piezo.setPosition(newPos);
        properties2gui()
    end

    function calPupilPos(~,~)
        obj.calibratePupilPosition();
    end

    function optimPupil(~,~)
        NumCoef = str2double(handles.editNumCoef.String);
        obj.optimizePupil(NumCoef);
    end

    function startZstack(~,~)
        % get save info
        SaveDir = handles.editSaveDir.String;
        FileName = handles.editFileName.String;
        SaveType = handles.editSaveType.String{handles.editSaveType.Value};
        TimeStamp = datestr(clock,'yyyy-mm-dd-HH-MM-SS');
        % get z range info
        ZrangeStr = handles.editZrange.String;
        idx = strfind(ZrangeStr,' ');
        Zrange = [str2double(ZrangeStr(1:idx(1)-1)),...
            str2double(ZrangeStr(idx(1)+1:idx(2)-1)),...
            str2double(ZrangeStr(idx(2)+1:end))];
        z0=obj.Piezo.CurrentPosition;
        z = Zrange(1):Zrange(2):Zrange(3);
        dataset=[];
        %Setup Camera
        obj.Camera.SequenceLength=str2double(handles.editNumFrames.String);
        obj.Camera.AcquisitionType = 'sequence';
        obj.Camera.setup_acquisition;
        %Collect
        obj.Laser642.on();
        pause(.25);
        for ii=1:length(z)
            obj.Piezo.setPosition(z0+z(ii))
            pause(.1);
            sequence=obj.Camera.start_sequence();
            dataset=cat(4,dataset,sequence);
        end
        %Turn off Laser and reset Piezo
        obj.Laser642.off();
        obj.Piezo.setPosition(z0);
        % show data
        dipshow(permute(squeeze(mean(dataset,3)),[2,1,3]));
        % save data
        switch SaveType
            case 'mat'
                Params.Camera = obj.Camera.exportState();
                Params.Piezo = obj.Piezo.exportState();
                Params.Laser642 = obj.Laser642.exportState();
                Params.SLM = obj.SLM.exportState();
                Params.Zrange = Zrange;
                Params.NA=obj.NA;
                Params.RefrIdx=obj.RefrIdx;
                Params.Fobjective=obj.Fobjective;
                Params.SLMangle = obj.SLMangle;
                Params.PixelSize = obj.PixelSize;
                Params.ZCoefOptimized = obj.ZCoefOptimized; %#ok<STRNU>
                save(fullfile(SaveDir,[FileName '#' TimeStamp '.mat']),'dataset','Params');
            case 'h5'
                warning('no h5 saving yet')
        end
    end
end

