classdef MIC_Reg3DTrans < MIC_Abstract
    %MIC_Reg3DTrans Register a sample to a stack of transmission images
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
    %    MIC_Abstract
    %  
    % MICROSCOPE SPECIFIC SETTINGS
    % TIRF: LampPower=?; LampWait=2.5; CamShutter=true; ChangeEMgain=true; 
    %       EMgain=2; ChangeExpTime=true; ExposureTime=0.01;   
    
    % Marjolein Meddens, Lidke Lab 2017
    
    properties
        % Input
        CameraObj           % Camera Object
        StageObj            % Stage Object
        LampObj             % Lamp Object
        CalibrationFile     % File containing previously calibrated pixel size, or path to save calibration file
        
        % These must be set by user for specific system
        LampPower=30;       % Lamp power setting to use for transmission image acquistion 
        LampWait=1;         % Time (s) to wait after turning on lamp before starting imaging
        CamShutter=true;    % Flag for opening and closing camera shutter (Andor Ixon's) before acquiring a stack
        ChangeEMgain=false; % Flag for changing EM gain before and after acquiring transmission images
        EMgain;             % EM gain setting to use for transmission image acquisitions
        ChangeExpTime=true; % Flag for changing exposure time before and after acquiring transmission images
        ExposureTime=0.01;  % Exposure time setting to use for transmission image acquisitions
        
        % Other properties
        PixelSize;          % image pixel size (um)
        AbortNow=0;         % flag for aborting the alignment
        RefImageFile;       % full path to reference image
        Image_Reference     % reference image
        Image_Current       % current image
        ZStack              % acquired zstack
        ZStack_MaxDev=0.5;  % distance from current zposition where to start and end zstack (um)
        ZStack_Step=0.05;   % z step size for zstack acquisition (um)
        ZStack_Pos;         % z positions where a frame should be acquired in zstack (um)
        Tol_X=.01;         % max X shift to reach convergence(um)
        Tol_Y=.01;         % max Y shift to reach convergence(um)
        Tol_Z=.05;          % max Z shift to reach convergence(um)
        MaxIter=10;         % max number of iterations for finding back reference position 
        MaxXYShift=5;       % max XY distance (um) stage should move, if found shift is larger it will move this distance
        MaxZShift=0.5;      % max Z distance (um) stage should move, if found shift is larger it will move this distance
        ZFitPos;            % found Z positions
        ZFitModel;          % fitted line though auto correlations
        ZMaxAC;             % autocorrelations of zstack
    end
    
    properties (SetAccess=protected)
        InstrumentName = 'Registration3DTransmission'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    properties (Hidden)
        StartGUI = false;       % Defines GUI start mode.  'true' starts GUI on object creation. 
        PlotFigureHandle;       % Figure handle of calibration/zposition plot
    end
    
    methods
        function obj=MIC_Reg3DTrans(CameraObj,StageObj,LampObj,CalFileName)
            % MIC_Reg3DTrans constructor
            % 
            %  INPUT (required)
            %    CameraObj - camera object
            %    StageObj - stage object
            %    LampObj - lamp object
            %  INPUT (optional)
            %    CalFileName - full path to calibration file (.mat) containing
            %                  'PixelSize' variable, if file doesn't exist calibration 
            %                  will be saved here
            
            % pass in input for autonaming feature MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            
            % check input
            if nargin <3
                error('MIC_Reg3DTrans:InvInput','You must pass in Camera, Stage and Lamp Objects')
            end
            obj.CameraObj = CameraObj;
            obj.StageObj = StageObj;
            obj.LampObj = LampObj;
            
            if nargin == 4
                obj.CalibrationFile = CalFileName;
                % get pixelsize
                if exist(obj.CalibrationFile,'file')
                    a=load(CalFileName);
                    obj.PixelSize=a.PixelSize;
                    clear a;
                end
            end
        end
        
        function takerefimage(obj)
            %takerefimage Takes new reference image

            if obj.ChangeEMgain
                CamSet = obj.CameraObj.CameraSetting;
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
            % turn lamp on
            obj.LampObj.on;
            
            obj.Image_Reference=obj.capture;
            dipshow(obj.Image_Reference);
            % turn lamp off
            obj.LampObj.off;
            
            % change back EMgain and exposure time if needed
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function saverefimage(obj)
            % saverefimage Saves reference image

            [a,b]=uiputfile('*.mat', 'Save Reference Image as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference; %#ok<NASGU,PROP> 
            save(f,'Image_Reference');
            obj.RefImageFile = f;
            obj.updateGui();
        end
        
        function calibratePixelSize(obj)
            % calibratePixelSize Calibrates pixel size
            %   Calibrates pixel size by moving the stage over 
            %     5 microns and fitting line to calculated shifts
            %   Result is saved in path in obj.CalibrationFile
            %   If no path is given, result will only be stored in current
            %     object
            
            X=obj.StageObj.Position;
            N=10;
            StepSize=0.1; %micron
            deltaX=((0:N-1)*StepSize)';
            ImSz=obj.CameraObj.ImageSize;
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            % remember start position
            Xstart=X;
            %change EMgain, shutter and exposure time if needed
            if obj.ChangeEMgain || obj.CamShutter
                CamSet = obj.CameraObj.CameraSetting;
            end
            if obj.ChangeEMgain
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
            end
            if obj.CamShutter
                CamSet.ManualShutter.Bit=1;
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
            if obj.ChangeEMgain || obj.CamShutter
                obj.CameraObj.setCamProperties(CamSet);
            end
            % setup camera
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
                        
            % turn lamp on
            obj.turnLampOn();
            % open shutter if needed
            if obj.CamShutter
                obj.CameraObj.setShutter(1);
            end
            
            % acquire stack
            for ii=1:N
                X(1)=Xstart(1)+deltaX(ii);
                obj.StageObj.setPosition(X);
                pause(.1);
                ImageStack(:,:,ii)=single(obj.CameraObj.start_capture);
            end
            
            % close shutter if needed
            if obj.CamShutter
                obj.CameraObj.setShutter(0);
            end
            % turn lamp off
            obj.turnLampOff();
            
            %change back EMgain, shutter and exposure time if needed
            if obj.CamShutter
                CamSet.ManualShutter.Bit=0;
            end
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
            if obj.ChangeEMgain || obj.CamShutter
                obj.CameraObj.setCamProperties(CamSet);
            end            
            
            % set stage back to initial position
            obj.StageObj.setPosition(Xstart);
            dipshow(ImageStack(10:end-10,10:end-10,:));
            % find shifts
            svec=zeros(N,2);
            refim=squeeze(ImageStack(10:end-10,10:end-10,1));
            for ii=1:N
                alignim=squeeze(ImageStack(10:end-10,10:end-10,ii));
                svec(ii,:)=findshift(alignim,refim,'iter');
            end
            % fit shifts
            P=polyfit(deltaX,svec(:,2),1);
            Xfit=P(1)*deltaX+P(2);
            PixelSize=1/P(1);  %#ok<PROP> 
            % plot result
            if isempty(obj.PlotFigureHandle)||~ishandle(obj.PlotFigureHandle)
                obj.PlotFigureHandle=figure;
            else
                figure(obj.PlotFigureHandle)
            end
            hold off
            plot(deltaX,svec(:,2),'r.','MarkerSize',14);
            hold on
            plot(deltaX,Xfit,'k','LineWidth',2);
            legend('Found Displacement','Fit');
            s=sprintf('Pixel Size= %g',PixelSize); %#ok<PROP>
            text(0.2,5,s);
            xlabel('Microns')
            ylabel('Pixels')
            % save result
            if isempty(obj.CalibrationFile)
                warning('MIC_Reg3DTrans:CalPxSz:NotSaving','No CalibrationFile specified in obj.CalibrationFile, not saving calibration')
            elseif exist(obj.CalibrationFile,'file')
                warning('MIC_Reg3DTrans:CalPxSz:OverwriteFile','Overwriting previous pixel size calibration file');
                save(obj.CalibrationFile,'PixelSize');
            else
                save(obj.CalibrationFile,'PixelSize');
            end
            obj.PixelSize=PixelSize; %#ok<PROP>
        end
        
        function turnLampOn(obj)
            %turnLampOn Turns lamp on using current power and wait properties
            obj.LampObj.setPower(obj.LampObj.Power);
            obj.LampObj.on;
            pause(obj.LampWait);
        end
        
        function turnLampOff(obj)
            %turnLampOn Turns lamp on using current power and wait properties
            obj.LampObj.off;
            pause(obj.LampWait);
        end
        
        function c=showoverlay(obj)
            %showoverlay Shows aligned image on top of reference image
            
            % check whether images exist
            if isempty(obj.Image_Reference)
                warning('MIC_Reg3DTrans:showoverlay:NoRef','No reference image saved, not making overlay');
                return
            elseif isempty(obj.Image_Current)
                warning('MIC_Reg3DTrans:showoverlay:NoCur','No current image saved, not making overlay');
                return
            end
            a=stretch(obj.Image_Reference(10:end-10,10:end-10));
            b=stretch(obj.Image_Current(10:end-10,10:end-10));
            c=joinchannels('RGB',a,b);
            h=dipshow(c);
            diptruesize(h,'tight');
        end
        
        function getcurrentimage(obj)
            % getcurrentimage Takes transmission image with current settings
            
            if obj.ChangeEMgain
                CamSet = obj.CameraObj.CameraSetting;
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
            % turn lamp on
            obj.LampObj.setPower(obj.LampObj.Power);
            obj.LampObj.on;
            obj.Image_Current=obj.capture;
            im=obj.Image_Current;
            dipshow(im);
            % turn lamp off
            obj.LampObj.off;
            
            % change back EMgain and exposure time if needed
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        

        function align2imageFit(obj)
            % align2imageFit 

            if obj.ChangeEMgain
                CamSet = obj.CameraObj.CameraSetting;
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
            %turn lamp on
            obj.LampObj.setPower(obj.LampObj.Power);
            obj.LampObj.on;
            
            iter=0;
            withintol=0;
            while (withintol==0)&&(iter<obj.MaxIter)
                if obj.AbortNow
                    obj.AbortNow = 0;
                    break
                end
                %find z-position and adjust
                [Zfit]=obj.findZPos();
                Pos=obj.StageObj.Position;
                Zshift=Zfit-Pos(3);
                Pos(3)=Pos(3) + (sign(real(Zshift))*min(abs(real(Zshift)),obj.MaxZShift));
                obj.StageObj.setPosition(Pos);
                
                %find XY position and adjust
                [Xshift,Yshift]=findXYShift(obj);
                Pos(1)=Pos(1)+sign(Xshift)*min(abs(Xshift),obj.MaxXYShift);
                Pos(2)=Pos(2)+sign(Yshift)*min(abs(Yshift),obj.MaxXYShift);
                obj.StageObj.setPosition(Pos);
                
                %show overlay
                obj.Image_Current=obj.capture;
                im=obj.Image_Reference(10:end-10,10:end-10);
                zs=obj.Image_Current(10:end-10,10:end-10);
                o=joinchannels('RGB',stretch(im),stretch(zs));
                h=dipshow(1234,o);
                diptruesize(h,'tight');
                drawnow;
                
                %check convergence
                withintol=(abs(Xshift)<obj.Tol_X)&(abs(Yshift)<obj.Tol_Y)&(abs(Zshift)<obj.Tol_Z);
                iter=iter+1;
            end
            
            if iter==obj.MaxIter
                warning('MIC_Reg3DTrans:MaxIter','Reached max iterations');
            end
            
            % turn lamp off
             obj.LampObj.off;
            
            % change back EMgain and exposure time if needed
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function collect_zstack(obj)
            % collect_zstack Collects Zstack 
            
            % get current position of stage
            XYZ=obj.StageObj.Position;
            X_Current=XYZ(1);
            Y_Current=XYZ(2);
            Z_Current=XYZ(3);
                      
            Zmax=obj.ZStack_MaxDev;     %micron
            Zstep=obj.ZStack_Step;      %micron
        
            obj.ZStack_Pos=(Z_Current-Zmax:Zstep:Z_Current+Zmax);
            N=length(obj.ZStack_Pos);
            obj.ZStack=[];
            
            %change EMgain, shutter and exposure time if needed
            if obj.ChangeEMgain || obj.CamShutter
                CamSet = obj.CameraObj.CameraSetting;
            end
            if obj.ChangeEMgain
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
            end
            if obj.CamShutter
                CamSet.ManualShutter.Bit=1;
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
            if obj.ChangeEMgain || obj.CamShutter
                obj.CameraObj.setCamProperties(CamSet);
            end
            % setup camera
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
                        
            % turn lamp on
            %obj.turnLampOn();
            % open shutter if needed
            if obj.CamShutter
                obj.CameraObj.setShutter(1);
            end
            % acquire zstack
            for nn=1:N
                if nn==1
                    pause(0.5);
                end
                obj.StageObj.setPosition([X_Current,Y_Current,obj.ZStack_Pos(nn)]);
                obj.ZStack(:,:,nn)=single(obj.CameraObj.start_capture);
            end
            % close shutter if needed
            if obj.CamShutter
                obj.CameraObj.setShutter(0);
            end
            % turn lamp off
            %obj.turnLampOff();
            
            %change back EMgain, shutter and exposure time if needed
            if obj.CamShutter
                CamSet.ManualShutter.Bit=0;
            end
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
            if obj.ChangeEMgain || obj.CamShutter
                obj.CameraObj.setCamProperties(CamSet);
            end
            
            % Move stage back to original position
            obj.StageObj.setPosition(XYZ);
        end
        
        function [Xshift,Yshift]=findXYShift(obj)
            % findXYShift Finds XY shift between reference image and newly 
            % acquired current image
            
            % check pixelsize
            if isempty(obj.PixelSize)
                error('MIC_Reg3DTrans:noPixelSize', 'no PixelSize given in obj.PixelSize, please calibrate pixelsize first. Run obj.calibratePixelSize')
            end
            
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
            svec=findshift(Current,Ref,'iter');
            Xshift=-svec(2)*obj.PixelSize; %note dipimage permute
            Yshift=-svec(1)*obj.PixelSize;
        end
        
        
        function [Zfit]=findZPos(obj)
            % findZPos acquires zstack and finds zposition matching
            %   reference image
            
            %collect z-data stack
            obj.collect_zstack();
            
            %whiten data to give zero mean and unit variance
            Ref=obj.Image_Reference(10:end-10,10:end-10);
            Ref=Ref-mean(Ref(:));
            Ref=Ref/std(Ref(:));
            zs=obj.ZStack;
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
            
            %fit
            [P, S, MU] = polyfit(Zpos_fit,maxAC_fit,3);
            model = polyval(P,Zpos_fit,S,MU);
            zAtMax=(-sqrt(P(2)^2-3*P(1)*P(3))-P(2))/3/P(1)*MU(2)+MU(1);
            
            %plot results
            if isempty(obj.PlotFigureHandle)||~ishandle(obj.PlotFigureHandle)
                obj.PlotFigureHandle=figure;
            else
                figure(obj.PlotFigureHandle);
            end
            hold off
            plot(obj.ZStack_Pos,maxAC,'ro');hold on
            plot(Zpos_fit,model,'b','linewidth',2);
            xlabel('Z position (microns)')
            ylabel('Max of Crosscorrelation')
            
            % update parameters
            obj.ZFitPos=Zpos_fit;
            obj.ZFitModel=model;
            obj.ZMaxAC=maxAC;
            
            %return best z position
            Zfit=zAtMax;
        end
 
        function out=capture(obj)
            % Captures a single image
            %   All camera parameters must have been set prior to running
            %     this method
            %   The lamp must have been turned on prior to running this
            %     method
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
            out=single(obj.CameraObj.start_capture);
        end
        
        function out=capture_single(obj)
            % Sets camera and lamp parameters and captures a single image
            
            % change EMgain and exposure time if needed
            if obj.ChangeEMgain
                CamSet = obj.CameraObj.CameraSetting;
                EMGTemp = CamSet.EMGain.Value;
                CamSet.EMGain.Value = obj.EMgain;
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
            % turn lamp on
%            obj.turnLampOn();
            % capture image
            out=obj.capture;
            % turn lamp off
 %           obj.turnLampOff();
            
            % change back EMgain and exposure time if needed
            if obj.ChangeEMgain
                CamSet.EMGain.Value = EMGTemp; 
                obj.CameraObj.setCamProperties(CamSet);
            end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function savealignment(obj)
            % savealignment() Saves current, refenrece and overlay images
            
            % check whether images exist
            if isempty(obj.Image_Reference)
                warning('MIC_Reg3DTrans:NoRef','No reference image saved, not making overlay');
                return
            elseif isempty(obj.Image_Current)
                warning('MIC_Reg3DTrans:NoCur','No current image saved, not making overlay');
                return
            end
            [a,b]=uiputfile('*.mat', 'Save Overlay as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference; %#ok<NASGU,PROP>
            Image_Current=obj.Image_Current; %#ok<NASGU,PROP>
            Image_Overlay=obj.showoverlay(); %#ok<NASGU>
            save(f,'Image_Reference','Image_Current','Image_Overlay');
        end

        function updateGui(obj)
            % updateGui Updates gui with current values/settings
            
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            for ii = 1 : numel(obj.GuiFigure.Children)
                if strcmp(obj.GuiFigure.Children(ii).Tag,'fileEdit')
                    obj.GuiFigure.Children(ii).String = obj.RefImageFile;
                end
            end
        end
        
        function [Attribute,Data,Children] = exportState(obj)
            % exportState Exports current state of object
            % all relevant object  properties will be returned in State
            % structure
            
            Attribute.CalibrationFile = obj.CalibrationFile;
            Attribute.LampPower = obj.LampObj.Power;
            Attribute.LampWait = obj.LampWait;
            Attribute.CamShutter = obj.CamShutter;
            Attribute.ChangeEMgain = obj.ChangeEMgain;
            Attribute.EMgain = obj.EMgain;
            Attribute.ChangeExpTime = obj.ChangeExpTime;
            Attribute.ExposureTime = obj.ExposureTime;
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
            
            if ~isempty(obj.ZFitPos);Data.ZFitPos = obj.ZFitPos;end
            if ~isempty(obj.ZFitModel);Data.ZFitModel = obj.ZFitModel;end
            if ~isempty(obj.ZMaxAC); Data.ZMaxAC = obj.ZMaxAC;end
            if ~isempty(obj.Image_Reference);Data.Image_Reference = obj.Image_Reference;end
            if ~isempty(obj.Image_Current); Data.Image_Current = obj.Image_Current;end
            if ~isempty(obj.ZStack);Data.ZStack = obj.ZStack;end
            
            Children=[];
            
        end
        
        function delete(obj)
            %delete Deletes gui figure before deleting object
            delete(obj.GuiFigure);
        end
    end
    
    methods (Static)
        function [fval,model]=GaussFit(X,CC,Zpos)
            u = X(1);    %mean
            s = X(2);    %sigma
            a = X(3);    %magnitude
            o = X(4);    %offset
            model=o + a*normpdf(Zpos,u,s);
            fval=mse(model,CC);
        end
        
        function State = unitTest(camObj,stageObj,lampObj)
            %unitTest Tests all functionality of MIC_Reg3DTrans
            % 
            %  INPUT (required)
            %    CameraObj - camera object
            %    StageObj - stage object
            %    LampObj - lamp object
            %
            %  This will only work fully if there is a sample on the
            %  microscope with some contrast in transmission and that
            %  changes with changing z focus

            fprintf('\nTesting MIC_Reg3DTrans class...\n')
            % constructing and deleting instances of the class
            RegObj = MIC_Reg3DTrans(camObj,stageObj,lampObj);
            delete(RegObj);
            RegObj = MIC_Reg3DTrans(camObj,stageObj,lampObj);
            fprintf('* Construction and Destruction of object works\n')
            % loading and closing gui
            RegObj.gui;
            close(gcf);
            RegObj.gui;
            fprintf('* Opening and closing of GUI works, please test GUI manually\n');
            % Calibration
            fprintf('* Testing pixel size calibration\n')
            RegObj.calibratePixelSize();
            % Get current and reference images
            fprintf('* Testing image acquisition\n')
            RegObj.getcurrentimage();
            RegObj.takerefimage();
            % Perform alignment
            fprintf('* Testing alignment\n')
            RegObj.align2imageFit();
            % export state
            State = RegObj.exportState;
            disp(State);
            fprintf('* Export of current state works, please check workspace for it\n')
            fprintf('Finished testing MIC_Reg3DTrans class\n');            
        end
    end
    
end

