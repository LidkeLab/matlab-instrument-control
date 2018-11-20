classdef MIC_ActiveReg3D_SPT < handle     %MIC_Abstract
 
    
    properties
        CameraObj
        StageObj
        PixelSize;            %micron
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
        MaxZShift  = 0.05;          %micron
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
        PlotFigureHandle
    end
    properties (SetAccess=protected)
        InstrumentName = 'Active3DTransmission'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    properties (Access='private')
        ZMax_Adapt;
        ZStep_Adapt;
        Fig_h_plot;
        Fig_h_ov;
    end 
    methods
        function obj=MIC_ActiveReg3D_SPT(CameraObj,StageObj)
            obj.StageObj=StageObj;
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
            X=obj.StageObj.Position;
            N=10;
            StepSize=0.1; %micron
            deltaX=((0:N-1)*StepSize)';
            ImSz=obj.CameraObj.ImageSize;
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            
            Xstart=X;
            for ii=1:N
                X(1)=Xstart(1)+deltaX(ii);
                X(2)=Xstart(2)+deltaX(ii);
                obj.StageObj.setPosition(X);
                pause(.5);
                ImageStack(:,:,ii)=obj.capture_single;
            end
            obj.StageObj.setPosition(Xstart);
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
            
            %             %Take several images to auto scale ???
            %             for nn=1:10
            %                 obj.capture_single();
            %             end
            %
            obj.capture_single();
            XYZ=obj.StageObj.Position;
            obj.X_Current=XYZ(1);
            obj.Y_Current=XYZ(2);
            obj.Z_Current=XYZ(3);
            
            Zmax=obj.ZStack_MaxDev;     %micron
            Zstep=obj.ZStack_Step;      %micron
        
            obj.ZStack_Pos=(obj.Z_Current-Zmax:Zstep:obj.Z_Current+Zmax);
            N=length(obj.ZStack_Pos);
            zstack=[];
            for nn=1:N
                obj.StageObj.setPosition([obj.X_Current,obj.Y_Current,obj.ZStack_Pos(nn)]);
                if nn==1
                    pause(0.2);
                end
                out=obj.capture_single;
                zstack=cat(3,zstack,out);
            end
            obj.Image_ReferenceStack=zstack;
            ind=find(obj.ZStack_Pos==obj.Z_Current);
            obj.Image_ReferenceInfocus=squeeze(zstack(:,:,ind(1)));
            obj.StageObj.setPosition(XYZ);
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
            X=obj.StageObj.Position;
            
            %This is the difference between the reference and current image
            Zshift=real(obj.ZStack_Pos(obj.IndexFocus)-Zfit);
            obj.ErrorSignal(3)=Zshift;
            
            %Image before corrections
            obj.Image_preCorrection=cat(3,obj.Image_preCorrection,obj.capture_single());
            
            %Change Z position
            %This restricts movement to obj.MaxZShift
            obj.Correction(3)=sign(obj.ErrorSignal(3))*min(obj.MaxZShift,abs(obj.ErrorSignal(3)));
            X(3)=X(3)+obj.Correction(3);
            obj.StageObj.setPosition(X);
            
            %Take new image, find XY position and adjust
            [Xshift,Yshift]=findXYShift(obj);
            obj.ErrorSignal(1:2)=[Xshift,Yshift]; % define error signal
            obj.Correction(1)=sign(-obj.ErrorSignal(1))*min(obj.MaxXYShift,abs(obj.ErrorSignal(1)));
            obj.Correction(2)=sign(-obj.ErrorSignal(2))*min(obj.MaxXYShift,abs(obj.ErrorSignal(2)));
            X(1:2)=X(1:2)+obj.Correction(1:2);
            obj.PosPostCorrect=X;
            
            %Keep history of correction
            obj.ErrorSignal_History=cat(1,obj.ErrorSignal_History,obj.ErrorSignal);
            obj.Correction_History=cat(1,obj.Correction_History,obj.Correction);
            obj.PosPostCorrect_History=cat(1,obj.PosPostCorrect_History,obj.PosPostCorrect);
            
            %Image after all corrections
            obj.StageObj.setPosition(X);
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
            Xshift=svec(2)*obj.PixelSize; %note dipimage permute
            Yshift=svec(1)*obj.PixelSize; % IR camera is mirror reflection in Y with the sCMOS
        end
        
        function out=capture_single(obj)
            img=obj.CameraObj.start_capture;
            out=single(img);
        end
    end
    
    
        
        
    
end