classdef ActiveReg3D < handle 
% mic.ActiveReg3D
% 
% ## Description
% `mic.ActiveReg3D` is a MATLAB class designed for three-dimensional active registration using camera and stage control via piezoelectric actuators. This class is intended for precision imaging applications where maintaining focus and alignment within sub-micron tolerances is crucial.
% 
% ## Features
% - Three-dimensional control of piezo stages (`Stage_Piezo_X`, `Stage_Piezo_Y`, `Stage_Piezo_Z`).
% - Error correction in real-time based on captured image feedback.
% - Dynamic adjustment and correction history tracking.
% - Calibration function to determine pixel size based on stage movements and image alignment.
% - Periodic alignment capability with adjustable intervals.
%
% ## Properties
% - `CameraObj`: Camera object for image capture.
% - `Stage_Piezo_X/Y/Z`: Piezo actuators for stage control in X, Y, and Z directions.
% - `SCMOS_PixelSize`, `PixelSize`: Pixel size in microns, updated during calibration.
% - `ImageFile`, `Image_ReferenceStack`, `Image_ReferenceInfocus`: Image storage for reference and processing.
% - `ZStack_MaxDev`, `ZStack_Step`: Parameters defining the Z-stack acquisition.
% - `X_Current`, `Y_Current`, `Z_Current`: Current positions in microns.
% - `Tol_X`, `Tol_Y`, `Tol_Z`: Tolerance levels for positioning corrections.
% - `MaxIter`, `MaxXYShift`, `MaxZShift`: Maximum allowed iterations and shifts during corrections.
% - `Timer`, `Period`: Timer object and period for periodic alignment.
% 
% ## Methods
% - `ActiveReg3D`: Constructor to initialize the object with camera and stage settings.
% - `calibrate`: Calibration method to determine the pixel size based on stage displacement and image shift correlation.
% - `takeRefImageStack`: Captures a stack of reference images to determine the best focus across a range of Z positions.
% - `start`, `stop`: Methods to start and stop periodic alignment.
% - `align2imageFit`: Function called periodically to align the current image to a reference image.
% - `findZPos`, `findXYShift`: Methods to find the optimal Z position and XY shifts based on image correlation.
% 
% ## Usage Example
% Here's a brief example on how to use `mic.ActiveReg3D`:
% ```matlab
% cameraObj = Camera(); % Replace with actual camera object initialization
% stageX = PiezoStage(); % Replace with actual piezo stage initialization
% stageY = PiezoStage(); % Replace with actual piezo stage initialization
% stageZ = PiezoStage(); % Replace with actual piezo stage initialization
% reg3d = mic.ActiveReg3D(cameraObj, stageX, stageY, stageZ);
% reg3d.calibrate();
% reg3d.takeRefImageStack();
% reg3d.start(); 
% % To stop the alignment process:
% reg3d.stop();
% ```
%  ### Citations: Lidkelab, 2017. 

   properties
        CameraObj
       % StageObj %old
        Stage_Piezo_X %new
        Stage_Piezo_Y %new
        Stage_Piezo_Z %new
        SCMOS_PixelSize;
%       PixelSize=0.108;            %micron
        PixelSize=0.124;            % bpp in micron
        ImageFile
        Image_ReferenceStack
        Image_ReferenceInfocus
        Image_preCorrection=[]            %Image before corrections
        Image_Current=[]               %Image after all corrections
        ZStack_MaxDev=0.5;          %micron
        ZStack_Step=0.05;           %micron
        X_Current;                  %micron
        Y_Current;                  %micron
        Z_Current;                  %micron
        ZStack_Pos;                 %micron
        Tol_X=.005;                 %micron
        Tol_Y=.005;                 %micron
        Tol_Z=.01;                  %micron
        MaxIter=10;
        MaxXYShift = 0.002;         %micron
        MaxZShift  = 0.1;          %micron
        ZFitPos;
        ZFitModel;
        ZMaxAC;
        IndexFocus;
        ErrorSignal     %Error Signal [X Y Z] in micron
        Correction      %Amount corrected [X Y Z] in micron
        PosPostCorrect  %Piezo Set Position after correction [X Y Z] in micron
        
        ErrorSignal_History=[]     %Error Signal [X Y Z] in micron
        Correction_History=[]      %Amount corrected [X Y Z] in micron
        PosPostCorrect_History=[]  %Piezo Set Position after correction [X Y Z] in micron
                
        X_position=[];
        
        Timer;
        Period=2;
    end
    
    properties (Access='private')
        ZMax_Adapt;
        ZStep_Adapt;
        Fig_h_plot;
        Fig_h_ov;
    end 
    methods
        
        %function obj=ActiveReg3D(CameraObj,StageObj) %old
         function obj=ActiveReg3D(CameraObj,Stage_Piezo_X,Stage_Piezo_Y,Stage_Piezo_Z) %new
            %obj.StageObj=StageObj; old
            obj.Stage_Piezo_X=Stage_Piezo_X; %new
            obj.Stage_Piezo_Y=Stage_Piezo_Y; %new
            obj.Stage_Piezo_Z=Stage_Piezo_Z; %new
            obj.CameraObj=CameraObj;
            
            [p,~]=fileparts(which('ActiveReg3D'));
            f=fullfile(p,'ActiveReg3D_Properties.mat');
            if exist(f,'file')
                a=load(f);
                obj.PixelSize=a.PixelSize;
                clear a;
            end
        end
        
        function State=exportState(obj)
           State.ErrorSignal_History =obj.ErrorSignal_History; 
           State.Correction_History =obj.Correction_History; 
           State.PosPostCorrect_History =obj.PosPostCorrect_History; 
           State.Image_ReferenceStack =obj.Image_ReferenceStack; 
           State.Image_Current =obj.Image_Current;  
           State.X_position =obj.X_position;  
        end
        
        function calibrate(obj)
            %move stage over 5 microns and fit line
            XYZ1=obj.Stage_Piezo_X.getPosition; %new
            XYZ2=obj.Stage_Piezo_Y.getPosition; %new
            XYZ3=obj.Stage_Piezo_Z.getPosition; %new
            XYZ=[XYZ1,XYZ2,XYZ3]; %new
            N=10;
            StepSize=0.1; %micron
            deltaX=((0:N-1)*StepSize)';
            ImSz=obj.CameraObj.ImageSize;
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            
            Xstart=XYZ; %new
            for ii=1:N
                %X(1)=Xstart(1)+deltaX(ii); old
                XYZ(1)=Xstart(1)+deltaX(ii); %new
                %X(2)=Xstart(2)+deltaX(ii);
                XYZ(2)=Xstart(2)+deltaX(ii); %new
                %obj.StageObj.set_position(X); old
                obj.Stage_Piezo_X.setPosition(XYZ(1)); %new
                obj.Stage_Piezo_Y.setPosition(XYZ(2)); %new
                pause(.5);
                ImageStack(:,:,ii)=obj.capture_single;
            end
             obj.Stage_Piezo_X.setPosition(Xstart(1)); %new
             obj.Stage_Piezo_Y.setPosition(Xstart(2)); %new
             obj.Stage_Piezo_Z.setPosition(Xstart(3)); %new
            dipshow(ImageStack);
            
            svec=zeros(N,2);
            refim=squeeze(ImageStack(:,:,1));
            for ii=1:N
                alignim=squeeze(ImageStack(:,:,ii));
                svec(ii,:)=findshift(alignim,refim,'iter');
            end
            
            Px=polyfit(deltaX,svec(:,1),1);
            Xfit=Px(1)*deltaX+Px(2);
            pixelSizex=abs(1/Px(1));     %micron
            
            Py=polyfit(deltaX,svec(:,2),1);
            Yfit=Py(1)*deltaX+Py(2);
            pixelSizey=abs(1/Py(1));     %micron
            
            if isempty(obj.Fig_h_plot)||~ishandle(obj.Fig_h_plot)
                obj.Fig_h_plot=figure;
            else
                figure(obj.Fig_h_plot)
            end
            plot(deltaX,svec(:,1),'r.','linewidth',2);
            hold on
            plot(deltaX,Xfit,'k','linewidth',2);
            plot(deltaX,svec(:,2),'r.','linewidth',2);
            plot(deltaX,Yfit,'k','linewidth',2);
            legend('Found Displacement','Fit');
            s1=sprintf('Pixel Size X= %g',pixelSizex);
            s2=sprintf('Pixel Size Y= %g',pixelSizey);
            text(0.2,-5,s1);
            text(0.2,-3,s2);
            xlabel('Microns')
            ylabel('Pixels')
            
            [p,~]=fileparts(which('ActiveReg3D'));
            f=fullfile(p,'ActiveReg3D_Properties.mat');
            PixelSize=(pixelSizex+pixelSizey)/2;
            save(f,'PixelSize');
            obj.PixelSize=PixelSize;
        end
        
        function takeRefImageStack(obj)
            
            %Take several images to auto scale
%             for nn=1:10 
%                 obj.capture_single();
%             end
            
            XYZ1=obj.Stage_Piezo_X.getPosition; %new
            XYZ2=obj.Stage_Piezo_Y.getPosition; %new
            XYZ3=obj.Stage_Piezo_Z.getPosition; %new
            XYZ=[XYZ1,XYZ2,XYZ3]; %new
            obj.X_Current=XYZ(1); 
            obj.Y_Current=XYZ(2);
            obj.Z_Current=XYZ(3);
                      
            Zmax=obj.ZStack_MaxDev;     %micron
            Zstep=obj.ZStack_Step;      %micron
        
            obj.ZStack_Pos=(obj.Z_Current-Zmax:Zstep:obj.Z_Current+Zmax);
            N=length(obj.ZStack_Pos);
            zstack=[];
            for nn=1:N
                obj.Stage_Piezo_X.setPosition(obj.X_Current); %new
                obj.Stage_Piezo_Y.setPosition(obj.Y_Current); %new
                obj.Stage_Piezo_Z.setPosition(obj.ZStack_Pos(nn)); %new
                if nn==1
                    pause(0.2);
                end
                out=obj.capture_single;
                zstack=cat(3,zstack,out);
            end
            obj.Image_ReferenceStack=zstack;
            ind=find(obj.ZStack_Pos==obj.Z_Current);
            obj.Image_ReferenceInfocus=squeeze(zstack(:,:,ind(1)));
            %obj.StageObj.set_position(XYZ); old
            obj.Stage_Piezo_X.setPosition(obj.X_Current); %new
            obj.Stage_Piezo_Y.setPosition(obj.Y_Current); %new
            obj.Stage_Piezo_Z.setPosition(obj.Z_Current); %new
            
            obj.IndexFocus=ind;
            pause(0.2);
        end
        
        function start(obj)
            %Start Periodic Alignment
            obj.Timer=timer('StartDelay',obj.Period,'period',obj.Period,'ExecutionMode','fixedRate');
            obj.Timer.TimerFcn=@obj.align2imageFit;
            start(obj.Timer);
        end
        
         function stop(obj)
            %Start Periodic Alignment
            stop(obj.Timer);
            delete(obj.Timer);
         end
        
        function align2imageFit(obj,varargin)
            %find z-position and adjust
            [Zfit]=obj.findZPos();
            XYZ1=obj.Stage_Piezo_X.getPosition; %new
            XYZ2=obj.Stage_Piezo_Y.getPosition; %new
            XYZ3=obj.Stage_Piezo_Z.getPosition; %new
            XYZ=[XYZ1,XYZ2,XYZ3]; %new        
            
            %This is the difference between the reference and current image
            Zshift=real(obj.ZStack_Pos(obj.IndexFocus)-Zfit);
            obj.ErrorSignal(3)=Zshift;
            
            %Image before corrections
            obj.Image_preCorrection=cat(3,obj.Image_preCorrection,obj.capture_single());
            
            %Change Z position
            %This restricts movement to obj.MaxZShift
            obj.Correction(3)=sign(obj.ErrorSignal(3))*min(obj.MaxZShift,abs(obj.ErrorSignal(3)));
            XYZ(3)=XYZ(3)+obj.Correction(3); %new
            obj.Stage_Piezo_X.setPosition(XYZ(1)); %new
            obj.Stage_Piezo_Y.setPosition(XYZ(2)); %new
            obj.Stage_Piezo_Z.setPosition(XYZ(3)); %new
            
            %Take new image, find XY position and adjust
            [Xshift,Yshift]=findXYShift(obj);
            obj.ErrorSignal(1:2)=[Xshift,Yshift]; % define error signal
            obj.Correction(1)=sign(obj.ErrorSignal(1))*min(obj.MaxXYShift,abs(obj.ErrorSignal(1)));
            obj.Correction(2)=sign(obj.ErrorSignal(2))*min(obj.MaxXYShift,abs(obj.ErrorSignal(2)));
            XYZ(1:2)=XYZ(1:2)+obj.Correction(1:2); %new
            obj.PosPostCorrect=XYZ; %new
            
            %Keep history of correction
            obj.ErrorSignal_History=cat(1,obj.ErrorSignal_History,obj.ErrorSignal);
            obj.Correction_History=cat(1,obj.Correction_History,obj.Correction);
            obj.PosPostCorrect_History=cat(1,obj.PosPostCorrect_History,obj.PosPostCorrect);
            
            %Image after all corrections
            obj.Stage_Piezo_X.setPosition(XYZ(1)); %new
            obj.Stage_Piezo_Y.setPosition(XYZ(2)); %new
            obj.Stage_Piezo_Z.setPosition(XYZ(3)); %new
            obj.Image_Current=cat(3,obj.Image_Current,obj.capture_single());

        end
        
        function [Zfit]=findZPos(obj)
            currentImg=obj.capture_single;
            Cur=currentImg(10:end-10,10:end-10);
            Cur=Cur-mean(Cur(:));
            Cur=Cur/std(Cur(:));
            
            zs=obj.Image_ReferenceStack(10:end-10,10:end-10,:);
            N=size(zs,3);
            n=numel(Cur);
            
            for ii=1:N
                %whiten 
                Refi=squeeze(zs(:,:,ii));
                Refi=Refi-mean(Refi(:));
                Refi=Refi/std(Refi(:));
                cc=abs(ifft2(fft2(Refi).*conj(fft2(Cur))));
                maxAC(ii)=1/n*max(cc(:));
            end
            [~,zindex]=find(maxAC==max(maxAC));
            
            %fit cross-correlation to find best in focus z-position
            StartFit=max(1,zindex-4);
            EndFit=min(N,zindex+4);
            Zpos_fit=obj.ZStack_Pos(StartFit:EndFit);
            maxAC_fit=maxAC(StartFit:EndFit);
            %fit
            [P, S,MU] = polyfit(Zpos_fit,maxAC_fit,3);
            model = polyval(P,Zpos_fit,S,MU);
            zAtMax=(-sqrt(P(2)^2-3*P(1)*P(3))-P(2))/3/P(1)*MU(2)+MU(1);

            obj.ZFitPos=Zpos_fit;
            obj.ZFitModel=model;
            obj.ZMaxAC=maxAC;
            
            %return z position
            Zfit=zAtMax;
        end
        
        function [Xshift,Yshift]=findXYShift(obj)
            %cut edges
            Ref=obj.Image_ReferenceInfocus(10:end-10,10:end-10);
            Ref=Ref-mean(Ref(:));
            Ref=Ref/std(Ref(:));

            %get image at current z-position
            Current=obj.capture_single;
            Current=Current(10:end-10,10:end-10);
            Current=Current-mean(Current(:));
            Current=Current/std(Current(:));
                
            %find 2D shift         
            svec=findshift(Current,Ref,'iter'); %finds shift between two images
            Xshift=svec(1)*obj.PixelSize; %note dipimage permute
            Yshift=svec(2)*obj.PixelSize; % IR camera is mirror reflection in Y with the sCMOS
        end
        
        function out=capture_single(obj)
            img=obj.CameraObj.start_capture;
            out=single(img);
        end
    end
    
    
        
        
    
end
