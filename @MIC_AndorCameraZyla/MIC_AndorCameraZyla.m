classdef MIC_AndorCameraZyla < MIC_Camera_Abstract
    %MIC_AndorCamera class for Zyla
    %
    %   Usage:
    %           CAM=AndorCameraZyla
    %           CAM.gui
    %
    %   Requires:
    %       Andor MATLAB SDK3 2.94.30005 or higher
    %
    %
    %   TODO:
    %
    % CITATION: Sandeep Pallikkuth, Lidke Lab, 2018
    
    properties(Access=protected, Transient=true)
        AbortNow;           %stop acquisition flag
        ErrorCode;
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;      %If not, call setup_acquisition
        TextHandle;
        CameraHandle;
        SDKPath;
        ImageSizeBytes;
        Buffer;
        Height;
        Width;
        Stride;
    end
    
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        
        CameraCap;          % capability (all options) of camera parameters created by qw
        CameraSetting;      % current setting of camera parameters created by qw
        CameraFrameIndex    %current frame number in sequence
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        
        Capabilities;       % Capabilities structure from camera
        
        InstrumentName='AndorZyla'
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  'true' starts GUI on object creation.
    end
    
    properties
        CamHandle;                  % Camera handle
        Binning=[1 1];              %   [binX binY]
        Data=[];                    %   last acquired data
        ExpTime_Focus=0;            %   focus mode exposure time
        ExpTime_Capture=0;          %   capture mode exposure time
        ExpTime_Sequence=0;         %   sequence mode expsoure time
        ExpTime;                    % exposure time
        ROI;                        %   [Xstart Xend Ystart Yend]
        SequenceLength=1;           %   Kinetic Series length
        FrameRate;                  % Frame rate of aquisition
        SequenceCycleTime;          %   Kinetic Series cycle time (1/frame rate)
        CycleMode;                  %
        GuiDialog;                  % GUI dialog for the CameraParameters
        % consider making GuiDialog abstract??
    end
    
    methods
        
        function obj=MIC_AndorCameraZyla()
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function start(obj)  %  I might put this in initialize later, need to test it out first...
            obj.initialize();
            %            obj.get_capabilities;
        end
        
        function initialize(obj)
            [p,~]=fileparts(which('MIC_AndorCameraZyla'));
            if exist(fullfile(p,'AndorCameraZyla_Properties.mat'),'file')
                a=load(fullfile(p,'AndorCameraZyla_Properties.mat'));
                if exist(a.SDKPath,'dir')
                    obj.SDKPath=a.SDKPath;
                else
                    error('Not a valid path')
                end
                clear a;
            else
                [SDK]=uigetdir(matlabroot,'Select Andor SDK3 Toolbox Directory');
                obj.SDKPath=SDK;
                if exist(obj.SDKPath,'dir')
                    save(fullfile(p,'AndorCameraZyla_Properties.mat'),'SDKPath');
                else
                    error('Not a valid path')
                end
            end
            
            addpath(obj.SDKPath)
            
            obj.LastError=AT_InitialiseLibrary();
            AT_CheckError(obj.LastError);
            %             if isempty(obj.CameraIndex)
            %                 obj.getcamera;
            %             end
            %             [obj.LastError,hndl] = AT_Open(obj.CameraIndex);
            [obj.LastError,obj.CamHandle] = AT_Open(0); % currently running only 1 camera
            AT_CheckError(obj.LastError);
            disp('Camera initialized');
            
            obj.get_properties;
            obj.Binning=[1 1];
            obj.ExpTime_Focus=0.01;
            obj.ExpTime_Capture=0.01;
            obj.ExpTime_Sequence=0.01;
            obj.ROI=[1 obj.XPixels 1 obj.YPixels];
            obj.ImageSize=[obj.ROI(2)-obj.ROI(1)+1 obj.ROI(4)-obj.ROI(3)+1];
            obj.SequenceLength=1;
            
            % load up camera params and capabilities
            obj.get_capabilities;
            
        end
        
        function reset(obj)
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStop');
            AT_CheckWarning(obj.LastError);
            [obj.LastError]=AT_Flush(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
        end
        
        function Out=start_sequence(obj)
            clc
            obj.AcquisitionType='sequence';
            obj.setup_acquisition();
            obj.CameraFrameIndex=0;
            %queue buffers
            for ii=1:10
                [obj.LastError] = AT_QueueBuffer(obj.CamHandle,obj.ImageSizeBytes);
            end
            obj.Data=zeros(obj.Width,obj.Height,obj.SequenceLength,'uint16');
            
            obj.AbortNow=0;
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStart');
            AT_CheckWarning(obj.LastError);
            
            IsRunning=1;
            while IsRunning
                if obj.AbortNow
                    obj.AbortNow=0;
                    IsRunning=0;
                    break
                end
                
                Im=obj.displaylastimage(); 
                obj.CameraFrameIndex=obj.CameraFrameIndex+1;
                obj.CameraFrameIndex
                obj.Data(:,:,obj.CameraFrameIndex)=Im;
                obj.Data(1,1,obj.CameraFrameIndex)
                if obj.CameraFrameIndex==obj.SequenceLength
                    break
                end
                
                [obj.LastError] = AT_QueueBuffer(obj.CamHandle,obj.ImageSizeBytes);
                AT_CheckWarning(obj.LastError);
            end
            
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStop');
            AT_CheckWarning(obj.LastError);
            
            [obj.LastError]=AT_Flush(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
            Out=obj.Data;
        end
        
        function Out=start_focus(obj)
            obj.AcquisitionType='focus';
            obj.setup_acquisition();
            [obj.LastError] = AT_Command(obj.CamHandle, 'AcquisitionStart');
            AT_CheckWarning(obj.LastError);
            [obj.LastError] = AT_QueueBuffer(obj.CamHandle,obj.ImageSizeBytes);
            IsRunning=1;
            
            while IsRunning
                if obj.AbortNow
                    obj.AbortNow=0;
                    IsRunning=0;
                    break
                end
                [obj.LastError] = AT_QueueBuffer(obj.CamHandle,obj.ImageSizeBytes);
                AT_CheckWarning(obj.LastError);
                
                [obj.LastError] = AT_Command(obj.CamHandle,'SoftwareTrigger');
                AT_CheckWarning(obj.LastError);
                
                obj.displaylastimage();
                
            end
            
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStop');
            AT_CheckWarning(obj.LastError);
            [obj.LastError]=AT_Flush(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
            Out=obj.Data;
        end
        
        function Out = start_capture(obj)
            obj.AcquisitionType='capture';
            obj.setup_acquisition();
            [obj.LastError] = AT_QueueBuffer(obj.CamHandle,obj.ImageSizeBytes);
            AT_CheckWarning(obj.LastError);
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStart');
            AT_CheckWarning(obj.LastError);
            [obj.LastError,buf] = AT_WaitBuffer(obj.CamHandle,1000+1000*obj.ExpTime_Capture);
            AT_CheckWarning(obj.LastError);
            [obj.LastError,Out] = AT_ConvertMono16ToMatrix(buf,obj.Height,obj.Width,obj.Stride);
            AT_CheckWarning(obj.LastError);
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStop');
            AT_CheckWarning(obj.LastError);
            [obj.LastError]=AT_Flush(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
            
            if obj.KeepData
                obj.Data=Out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    Out=dip_image(Out,'uint16');
                case 'matlab'
                    %already in uint16
            end
        end
        
        function setup_acquisition(obj)
            
            % Common Setup
            obj.ImageSize=[obj.ROI(2)-obj.ROI(1)+1 obj.ROI(4)-obj.ROI(3)+1];
            
            [rc] = AT_SetInt(obj.CamHandle,'AOIWidth',obj.ROI(2)-obj.ROI(1)+1);
            AT_CheckError(rc);
            [rc] = AT_SetInt(obj.CamHandle,'AOIHeight',obj.ROI(4)-obj.ROI(3)+1);
            AT_CheckError(rc);
            [rc] = AT_SetInt(obj.CamHandle,'AOILeft',obj.ROI(1));
            AT_CheckError(rc);
            [rc] = AT_SetInt(obj.CamHandle,'AOITop',obj.ROI(3));
            AT_CheckError(rc);
            
            [obj.LastError] = AT_SetEnumString(obj.CamHandle,'TriggerMode','Internal');
            AT_CheckWarning(obj.LastError);
            [rc] = AT_SetEnumString(obj.CamHandle,'PixelEncoding','Mono16');
            AT_CheckWarning(rc);
            [obj.LastError,obj.ImageSizeBytes] = AT_GetInt(obj.CamHandle,'ImageSizeBytes');
            AT_CheckWarning(obj.LastError);
            [obj.LastError,obj.Height] = AT_GetInt(obj.CamHandle,'AOIHeight');
            AT_CheckWarning(obj.LastError);
            [obj.LastError,obj.Width] = AT_GetInt(obj.CamHandle,'AOIWidth');
            AT_CheckWarning(obj.LastError);
            
            switch obj.AcquisitionType
                case 'focus'
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'ExposureTime',obj.ExpTime_Focus);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetEnumString(obj.CamHandle,'CycleMode','Continuous');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,MaxFrameRate] = AT_GetFloatMax(obj.CamHandle,'FrameRate');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'FrameRate',MaxFrameRate*.99);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,obj.Stride] = AT_GetInt(obj.CamHandle,'AOIStride');
                    AT_CheckWarning(obj.LastError);
                    
                case 'capture'
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'ExposureTime',obj.ExpTime_Capture);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetEnumString(obj.CamHandle,'CycleMode','Fixed');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetInt(obj.CamHandle,'FrameCount',1);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,obj.Stride] = AT_GetInt(obj.CamHandle,'AOIStride');
                    AT_CheckWarning(obj.LastError);
                    
                case 'sequence'
                    [obj.LastError] = AT_SetInt(obj.CamHandle,'FrameCount',obj.SequenceLength);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,MinExpTime] = AT_GetFloatMin(obj.CamHandle,'ExposureTime');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'ExposureTime',MinExpTime*1.01);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetEnumString(obj.CamHandle,'CycleMode','Fixed');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetEnumString(obj.CamHandle,'TriggerMode','Internal');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,obj.Stride] = AT_GetInt(obj.CamHandle,'AOIStride');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'FrameRate',1/obj.ExpTime_Sequence);
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError,MaxExpTime] = AT_GetFloatMax(obj.CamHandle,'ExposureTime');
                    AT_CheckWarning(obj.LastError);
                    [obj.LastError] = AT_SetFloat(obj.CamHandle,'ExposureTime',obj.ExpTime_Sequence);
                    AT_CheckWarning(obj.LastError);
                    
            end
            
            %get back actual timings
            %             obj.get_parameters();
            switch obj.AcquisitionType
                case 'focus'
                    [obj.LastError,obj.ExpTime_Focus]=AT_GetFloat(obj.CamHandle, 'ExposureTime');
                case 'capture'
                    [obj.LastError,obj.ExpTime_Capture]=AT_GetFloat(obj.CamHandle, 'ExposureTime');
                case 'sequence'
                    [obj.LastError,obj.ExpTime_Sequence]=AT_GetFloat(obj.CamHandle, 'ExposureTime');
            end
            
            
            obj.ReadyForAcq=1;
            
        end
        
        function out=getdata(obj)
            
        end
        
        function Out=getlastimage(obj)
            [obj.LastError,buf] = AT_WaitBuffer(obj.CamHandle,10000);
            AT_CheckWarning(obj.LastError);
            [obj.LastError,Out] = AT_ConvertMono16ToMatrix(buf,obj.Height,obj.Width,obj.Stride);
            AT_CheckWarning(obj.LastError);
            obj.Data=Out;
        end
        
        function errorcheck(obj)
            
        end
        
        function abort(obj)
            
            obj.AbortNow=1;
            
            [obj.LastError] = AT_Command(obj.CamHandle,'AcquisitionStop');
            AT_CheckWarning(obj.LastError);
            [obj.LastError]=AT_Flush(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
            
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            
            %Get default properties
            Attributes=[];
            Data=[];
            Children=[];
            
            %Add anything else we want to State here:
            
        end
        
        function delete(obj)
            obj.shutdown();
        end
        
        function shutdown(obj)
            [obj.LastError] = AT_Close(obj.CamHandle);
            AT_CheckWarning(obj.LastError);
            [obj.LastError] = AT_FinaliseLibrary();
            AT_CheckWarning(obj.LastError);
            disp('Zyla shutdown');
        end
        
    end
    
    methods(Access=protected)
        function obj=get_properties(obj)
            [obj.LastError, obj.Manufacturer] = AT_GetString(obj.CamHandle,'CameraFamily',256);
            AT_CheckError(obj.LastError);
            [obj.LastError, obj.Model] = AT_GetString(obj.CamHandle,'CameraModel',256);
            AT_CheckError(obj.LastError);
            [obj.LastError, obj.XPixels] = AT_GetInt(obj.CamHandle,'AOIWidth');
            AT_CheckError(obj.LastError);
            [obj.LastError, obj.YPixels] = AT_GetInt(obj.CamHandle,'AOIHeight');
            AT_CheckError(obj.LastError);
            [obj.LastError, obj.SequenceLength] = AT_GetInt(obj.CamHandle,'FrameCount');
            AT_CheckError(obj.LastError);
            [obj.LastError, obj.FrameRate] = AT_GetFloat(obj.CamHandle,'FrameRate');
            AT_CheckWarning(obj.LastError);
            obj.SequenceCycleTime=1/obj.FrameRate;
            [obj.LastError, obj.ExpTime] = AT_GetFloat(obj.CamHandle,'ExposureTime');
            AT_CheckWarning(obj.LastError);
        end
        
        function obj=gettemperature(obj)
            % Not sure if Zyla has a sensor cooling
        end
        
        function obj=get_capabilities(obj)
            % making the CameraSetting
            
        end
    end
    
    methods (Static)
        
        function Success=unitTest()
            Success=0;
            %Create object
            try
                A=MIC_AndorCameraZyla();
                A.ExpTime_Focus=.1;
                A.KeepData=1;
                A.setup_acquisition()
                A.start_focus()
                
                A.AcquisitionType='capture'
                A.ExpTime_Capture=.1;
                A.setup_acquisition()
                A.KeepData=1;
                A.start_capture()
                dipshow(A.Data)
                A.AcquisitionType='sequence'
                A.ExpTime_Sequence=.01;
                A.SequenceLength=100;
                A.setup_acquisition()
                
                A.start_sequence()
                A.exportState
                delete(A)
                Success=1;
            catch
                delete(A)
            end
            
        end
        
        
        function GuiCurSel = camSet2GuiSel(CameraSetting)
            % translate current camera settings to GUI selections
            cameraFields = fields(CameraSetting);
            for ii=1:length(cameraFields)
                if isfield(CameraSetting.(cameraFields{ii}),'Ind')
                    GuiCurSel.(cameraFields{ii}).Val = CameraSetting.(cameraFields{ii}).Ind;
                elseif isfield(CameraSetting.(cameraFields{ii}),'Value')
                    GuiCurSel.(cameraFields{ii}).Val = CameraSetting.(cameraFields{ii}).Value;
                end
            end
        end
        
    end
end
