classdef MIC_Camera_Abstract < MIC_Abstract
  
% MIC_Camera_Abstract Class
% 
% The `MIC_Camera_Abstract` class serves as a base class for creating specific camera control classes in MATLAB. This abstract class provides a structured approach to implement common camera functionalities, ensuring consistency and ease of use across different camera models.
% 
% ## Features
% 
% - Uniform interface for various camera operations such as focus, capture, and sequence modes.
% - Properties for auto-scaling, display zoom, and live image display.
% - Customizable return types for image data and file saving formats.
% - Abstract methods that must be implemented for specific camera functionalities like initialization, acquisition setup, and shutdown.
% 
% ## Requirements
% 
% - MATLAB 2014 or higher.
% - Image Acquisition Toolbox.
% 
% ## Properties
% 
% - `AcquisitionType`: Type of acquisition ('focus', 'capture', 'sequence').
% - `AutoScale`: Enables automatic scaling of display images.
% - `DisplayZoom`: Factor by which the live display is zoomed.
% - `KeepData`: Specifies whether to store captured images.
% - `LUTScale`: Range for image display stretching.
% - `RangeDisplay`: Enables display of the minimum and maximum values on the live image.
% - `ReturnType`: Format of the returned image data ('matlab', 'dipimage').
% - `SaveType`: Format for saving images ('mat', 'ics').
% - `ShowLive`: Determines whether to show live data during acquisition.
% 
% ## Methods
% 
% ### Abstract Methods
% These methods must be implemented by subclasses to handle specific camera functionalities:
% 
% - `initialize()`: Initializes the camera settings.
% - `setup_acquisition()`: Prepares the camera for a specific type of acquisition.
% - `shutdown()`: Safely shuts down the camera.
% - `start_capture()`: Starts capturing images in capture mode.
% - `start_focus()`: Starts capturing images in focus mode.
% - `start_sequence()`: Starts capturing a sequence of images.
% - `getlastimage()`: Retrieves the most recent image captured.
% - `getdata()`: Retrieves all data acquired in the current session.

% CITATION: Sajjad Khan, Lidkelab, 2024.  
    
%These are not abstract so we can give set functions
    properties
        AcquisitionType='focus';    %'sequence','capture','focus'
        AutoScale=1;                %   1: on,0: off
        DisplayZoom=1;              %   live display zoom
        KeepData=1;                 %   1: store in 'Data', 0: discard
        LUTScale=[0 16000];         %   [min max] live view stretch
        RangeDisplay=1;             %   display [min max] on live image
        ReturnType='dipimage';      %   'matlab','dipimage','none'
        SaveType='mat';             %   'mat','ics'
        ShowLive=1;                 %   show data on screen during acquisision
    end
    
    properties(Abstract,Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq;        %If not, call setup_acquisition
        TextHandle;
    end
    
    properties(Abstract,SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
    end
    
    properties(Abstract)
        Binning;            %   [binX binY]
        Data;               %   last acquired data
        ExpTime_Focus;      %   focus mode exposure time
        ExpTime_Capture;    %   capture mode exposure time
        ExpTime_Sequence;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        SequenceLength;     %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
    end
    
    methods
        
        function obj = MIC_Camera_Abstract(AutoName)
            %Constructor 
            obj=obj@MIC_Abstract(AutoName);
            
            if nargin<1
                obj.CameraIndex=[];
            end
            
            obj.initialize;
            obj.get_properties;
        end
        
         function delete(obj)
             if ~(isempty(obj.FigureHandle)||~ishandle(obj.FigureHandle))
                close(obj.FigureHandle); 
             end
            obj.shutdown;
         end
        
        function obj = abortnow(obj)
            obj.AbortNow=1;
            obj.FigurePos=get(obj.FigureHandle,'position');
            obj.FigureHandle=[];
            obj.TextHandle=[];
            obj.abort;
        end
        
        function obj = roiselect(obj)
        end
        
        function obj = save(obj,filename)
            data=obj.getdata;
            switch obj.ReturnType
                case 'dipimage'
                    data=dip_image(data,'uint16');
                case 'matlab'
                     %already in uint16   
            end   
            
            switch obj.SaveType
                case 'mat'
                    eval([obj.AcquisitionType '=data';]);
                    params=obj.exportparameters();
                    params.FileName=filename;
                    save(filename,obj.AcquisitionType,'params');
                case 'ics'
                    writeim(obj.Data,filename,'ics');
            end
        end
        
        function params = exportParameters(obj)
            params=obj.CameraParameters;
            params.AcquisitionType=obj.AcquisitionType;
            params.ImageSize=obj.ImageSize;
            params.LastError=obj.LastError;
            params.Manufacturer=obj.Manufacturer;
            params.Model=obj.Model;
            params.XPixels=obj.XPixels;
            params.YPixels=obj.YPixels;
            params.Binning=obj.Binning;
            params.ExpTime_Focus=obj.ExpTime_Focus;
            params.ExpTime_Capture=obj.ExpTime_Capture;
            params.ExpTime_Sequence=obj.ExpTime_Sequence;
            params.ROI=obj.ROI;
            params.SequenceLength=obj.SequenceLength;
            params.SequenceCycleTime=obj.SequenceCycleTime;
        end
        
        
        %- SET METHODS--------------------------------------------------
        
        function set.AcquisitionType(obj,Type)
            obj.ReadyForAcq=0;
            switch Type
                case 'focus'
                    obj.AcquisitionType='focus';
                case 'capture'
                    obj.AcquisitionType='capture';
                case 'sequence'
                    obj.AcquisitionType='sequence';
                otherwise
                    warning('Type must be ''focus'', ''capture'' or ''sequence''. Not changed');
            end
        end
        
        function set.AutoScale(obj,in)
            switch in
                case 0
                    obj.AutoScale=0;
                case 1
                    obj.AutoScale=1;
                otherwise
                    warning('AutoScale must be 0 or 1. Not changed')
            end
        end
        
        function set.DisplayZoom(obj,in)
            if (in<.25)||(in>10)
                 warning('DisplayZoom must be between 0.25 and 10.Not changed')
                 return;
            end
            obj.DisplayZoom=in;
            obj.FigurePos=[];
            if (~isempty(obj.FigureHandle)&&ishandle(obj.FigureHandle))
                close(obj.FigureHandle);
                obj.FigurePos=[];
            end
            
        end

        function set.KeepData(obj,in)
            switch in
                case 0
                    obj.KeepData=0;
                case 1
                    obj.KeepData=1;
                otherwise
                    warning('KeepData must be 0 or 1. Not changed')
            end
        end
        
        function set.LUTScale(obj,in)
            if length(in)~=2
                warning('LUTScale must be [min max]')
                return;
            end
            if in(2)<=in(1)
                warning('max must be greater than min')
                return;
            end
            obj.LUTScale=in;
        end
        
        function set.RangeDisplay(obj,in)
            switch in
                case 0
                    obj.RangeDisplay=0;
                case 1
                    obj.RangeDisplay=1;
                otherwise
                    warning('RangeDisplay must be 0 or 1. Not changed')
            end
        end
        
        function set.ReturnType(obj,in)
            switch in
                case 'matlab'
                    obj.ReturnType='matlab';
                case 'dipimage'
                    obj.ReturnType='dipimage';  
                otherwise
                    warning('ReturnType must ''matlab'', ''dipimage'', or ''none''.  Not changed')
            end
        end
        
        function set.SaveType(obj,in)
            switch in
                case 'mat'
                    obj.SaveType='mat';
                case 'ics'
                    obj.SaveType='ics';
                otherwise
                    warning('SaveType must be mat or ics. Not changed')
            end
        end
        
        function set.ShowLive(obj,in)
            switch in
                case 0
                    obj.ShowLive=0;
                case 1
                    obj.ShowLive=1;
                otherwise
                    warning('ShowLive must be 0 or 1. Not changed')
            end
        end
        
    end
    
    methods(Access=protected)
        
        function displaylastimage(obj)
            
            im=obj.getlastimage();
            
            %open window if necessary
            if isempty(obj.FigureHandle)||~ishandle(obj.FigureHandle)
                obj.FigureHandle=figure;
                obj.ImageHandle=image(im');
                set(obj.FigureHandle,'Name','CameraLive');
                set(obj.FigureHandle,'DeleteFcn',@(h,e)obj.abortnow())
                set(obj.FigureHandle,'colormap',gray(256))
                %set(obj.FigureHandle,'Renderer','Painters','Toolbar','none','menubar','none')
                set(obj.FigureHandle,'Renderer','OpenGL','Toolbar','none','menubar','none')
                set(gca,'xlim',[0.5,size(im,1)],'ylim',[0.5,size(im,2)])%'ed
                set(gca,'Visible','off')
                set(gca,'Position',[0 0 1 1])
                %set position of the figure
                if ~isempty(obj.FigurePos)
                    set(obj.FigureHandle,'position',obj.FigurePos);
                else
                    scrsz=get(0,'ScreenSize');
                    imsz_display=[obj.ImageSize(1) obj.ImageSize(2)]*obj.DisplayZoom;
                    ypos=scrsz(4)-imsz_display(2)-75;
                    xpos=max([scrsz(3)-imsz_display(1)-200 50]);
                    set(obj.FigureHandle,'position',[xpos ypos imsz_display(1) imsz_display(2)])
                end
            end

            %scaling
            mx=double(max(max(im)));
            mn=double(min(min(im)));
            if obj.AutoScale
                im = single(im-mn)/(mx-mn);
                im=255*im';
            else
                im = single(in-obj.LUTScale(1))/(obj.LUTScale(2)-obj.LUTScale(1));
                im=255*im';
            end
            
            %update data
            set(obj.ImageHandle,'cdata',im);
            
            
            %range display
            if obj.RangeDisplay && ~isempty(obj.FigureHandle)
                s=sprintf('[%d %d]',mn,mx);
                if isempty(obj.TextHandle)||~ishandle(obj.TextHandle)
                    obj.TextHandle=text(50/obj.DisplayZoom,50/obj.DisplayZoom,s);
                    set(obj.TextHandle,'Color','g')
                    set(obj.TextHandle,'FontSize',16)
                else
                    set(obj.TextHandle,'String',s)
                end
            end
            
            drawnow limitrate ;
            
        end
        
    end
    
    methods(Abstract)
        abort(obj)
        %delete(obj)%cannot be abstract
        errorcheck(obj,funcname)
        out=getlastimage(obj)
        out=getdata(obj)
        initialize(obj)
        setup_acquisition(obj)
        shutdown(obj)
        start_capture(obj)
        start_focus(obj)
        start_sequence(obj)
    end
    
    methods(Abstract,Access=protected)
        obj=get_properties(obj)    %Sets all protected properties
        [temp status]=gettemperature(obj);
             %output status
                %0: temp not available
                %1: temp has stabilized
                %2: temp not stabilized 
                %3: temp drifted after stabilzation
    end
    
    
end
