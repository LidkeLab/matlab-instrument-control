classdef MIC_SeqReg3DTrans < MIC_Abstract
        %MIC_SeqReg3DTrans Register a sample to a stack of transmission images
    %  Class that performs 3D registration using transmission images
    % 
    % INPUT
    %    CameraObj - camera object -- tested with MIC_AndorCamera only
    %    StageObj - stage object -- tested with MIC_MCLNanoDrive only
    %    LampObj - lamp object -- tested with MIC_IX71Lamp only, will work
    %                             with other lamps that inherit from
    %                             MIC_LightSource_Abstract
    %    Calibration file (optional)
    %
    % SETTING (IMPORTANT!!)
    %    There are several properties that are system specific. These need
    %    to be specified after initialization of the class, before using
    %    any of the functionality. See properties section for explanation
    %    and which ones.
    %
    % REQUIRES
    %    Matlab 2014b or higher
    %    MIC_Abstrac
    
    properties
        CameraObj
%       StageObj %old
        StagePiezoX %new
        StagePiezoY %new
        StagePiezoZ %new
        MotorObj
        PixelSize = .104;          %micron
        RefImageFile
        Image_Reference
        Image_Current
        ZStack
        ZStack_MaxDev=0.5;    %micron
        ZStack_Step=0.05;   %micron
        X_Current;          %micron
        Y_Current;          %micron
        Z_Current;          %micron
        ZStack_Pos;         %micron
%         Tol_X=.007;         %micron
%         Tol_Y=.007;         %micron
        Tol_X=0.01; %F
        Tol_Y=0.01; %F
        Tol_Z=.05;          %micron
        UseStackCorrelation = 1; % find [x,y,z] shifts by stack comparison
        MaxIter=20; %FF
        MaxXYShift = 5;     %micron
        MaxZShift  = 1;   %micron
        ZFitPos;
        ZFitModel;
        ZMaxAC;
        ErrorSignal = zeros(0, 3); %Error Signal [X Y Z] in microns
        ErrorSignal_History=[]     %Error Signal [X Y Z] in micron
    end
    
    properties (Access='private')
        GUIFig;
        GUIhandles;
        ZMax_Adapt;
        ZStep_Adapt;
        EMGain;
        Fig_h_plot;
        Fig_h_ov;
    end
    
    properties (SetAccess=protected)
        InstrumentName = 'MIC_SeqReg3DTrans'; %Descriptive name of instrument.  Must be a valid Matlab varible name.
    end
    
    properties (Hidden)
        StartGUI = false;       % Defines GUI start mode.  'true' starts GUI on object creation.
        PlotFigureHandle;       % Figure handle of calibration/zposition plot
    end
    
    methods
%         function obj=SeqReg3DTrans(CameraObj,StageObj,MotorObj)
          function obj=MIC_SeqReg3DTrans(SCMOS,StagePiezoX,StagePiezoY,StagePiezoZ,Stage_Stepper) %new

            % pass in input for autonaming feature MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
           
            % check input
            if nargin <5
                error('MIC_Reg3DTrans:InvInput','You must pass in Camera, Stepper and Piezo Objects')
            end
            
            %obj.StageObj=StageObj;
            obj.StagePiezoX=StagePiezoX;
            obj.StagePiezoY=StagePiezoY;
            obj.StagePiezoZ=StagePiezoZ;
            obj.CameraObj=SCMOS;
            obj.MotorObj=Stage_Stepper;
            [p,~]=fileparts(which('Reg3DTrans'));
            f=fullfile(p,'Reg3DTrans_Properties.mat');
            if exist(f,'file')
                a=load(f);
                obj.PixelSize=a.PixelSize;
                clear a;
            end
            
            %obj.gui();
            
            if nargout==0 %% This doesn't work, nargout is always 1
                warning('You must assign this object to a variable: r3d=Reg3DTrans(cam,mcl). This time, I assign for you..')
                varname = 'r3d';
                n=1;
                while exist('varname','var')
                    s=sprintf('%s%d',varname,n);
                    n=n+1;
                end
                assignin('base',s,obj);
            end
            
        end
        
        function [Attribute,Data,Children] = exportState(obj)
            % exportState Exports current state of object
            % all relevant object  properties will be returned in State
            % structure

            Attribute.PixelSize = obj.PixelSize;
            Attribute.RefImageFile = obj.RefImageFile;
            Attribute.ZStack_MaxDev = obj.ZStack_MaxDev;
            Attribute.ZStack_Step = obj.ZStack_Step;
            Attribute.ZStack_Pos = obj.ZStack_Pos;
            Attribute.Tol_X = obj.Tol_X;
            Attribute.Tol_Y = obj.Tol_Y;
            Attribute.Tol_Z = obj.Tol_Z;
            Attribute.MaxIter = obj.MaxIter;
            Attribute.MaxXYShift = obj.MaxXYShift;
            Attribute.MaxZShift = obj.MaxZShift;
            
            %Return 0 as null marker
            Data.ZFitPos = 0;
            Data.ZFitModel = 0;
            Data.ZMaxAC = 0;
            Data.Image_Reference = 0;
            Data.Image_Current = 0;
            Data.ZStack = 0;
            Data.ErrorSignal_History = obj.ErrorSignal_History;
            
            if ~isempty(obj.ZFitPos);Data.ZFitPos = obj.ZFitPos;end
            if ~isempty(obj.ZFitModel);Data.ZFitModel = obj.ZFitModel;end
            if ~isempty(obj.ZMaxAC); Data.ZMaxAC = obj.ZMaxAC;end
            if ~isempty(obj.Image_Reference);Data.Image_Reference = obj.Image_Reference;end
            if ~isempty(obj.Image_Current); Data.Image_Current = obj.Image_Current;end
            if ~isempty(obj.ZStack);Data.ZStack = obj.ZStack;end
            
            Children=[];
            
        end
        
        function gui(obj)
            
            h = findall(0,'tag','Reg3DTrans.gui');
            if ~(isempty(h))
                figure(h);
                return;
            end

            xsz=500;
            ysz=210;
            xst=100;
            yst=100;
            bszx=100;
            bszy=30;
            
            guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
                'MenuBar','none','ToolBar','none','Visible','on',...
                'NumberTitle','off','UserData',0,'Tag',...
                'Reg3DTrans.gui','HandleVisibility','off');
            defaultBackground = get(0,'defaultUicontrolBackgroundColor');
            set(guiFig,'Color',defaultBackground)
            handles.output = guiFig;
            guidata(guiFig,handles)
            
            handles.button_findimage = uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', ...
                'Find Ref. Image','Position', [10 ysz-bszy-10 bszx bszy],'Callback', ...
                @obj.gui_getimagefile);
            
            handles.edit_imagefile = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
                'Image File','Position', [20 + bszx  ysz-bszy-10 xsz-bszx-20 bszy]);
            
            handles.button_takezstack = uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', ...
                'Show Ref. Image','Position',[10 ysz-2*(bszy+10) bszx bszy],'Callback', ...
                @obj.gui_showrefimage);
            
            handles.button_align = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Align', 'Position', [10 ysz-3*(bszy+10) bszx bszy], 'Callback', @obj.gui_align);
            
            handles.button_getcurrentimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Get Current Image', 'Position', [20+2*bszx ysz-4*(bszy+10) bszx bszy], 'Callback', @obj.gui_getcurrentimage);
            
            handles.button_showoverlay = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Show Overlay', 'Position', [10 ysz-4*(bszy+10) bszx bszy], 'Callback', @obj.gui_showoverlay);
            
            handles.button_calibrate = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Calibrate', 'Position', [10 ysz-5*(bszy+10) bszx bszy], 'Callback', @obj.gui_calibrate);
            
            handles.button_takerefimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Take Ref. Image', 'Position', [xsz-10-bszx ysz-3*(bszy+10) bszx bszy], 'Callback', @obj.gui_takerefimage);
            
            handles.button_saverefimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Save Ref. Image', 'Position', [xsz-10-bszx ysz-4*(bszy+10) bszx bszy], 'Callback', @obj.gui_saverefimage);
            
            handles.button_save = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
                'Save Overlay', 'Position', [xsz-10-bszx ysz-5*(bszy+10) bszx bszy], 'Callback', @obj.gui_save);
            
            obj.GUIFig=guiFig;
            obj.GUIhandles=handles;
        end
        
        function gui_getimagefile(obj,~,~)
            if isempty(obj.RefImageFile)
                [a,b]=uigetfile();
            else
                [filepath]=fileparts(obj.RefImageFile);
                [a,b]=uigetfile('*.mat','',filepath);
            end
            obj.RefImageFile = fullfile(b,a);
            if ishandle(obj.GUIFig)
                set(obj.GUIhandles.edit_imagefile,'String',obj.RefImageFile);
            end
            tmp=load(obj.RefImageFile,'Image_Reference','cellpos');
            obj.Image_Reference=tmp.Image_Reference;
            obj.MotorObj.Cellpos=tmp.cellpos;
        end
        
        function gui_showrefimage(obj,~,~)
            h=dipshow(permute(obj.Image_Reference,[2,1]));
            dipmapping(h,'lin');
        end
        
        function gui_align(obj,~,~)
            obj.align2imageFit;
        end
        
        function gui_showoverlay(obj,~,~)
            obj.showoverlay;
        end
        
        function gui_getcurrentimage(obj,~,~)
            obj.getcurrentimage;
        end
        
        function gui_calibrate(obj,~,~)
            obj.calibrate;
        end
        
        function gui_takerefimage(obj,~,~)
            obj.takerefimage;
        end
        
        function gui_saverefimage(obj,~,~)
            obj.saverefimage;
        end
        
        function gui_save(obj,~,~)
            obj.savealignment;
        end
        
        function takerefimage(obj)
            obj.Image_Reference=obj.capture_single;
            h=dipshow(obj.Image_Reference);
            dipmapping(h,'lin');
            obj.RefImageFile=[];
        end
        
        function saverefimage(obj)
            [a,b]=uiputfile('*.mat', 'Save Reference Image as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference;
            obj.MotorObj.get_position;
            cellpos=obj.MotorObj.Position;
            save(f,'Image_Reference','cellpos');
        end
        
        function calibrate(obj)
            %move stage over 5 microns and fit line
            X=obj.StagePiezoX.Position; %new
            Y=obj.StagePiezoY.Position; %new
            Z=obj.StagePiezoZ.Position; %new
            N=10;
            StepSize=0.1; %micron
            deltaX=((0:N-1)*StepSize)'; %old
            deltaY=((0:N-1)*StepSize)'; %new
            deltaZ=((0:N-1)*StepSize)'; %new
            ImSz=obj.CameraObj.ImageSize;
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            
            Xstart=X; %old
            Ystart=Y; %new
            Zstart=Z; %new
            for ii=1:N
                X(1)=Xstart(1)+deltaX(ii); %old
                Y(1)=Ystart(1)+deltaY(ii); %new
                Z(1)=Zstart(1)+deltaZ(ii); %new
%               obj.StageObj.set_position(X); %old
                obj.StagePiezoX.set_position(X); %new
                obj.StagePiezoY.set_position(Y); %new
                obj.StagePiezoZ.set_position(Z); %new
                pause(.1);
                ImageStack(:,:,ii)=single(obj.CameraObj.start_capture);
            end
            obj.StageObj.set_position(Xstart);
            dipshow(ImageStack);
            
            svec=zeros(N,2);
            refim=squeeze(ImageStack(10:end-10,10:end-10,1));
            for ii=1:N
                alignim=squeeze(ImageStack(10:end-10,10:end-10,ii));
                svec(ii,:)=findshift(alignim,refim,'iter');
            end
            
            P=polyfit(deltaX,svec(:,2),1);
            Xfit=P(1)*deltaX+P(2);
            PixelSize=1/P(1);     %micron
            
            if isempty(obj.Fig_h_plot)||~ishandle(obj.Fig_h_plot)
                obj.Fig_h_plot=figure;
            else
                figure(obj.Fig_h_plot)
            end
            plot(deltaX,svec(:,2),'r.','linewidth',2);
            hold on
            plot(deltaX,Xfit,'k','linewidth',2);
            legend('Found Displacement','Fit');
            s=sprintf('Pixel Size= %g',PixelSize);
            text(0.2,5,s);
            xlabel('Microns')
            ylabel('Pixels')
            
            [p,~]=fileparts(which('Reg3DTrans'));
            f=fullfile(p,'Reg3DTrans_Properties.mat');
            save(f,'PixelSize');
            obj.PixelSize=PixelSize;
        end
        function stagetest(obj,deltaX,deltaY)
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;

%           X=obj.StageObj.Position;
            X=obj.StagePiezoX.Position; %new
            Y=obj.StagePiezoY.Position; %new
            Z=obj.StagePiezoZ.Position; %new
            N=length(deltaX);
            ImSz=obj.CameraObj.ImageSize;
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            
            Xstart=X; %old
            Ystart=Y; %new
            Zstart=Z; %new
            for ii=1:N
%               X(1)=Xstart(1)+deltaX(ii); %old
                X=Xstart+deltaX(ii); %new
%               X(2)=Xstart(2)+deltaY(ii); %old
                Y=Ystart+deltaY(ii); %new
%               obj.StageObj.set_position(X); %old
                obj.StagePiezoX.set_position(X); %new
                obj.StagePiezoY.set_position(Y); %new
                obj.StagePiezoZ.set_position(Z); %new
                pause(1)
                ImageStack(:,:,ii)=single(obj.CameraObj.start_capture);
            end
%           obj.StageObj.set_position(Xstart); %old
            obj.StagePiezoX.set_position(Xstart); %new 
            obj.StagePiezoY.set_position(Ystart); %new
            obj.StagePiezoZ.set_position(Zstart); %new
            dipshow(ImageStack);
            sequence=ImageStack;
            Params.CameraObj.ROI=obj.CameraObj.ROI;
            [p,~]=fileparts(which('Reg3DTrans'));
            timenow=clock;
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            f=fullfile(p,['stagetest',s,'.mat']);
            save(f,'sequence','Params');
        end
        function stageimpulseTest(obj,fmr,numf,deltaX,savename)
            % laser should be on, camera should be adjusted to best
            % exposure time, sequence length is set by the main gui
            % setup cameras
            obj.CameraObj.AcquisitionType = 'sequence';
            obj.CameraObj.setup_acquisition();
            % start timer
            TimerST=timer('StartDelay',0,'period',fmr,'TasksToExecute',numf,'ExecutionMode','fixedRate');
%           TimerST.TimerFcn={@ImpulseTimerFcn,obj.StageObj,deltaX,fmr/2};  %old
            TimerST.TimerFcn={@ImpulseTimerFcn,obj.StagePiezoX,obj.StagePiezoY,obj.StagePiezoZ,deltaX,fmr/2}; %new
            start(TimerST);
            sequence=obj.CameraObj.start_sequence();
            % delete timer
            st=TimerST.Running;
            while(strcmp(st,'on'))
                st=TimerST.Running;
                pause(0.1);
            end
            delete(TimerST);
            % save data
            Params.CameraObj.ROI=obj.CameraObj.ROI;
            [p,~]=fileparts(which('Reg3DTrans'));
            timenow=clock;
            savename='0d1um';
            s=['-' num2str(timenow(1)) '-' num2str(timenow(2))  '-' num2str(timenow(3)) '-' num2str(timenow(4)) '-' num2str(timenow(5)) '-' num2str(round(timenow(6)))];
            f=fullfile(p,['stageimpulseTest-', savename,s,'.mat']);
            save(f,'sequence','Params');
        end
        
        function c=showoverlay(obj)
            %show aligned image on top of past image
            a=stretch(obj.Image_Reference(10:end-10,10:end-10));
            b=stretch(obj.Image_Current(10:end-10,10:end-10));
            c=joinchannels('RGB',a,b);
            h=dipshow(c);
            diptruesize(h,'tight');
        end
        
        function getcurrentimage(obj)
            im=obj.capture_single;
            h=dipshow(permute(im,[2,1]));
            dipmapping(h,'lin');
        end
        

        function align2imageFit(obj,RefStruct)
            
            iter=1;
            withintol=0;
            while (withintol==0)&&(iter<=obj.MaxIter)
                X=obj.StagePiezoX.getPosition();
                Y=obj.StagePiezoY.getPosition();
                Z=obj.StagePiezoZ.getPosition();
                
                % Determine if we are making comparisons to a single
                % reference image or to a reference stack and proceed with
                % the appropriate method.
                if obj.UseStackCorrelation
%                     % Set parameters based on the iteration.
%                     if iter == 1
%                         MaxOffset = [30; 30; 30];
%                     elseif iter <= 3
%                         MaxOffset = [5; 5; 5];
%                     elseif iter <= 5
%                         MaxOffset = [2; 2; 2];
%                     else
%                         MaxOffset = [1; 1; 1];
%                     end
                    MaxOffset = [30; 30; 30];
                    
                    % Set limits on the extent to which we can shift.
                    obj.ZStack_Step = 0.1; % in case it's changed elsewhere
                    obj.ZStack_MaxDev = 2;
                    
                    % Extract the z-stack from the RefStruct.
                    ReferenceStack = RefStruct.ReferenceStack;
                    
                    % Collect a z-stack for the current location.
                    obj.collect_zstack();
                    CurrentStack = obj.ZStack;
                    
                    % Determine the pixel and sub-pixel predicted shifts
                    % between the two stacks.
                    [PixelOffset, SubPixelOffset, CorrAtOffset] = ...
                        obj.findStackOffset(ReferenceStack, ...
                        CurrentStack, MaxOffset, 'FFT', '1D');
                    
                    % Decide which shift to proceed with based on
                    % PixelOffset and SubPixelOffset (SubPixelOffset can be
                    % innacurate).
                    if iter > 1
                        % On the first iteration, just use the raw pixel
                        % offset (don't use the polynomial fit).
                        % After the first iteration, proceed to use the
                        % below formulation.
                        PixelOffset = SubPixelOffset ...
                            .* (abs(PixelOffset-SubPixelOffset) <= 0.5) ...
                            + PixelOffset ...
                            .* (abs(PixelOffset-SubPixelOffset) > 0.5);
                    end
                    PixelOffset = PixelOffset * obj.PixelSize; % pixel->um
                    
                    % Modify PixelOffset to correspond to physical piezo
                    % dimensions.
                    PixelOffset = ...
                        [PixelOffset(2), -PixelOffset(1), -PixelOffset(3)];
                    
                    % Move the piezos to adjust for the predicted shift.
                    CurrentPosX = obj.StagePiezoX.getPosition();
                    CurrentPosY = obj.StagePiezoY.getPosition();
                    CurrentPosZ = obj.StagePiezoZ.getPosition();
                    NewPosX = CurrentPosX - PixelOffset(1);
                    NewPosY = CurrentPosY - PixelOffset(2);
                    NewPosZ = CurrentPosZ - PixelOffset(3);
                    obj.StagePiezoX.setPosition(NewPosX);
                    obj.StagePiezoY.setPosition(NewPosY);
                    obj.StagePiezoZ.setPosition(NewPosZ);
                    
                    % Rename parameters for consistency with the rest of
                    % the code.
                    Xshift = PixelOffset(1);
                    Yshift = PixelOffset(2);
                    Zshift = PixelOffset(3);
                    mACfit = CorrAtOffset;
                    
                    % Save the error signal.
                    obj.ErrorSignal = PixelOffset.'; % col->row vector
                else
                    %find z-position and adjust in Z using Piezo:
                    if iter < 2
                        obj.ZStack_MaxDev=4;
                        obj.ZStack_Step=0.05; %50 nm
                    else
                        obj.ZStack_MaxDev=0.5;
                        obj.ZStack_Step=0.05; %50 nm
                    end
                    [Zfit,mACfit]=obj.findZPos();
                    Zshift=Z-abs(Zfit); %new
                    Z=Zfit; %new
                    obj.StagePiezoX.setPosition(X); %new
                    obj.StagePiezoY.setPosition(Y); %new
                    obj.StagePiezoZ.setPosition(Z); %new
                    
                    %find XY position and adjust in XY using Piezo:
                    [Xshift,Yshift]=findXYShift(obj); % in um
                    obj.ErrorSignal(1:2)=[Xshift,Yshift];
                    obj.ErrorSignal(3) = Zshift;
                    
                    % current position on Piezo
                    CurrentPosX=obj.StagePiezoX.getPosition;
                    CurrentPosY=obj.StagePiezoY.getPosition;
                    NewPosX = CurrentPosX - Xshift;
                    NewPosY = CurrentPosY - Yshift;
                    obj.StagePiezoX.setPosition(NewPosX);
                    obj.StagePiezoY.setPosition(NewPosY);
                    obj.StagePiezoZ.setPosition(Z);
                end
                
                obj.ErrorSignal_History=cat(1,obj.ErrorSignal_History,obj.ErrorSignal);
                
                %show overlay
                obj.Image_Current=obj.capture_single();
                
                im=obj.Image_Reference(10:end-10,10:end-10);
                zs=obj.Image_Current(10:end-10,10:end-10);
                
                o=joinchannels('RGB',stretch(im),stretch(zs));
                if isempty(obj.Fig_h_ov)||~ishandle(obj.Fig_h_ov)
                    obj.Fig_h_ov=figure;
                else
                    figure(obj.Fig_h_ov)
                end
                h=dipshow(obj.Fig_h_ov,o);
                diptruesize(h,'tight');
                drawnow;
                
                %check convergence
                
                withintol=(abs(Xshift)<obj.Tol_X)&(abs(Yshift)<obj.Tol_Y)&(abs(Zshift)<obj.Tol_Z)&(mACfit>0.9);
                fprintf('Alignment iteration %i complete \n', iter)
                iter = iter + 1;
            end
            
            
            if iter==obj.MaxIter
                error('reached max iterations')
%                 warning('reached max iterations')
            end
            
        end
        
        function collect_zstack(obj)
            X=obj.StagePiezoX.getPosition; %new
            Y=obj.StagePiezoY.getPosition; %new
            Z=obj.StagePiezoZ.getPosition; %new
            obj.X_Current=X; %new
            obj.Y_Current=Y; %new
            obj.Z_Current=Z; %new
                      
            Zmax=obj.ZStack_MaxDev;     %micron
            Zstep=obj.ZStack_Step;      %micron
        
            obj.ZStack_Pos=(obj.Z_Current-Zmax:Zstep:obj.Z_Current+Zmax);
            N=length(obj.ZStack_Pos);
            obj.ZStack=[];
            
            %set fast acquisition
            obj.CameraObj.ExpTime_Sequence=obj.CameraObj.ExpTime_Capture;
            obj.CameraObj.abort;
            obj.CameraObj.setup_fast_acquisition(N);
            %out=single(obj.CameraObj.start_capture);
            for nn=1:N
                obj.StagePiezoX.setPosition(obj.X_Current); %now
                obj.StagePiezoY.setPosition(obj.Y_Current); %now
                obj.StagePiezoZ.setPosition(obj.ZStack_Pos(nn)); %now
                if nn==1
                    pause(.2); %it was 0.5 originally
                end
                obj.CameraObj.TriggeredCapture;
            end
            out=obj.CameraObj.FinishTriggeredCapture(N);
            obj.ZStack=single(out);
            obj.StagePiezoX.setPosition(X); %new
            obj.StagePiezoY.setPosition(Y); %new
            obj.StagePiezoZ.setPosition(Z); %new
            %put EMGain/Shutter back
        end
        
        function [Xshift,Yshift]=findXYShift(obj)
            
            %cut edges                        
            Ref=dip_image(obj.Image_Reference(10:end-10,10:end-10));
            Ref=Ref-mean(Ref);
            Ref=Ref/std(Ref(:));
            %get image at current z-position
            Current=obj.capture_single;
            Current=dip_image(Current(10:end-10,10:end-10)); 
            Current=Current-mean(Current);
            Current=Current/std(Current(:));                
            %find 2D shift         
            svec=findshift(Current,Ref,'iter'); % 'iter': doesn't round to integers
            Xshift=svec(1)*obj.PixelSize; %note dipimage permute
            Yshift=-svec(2)*obj.PixelSize;          
            
        end
        
        
        function [Zfit,mACfit]=findZPos(obj)
            
            %collect z-data stack
            obj.collect_zstack();
            
            %find which z-stack image has best correlation
            
            %whiten data to give zero mean and unit variance
            Ref=single(obj.Image_Reference(10:end-10,10:end-10));
            Ref=Ref-mean(Ref(:));
            Ref=Ref/std(Ref(:));
            
            zs=single(obj.ZStack);
            zs=zs(10:end-10,10:end-10,:);
            N=size(zs,3);
            n=numel(Ref);
            
            for ii=1:N
                %whiten 
                Current=squeeze(zs(:,:,ii));
                Current=Current-mean(Current(:));
                Current=Current/std(Current(:));
                cc=abs(ifft2(fft2(Current).*conj(fft2(Ref))));
                maxAC(ii)=1/n*max(cc(:));
            end
            [~,zindex]=find(maxAC==max(maxAC));
            
            %fit cross-correlation to find best in focus z-position
            StartFit=max(1,zindex-4);
            EndFit=min(N,zindex+4);
            Zpos_fit=obj.ZStack_Pos(StartFit:EndFit);
            maxAC_fit=maxAC(StartFit:EndFit);
            mACfit=max(maxAC_fit); %FF
            
            %fit
            [P, S MU] = polyfit(Zpos_fit,maxAC_fit,3);
            model = polyval(P,Zpos_fit,S,MU);
            
%             zinterp=linspace(Zpos_fit(1),Zpos_fit(end),round((Zpos_fit(end)-Zpos_fit(1))/0.01));
%             modelinterp = polyval(P,zinterp,S,MU);
%             [val,ind]=max(modelinterp);
            zAtMax=(-sqrt(P(2)^2-3*P(1)*P(3))-P(2))/3/P(1)*MU(2)+MU(1);
            %plot results
            if isempty(obj.Fig_h_plot)||~ishandle(obj.Fig_h_plot);
                obj.Fig_h_plot=figure;
            else
                figure(obj.Fig_h_plot)
            end
            hold off
            plot(obj.ZStack_Pos,maxAC,'ro');hold on
            plot(Zpos_fit,model,'b','linewidth',2);
            xlabel('Z position (microns)')
            ylabel('Max of Crosscorrelation')
            
            obj.ZFitPos=Zpos_fit;
            obj.ZFitModel=model;
            obj.ZMaxAC=maxAC;
            
            %return z position
            %Zfit=MU(1);
            %Zfit=zinterp(ind);
            Zfit=zAtMax;
        end
        
        function [fval,model]=GaussFit(obj,X,CC,Zpos)
           u = X(1);    %mean
           s = X(2);    %sigma
           a = X(3);    %magnitude
           o = X(4);    %offset
           X
           model=o + a*normpdf(Zpos,u,s);
           fval=mse(model,CC);
        end
 
        function out=capture(obj)
            %camera must be adjusted already to best exposure time
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
            out=single(obj.CameraObj.start_capture);
        end
        
        function out=capture_single(obj)
            %camera must be adjusted already to best exposure time
            
            out=obj.capture;
        end
        
        function savealignment(obj)
            [a,b]=uiputfile('*.mat', 'Save Overlay as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference;
            Image_Current=obj.Image_Current;
            Image_Overlay=obj.showoverlay();
            save(f,'Image_Reference','Image_Current','Image_Overlay');
        end
        
%         function delete(obj)
%            []; 
%         end
        
        function unitTest(obj)
            [];
        end
    end
    methods (Static)
        [PixelOffset, SubPixelOffset, CorrAtOffset] = ...
            findStackOffset(Stack1, Stack2, MaxOffset, Method, FitType)
    end
    
    
end

