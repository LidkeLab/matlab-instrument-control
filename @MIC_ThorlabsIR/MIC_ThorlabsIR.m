classdef MIC_ThorlabsIR < MIC_Camera_Abstract
    % MIC_ThorlabsIR Matlab Instrument Class for control of
    % Thorlabs IR Camera (Model:DCC1545M)
    % 
    % This class controls the DCxCamera via a USB port. It is required to
    % install the software from the following link
    % https://www.thorlabs.com/software_pages/viewsoftwarepage.cfm?code=ThorCam
    % and make sure 'uc480DotNet.dll' is in this directory: 
    % 'C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet'
    % to initialize the camera
    % For the first time it is required to load the directory of .dll file 
    % from Program Files.    
    %
    % Example: obj=MIC_ThorlabsIR();
    % Function: initialize, abort, delete, shutdown, getlastimage, getdata,
    % setup_acquisition, start_focus, start_capture, start_sequence, set.ROI,
    % get_properties, exportState, unitTest  
    %     
    % REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_Camera_Abstract.m
    %   MATLAB software version R2016b or later
    %   uc480DotNet.dll file downloaded from the Thorlabs website for DCx cameras
    % 
    % CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
    
    properties(Access=protected, Transient=true)
        AbortNow;                 %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;            %If not, call setup_acquisition
        TextHandle;
        dllPath;                  %path for dll file
    end
    
    properties(SetAccess=protected)
        CameraIndex;              %index used when more than one camera
        ImageSize;                %size of current ROI
        LastError;                %last errorcode
        Manufacturer;             %camera manufacturer
        Model;                    %camera model
        CameraParameters;         %camera specific parameters
        XPixels;                  %number of pixels in first dimention
        YPixels;                  %number of pixels in second dimention
        InstrumentName='DCxCamera'%Name of instrument
        
    end
    
    properties (Hidden)
        StartGUI=false;        % Starts GUI
    end
    
    properties
        Binning;               %[binX binY]
        Data;                  %last acquired data
        ExpTime_Focus=.01;     %focus mode exposure time
        ExpTime_Capture=.01;   %capture mode exposure time
        ExpTime_Sequence=.01;  %sequence mode expsoure time
        ROI;                   %[Xstart Xend Ystart Yend]
        SequenceLength;        %Kinetic Series length
        SequenceCycleTime;     %Kinetic Series cycle time (1/frame rate)
        Cam;                   %.NET Camera Object
        MemID;                 %Camera memory ID
    end
    
    methods
        function obj=MIC_ThorlabsIR()
            % Set up from Camera Abstract class
            % Example: IRCamera=MIC_ThorlabsIR();
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function initialize(obj)
            % Initialize the camera
            % Load .dll file 
            [p,~]=fileparts(which('MIC_ThorlabsIR'));
            if exist(fullfile(p,'ThorlabsIRCamera_Properties.mat'),'file')
                a=load(fullfile(p,'ThorlabsIRCamera_Properties.mat'));
                if exist(a.dllPath,'dir')
                    obj.dllPath=a.dllPath;
                else
                    error('Not a valid path')
                end
                clear a;
            else
                [dllPath]=uigetdir(matlabroot,'Select IRCamera .dll Directory');
                obj.dllPath=dllPath;
                if exist(obj.dllPath,'dir')
                    save(fullfile(p,'ThorlabsIRCamera_Properties.mat'),'dllPath');
                else
                    error('Not a valid path')
                end
            end
            
            % Connect to the camera via .NET Programming Interface
            NET.addAssembly(fullfile(obj.dllPath,'uc480DotNet.dll'))
            [a,CamList]=uc480.Info.Camera.GetCameraList;
            CamList(1)
            CamList(1).Model
            CamList(1).SerialNumber
            obj.Cam=uc480.Camera();
            obj.Cam.Init();
            obj.Cam.PixelFormat.Set(uc480.Defines.ColorMode.SensorRaw8);
            obj.get_properties;
            obj.ROI=[1 obj.XPixels 1 obj.YPixels];
            obj.ImageSize=[obj.ROI(2)-obj.ROI(1)+1 obj.ROI(4)-obj.ROI(3)+1];
            obj.SequenceLength=1;
        end
        
        function abort(obj)
            %stop taking data during acquisition
            obj.AbortNow=1;
            obj.Cam.Acquisition.Stop;
        end
     
        function delete(obj)
            % Destructor
            obj.shutdown();
        end
            
        function shutdown(obj)
            % Shuts down obj
            obj.Cam.Exit()
        end
        
        function errorcheck(obj)
            % There is no errorcheck function for this camera!
        end 
        
        function out=getlastimage(obj)
            %getting last image
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            [a,b]=obj.Cam.Memory.CopyToArray(obj.MemID);
            ImageElements=obj.ImageSize(1)*obj.ImageSize(2);
            bPrime=reshape(single(b),[obj.XPixels,obj.YPixels]);
            out=bPrime(obj.ROI(1):obj.ROI(2),obj.ROI(3):obj.ROI(4));
        end
        
        function out=getdata(obj)
            %taking data for each type of acquisition
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
        
        function setup_acquisition(obj)
          % set the camera for each type of acquistion            
            
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
                case 'sequence'
                    obj.Cam.Timing.Framerate.Set(1/obj.ExpTime_Sequence);
                    obj.Cam.Timing.Exposure.Set(obj.ExpTime_Sequence*1000);
                    [Stat, ExpTime]=obj.Cam.Timing.Exposure.Get;
            end
            obj.ReadyForAcq=1;
        end
    
        
        function out=start_focus(obj)
            % taking image in the case of focus 
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
            end
            
        end
        
        function out=start_capture(obj)
            % taking image in the case of capture
            obj.AcquisitionType='capture';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
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
            end
            dipshow(permute(out,[2 1]));
        end
        function start_sequence(obj)
            % taking image in the case of sequence
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            %init empty array
            obj.Data=zeros(obj.ROI(2)-obj.ROI(1)+1,obj.ROI(4)-obj.ROI(3)+1,obj.SequenceLength);
            obj.AbortNow=0;
            for ii=1:obj.SequenceLength
                s32Wait=uc480.Defines.DeviceParameter.Wait;
                obj.Cam.Acquisition.Freeze(s32Wait);
                out=obj.getlastimage;
                
                if obj.AbortNow
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
                end
                obj.displaylastimage;
            end
            SeqOutput=obj.Data;
            
        end
        
        function set.ROI(obj,in)
            % set the Region Of Interest to take image 
            obj.ROI=in;
            obj.ImageSize=[in(2)-in(1)+1,in(4)-in(3)+1];
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export current state of the Camera
            %Get default properties
            Attributes=obj.exportParameters();
            Data=[];
            Children=[];
            
        end
    end
    
    % all abstract function to set the properties of the camera
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
    
    methods (Static=true)
        function Success=unitTest()
            % unit test of object functionality
            % Syntax: MIC_ThorlabsIR.unitTest();
            % Example:
            % MIC_ThorlabsIR.unitTest();
            
            Success=0;
            %Create object
            try
                CamIR=MIC_ThorlabsIR();
                CamIR.ExpTime_Focus=.1;
                CamIR.KeepData=1;
                CamIR.setup_acquisition()
                CamIR.start_focus()
                CamIR.AcquisitionType='capture';
                CamIR.ExpTime_Capture=.1;
                CamIR.setup_acquisition()
                CamIR.KeepData=1;
                CamIR.start_capture()
                dipshow(CamIR.Data)
                CamIR.AcquisitionType='sequence';
                CamIR.ExpTime_Sequence=.01;
                CamIR.SequenceLength=10;
                CamIR.setup_acquisition();
                CamIR.start_sequence();
                CamIR.exportState;
                delete(CamIR)
                Success=1;
            catch
                delete(CamIR)
                close all
            end
            
        end
    end
end