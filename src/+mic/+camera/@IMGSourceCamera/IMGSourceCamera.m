classdef IMGSourceCamera <  mic.camera.abstract
    % mic.camera.IMGSourceCamera: Matlab instument class for ImagingSource camera.
    %
    % ## Description 
    % It requires dll to be registered in MATLAB.
    % TISImaq interfaces directly with the IMAQ Toolbox. This allows you to 
    % bring image data directly into MATLAB for analysis, visualization, 
    % and modelling.
    % The plugin allows the access to all camera Properties as they are 
    % known from IC Capture. The plugin works in all Matlab versions 
    % since 2013a. Last tested version is R2016b.
    % After installing the plugin it must be registered in Matlab manually.
    % How to do that is shown in a Readme, that can be displayed after 
    % installation. 
    % imaqregister('C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\x64\TISImaq_R2013.dll')
    % http://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/
    % This was done with imaqtool using Tools menu.
    %
    % ## Protected Properties
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
    % Indicates if the camera is ready for acquisition.
    % **Default:** `0` (call `setup_acquisition` if not ready).
    %
    % ### `TextHandle`
    % Handle for text display.
    %
    % ### `CameraHandle`
    % Handle for the camera object.
    %
    % ### `CameraCap`
    % Camera capabilities.
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Defines whether the GUI starts automatically on object creation.
    % **Default:** `false`.
    %
    % ## Protected Properties (with Set Access)
    %
    % ### `CameraIndex`
    % Index used when more than one camera is present.
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
    % ### `CameraSetting`
    % Specific settings for the camera.
    %
    % ### `XPixels`
    % Number of pixels in the first dimension.
    %
    % ### `YPixels`
    % Number of pixels in the second dimension.
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'IMGSourceCamera'`.
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
    %
    % ### `ExpTime_Capture`
    % Exposure time for capture mode.
    %
    % ### `ExpTime_Sequence`
    % Exposure time for sequence mode.
    %
    % ### `ROI`
    % Region of interest in the format `[Xstart Xend Ystart Yend]`.
    %
    % ### `SequenceLength`
    % Length of the kinetic series.
    % **Default:** `1`.
    %
    % ### `SequenceCycleTime`
    % Cycle time for the kinetic series (equivalent to `1/frame rate`).
    %
    % ### `ScanMode`
    % Scan mode for the Hamamatsu sCMOS camera.
    %
    % ### `TriggerMode`
    % Trigger mode for the Hamamatsu sCMOS camera.
    %
    % ### `DefectCorrection`
    % Defect correction setting for the Hamamatsu sCMOS camera.
    %
    % ### `GuiDialog`
    % GUI dialog object.
    %
    % ## Contructor
    % Example: obj=mic.camera.IMGSourceCamera();
    %
    % ## Methods
    %
    % ### `abort()`
    % Aborts the current acquisition process.
    % - Stops the camera handle.
    % - Sets `ReadyForAcq` to `0`.
    %
    % ### `shutdown()`
    % Shuts down the object and releases resources.
    % - Deletes and clears the `CameraHandle`.
    %
    % ### `errorcheck(funcname)`
    % Performs error checking for the specified function name.
    %
    % ### `initialize()`
    % Initializes the camera settings and properties.
    % - Retrieves the camera if `CameraIndex` is empty.
    % - Sets up camera settings, ROI, and GUI dialog.
    %
    % ### `setup_acquisition()`
    % Configures the acquisition parameters based on the acquisition type (`focus`, `capture`, or `sequence`).
    %
    % ### `getlastimage()`
    % Retrieves the last captured image from the camera handle.
    % - Adjusts the image based on the specified ROI.
    %
    % ### `getdata()`
    % Retrieves data based on the acquisition type (`focus`, `capture`, or `sequence`).
    % - Adjusts the output based on the specified ROI.
    %
    % ### `start_focus()`
    % Starts the focus mode acquisition.
    % - Configures acquisition settings.
    % - Handles data acquisition and displays the last image.
    %
    % ### `start_capture()`
    % Starts the image capture mode.
    % - Configures acquisition settings and captures a single image.
    %
    % ### `start_sequence()`
    % Starts sequence acquisition.
    % - Configures acquisition settings and captures a sequence of images.
    %
    % ### `getstatus()`
    % Retrieves the current status of the camera.
    % **Returns:**
    % - `status` (double): Indicates if the camera is running.
    %
    % ### `start_sequence_fast()`
    % Starts fast sequence capture.
    % - Configures acquisition settings and starts the sequence.
    %
    % ### `build_guiDialog(GuiCurSel)`
    % Builds the GUI dialog for camera settings based on the provided `GuiCurSel`.
    %
    % ### `apply_camSetting()`
    % Applies the camera settings from the GUI dialog.
    %
    % ### `exportState()`
    % Exports the current state of the camera.
    %
    % ### `setCamProperties(Infield)`
    % Sets up camera properties based on input fields.
    %
    % ### `set.ROI(in)`
    % Sets up the ROI (Region of Interest).
    %
    % ### `set.ExpTime_Focus(in)`
    % Sets the exposure time for focus mode.
    %
    % ### `set.ExpTime_Capture(in)`
    % Sets the exposure time for image capture.
    %
    % ### `set.ExpTime_Sequence(in)`
    % Sets the exposure time for sequence capture.
    %
    % ### `set.SequenceLength(in)`
    % Sets the length of the sequence.
    %
    % ## Protected Methods
    %
    % ### `get_properties()`
    % Retrieves properties of the object.
    %
    % ### `gettemperature()`
    % Retrieves the temperature and status of the camera.
    % **Returns:**
    % - `temp` (double): Temperature value.
    % - `status` (double): Status code.
    %
    % ## Static Methods
    %
    % ### `funcTest()`
    % Tests the functionality of the class/instrument.
    % - Creates an instance of `IMGSourceCamera`.
    % - Configures and performs various acquisitions.
    % - Deletes the instance and returns a success flag.
    %
    % ### `camSet2GuiSel(CameraSetting)`
    % Converts camera settings to GUI selection values.
    %
    % ## REQUIREMENTS:
    %   mic.Abstract.m
    %   mic.camera.abstract.m
    %   MATLAB software version R2013a or later
    %
    % ### CITATION: , Lidkelab, 2017.
    
    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;        %If not, call setup_acquisition
        TextHandle;
        CameraHandle;
        CameraCap;
    end
    
    properties (Hidden)
        StartGUI=false;     %Defines GUI start mode.  'true' starts GUI on object creation.
    end
    
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        CameraSetting;
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        InstrumentName='IMGSourceCamera'
    end
    
    properties
        Binning;            %   [binX binY]        
        Data;               %   last acquired data
        ExpTime_Focus;      %   focus mode exposure time
        ExpTime_Capture;    %   capture mode exposure time
        ExpTime_Sequence;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        SequenceLength=1;   %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
        ScanMode;           %   scan mode for Hamamatsu sCMOS camera
        TriggerMode;        %   trigger mode for Hamamatsu sCMOS camera
        DefectCorrection;   %   defect correction  for Hamamatsu sCMOS camera
        GuiDialog;
    end
    
    methods
        
        function obj=IMGSourceCamera() 
            % Object constructor
            obj = obj@mic.camera.abstract(~nargout);
        end
        
        function abort(obj)
            % Abort function
            stop(obj.CameraHandle);
            obj.ReadyForAcq=0;
        end
        
        function shutdown(obj)
            % Object shutdown
            delete(obj.CameraHandle);
            clear obj.CameraHandle;
        end
        
        function errorcheck(obj,funcname)
        end
        
        function initialize(obj)
            % Initialization
            if isempty(obj.CameraIndex)
                obj.getcamera;
            end
            
            camset=struct('Brightness',[],'ExposureAuto',[],'ExposureAutoMaxValue',[],...
                'ExposureAutoReference',[],'FrameRate',[],'Gain',[],'GainAuto',[],...
                'Gamma',[],'Trigger',[],'TriggerPolarity',[],'TriggerSoftwareTrigger',[]);
            fieldp=fields(camset);
            for ii=1:length(fieldp)
                pInfo=propinfo(obj.CameraCap,fieldp{ii});
                switch pInfo.Constraint
                    case 'enum'
                        obj.CameraSetting.(fieldp{ii}).Bit=obj.CameraCap.(fieldp{ii});
                        obj.CameraSetting.(fieldp{ii}).Ind=find(strcmp(pInfo.ConstraintValue,obj.CameraCap.(fieldp{ii})));
                    case 'bounded'
                        obj.CameraSetting.(fieldp{ii}).Value=obj.CameraCap.(fieldp{ii});
                end
            end
            obj.ReturnType='matlab';
            obj.ExpTime_Focus=obj.CameraCap.Exposure;
            obj.ExpTime_Capture=obj.CameraCap.Exposure;
            obj.ExpTime_Sequence=obj.CameraCap.Exposure;
            CCDsize=obj.CameraHandle.VideoResolution;
            obj.XPixels=CCDsize(1);
            obj.YPixels=CCDsize(2);
            obj.ImageSize=CCDsize;
            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            obj.setCamProperties(obj.CameraSetting);
            GuiCurSel = mic.camera.IMGSourceCamera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
            %obj.gui;
            
        end
        
        function setup_acquisition(obj)
            % Setup acquisition
            obj.abort;
            switch obj.AcquisitionType
                case 'focus'
                    obj.CameraHandle.TriggerRepeat=Inf;
                    obj.CameraHandle.FramesPerTrigger=100;
                    obj.CameraHandle.FrameGrabInterval = 1;
                    if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                        obj.CameraCap.Exposure=obj.ExpTime_Focus;
                    end
                    obj.ExpTime_Focus=obj.CameraCap.Exposure;
                case 'capture'
                    obj.CameraHandle.TriggerRepeat=0;
                    obj.CameraHandle.FramesPerTrigger=1;
                    obj.CameraHandle.FrameGrabInterval = 1;
                    if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                        obj.CameraCap.Exposure=obj.ExpTime_Capture;
                    end
                    obj.ExpTime_Capture=obj.CameraCap.Exposure;
                case 'sequence'
                    obj.CameraHandle.TriggerRepeat=0;
                    obj.CameraHandle.FramesPerTrigger=obj.SequenceLength;
                    obj.CameraHandle.FrameGrabInterval = 1;
                    if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                        obj.CameraCap.Exposure=obj.ExpTime_Sequence;
                    end
                    obj.ExpTime_Sequence=obj.CameraCap.Exposure;
                    obj.SequenceCycleTime=obj.CameraCap.Exposure;
            end
            obj.ReadyForAcq=1;
        end
        
        function out=getlastimage(obj)
            % Gets last captured image
            pause(obj.CameraCap.Exposure);
            Img=getsnapshot(obj.CameraHandle);
            roi=obj.ROI;
            out=Img(roi(3):roi(4),roi(1):roi(2));
            out=permute(out,[2,1]);
        end
        
        function out=getdata(obj)
            % Gets data
            roi=obj.ROI;
            switch obj.AcquisitionType
                case 'focus'
                    Img=squeeze(getdata(obj.CameraHandle,1));
                case 'capture'
                    Img=squeeze(getdata(obj.CameraHandle,1));
                case 'sequence'
                    Img=squeeze(getdata(obj.CameraHandle,obj.SequenceLength));
            end
            out=Img(roi(3):roi(4),roi(1):roi(2),:);
            out=permute(out,[2,1,3]);
        end
        
        function out=start_focus(obj)
            % Starts focus funtion
            obj.AcquisitionType='focus';
            obj.setup_acquisition;
            obj.AbortNow=0;
            flushdata(obj.CameraHandle);
            start(obj.CameraHandle);
            while (isrunning(obj.CameraHandle))
                if (obj.CameraHandle.FramesAvailable > obj.CameraHandle.FramesPerTrigger)
                    flushdata(obj.CameraHandle)
                end
                
                if obj.AbortNow
                    obj.AbortNow=0;
                    break;
                end
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
            % Starts image capture
            obj.AcquisitionType='capture';
            obj.setup_acquisition;
            flushdata(obj.CameraHandle);
            start(obj.CameraHandle);
            while (isrunning(obj.CameraHandle))
                if (obj.CameraHandle.FramesAvailable > 0)
                    break;
                end
            end
            out=obj.getdata;
            %dipshow(out);
            obj.abort;
            obj.AbortNow=0;
            
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
        
        function out=start_sequence(obj)
            % Starts sequence
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            flushdata(obj.CameraHandle);
            obj.AbortNow=0;
            start(obj.CameraHandle);
            while (isrunning(obj.CameraHandle))
                if obj.AbortNow
                    obj.AbortNow=0;
                    break;
                end
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
        function status=getstatus(obj)
            % Gets current status
            status=double(isrunning(obj.CameraHandle));
        end
        
        function start_sequence_fast(obj)
            % Starts fast sequence capture
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            flushdata(obj.CameraHandle);
            obj.AbortNow=0;
            start(obj.CameraHandle);
        end
        
        function build_guiDialog(obj,GuiCurSel)
            % gui building
            fieldp=fields(obj.CameraSetting);
            for ii=1:length(fieldp)
                pInfo=propinfo(obj.CameraCap,fieldp{ii});
                switch pInfo.Constraint
                    case 'enum'
                        obj.GuiDialog.(fieldp{ii}).Desc=pInfo.ConstraintValue;
                        obj.GuiDialog.(fieldp{ii}).uiType='select';
                    case 'bounded'
                        obj.GuiDialog.(fieldp{ii}).Range=pInfo.ConstraintValue;
                        obj.GuiDialog.(fieldp{ii}).Desc=num2str(pInfo.ConstraintValue);
                        obj.GuiDialog.(fieldp{ii}).enable=1;
                        obj.GuiDialog.(fieldp{ii}).uiType='input';
                end
                obj.GuiDialog.(fieldp{ii}).curVal=GuiCurSel.(fieldp{ii}).Val;
            end
            
        end
        
        function apply_camSetting(obj)
            % Apply camera settings
            guiFields=fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                disp(['Writing ',guiFields{ii},' in CameraSetting...']);
                pInfo=propinfo(obj.CameraCap,guiFields{ii});
                switch pInfo.Constraint
                    case 'enum'
                        ind=obj.GuiDialog.(guiFields{ii}).curVal;
                        obj.CameraSetting.(guiFields{ii}).Ind = ind;
                        obj.CameraSetting.(guiFields{ii}).Bit=obj.GuiDialog.(guiFields{ii}).Desc{ind};
                    case 'bounded'
                        val=obj.GuiDialog.(guiFields{ii}).curVal;
                        obj.CameraSetting.(guiFields{ii}).Value=val;
                end
            end
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Exports current state of camera
            Attributes=obj.exportParameters();
            Data=[];
            Children=[];
        end
        
        function setCamProperties(obj,Infield)
            % Set up properties
            fieldp=fields(Infield);
            for ii=1:length(fieldp)
                pInfo=propinfo(obj.CameraCap,fieldp{ii});
                switch pInfo.Constraint
                    case 'enum'
                        obj.CameraCap.(fieldp{ii})=Infield.(fieldp{ii}).Bit;
                    case 'bounded'
                        obj.CameraCap.(fieldp{ii})=Infield.(fieldp{ii}).Value;
                end
            end
            if strcmp(obj.CameraCap.GainAuto,'On')
                obj.GuiDialog.Gain.enable=0;
            end
            
        end
        
        function set.ROI(obj,in)
            % Sets up ROI
            obj.ROI=in;
            obj.ImageSize=[in(2)-in(1)+1,in(4)-in(3)+1];
        end
        
        function set.ExpTime_Focus(obj,in)
            % Sets exposure time for focus function
                obj.ReadyForAcq=0;
                obj.ExpTime_Focus=in;
        end

        function set.ExpTime_Capture(obj,in)
            % Sets exposure time for image capture
                obj.ReadyForAcq=0;
                obj.ExpTime_Capture=in;
        end
        
        function set.ExpTime_Sequence(obj,in)
            % Sets exposure time for sequence capture
                obj.ReadyForAcq=0;
                obj.ExpTime_Sequence=in;
        end
        
        function set.SequenceLength(obj,in)
            % Sets sequence length
                obj.ReadyForAcq=0;
                obj.SequenceLength=in;
        end
        
    end
    
    methods(Access=protected)
        function obj=get_properties(obj)
        end
        function [temp, status]=gettemperature(obj)
            status=0;
            temp=0;
        end
    end
   
    methods (Static)
        
                function Success=funcTest()
                    % Test fucntionality of class/instrument
            Success=0;
            %Create object
            try 
                A=mic.camera.IMGSourceCamera();
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
