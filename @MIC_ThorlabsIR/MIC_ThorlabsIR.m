classdef MIC_ThorlabsIR < MIC_Camera_Abstract
% MIC_ThorlabsIR Matlab Instrument Control Class for the Thorlab IR Camera
    %   This class controls the IRcamera via a USB port
    %   model DCxCamera.
    %     
    %   Constructor requires the Device and Channel details.
    %   Usage:
    %           CAM=MIC_ThorlabsIR
    %           CAM.gui
    %   
    % REQUIRES: 
    %   MIC_Abstract.m
    %   MIC_Camera_Abstract.m
    %   Data Acquisition Toolbox
    %   ThorLabs DCx CMOS and CCD Cameras
    %   Requires uc480DotNet.dll
    
    
    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;;        %If not, call setup_acquisition
        TextHandle;
    end
    
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        InstrumentName='DCxCamera' 

    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  'true' starts GUI on object creation. 
    end
    
    properties
        Binning;            %   [binX binY]
        Data;               %   last acquired data
        ExpTime_Focus=.1;      %   focus mode exposure time
        ExpTime_Capture=.5;    %   capture mode exposure time
        ExpTime_Sequence=.1;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        %%%
        SequenceLength=1;     %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
        Cam;                %   .NET Camera Object
        MemID;              %   Camera memory ID
    end
    
    methods
         function obj=MIC_ThorlabsIR()
            obj = obj@MIC_Camera_Abstract(~nargout);
         end
        
         function delete(obj)%cannot be abstract
                    obj.shutdown()
                end
        %
         
        function abort(obj)
            obj.AbortNow=1;
            obj.Cam.Acquisition.Stop;
        end
         function out=getlastimage(obj)
            if isempty(obj.ROI)
                            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
          
            [a,b]=obj.Cam.Memory.CopyToArray(obj.MemID);
          ImageElements=obj.ImageSize(1)*obj.ImageSize(2);
          bPrime=reshape(single(b),[obj.XPixels,obj.YPixels]); %FF
          out=bPrime(obj.ROI(1):obj.ROI(2),obj.ROI(3):obj.ROI(4)); %FF
          
          %bPrime=bPrime(1:ImageElements);
            %out=reshape(bPrime,obj.ImageSize(1),obj.ImageSize(2)); %%% i should 
            %%%change it to reshape (single(b),obj.ROI(2), ...)but I need
            %%%to chaneg line 126 as well.
            %   %%%          aa=dip_image(out,'uint8')
        end
        
        function out=getdata(obj)
            if isempty(obj.ROI)
                            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            switch obj.AcquisitionType
                case 'focus'
                    out=obj.getlastimage();
                case 'capture'
                    out=obj.getlastimage();
                case 'sequence'
                    for ii=1:obj.SequenceLength
                        out=zeros(obj.ROI(2),obj.ROI(4),obj.SequenceLength);
                        out(:,:,ii)=obj.getlastimage;
                    end
            end
            
        end
        
        function errorcheck(obj,funcname)
        end
        
           
        function initialize(obj)
            
            %NET.addAssembly(fullfile(pwd,'uc480DotNet.dll'));
            NET.addAssembly('C:\Program Files (x86)\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\signed\uc480DotNet.dll')
            [a,CamList]=uc480.Info.Camera.GetCameraList
            CamList(1)
            CamList(1).Model
            CamList(1).SerialNumber
            %             CamID=1;
            obj.Cam=uc480.Camera()
            obj.Cam.Init();
            %%%
            obj.Cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);
                        obj.get_properties;

        end
        
        function setup_acquisition(obj)
            
            %%% check if it is needed to add obj.abort IMGSourceCamera line
            %%%103
%             [a,SensorInfo]=obj.Cam.Information.GetSensorInfo();
%             obj.XPixels=SensorInfo.MaxSize.Width;
%             obj.YPixels=SensorInfo.MaxSize.Height;
            
            
            %%%
            
            %%%E
            
            % This sets up memory
            [Stat,obj.MemID]=obj.Cam.Memory.Allocate(obj.XPixels,obj.YPixels,8);
            obj.Cam.Memory.SetActive(obj.MemID);
            
            obj.Cam.Timing.PixelClock.Set(5); %Mhz
            
            switch obj.AcquisitionType
                case 'focus'
                    obj.Cam.Timing.Framerate.Set(1/obj.ExpTime_Focus);
                    obj.Cam.Timing.Exposure.Set(obj.ExpTime_Focus*1000);
                    [Stat, ExpTime]=obj.Cam.Timing.Exposure.Get;
                    fprintf('Expsoure Time: %g\n',ExpTime)
                case 'capture'
                    obj.Cam.Timing.Framerate.Set(1/obj.ExpTime_Capture);
                    obj.Cam.Timing.Exposure.Set(obj.ExpTime_Capture*1000);
                    [Stat, ExpTime]=obj.Cam.Timing.Exposure.Get;
                    fprintf('Expsoure Time: %g\n',ExpTime)
                    
                    %%%
                case 'sequence'
                    %                    obj.SequenceLength= from gui ?
                    obj.Cam.Timing.Framerate.Set(1/obj.ExpTime_Capture);
                    obj.Cam.Timing.Exposure.Set(obj.ExpTime_Sequence*1000);
                    [Stat, ExpTime]=obj.Cam.Timing.Exposure.Get;
                    %                     fprintf('Expsoure Time: %g\n',ExpTime)
                    
                    %%%E
            end
            
            obj.ReadyForAcq=1;%%%
            
        end
        
        function shutdown(obj)
            obj.Cam.Exit()
        end
       
        
        function out=start_focus(obj)
            
            obj.AcquisitionType='focus';
            obj.setup_acquisition;
            obj.AbortNow=0;
            
            obj.Cam.Acquisition.Capture();
            while ~obj.AbortNow
                obj.displaylastimage;
            end
            
            out=obj.getdata;
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint8');
                case 'matlab'
                    %already in uint8
            end
            
        end
        
        function out=start_capture(obj)
            obj.AcquisitionType='capture';
            obj.setup_acquisition;
            s32Wait=uc480.Defines.DeviceParameter.Wait;
            obj.Cam.Acquisition.Freeze(s32Wait);
            out=obj.getdata;
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint8');
                case 'matlab'
                    %already in uint8
            end
            dipshow(permute(out,[2 1])); %%%?
            
        end
        
        
        
        function SeqOutput=start_sequence(obj)
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
                        obj.Data=zeros(obj.ROI(2),obj.ROI(4),obj.SequenceLength);
            %init empty array
            for ii=1:obj.SequenceLength
                s32Wait=uc480.Defines.DeviceParameter.Wait;
            obj.Cam.Acquisition.Freeze(s32Wait);
%                 out=obj.getlastimage; %FF
                
                if obj.AbortNow
                    %obj.LastError=AbortAcquisition();
                    obj.AbortNow=0;
                    break
                end
                
                if obj.KeepData
                    obj.Data(:,:,ii)=out;
                end
                
                switch obj.ReturnType
                    case 'dipimage'
                        out=dip_image(out,'uint8');
                    case 'matlab'
                        %already in uint8
                end
                %                 dipshow(permute(out,[2 1])); %%%?
                obj.displaylastimage;
            end
            SeqOutput=obj.Data;
            
        end
        %%%
        function set.ROI(obj,in)
            obj.ROI=in;
            obj.ImageSize=[in(2)-in(1)+1,in(4)-in(3)+1];
        end
        %%%E
        
         
        function exportState()
        end
        
        function unitTest()
        end
    end
    
    methods(Access=protected)
        function obj=get_properties(obj)         %Sets all protected properties
        
        [a,SensorInfo]=obj.Cam.Information.GetSensorInfo();
            obj.XPixels=SensorInfo.MaxSize.Width;
            obj.YPixels=SensorInfo.MaxSize.Height;
        
        end
       
        
        function [temp status]=gettemperature(obj)
            temp=0;
            status=1;
        end
    end
end