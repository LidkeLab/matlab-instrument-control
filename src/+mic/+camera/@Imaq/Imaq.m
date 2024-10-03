classdef Imaq < mic.camera.abstract
% mic.camera.Imaq Class Documentation
% 
% ## Overview
% `mic.camera.Imaq` is a MATLAB class designed for camera control using the Image Acquisition Toolbox. It extends the `mic.camera.abstract` class and includes methods for initializing the camera, managing acquisitions, and retrieving images.
% 
% ## Methods
% - **Constructor**: Initializes the camera with optional parameters for adaptor name, format, and device ID.
% - `abort()`: Aborts the ongoing acquisition.
% - `shutdown()`: Stops the camera and cleans up the handle.
% - `initializeImaq(AdaptorName, Format, DevID)`: Initializes the camera with specific settings.
% - `setup_acquisition()`: Configures the camera for the current acquisition mode.
% - `setup_softwareTrigger(TriggerN)`: Prepares the camera for software triggered acquisition.
% - `start_softwareTrigger()`: Starts acquisition using software triggers.
% - `getlastimage()`: Retrieves the last captured image.
% - `getdata()`: Retrieves data based on the current acquisition type.
% - `start_focus()`: Starts acquisition in focus mode.
% - `start_capture()`: Starts acquisition in capture mode.
% - `start_sequence()`: Starts acquisition in sequence mode.
% - `setCamProperties(Infield)`: Applies camera settings from a structured input.
% - `build_guiDialog(GuiCurSel)`: Constructs the GUI dialog based on current settings.
% - `apply_camSetting()`: Applies GUI changes to the camera settings.
% - `getExpfield()`: Determines the appropriate exposure field from camera settings.
% - `valuecheck(prop, val)`: Checks and adjusts the value based on camera constraints.
% 
% ## Static Methods
% - `unitTest()`: Tests the functionality of the class.
% - `camSet2GuiSel(CameraSetting)`: Converts camera settings into GUI selections.
% 
% ## Usage
% To utilize `mic.camera.Imaq`, create an instance of the class specifying the adaptor name, format, and device ID as needed. Use the class methods to control the camera and manage image acquisition within MATLAB.
% 
% ### CITATION: Sheng Liu, Lidkelab, 2024.

    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq;        %If not, call setup_acquisition
        TextHandle;
        CameraHandle;
        CameraCap;
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
        InstrumentName = '';
        Expfield = '';
    end
    properties
        Binning;            %   [binX binY]
        Data;               %   last acquired data
        ExpTime_Focus;      %   focus mode exposure time
        ExpTime_Capture;    %   capture mode exposure time
        ExpTime_Sequence;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        SequenceLength;     %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
        GuiDialog;
    end

    properties (Hidden)
        StartGUI=false;     %Defines GUI start mode.  'true' starts GUI on object creation.
    end


    methods
        function obj=Imaq(AdaptorName,Format,DevID) 
            % Object constructor
            obj = obj@mic.camera.abstract(~nargout);
            if nargin>2
                obj.initializeImaq(AdaptorName,Format,DevID)
            elseif nargin>1
                obj.initializeImaq(AdaptorName,Format)
            else
                obj.initializeImaq(AdaptorName)
            end
        end
        
        function abort(obj)
            % Abort function
            %stop(obj.CameraHandle);
            obj.ReadyForAcq=0;
        end
        
        function shutdown(obj)
            % Object shutdown
            stop(obj.CameraHandle);
            delete(obj.CameraHandle);
            clear obj.CameraHandle;
        end
        
        function errorcheck(obj,funcname)
        end

        function initialize(obj)
        end
        function initializeImaq(obj, AdaptorName, Format,DevID)
            % Initialization
            if isempty(obj.CameraIndex)
                if nargin>3
                    obj.getcamera(AdaptorName,Format,DevID);
                elseif nargin>2
                    obj.getcamera(AdaptorName,Format)
                else
                    obj.getcamera(AdaptorName)
                end
            end
            disp(obj.CameraHandle)
            start(obj.CameraHandle)
            stop(obj.CameraHandle)
            triggerconfig(obj.CameraHandle,'manual')
            obj.InstrumentName = obj.CameraHandle.Name;
            camset = get(obj.CameraCap);
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
            obj.getExpfield();
            ExpTime = camset.(obj.Expfield);
            obj.ExpTime_Focus=ExpTime;
            obj.ExpTime_Capture=ExpTime;
            obj.ExpTime_Sequence=ExpTime;
            CCDsize=obj.CameraHandle.VideoResolution;
            obj.XPixels=CCDsize(1);
            obj.YPixels=CCDsize(2);
            obj.ImageSize=CCDsize;
            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            obj.setCamProperties(obj.CameraSetting);
            GuiCurSel = mic.camera.Imaq.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
            %obj.gui;
            
        end

        function setup_acquisition(obj)
            obj.abort;
            switch obj.AcquisitionType
                case 'focus'
                    %triggerconfig(obj.CameraHandle,'manual')
                    obj.CameraHandle.TriggerRepeat=Inf;
                    if obj.CameraHandle.FramesPerTrigger ~= 100
                        stop(obj.CameraHandle)
                        obj.CameraHandle.FramesPerTrigger=100;
                    end
                    obj.CameraHandle.FrameGrabInterval = 1;
                    %if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                    %    obj.CameraCap.Exposure=obj.ExpTime_Focus;
                    %end
                    obj.CameraCap.(obj.Expfield) = obj.valuecheck(obj.Expfield,obj.ExpTime_Focus);
                    obj.ExpTime_Focus=obj.CameraCap.(obj.Expfield);
                case 'capture'
                    %triggerconfig(obj.CameraHandle,'immediate')
                    obj.CameraHandle.TriggerRepeat=Inf;
                    if obj.CameraHandle.FramesPerTrigger ~= 1
                        stop(obj.CameraHandle)
                        obj.CameraHandle.FramesPerTrigger=1;
                    end
                    obj.CameraHandle.FrameGrabInterval = 1;
                    %if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                    %    obj.CameraCap.Exposure=obj.ExpTime_Capture;
                    %end
                    obj.CameraCap.(obj.Expfield) = obj.valuecheck(obj.Expfield,obj.ExpTime_Capture);
                    obj.ExpTime_Capture=obj.CameraCap.(obj.Expfield);
                case 'sequence'
                    
                    %triggerconfig(obj.CameraHandle,'manual')
                    %obj.CameraHandle.TriggerRepeat=Inf;
                    if obj.SequenceLength ~= obj.CameraHandle.FramesPerTrigger
                        stop(obj.CameraHandle)
                        obj.CameraHandle.FramesPerTrigger=obj.SequenceLength;
                    end
                    obj.CameraHandle.FrameGrabInterval = 1;
                    %if (strcmp(obj.CameraCap.ExposureAuto,'Off'))
                    %    obj.CameraCap.Exposure=obj.ExpTime_Sequence;
                    %end
                    obj.CameraCap.(obj.Expfield) = obj.valuecheck(obj.Expfield,obj.ExpTime_Sequence); 
                    obj.ExpTime_Sequence=obj.CameraCap.(obj.Expfield);
                    obj.SequenceCycleTime=obj.CameraCap.(obj.Expfield);
            end
            obj.ReadyForAcq=1;

        end

        function setup_softwareTrigger(obj,TriggerN)
            obj.abort;
            triggerconfig(obj.CameraHandle,'manual')
            obj.CameraHandle.TriggerRepeat = TriggerN;
            obj.CameraHandle.FramesPerTrigger=obj.SequenceLength;
            obj.CameraHandle.FrameGrabInterval = 1;
            obj.CameraCap.(obj.Expfield) = obj.valuecheck(obj.Expfield,obj.ExpTime_Sequence);
            obj.ExpTime_Sequence=obj.CameraCap.(obj.Expfield);
            obj.ReadyForAcq=1;
        end


        function out = start_softwareTrigger(obj)
            % Starts
            obj.AbortNow=0;
            flushdata(obj.CameraHandle);
            start(obj.CameraHandle);
            N = obj.CameraHandle.TriggerRepeat;
            for ii = 1:N
                
                trigger(obj.CameraHandle)
                while islogging(obj.CameraHandle)

                    if obj.AbortNow
                        obj.AbortNow=0;
                        break;
                    end
                    obj.displaylastimage;

                end
            end

            out=getdata(obj.CameraHandle,obj.CameraHandle.FramesAvailable);
            
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


        function out=getlastimage(obj)
            % Gets last captured image
           
            pause(obj.CameraCap.(obj.Expfield));
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
            if ~isrunning(obj.CameraHandle)
                start(obj.CameraHandle);
            end
            count = 0;
            while (count<obj.CameraHandle.TriggerRepeat)
                trigger(obj.CameraHandle)
                count=count+1;
                if (obj.CameraHandle.FramesAvailable > obj.CameraHandle.FramesPerTrigger)
                    flushdata(obj.CameraHandle)
                end

                while (islogging(obj.CameraHandle))

                    if obj.AbortNow
                        obj.AbortNow=0;
                        
                        count = obj.CameraHandle.TriggerRepeat;
                        break;
                    end
                    obj.displaylastimage;
                end
                
                
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

        function out=start_focus_v1(obj)
            % Starts focus funtion
            obj.AcquisitionType='focus';
            obj.setup_acquisition;
            obj.AbortNow=0;
            flushdata(obj.CameraHandle);
            start(obj.CameraHandle);
            while (islogging(obj.CameraHandle))
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
            obj.AbortNow=0;
            flushdata(obj.CameraHandle);
            if ~isrunning(obj.CameraHandle)
                start(obj.CameraHandle);
            end
            trigger(obj.CameraHandle)
            while (islogging(obj.CameraHandle))
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
            if ~isrunning(obj.CameraHandle)
                start(obj.CameraHandle);
            end
            trigger(obj.CameraHandle)
            while (islogging(obj.CameraHandle))
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

        function setCamProperties(obj,Infield)
            % Set up properties
            fieldp=fields(Infield);
            for ii=1:length(fieldp)
                pInfo=propinfo(obj.CameraCap,fieldp{ii});
                if strcmp(pInfo.ReadOnly,'never')
                    switch pInfo.Constraint
                        case 'enum'
                            obj.CameraCap.(fieldp{ii})=Infield.(fieldp{ii}).Bit;
                        case 'bounded'
                            obj.CameraCap.(fieldp{ii})=Infield.(fieldp{ii}).Value;
                    end
                end
            end
            %             if strcmp(obj.CameraCap.GainAuto,'On')
            %                 obj.GuiDialog.Gain.enable=0;
            %             end

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
                if strcmp(pInfo.ReadOnly,'never')
                    obj.GuiDialog.(fieldp{ii}).enable=1;
                else
                    obj.GuiDialog.(fieldp{ii}).enable=0;
                end
                obj.GuiDialog.(fieldp{ii}).curVal=GuiCurSel.(fieldp{ii}).Val;
            end
            
        end

        function apply_camSetting(obj)
            % Apply camera settings
            guiFields=fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                %disp(['Writing ',guiFields{ii},' in CameraSetting...']);
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

        function Expfield = getExpfield(obj)
            camset = obj.CameraSetting;
            if isfield(camset,'ExposureTime')
                Expfield = 'ExposureTime';
            end
            if isfield(camset,'Exposure')
                Expfield = 'Exposure';
            end
            obj.Expfield = Expfield;
        end

        function val = valuecheck(obj,prop,val)
            pInfo = propinfo(obj.CameraCap,prop);
            if val>pInfo.ConstraintValue(2)
                val = pInfo.ConstraintValue(2);
            end
            if val<pInfo.ConstraintValue(1)
                val = pInfo.ConstraintValue(1);
            end
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
        
        function Success=unitTest()
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
