function guiPSF( obj )
%GUIPSF Gui for PSF engineering and acquisition for MIC_SR_CollectRB class
%   Detailed explanation goes here

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigurePSF)
    guiFig = obj.GuiFigurePSF;
    figure(obj.GuiFigurePSF);
    return
end

Fig_H = 510;
Fig_W = 500;
PanLeft_W = 210;
PanLeft_S = 10;
PanRight_W = 260;
PanRight_S = 230;
PanBottom_S = 10;

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[420 540 Fig_W Fig_H]);
% Create a property based on GuiFigure
obj.GuiFigurePSF = guiFig;
obj.GuiFigurePSF.Name = 'PSF data collection and engineering';
%Prevent closing after a 'close' or 'close all'
obj.GuiFigurePSF.HandleVisibility='off';
%Save Propeties upon close
obj.GuiFigurePSF.CloseRequestFcn = @closeFigure;
%Mouse scroll wheel callback
obj.GuiFigurePSF.WindowScrollWheelFcn = @wheel;

% File name and save dir
File_H = 120;
FilePanel = uipanel(guiFig,'Title','PSF File','FontSize',8,...
    'Units','Pixels','Position',...
    [PanLeft_S Fig_H-(File_H+10) PanLeft_W File_H]);
uicontrol(FilePanel,'Style','text','String','Save Directory',...
    'Position',[5,85,130,15],'FontSize',8,'HorizontalAlignment','left');
handles.editSaveDir = uicontrol(FilePanel,'Style','edit',...
    'Position',[5,65,200,20],'FontSize',8);
uicontrol(FilePanel,'Style','text','String','File name',...
    'Position',[5,50,130,15],'FontSize',8,'HorizontalAlignment','left');
handles.editFileName = uicontrol(FilePanel,'Style','edit',...
    'Position',[5,30,200,20],'FontSize',8);
uicontrol(FilePanel,'Style','text','String','Save type',...
    'Position',[5,5,130,15],'FontSize',8,'HorizontalAlignment','left');
handles.editSaveType = uicontrol(FilePanel,'Style','popup','String',...
    {'mat','h5'},'Position',[75,5,100,20],'FontSize',8);

% light source
Light_H = 140;
LightPanel = uipanel(guiFig,'Title','Light Source','FontSize',8,...
    'Units','Pixels','Position',[PanLeft_S Fig_H-(File_H+Light_H+20) PanLeft_W Light_H]);
uicontrol(LightPanel,'Style','text','String','Use',...
    'HorizontalAlignment','left','Position',[0,50,30,15]);
uicontrol(LightPanel,'Style','text','String','Power',...
    'HorizontalAlignment','left','Position',[0,15,35,15]);

h405Panel=uipanel(LightPanel,'Title','405','Units','pixels',...
    'Position',[PanLeft_W/(6/1) 5 PanLeft_W/6 Light_H-20]);
handles.Button405 = uicontrol(h405Panel,'Style','togglebutton','String','Off',...
    'Position',[2 75 28 20],'BackgroundColor',[0.8  0.8  0.8],...
    'Tag','405','Callback',@toggleLaser);
handles.Use405 = uicontrol(h405Panel,'Style','checkbox',...
    'Value',0,'Position',[8 40 30 20]);
handles.Power405 = uicontrol(h405Panel,'Style','edit',...
    'Position',[2 5 28 20]);

h488Panel=uipanel(LightPanel,'Title','488','Units','pixels',...
    'Position',[PanLeft_W/(6/2) 5 PanLeft_W/6 Light_H-20]);
handles.Button488 = uicontrol(h488Panel,'Style','togglebutton','String','Off',...
    'Position',[2 75 28 20],'BackgroundColor',[0.8  0.8  0.8],...
    'Tag','488','Callback',@toggleLaser);
handles.Use488 = uicontrol(h488Panel,'Style','checkbox',...
    'Value',0,'Position',[8 40 30 20]);
handles.Power488 = uicontrol(h488Panel,'Style','edit',...
    'Position',[2 5 28 20]);

h561Panel=uipanel(LightPanel,'Title','561','Units','pixels',...
    'Position',[PanLeft_W/(6/3) 5 PanLeft_W/6 Light_H-20]);
handles.Button561 = uicontrol(h561Panel,'Style','togglebutton','String','Off',...
    'Position',[2 75 28 20],'BackgroundColor',[0.8  0.8  0.8],...
    'Tag','561','Callback',@toggleLaser);
handles.Use561 = uicontrol(h561Panel,'Style','checkbox',...
    'Value',0,'Position',[8 40 30 20]);
handles.Power561 = uicontrol(h561Panel,'Style','text',...
    'Position',[2 5 28 20],'String','N/A');

h642Panel=uipanel(LightPanel,'Title','642','Units','pixels',...
    'Position',[PanLeft_W/(6/4) 5 PanLeft_W/6 Light_H-20]);
handles.Button642 = uicontrol(h642Panel,'Style','togglebutton','String','Off',...
    'Position',[2 75 28 20],'BackgroundColor',[0.8  0.8  0.8],...
    'Tag','642','Callback',@toggleLaser);
handles.Use642 = uicontrol(h642Panel,'Style','checkbox',...
    'Value',0,'Position',[8 40 30 20]);
handles.Power642 = uicontrol(h642Panel,'Style','edit',...
    'Position',[2 5 28 20]);

hLEDPanel=uipanel(LightPanel,'Title','LED','Units','pixels',...
    'Position',[PanLeft_W/(6/5) 5 PanLeft_W/6 Light_H-20]);
handles.ButtonLED = uicontrol(hLEDPanel,'Style','togglebutton','String','Off',...
    'Position',[2 75 28 20],'BackgroundColor',[0.8  0.8  0.8],...
    'Tag','LED','Callback',@toggleLaser);
handles.UseLED = uicontrol(hLEDPanel,'Style','checkbox',...
    'Value',0,'Position',[8 40 30 20]);
handles.PowerLED = uicontrol(hLEDPanel,'Style','edit',...
    'Position',[2 5 28 20]);


% acquire PSF
Acq_H = 210;
AcqPanel = uipanel(guiFig,'Title','Acquire PSF','FontSize',8,...
    'Units','Pixels','Position',[PanLeft_S Fig_H-(File_H+Acq_H+Light_H+30) PanLeft_W Acq_H]);
handles.CamFocus = uicontrol(AcqPanel,'Style','pushbutton',...
    'String','Focus','Position',[5,5,95,30],'FontSize',8,...
    'BackgroundColor',[1,0.5,0.5],'Callback',@focusCamera);
handles.startZstack = uicontrol(AcqPanel,'Style','pushbutton',...
    'String','Start','Position',[105,5,95,30],'FontSize',8,...
    'BackgroundColor',[0.5,1,0.5],'Callback',@startZstack);
uicontrol(AcqPanel,'Style','text','String',...
    'Camera ROI','Position',[5,80,70,15],'FontSize',8,'HorizontalAlignment','left');
handles.CamROIpopup = uicontrol(AcqPanel,'Style','popup','String',...
    {'center 128','center 256','center 512','center 1024','full'},...
    'Position', [90 80 110 15],'FontSize',8,'Callback',@setROI);
uicontrol(AcqPanel,'Style','text','String',...
    'Zoom','Position',[5,50,50,15],'FontSize',8,'HorizontalAlignment','left');
handles.CamZoom_popup = uicontrol(AcqPanel,'Style','popupmenu',...
    'String',{'50%','100%','200%','400%','1000%'},'Value',4,...
    'Position', [90 50 110 15],'FontSize',8,'CallBack',@setZoom);
uicontrol(AcqPanel,'Style','text','String',...
    'Acquisition time (s)','Position',[5,110,100,15],'FontSize',8,...
    'HorizontalAlignment','left');
handles.CamAcqTime = uicontrol(AcqPanel,'Style','edit',...
    'Position',[140,110,60,20],'FontSize',8,'Tag','CamAcqEdit',...
    'Callback',@setAcqTime);
uicontrol(AcqPanel,'Style','text','String','Z range ([min step max])',...
    'Position',[5,140,140,15],'FontSize',8,'HorizontalAlignment','left');
handles.editZrange = uicontrol(AcqPanel,'Style','edit','String','-1 0.25 1',...
    'Position',[140,140,60,20],'FontSize',8,'HorizontalAlignment','center');
uicontrol(AcqPanel,'Style','text','String','Frames per Z position',...
    'Position',[5,170,140,15],'FontSize',8,'HorizontalAlignment','left');
handles.editNumFrames = uicontrol(AcqPanel,'Style','edit','String','100',...
    'Position',[140,170,60,20],'FontSize',8,'HorizontalAlignment','center');


% zernike coefficients
ZC_H = 345;
ZCPanel = uipanel(guiFig,'Title','Zernike Coefficients','FontSize',8,...
    'Units','Pixels','Position',[PanRight_S PanBottom_S PanRight_W ZC_H]);
% zernike sliders
stepSizeZC = 0.05;
minValZC=-5;
maxValZC=5;
ZCnum = 15;
ZernikeNames = {'Piston','Tilt X','Tilt Y','Defocus','Ast 45deg',...
    'Ast','Coma Y','Coma X','Tre','Tre 45deg','Spherical','Ast2',...
    'Ast2 45deg','Quadr','Quadr 45deg'};
sliderVertPos = ((ZCnum-1)*20+5):-20:5;
sliderLeft = 85;
sliderWidth = 130;
sliderHeight = 15;
for zc = 1:ZCnum
    ZCstring = sprintf('%i:%s',zc,ZernikeNames{zc});
    uicontrol(ZCPanel,'Style','text','String',ZCstring,...
        'Position',[5,sliderVertPos(zc),80,15],'HorizontalAlignment','left');
    handles.ZCslider(zc)=uicontrol(ZCPanel,'Style','slider','Min',minValZC,...
        'Max',maxValZC,'Value',0,'SliderStep',[stepSizeZC stepSizeZC],...
        'Position', [sliderLeft sliderVertPos(zc) sliderWidth sliderHeight],...
        'Tag',num2str(zc),'Callback',@ZCslider,...
        'KeyPressFcn' ,@ZCsliderKey);
    handles.ZCedit(zc)=uicontrol(ZCPanel,'Style','edit',...
        'String','0','Position',[225 sliderVertPos(zc),25,15],...
        'Tag',num2str(zc),'Callback',@ZCedit);
end
uicontrol(ZCPanel,'Style','text','String','Use optimized pupil',...
    'Position',[5,ZC_H-35,100,15],'HorizontalAlignment','left');
handles.ZCuseOptimPupil =  uicontrol(ZCPanel,'Style','checkbox','Value',1,...
    'Position',[105,ZC_H-35,100,15],'Callback', @useOptimPupil);
handles.ZCreset = uicontrol(ZCPanel,'Style','pushbutton','String','Reset all coefficients',...
        'Position',[130,ZC_H-35,120,20],'Callback', @resetZC);

% SLM
SLM_H = 135;
SLMPanel = uipanel(guiFig,'Title','SLM','FontSize',8,...
    'Units','Pixels','Position',[PanRight_S ZC_H+20 PanRight_W SLM_H]);
uicontrol(SLMPanel,'Style','text','String','Pupil center (X,Y): ',...
    'Position',[5,SLM_H-35,95,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMtextPupilCenter = uicontrol(SLMPanel,'Style','text','String','000 000',...
    'Position',[105,SLM_H-35,60,15],'FontSize',8,'HorizontalAlignment','left');
uicontrol(SLMPanel,'Style','text','String','Pupil radius:',...
    'Position',[5,SLM_H-50,65,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMtextPupilRadius = uicontrol(SLMPanel,'Style','text','String','000',...
    'Position',[105,SLM_H-50,60,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMcalPupilPos = uicontrol(SLMPanel,'Style','pushbutton',...
    'String','Cal Pupil Position','Position',[155,SLM_H-50,95,30],...
    'FontSize',8,'Callback',@calPupilPos);

uicontrol(SLMPanel,'Style','text','String','Optimized Zernike coefficients',...
    'Position',[5,SLM_H-72,150,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMtextNumCoef = uicontrol(SLMPanel,'Style','text','String','(5:13)',...
    'Position',[155,SLM_H-72,150,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMtextOptCoef = uicontrol(SLMPanel,'Style','text','String',...
    '[00,00,00,00,00,00,00,00,00,00,00]',...
    'Position',[5,SLM_H-87,240,15],'FontSize',8,'HorizontalAlignment','left');

handles.SLMoptimPSF = uicontrol(SLMPanel,'Style','pushbutton',...
    'String','Optimize PSF','Position',[155,10,95,30],'FontSize',8,'Callback',@optimPupil);
uicontrol(SLMPanel,'Style','text','String','# zernike coef to optimize:',...
    'Position',[5,SLM_H-110,150,15],'FontSize',8,'HorizontalAlignment','left');
handles.SLMeditNumCoef = uicontrol(SLMPanel,'Style','edit','String','13',...
    'Position',[5,10,60,15],'FontSize',8);

% Initialize GUI properties
properties2gui();
% Change some defaults
handles.CamROIpopup.Value = 1;
handles.CamZoom_popup.Value = 4;
handles.CamAcqTime.String = '0.01';
handles.Use642.Value = 1;
handles.Power405.String = '1';
handles.Power488.String = '1';
handles.Power642.String = '1';
handles.PowerLED.String = '1';
gui2properties();

%% callback functions

    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigurePSF);
    end

    function properties2gui()
        % update gui with object properties
        
        % camera
        handles.CamAcqTime.String = obj.Camera.ExpTime_Focus;
        
        % SLM
        if numel(obj.SLM.ZernikeCoef) < ZCnum
            obj.SLM.ZernikeCoef(15) = 0;
        end
        for num = 1:ZCnum
            handles.ZCedit(num).String = num2str(obj.SLM.ZernikeCoef(num));
            handles.ZCslider(num).Value = obj.SLM.ZernikeCoef(num);
        end
        
        handles.SLMtextPupilCenter.String = num2str(obj.SLM.PupilCenter);
        handles.SLMtextPupilRadius.String = num2str(obj.SLM.PupilRadius);
        handles.SLMtextNumCoef.String = sprintf('(5:%i)',numel(obj.SLM.ZernikeCoefOptimized));
        handles.SLMtextOptCoef.String = sprintf('[%.1f]',obj.SLM.ZernikeCoefOptimized(5:end));
    end

    function gui2properties()
        setROI();
        setZoom();
        setAcqTime();
    end

    function focusCamera(~,~)
        setROI();
        setZoom();
        setAcqTime();
        laserOnPSF();
        obj.Camera.start_focus;
        laserOffPSF();
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

    function ZCslider(Src,~)
        ZC = str2double(Src.Tag);
        Value=Src.Value;
        obj.SLM.ZernikeCoef(ZC) = Value;
        handles.ZCedit(ZC).String = num2str(Value);
        obj.SLM.calcZernikeImage;
    end

    function ZCedit(Src,~)
        ZC = str2double(Src.Tag);
        Value = str2double(Src(ZC).String);
        handles.ZCslider(ZC).Value = Value;
        obj.SLM.ZernikeCoef(ZC) = Value;
        obj.SLM.calcZernikeImage;
    end

    function ZCsliderKey(Src,~)
        ZC = str2double(Src.Tag);
        Value=Src.Value;
        obj.SLM.ZernikeCoef(ZC) = Value;
        handles.ZCedit(ZC).String = num2str(Value);
        obj.SLM.calcZernikeImage;
    end

    function wheel(Src,Event)
        
        WheelStepSize = 0.1;
        point = guiFig.CurrentPoint;
        Left = PanRight_S+sliderLeft;
        Right = PanRight_S+sliderLeft+sliderWidth;
        Bottoms = PanBottom_S+sliderVertPos;
        Tops = PanBottom_S+sliderVertPos+sliderHeight;
        % check whether mouse is in slider range
        if point(1) < Left || point(1) > Right ...
                || point(2) < min(Bottoms) || point(2) > max(Tops)
            return
        end
        % find which slider it is over
        coef = 0;
        for num = 1:ZCnum
            if point(2) >= Bottoms(num) && point(2) <= Tops(num)
                coef = num;
            end
        end
        % return if it's in between sliders
        if coef == 0
            return
        end
        
        %
        Step = -Event.VerticalScrollCount;
        ValueOld = obj.SLM.ZernikeCoef(coef);
        ValueNew = ValueOld + WheelStepSize*Step;
        handles.ZCslider(coef).Value = ValueNew;
        handles.ZCedit(coef).String = num2str(ValueNew);
        obj.SLM.ZernikeCoef(coef) = ValueNew;
        obj.SLM.calcZernikeImage;
        figure(Src); %otherwise it responds only once
        
    end

    function useOptimPupil(~,~)
        UseOptim = handles.ZCuseOptimPupil.Value;
        if UseOptim
            obj.SLM.calcOptimPSFImage();
            obj.SLM.calcDisplayImage;
            obj.SLM.displayImage;
        else
            obj.SLM.Image_OptimPSF = 0;
            obj.SLM.calcDisplayImage;
            obj.SLM.displayImage;
        end        
    end

    function resetZC(~,~)
        for num = 1 : ZCnum
            handles.ZCslider(num).Value = 0;
            handles.ZCedit(num).String = '0';
        end
        obj.SLM.ZernikeCoef = 0;
        obj.SLM.ZernikeCoef(15) = 0;
        obj.SLM.calcZernikeImage();
    end

    function calPupilPos(~,~)
        % calibratePupilPosition calibrates the position and size of
        % pupil on the SLM
        % It scans a blaze across the SLM in the horizontal and
        % vertical directions.
        %
        % USER INPUT DURING PROCEDURE
        % The method starts with running focus, during which the user
        % should adjust the focus and field of view to have a bright
        % bead in focus. The user should then close the focus window
        % and click on the bead in the figure window that appears.
        % After that the code will run automatically and update the
        % fields of the SLM object with the results
        %
        % Marjolein Meddens 2017, Lidke Lab
        
        % perform blaze scan
        [HInt,HScan,VInt,VScan] = scanBlaze();
        % fit results
        % initial guess of parameters
        R=ceil(obj.NA*obj.Fobjective/obj.SLM.PixelPitch*1000);
        X0hor = [max(HInt)-min(HInt),min(HInt),obj.SLM.HorPixels/2, R];
        X0ver = [max(VInt)-min(HInt),min(VInt),obj.SLM.VerPixels/2, R];
        % run fminsearch
        funHor = @(x)obj.blazeScanObjFcn(x,HInt,HScan);
        Xhor = fminsearch(funHor,X0hor);
        funVer = @(x)obj.blazeScanObjFcn(x,VInt,VScan);
        Xver = fminsearch(funVer,X0ver);
        
        % calculate fit curve results
        HIntFit = zeros(size(HInt));
        VIntFit = zeros(size(VInt));
        for ii = 1:numel(HIntFit)
            HIntFit(ii) = obj.blazeScanIntensity(HScan(ii),Xhor(1),Xhor(2),Xhor(3),Xhor(4));
        end
        for ii = 1:numel(VIntFit)
            VIntFit(ii) = obj.blazeScanIntensity(VScan(ii),Xver(1),Xver(2),Xver(3),Xver(4));
        end
        % plot results
        figure;
        plot(HScan,HInt,'or')
        hold on
        plot(HScan,HIntFit,'-g','LineWidth',2)
        plot(VScan,VInt,'ob')
        plot(VScan,VIntFit,'-m','LineWidth',2)
        legend({'Horizontal scan data','Horizontal scan fit','Vertical scan data','Vertical scan fit'});
        
        % update SLM properties
        obj.SLM.PupilCenter = round([Xver(3),Xhor(3)]);
        obj.SLM.PupilRadius = round(max(Xhor(4),Xver(4))); %assume round pupil for now
        % reset blaze image
        obj.SLM.Image_Blaze = 0;
        obj.SLM.calcDisplayImage();
        obj.SLM.displayImage();
        % update gui
        properties2gui();
    end

    function optimPupil(~,~)
        
        NumCoefs = str2double(handles.SLMeditNumCoef.String);
        handles.SLMtextNumCoef.String = sprintf('(5:%i)',NumCoefs);
        % number of steps during optimization
        NSteps = 21;
        CoefRange = [-5 5];
        CoefVals = linspace(CoefRange(1),CoefRange(2),NSteps);
        ZernikeCoefs = zeros(NumCoefs,1);
        obj.SLM.ZernikeCoef = ZernikeCoefs;
        obj.ZCoefOptimized = ZernikeCoefs;
        obj.SLM.Image_OptimPSF = 0;
        NumMaxPix = 5; %number of pixels to sum for max intensity (highest value pixels)
        
        % Start with uniform pupil function
        obj.SLM.Image_Pattern = 0;
        obj.SLM.Image_Blaze = 0;
        obj.SLM.calcDisplayImage();
        obj.SLM.displayImage();
        
        % get PSFpos by mouse click
        laserOnPSF();
        Data = obj.Camera.start_focus;
        laserOffPSF();
        h = dipshow(Data);
        diptruesize(h,400);
        Point = dipgetcoords(h,1);
        close(h);
        PSFpos = [Point(2),Point(1)]; %[Y,X]
        ROIsize = 12; % pixels
        PSFROI=ceil([PSFpos(1)-ROIsize/2,PSFpos(1)+ROIsize/2-1,PSFpos(2)-ROIsize/2,PSFpos(2)+ROIsize/2-1]); %
        
        % initialize figures
        hf = figure;
        hf.Name = 'Zernike coefficient optimization intial';
        hf.Position = [21 82 560 880];
        hAx1st = subplot(2,1,1); hold on;
        title(['Initial optimization']);
        hAx2nd = subplot(2,1,2); hold on;
        title(['Refinement']);
        
        for jj = 1 : 2
            % optimize each coefficient
            switch jj
                case 1
                    hAx = hAx1st;
                case 2
                    hAx = hAx2nd;
            end
            for ii = 4 : NumCoefs
                
                
                % setup camera
                obj.Camera.abort;
                obj.Camera.setup_fast_acquisition(NSteps);
                
                % run 1st coef scan
                laserOnPSF();
                pause(1);
                for kk=1:NSteps
                    % set pupil
                    obj.SLM.ZernikeCoef(ii) = CoefVals(kk);
                    obj.SLM.calcZernikeImage();
                    pause(.1);
                    % acquire image
                    obj.Camera.TriggeredCapture();
                end
                laserOffPSF();
                % get data
                Data=obj.Camera.FinishTriggeredCapture(NSteps);
                PSFcropped = Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:);
                Isort = sort(reshape(PSFcropped,[size(PSFcropped,1)*size(PSFcropped,2),size(PSFcropped,3)]),1);
                Imax = sum(Isort(end-NumMaxPix+1:end,:),1);
                
                % plot data
                hp = plot(hAx,CoefVals,Imax,'o');
                
                % fit data
                % crop data around peak
                MaxCoef = find(Imax==max(Imax));
                PeakStart = max([0,MaxCoef-5]);
                PeakEnd = min([MaxCoef+5,NSteps]);
                CVpeak = CoefVals(PeakStart:PeakEnd);
                Ipeak = Imax(PeakStart:PeakEnd);
                % fit to 3rd order polynomial
                PolyCoef = polyfit(CVpeak,Ipeak,4);
                fitGrid = linspace(min(CVpeak),max(CVpeak),100);
                Ifit = polyval(PolyCoef,fitGrid);
                Der = polyder(PolyCoef);
                r = sort(roots(Der));
                if isreal(r)
                    MaxPos = r(2);
                else
                    MaxPos = r(imag(r)== 0);
                end
                % plot fit
                plot(hAx,fitGrid,Ifit,'-','Color',hp.Color);
                
                
                ZernikeCoefs(ii) = MaxPos;
                obj.SLM.ZernikeCoef = ZernikeCoefs;
                handles.SLMtextOptCoef.String = sprintf('[%.1f]',ZernikeCoefs(5:end));
            end
            
        end
        
        % set defocus back to zero
        ZernikeCoefs(4) = 0;
        % store optimized coefficients
        obj.SLM.ZernikeCoefOptimized = ZernikeCoefs;
        handles.SLMtextOptCoef.String = sprintf('[%.1f]',ZernikeCoefs(5:end));
        obj.SLM.ZernikeCoef = 0;
        % calculate optimized PSF image and store image in SLM object
        obj.SLM.calcOptimPSFImage();
        obj.SLM.Image_Pattern = 0;
        obj.SLM.calcDisplayImage;
        obj.SLM.displayImage;
        properties2gui();
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
        z0=obj.StageObj.StagePiezoZ.CurrentPosition;
        z = Zrange(1):Zrange(2):Zrange(3);
        dataset=[];
        %Setup Camera
        obj.Camera.SequenceLength=str2double(handles.editNumFrames.String);
        obj.Camera.AcquisitionType = 'sequence';
        obj.Camera.setup_acquisition;
        %Collect
        laserOnPSF();
        pause(.25);
        for ii=1:length(z)
            obj.StageObj.StagePiezoZ.setPosition(z0+z(ii))
            pause(.1);
            sequence=obj.Camera.start_sequence();
            dataset=cat(4,dataset,sequence);
        end
        %Turn off Laser and reset Piezo
        laserOffPSF();
        obj.StageObj.StagePiezoZ.setPosition(z0);
        % show data
        dipshow(permute(squeeze(mean(dataset,3)),[2,1,3]));
        % save data
        switch SaveType
            case 'mat'
                Params = getAttributes(); %#ok<NASGU>
                save(fullfile(SaveDir,[FileName '#' TimeStamp '.mat']),'dataset','Params');
            case 'h5'
                warning('no h5 saving yet')
        end
    end

    function Attributes = getAttributes()
        Attributes.Camera = obj.Camera.exportState();
        Attributes.Piezo = obj.StageObj.StagePiezoZ.exportState();
        Attributes.Laser405 = obj.Laser405.exportState();
        Attributes.Laser488 = obj.Laser488.exportState();
        Attributes.Laser561 = obj.Laser561.exportState();
        Attributes.Laser642 = obj.Laser642.exportState();
        Attributes.LED = obj.LED.exportState();
        Attributes.SLM = obj.SLM.exportState();
        ZrangeStr = handles.editZrange.String;
        idx = strfind(ZrangeStr,' ');
        Zrange = [str2double(ZrangeStr(1:idx(1)-1)),...
            str2double(ZrangeStr(idx(1)+1:idx(2)-1)),...
            str2double(ZrangeStr(idx(2)+1:end))];
        Attributes.Zrange = Zrange;
        Attributes.NA=obj.NA;
        Attributes.RefrIdx=obj.RefrIdx;
        Attributes.Fobjective=obj.Fobjective;
        Attributes.SLMangle = obj.SLMangle;
        Attributes.PixelSizeX = obj.PixelSizeX;
        Attributes.PixelSizeY = obj.PixelSizeY;
        Attributes.Use405 = handles.Use405.Value;
        Attributes.Use488 = handles.Use488.Value;
        Attributes.Use561 = handles.Use561.Value;
        Attributes.Use642 = handles.Use642.Value;
        Attributes.UseLED = handles.UseLED.Value;
        Attributes.UseOptimizedPupil = handles.ZCuseOptimPupil.Value;
    end

    function laserOnPSF()
        %laserOnPSF turns on laser according to PSF gui settings
        if handles.Use405.Value
            obj.Laser405.setPower(str2double(handles.Power405.String))
            obj.Laser405.on()
        end
        if handles.Use488.Value
            obj.Laser488.setPower(str2double(handles.Power488.String))
            obj.Laser488.on()
        end
        if handles.Use561.Value
            obj.Laser561.on()
        end
        if handles.Use642.Value
            obj.Laser642.setPower(str2double(handles.Power642.String))
            obj.Laser642.on()
        end
        if handles.UseLED.Value
            obj.LaserLED.setPower(str2double(handles.PowerLED.String))
            obj.Laser4LED.on()
        end
    end

    function laserOffPSF()
        %laserOffPSF turns on lasers off
        obj.Laser405.off()
        obj.Laser488.off()
        obj.Laser561.off()
        obj.Laser642.off()
        obj.LED.off()
    end

    function toggleLaser(Src,~)
        
        state=Src.Value;
        Laser = Src.Tag;
        if state
            switch Laser
                case '405'
                    obj.Laser405.setPower(str2double(handles.Power405.String));
                    obj.Laser405.on();
                case '488'
                    obj.Laser488.setPower(str2double(handles.Power488.String));
                    obj.Laser488.on();
                case '561'
                    obj.Laser561.on();
                case '642'
                    obj.Laser642.setPower(str2double(handles.Power642.String));
                    obj.Laser642.on();
                case 'LED'
                    obj.LED.setPower(str2double(handles.PowerLED.String));
                    obj.LED.on();
            end
            Src.BackgroundColor = 'red';
            Src.String = 'On';
        else
            Src.BackgroundColor = [0.8  0.8  0.8];
            Src.String = 'Off';
            switch Laser
                case '405'
                    obj.Laser405.off();
                case '488'
                    obj.Laser488.off();
                case '561'
                    obj.Laser561.off();
                case '642'
                    obj.Laser642.off();
                case 'LED'
                    obj.LED.off();
            end
        end
    end

    function [HInt,HScan,VInt,VScan]=scanBlaze()
        % scanBlaze scans a blaze across the SLM to measure pupil position
        %
        % OUTPUTS
        %   HInt:   Result of horizontal scan, Intensity
        %   VInt:   Result of vertical scan, Intensity
        %
        % REQUIRES
        %
        % Marjolein Meddens, Lidke Lab 2017
        
        % reset SLM image
        obj.SLM.Image_Pattern = 0;
        obj.SLM.Image_Blaze = 0;
        obj.SLM.calcDisplayImage();
        obj.SLM.displayImage();
        
        % get PSFpos by mouse click
        laserOnPSF();
        Data = obj.Camera.start_focus;
        laserOffPSF();
        h = dipshow(Data);
        diptruesize(h,400);
        Point = dipgetcoords(h,1);
        close(h);
        PSFpos = [Point(2),Point(1)]; %[Y,X]
        ROIsize = 12; % pixels
        PSFROI=ceil([PSFpos(1)-ROIsize/2,PSFpos(1)+ROIsize/2-1,PSFpos(2)-ROIsize/2,PSFpos(2)+ROIsize/2-1]); %
        
        %Horizontal scan of blaze
        ScanStep = 10;
        HScan=(1:ScanStep:obj.SLM.HorPixels);
        
        % setup camera
        nFrames = length(HScan);
        obj.Camera.abort;
        obj.Camera.setup_fast_acquisition(nFrames);
        
        % run horizontal scan
        laserOnPSF();
        pause(1);
        for ii=1:length(HScan)
            obj.SLM.calcBlazeImage(.1,[1 1 obj.SLM.VerPixels HScan(ii)])
            obj.SLM.calcDisplayImage()
            obj.SLM.displayImage()
            obj.Camera.TriggeredCapture();
        end
        laserOffPSF();
        Data=obj.Camera.FinishTriggeredCapture(nFrames);
        HInt=squeeze(sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:),1),2));
        
        %Verticl scan of blaze at size of pupil
        VScan=(1:ScanStep:obj.SLM.VerPixels);
        
        % setup camera
        nFrames = length(VScan);
        obj.Camera.abort;
        obj.Camera.setup_fast_acquisition(nFrames);
        
        % reset pattern
        obj.SLM.Image_Pattern = 0;
        obj.SLM.Image_Blaze = 0;
        obj.SLM.calcDisplayImage();
        obj.SLM.displayImage();
        %run vertical scan
        laserOnPSF();
        pause(1);
        
        for ii=1:length(VScan)
            obj.SLM.calcBlazeImage(.1,[1 1 VScan(ii) obj.SLM.HorPixels])
            obj.SLM.calcDisplayImage()
            obj.SLM.displayImage()
            obj.Camera.TriggeredCapture();
        end
        laserOffPSF();
        Data=obj.Camera.FinishTriggeredCapture(nFrames);
        VInt=squeeze(sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:),1),2));
        
    end
end

