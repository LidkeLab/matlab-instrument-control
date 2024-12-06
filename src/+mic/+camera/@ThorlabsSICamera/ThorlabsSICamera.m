classdef ThorlabsSICamera < mic.camera.abstract
    % mic.camera.ThorlabsIR Matlab Instrument Class for control of
    % Thorlabs Scientific Camera (Model:CS165MU)
    % 
    % This class controls the Thorlabs Scientific Camera via a USB port. It is required to
    % install the software from the following link
    % https://www.thorlabs.com/software_pages/viewsoftwarepage.cfm?code=ThorCam
    % unzip 'Scientific Camera Interfaces.zip' which can be found in the installation folder at
    % 'C:\Program Files\Thorlabs\Scientific Imaging\Scientific Camera Support\'
    % Copy the .dll files from: 
    % 'Scientific Camera Interfaces\SDK\DotNet Toolkit\dlls\Managed_64_lib\' 
    % in this directory: 
    % 'C:\Program Files\Thorlabs\Scientific Imaging\Scientific Camera Support\Scientific Camera Interfaces\MATLAB\'
    % to initialize the camera
    % For the first time it is required to load the directory of .dll file 
    % from Program Files.    
    %
    % ## Protected and Transient Properties
    %
    % ### `AbortNow`
    % Flag to stop acquisition.
    %
    % ### `FigurePos`
    % Position of the figure window.
    %
    % ### `FigureHandle`
    % Handle for the figure window.
    %
    % ### `ImageHandle`
    % Handle for the image display.
    %
    % ### `ReadyForAcq`
    % Flag indicating if the camera is ready for acquisition.
    % **Default:** `0` (call `setup_acquisition` if not ready).
    %
    % ### `TextHandle`
    % Handle for text display.
    %
    % ### `dllPath`
    % Path for the DLL file.
    %
    % ## Protected Properties
    %
    % ### `CameraIndex`
    % Index used when more than one camera is present.
    %
    % ### `SerialNumbers`
    % Serial numbers associated with the camera.
    %
    % ### `ImageSize`
    % Size of the current ROI (Region of Interest).
    %
    % ### `LastError`
    % Last error code encountered.
    %
    % ### `Manufacturer`
    % Camera manufacturer.
    %
    % ### `Model`
    % Camera model.
    %
    % ### `CameraParameters`
    % Camera-specific parameters.
    %
    % ### `XPixels`
    % Number of pixels in the first dimension.
    %
    % ### `YPixels`
    % Number of pixels in the second dimension.
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'TSICamera'`.
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Flag to control whether the GUI starts automatically.
    % **Default:** `false`.
    %
    % ## Public Properties
    %
    % ### `Binning`
    % Binning settings in the format `[binX binY]`.
    %
    % ### `Data`
    % Last acquired data.
    %
    % ### `ExpTime_Focus`
    % Exposure time for focus mode.
    % **Default:** `0.01`.
    %
    % ### `ExpTime_Capture`
    % Exposure time for capture mode.
    % **Default:** `0.01`.
    %
    % ### `ExpTime_Sequence`
    % Exposure time for sequence mode.
    % **Default:** `0.01`.
    %
    % ### `ROI`
    % Region of interest in the format `[Xstart Xend Ystart Yend]`.
    %
    % ### `SequenceLength`
    % Length of the kinetic series.
    %
    % ### `SequenceCycleTime`
    % Cycle time for the kinetic series (equivalent to `1/frame rate`).
    %
    % ### `CameraHandle`
    % .NET Camera object handle.
    %
    % ### `SDKHandle`
    % Handle for the TLCameraSDK.
    %
    % ### `TriggerMode`
    % Trigger mode for the camera.
    % **Default:** `'internal'`.
    %
    % Example: obj=mic.camera.ThorlabsSICamera();
    % Function: initialize, abort, delete, shutdown, getlastimage, getdata,
    % setup_acquisition, start_focus, start_capture, start_sequence, set.ROI,
    % get_properties, exportState, funcTest  
    %     
    % REQUIREMENTS: 
    %   mic.abstract.m
    %   mic.camera.abstract.m
    %   MATLAB software version R2016b or later
    % 
    % CITATION: Sheng Liu  Lidkelab, 2024.
    
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
        SerialNumbers;
        ImageSize;                %size of current ROI
        LastError;                %last errorcode
        Manufacturer;             %camera manufacturer
        Model;                    %camera model
        CameraParameters;         %camera specific parameters
        XPixels;                  %number of pixels in first dimention
        YPixels;                  %number of pixels in second dimention
        InstrumentName='TSICamera'%Name of instrument
        
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
        CameraHandle;                   %.NET Camera Object
        SDKHandle;             %TLCameraSDK handle
        TriggerMode='internal';
    end
    
    methods
        function obj=ThorlabsSICamera()
            % Set up from Camera Abstract class
            % Example: IRCamera=mic.camera.ThorlabsIR();
            obj = obj@mic.camera.abstract(~nargout);
        end
        
        function initialize(obj)
            % Initialize the camera
            % Load .dll file 
            [p,~]=fileparts(which('mic.camera.ThorlabsSICamera'));
            if exist(fullfile(p,'ThorlabsSICamera_Properties.mat'),'file')
                a=load(fullfile(p,'ThorlabsSICamera_Properties.mat'));
                if exist(a.dllPath,'dir')
                    obj.dllPath=a.dllPath;
                else
                    error('Not a valid path')
                end
                clear a;
            else
                [dllPath]=uigetdir(matlabroot,'Select Scientific Camera .dll Directory');
                obj.dllPath=dllPath;
                if exist(obj.dllPath,'dir')
                    save(fullfile(p,'ThorlabsSICamera_Properties.mat'),'dllPath');
                else
                    error('Not a valid path')
                end
            end
            addpath(obj.dllPath)
            % Connect to the camera via .NET Programming Interface
            NET.addAssembly(fullfile(obj.dllPath,'Thorlabs.TSI.TLCamera.dll'));
            CurrentPath = pwd;
            cd(obj.dllPath)
            obj.SDKHandle = Thorlabs.TSI.TLCamera.TLCameraSDK.OpenTLCameraSDK;
            % Get serial numbers of connected TLCameras.
            obj.SerialNumbers = obj.SDKHandle.DiscoverAvailableCameras;
            % Open the first TLCamera using the serial number.
            tlCamera = obj.SDKHandle.OpenCamera(obj.SerialNumbers.Item(0), false);

            
            obj.CameraHandle = tlCamera;
            
            obj.XPixels = tlCamera.SensorWidth_pixels;
            obj.YPixels = tlCamera.SensorHeight_pixels;
            obj.ROI=[1, obj.XPixels, 1, obj.YPixels];
            
            obj.SequenceLength=1;
            obj.CameraHandle.OperationMode = Thorlabs.TSI.TLCameraInterfaces.OperationMode.SoftwareTriggered;
            obj.KeepData = 1;
            obj.ReturnType = 'matlab';
            cd(CurrentPath)
        end
        
        function abort(obj)
            %stop taking data during acquisition
            obj.AbortNow=1;
            obj.CameraHandle.Disarm;
        end
     
        function delete(obj)
            % Destructor
            obj.shutdown();
        end
            
        function shutdown(obj)
            % Shuts down obj
            CurrentPath = pwd;
            cd(obj.dllPath)
            obj.CameraHandle.Dispose();
            obj.SDKHandle.Dispose;
            cd(CurrentPath)
        end
        
        function errorcheck(obj)
            % There is no errorcheck function for this camera!
        end 
        
        function out=getlastimage(obj)
            %getting last image
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            while(obj.CameraHandle.NumberOfQueuedFrames == 0) 
                pause(obj.CameraHandle.FrameTime_us/1e6)
                if obj.AbortNow
                    break;
                end
            end
            imageFrame = obj.CameraHandle.GetPendingFrameOrNull();
            if ~isempty(imageFrame)
                imageData = uint16(imageFrame.ImageData.ImageData_monoOrBGR);
                out = reshape(imageData,[obj.ImageSize(1),obj.ImageSize(2)]);
            else
                out = [];
            end
            % Release the image frame
            delete(imageFrame);
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

            end
            
        end
        
        function setup_acquisition(obj)
          % set the camera for each type of acquistion            
            
            
            switch obj.AcquisitionType
                case 'focus'
                    obj.CameraHandle.ExposureTime_us = obj.ExpTime_Focus*1e6;
                    obj.CameraHandle.MaximumNumberOfFramesToQueue = 5;
                    obj.CameraHandle.FramesPerTrigger_zeroForUnlimited = 0;
                case 'capture'
                    obj.CameraHandle.ExposureTime_us = obj.ExpTime_Capture*1e6;
                    obj.CameraHandle.MaximumNumberOfFramesToQueue = 1;
                    obj.CameraHandle.FramesPerTrigger_zeroForUnlimited = 1;
                case 'sequence'
                    obj.CameraHandle.ExposureTime_us = obj.ExpTime_Sequence*1e6;
                    obj.CameraHandle.MaximumNumberOfFramesToQueue = obj.SequenceLength;
                    obj.CameraHandle.FramesPerTrigger_zeroForUnlimited = obj.SequenceLength;
                    
            end
            obj.SequenceCycleTime = obj.CameraHandle.FrameTime_us/1e6;
            obj.ReadyForAcq=1;
        end
    
        
        function out=start_focus(obj)
            % taking image in the case of focus 
            obj.AcquisitionType='focus';
            obj.setup_acquisition;
            obj.AbortNow=0;
            
            obj.CameraHandle.Arm;
            obj.CameraHandle.IssueSoftwareTrigger;
            while ~obj.AbortNow
                    out = obj.displaylastimage;
            end
            
            
            if obj.KeepData
                obj.Data=out;
            end
            obj.CameraHandle.Disarm;
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
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
            obj.CameraHandle.Arm;
            obj.CameraHandle.IssueSoftwareTrigger;
            out=obj.getdata;
            obj.CameraHandle.Disarm;
            if obj.KeepData
                obj.Data=out;
            end
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
            end
        end
        function SeqOutput=start_sequence(obj)
            % taking image in the case of sequence
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            %init empty array
            obj.Data=zeros(obj.ROI(2)-obj.ROI(1)+1,obj.ROI(4)-obj.ROI(3)+1,obj.SequenceLength);
            obj.AbortNow=0;
            obj.CameraHandle.Arm;
            obj.CameraHandle.IssueSoftwareTrigger;
            for ii=1:obj.SequenceLength

                out=obj.displaylastimage;
                
                if obj.AbortNow
                    obj.AbortNow=0;
                    break
                end
                
                if obj.KeepData
                    obj.Data(:,:,ii)=out;
                end
                
  

            end
            obj.CameraHandle.Disarm;
            SeqOutput=obj.Data;
            
        end
        
        function set.ROI(obj,in)
            % set the Region Of Interest to take image 
            obj.ROI = in;
            obj.CameraHandle.ROIAndBin.ROIOriginX_pixels = in(1)-1;
            obj.CameraHandle.ROIAndBin.ROIWidth_pixels = in(2)-in(1)+1;
            obj.CameraHandle.ROIAndBin.ROIOriginY_pixels = in(3)-1;
            obj.CameraHandle.ROIAndBin.ROIHeight_pixels = in(4)-in(3)+1;
            obj.ImageSize=[obj.CameraHandle.ImageWidth_pixels,obj.CameraHandle.ImageHeight_pixels];
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export current state of the Camera
            %Get default properties
            Attributes=obj.exportParameters();
            Data=obj.Data;
            Children=[];
            
        end
        
        function fireTrigger(obj)
            % For now, just throw a warning since we haven't implemented
            % software triggering for the Andor cameras.
            warning('Software triggered capturing not yet implemented!')
        end
    end
    
    % all abstract function to set the properties of the camera
    methods(Access=protected)
        function obj=get_properties(obj)         %Sets all protected properties
            

            
        end
        
        function [temp status]=gettemperature(obj)
            temp=0;
            status=1;
        end
    end
    
    methods (Static=true)
        function Success=funcTest()
            % unit test of object functionality
            % Syntax: mic.camera.ThorlabsIR.funcTest();
            % Example:
            % mic.camera.ThorlabsIR.funcTest();
            
            Success=0;
            %Create object
            try
                Cam=mic.camera.ThorlabsSCamera();
                Cam.ExpTime_Focus=.1;
                Cam.KeepData=1;
                Cam.setup_acquisition()
                Cam.start_focus()
                Cam.AcquisitionType='capture';
                Cam.ExpTime_Capture=.1;
                Cam.setup_acquisition()
                Cam.KeepData=1;
                Cam.start_capture()
                dipshow(Cam.Data)
                Cam.AcquisitionType='sequence';
                Cam.ExpTime_Sequence=.01;
                Cam.SequenceLength=10;
                Cam.setup_acquisition();
                Cam.start_sequence();
                Cam.exportState;
                delete(Cam)
                Success=1;
            catch
                delete(Cam)
                close all
            end
            
        end
    end
end
