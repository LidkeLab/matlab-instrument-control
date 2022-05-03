classdef MIC_DCAM4Camera < MIC_Camera_Abstract
    %MIC_DCAM4Camera contains methods to control Hamamatsu cameras.
    % This class is a modified version of MIC_HamamatsuCamera that uses the
    % DCAM4 API.
    
    properties(Access = protected)
        AbortNow;
        ErrorCode;
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;      %If not, call setup_acquisition
        TextHandle;
        SDKPath = 'C:\Users\lidkelab\Documents\GitHub\matlab-instrument-control\source\MIC\DCAM4\x64\Release';
    end
    
    properties(SetAccess = protected)
        CameraHandle;
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        CameraCap;          %capability (all options) of camera parameters
        CameraSetting;
        Capabilities;       %capabilities structure from camera
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        InstrumentName='HamamatsuCamera'
    end
    
    properties (Hidden)
        StartGUI=false;     %Defines GUI start mode.  'true' starts GUI on object creation.
    end
    
    properties
        Binning;            %   binning mode: see DCAM_IDPROP_BINNING
        Data=[];               %   last acquired data
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
        Timeout = 1000;        % timeout sent to several DCAM functions (milliseconds)
        EventMaskString = 'DCAMWAIT_CAPEVENT_CYCLEEND'; % wait event mask used in DCAM functions (see dcamprop.h DCAMWAIT_EVENT)
        APIPath = 'C:\Program Files\dcamsdk4\inc\dcamapi4.h';
    end
    
    properties (Hidden)
        EventMask = 4;
    end
    
    methods
        
        function obj=MIC_DCAM4Camera() %constructor
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function errorcheck(obj)
        end
        
        getcamera(obj);
        
        function delete(obj)
            obj.shutdown()
        end
        
        function abort(obj)
            % Abort the current capture by attempting to stop the capture
            % and then freeing the camera memory buffer.
            DCAM4StopCapture(obj.CameraHandle)
            DCAM4ReleaseMemory(obj.CameraHandle)
        end
        
        function Image = getlastimage(obj)
            % Return the last image taken by the camera.
            Image = DCAM4CopyLastFrame(obj.CameraHandle, obj.Timeout);
            Image = reshape(Image, obj.ImageSize(1), obj.ImageSize(2));
        end
        
        function Data = getdata(obj)
            % Grab data from the camera.
            switch obj.AcquisitionType
                case 'focus'
                    Data = obj.getlastimage();
                case 'capture'
                    Data = obj.getlastimage();
                case 'sequence'
                    Data = DCAM4CopyFrames(obj.CameraHandle, ...
                        obj.SequenceLength, obj.Timeout, ...
                        obj.EventMask);
                    Data = reshape(Data, ...
                        obj.ImageSize(1), obj.ImageSize(2), ...
                        obj.SequenceLength);
            end
        end
        
        function initialize(obj)
            addpath(obj.SDKPath)
            if isempty(obj.CameraIndex)
                fprintf('Getting Hamamatsu Camera Info.\n')
                obj.getcamera()
            end
            obj.Binning=1;
            obj.ScanMode=1; %scan mode is slow
            obj.DefectCorrection=1;% defection correction is off
            obj.XPixels=2048;
            obj.YPixels=2048;
            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            obj.TriggerMode=int32(hex2dec('0001'));
            obj.ExpTime_Focus=single(0.004);
            obj.ExpTime_Capture=single(0.004);
            obj.ExpTime_Sequence=single(0.004);
            
            obj.CameraSetting.Binning.Bit=obj.Binning;
            obj.CameraSetting.TriggerMode.Bit=obj.TriggerMode;
            obj.CameraSetting.ScanMode.Bit=obj.ScanMode;
            obj.CameraSetting.DefectCorrection.Bit=obj.DefectCorrection;
            
            obj.CameraSetting.Binning.Ind=1;
            obj.CameraSetting.TriggerMode.Ind=1;
            obj.CameraSetting.ScanMode.Ind=1;
            obj.CameraSetting.DefectCorrection.Ind=1;
            
            obj.setCamProperties(obj.CameraSetting);
            GuiCurSel = MIC_HamamatsuCamera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
        end
        
        function setup_acquisition(obj)
            status=obj.HtsuGetStatus();
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort();
            end
            switch obj.AcquisitionType
                % Exposure time:
                %   DCAM_IDPROP_EXPOSURETIME <-> 0x001F0110 <-> 2031888
                case 'focus'        %Run-Till-Abort
                    TotalFrame=100;
                    obj.ExpTime_Focus = obj.setGetProperty(...
                        obj.CameraHandle, 2031888, obj.ExpTime_Focus);
                    obj.prepareForCapture(obj.CameraHandle,TotalFrame);
                case 'capture'      %Single Scan
                    TotalFrame=1;
                    obj.ExpTime_Capture = obj.setGetProperty(...
                        obj.CameraHandle, 2031888, obj.ExpTime_Capture);
                    obj.prepareForCapture(obj.CameraHandle,TotalFrame);
                case 'sequence'     %Kinetic Series
                    obj.ExpTime_Sequence = obj.setGetProperty(...
                        obj.CameraHandle, 2031888, obj.ExpTime_Sequence);
                    obj.prepareForCapture(obj.CameraHandle,obj.SequenceLength);
            end
            
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')
                obj.ReadyForAcq=1;
            else
                error('Hamamatsu Camera not ready. Try Resetting')
            end
        end
        
        function setup_fast_acquisition(obj)
            obj.AcquisitionType='sequence';
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
            end
            obj.setup_acquisition()
            
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')
                obj.ReadyForAcq=1;
            end
            
            % set Trigger mode to Software so we can use firetrigger
            TriggerModeIdx = 3; % Software mode
            obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TriggerMode.Bit;
            % apply trigger mode
            % DCAM_IDPROP_TRIGGERSOURCE <-> 0x00100110 <-> 1048848
            obj.setProperty(obj.CameraHandle, 1048848, obj.TriggerMode);
            
            % start capture so triggering can start
            captureMode=-1; % sequence
            DCAM4StartCapture(obj.CameraHandle, captureMode);
            pause(1) % pause briefly before proceeding
        end
        
        function shutdown(obj)
            DCAM4Close(obj.CameraHandle);
        end
        
        function out=start_capture(obj)
            %obj.AcquisitionType='capture';
            obj.abort;
            obj.AcquisitionType='capture';
            %             status=obj.HtsuGetStatus;
            %             if strcmp(status,'Ready')||strcmp(status,'Busy')
            %                 obj.abort;
            %             end
            
            % Call the setup_acquisition method, but do so 'quietly' i.e.
            % prevent the method from displaying anything in the Command
            % Window.
            evalc('obj.setup_acquisition()');
            
            obj.AbortNow=1;
            DCAM4StartCapture(obj.CameraHandle, 0);
            pause(1) % pause briefly before proceeding
            out=obj.getdata();
            %             obj.displaylastimage();
            obj.abort();
            obj.AbortNow=0;
            
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
            end
        end
        
        
        function out=start_focus(obj)
            obj.abort;
            obj.AcquisitionType='focus';
            
            obj.setup_acquisition();
            
            [Status]=obj.HtsuGetStatus();
            switch Status
                case 'Ready'
                otherwise
                    error('Hamamatsu not ready')
            end
            
            obj.AbortNow=0;
            DCAM4StartCapture(obj.CameraHandle, -1);
            pause(1) % pause briefly before proceeding
            
            Camstatus=obj.HtsuGetStatus;
            while strcmp(Camstatus,'Busy')
                if obj.AbortNow
                    obj.AbortNow=0;
                    out=[];
                    break;
                else
                    out=obj.getdata;
                end
                obj.displaylastimage;
                Camstatus=obj.HtsuGetStatus;
            end
            
            if obj.AbortNow
                obj.abort;
                obj.AbortNow=0;
                return;
            end
            
            out=obj.getdata;
            
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
                    %already in uint16
            end
        end
        
        function out=start_focusWithFeedback(obj)
            obj.abort;
            obj.AcquisitionType='focus';
            IfigHandle = figure('Position',[497 190 305 172],'MenuBar','none');
            ItextHandle = uicontrol(IfigHandle,'Style','text',...
                'String','0','Position',[0 0 290 140],'FontSize',60,...
                'HorizontalAlignment','right');
            obj.setup_acquisition;
            
            [Status]=obj.HtsuGetStatus();
            switch Status
                case 'Ready'
                otherwise
                    error('Hamamatsu not ready')
            end
            
            obj.AbortNow=0;
            DCAM4StartCapture(obj.CameraHandle, -1);
            pause(1) % pause briefly before proceeding
            
            Camstatus=obj.HtsuGetStatus;
            while strcmp(Camstatus,'Busy')
                if obj.AbortNow
                    obj.AbortNow=0;
                    out=[];
                    break;
                else
                    out=obj.getdata;
                end
                Isort = sort(out(:));
                Imax = sum(Isort(end-4:end));
                ItextHandle.String = num2str(Imax);
                obj.displaylastimage;
                Camstatus=obj.HtsuGetStatus;
            end
            
            if obj.AbortNow
                obj.abort;
                obj.AbortNow=0;
                close(IfigHandle);
                return;
            end
            
            out=obj.getdata;
            
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
                    %already in uint16
            end
        end
        
        function out=start_sequence(obj, CaptureMode)
            if (~exist('CaptureMode', 'var') || isempty(CaptureMode))
                % Capture mode can be either 0 ("snap", images are taken
                % until buffer is filled) or -1 ("sequence", images are
                % taken until capturing is force stopped, e.g., focus mode
                % or triggered capture).
                CaptureMode = 0;
            end
            %obj.AcquisitionType='sequence';
            obj.abort;
            obj.AcquisitionType='sequence';
            %             status=obj.HtsuGetStatus;
            %             if strcmp(status,'Ready')||strcmp(status,'Busy')
            %                 obj.abort;
            %             end
            obj.setup_acquisition;
            
            obj.AbortNow=0;
            DCAM4StartCapture(obj.CameraHandle, CaptureMode); % what we call sequence needs snap mode
            pause(1) % pause briefly before proceeding
            
            Camstatus=obj.HtsuGetStatus;
            while strcmp(Camstatus,'Busy')
                if obj.AbortNow
                    obj.AbortNow=0;
                    out=[];
                    break;
                end
                obj.displaylastimage;
                Camstatus=obj.HtsuGetStatus;
            end
            
            if obj.AbortNow
                obj.abort;
                obj.AbortNow=0;
                out=[];
                return;
            end
            
            out=obj.getdata;
            
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
                    %already in uint16
            end
        end
        
        function triggeredCapture(obj)
            obj.fireTrigger()
            obj.displaylastimage();
        end
        
        function fireTrigger(obj)
            DCAM4FireTrigger(obj.CameraHandle, obj.Timeout)
        end
        
        function out=finishTriggeredCapture(obj,numFrames)
%             obj.abort();
            imgall = DCAM4CopyFrames(obj.CameraHandle, numFrames, ...
                obj.ExpTime_Sequence*numFrames, obj.EventMask);
            out=reshape(imgall,obj.ImageSize(1),obj.ImageSize(2),numFrames);
            
            % set Trigger mode back to Internal so data can be captured
            TriggerModeIdx = 1; % Internal mode
            obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TriggerMode.Bit;
            % apply trigger mode
            obj.setProperty(obj.CameraHandle, 1048848, obj.TriggerMode);
        end
        
        function out=take_sequence(obj)
            %obj.AcquisitionType='sequence';
            %obj.abort;
            obj.AcquisitionType='sequence';
            %             status=obj.HtsuGetStatus;
            %             if strcmp(status,'Ready')||strcmp(status,'Busy')
            %                 obj.abort;
            %             end
            
            obj.AbortNow=0;
            DCAM4StartCapture(obj.CameraHandle, 0); % what we call sequence needs snap mode
            pause(1) % pause briefly before proceeding
            
            Camstatus=obj.HtsuGetStatus;
            while strcmp(Camstatus,'Busy')
                if obj.AbortNow
                    obj.AbortNow=0;
                    out=[];
                    break;
                end
                obj.displaylastimage;
                Camstatus=obj.HtsuGetStatus;
            end
            
            if obj.AbortNow
                obj.abort;
                obj.AbortNow=0;
                out=[];
                return;
            end
            
            out=obj.getdata;
            %              out=zeros(obj.ImageSize(1),obj.ImageSize(2),obj.SequenceLength);
            
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
                    %already in uint16
            end
        end
        
        function reset(obj)
            DCAM4Close(obj.CameraHandle)
            obj.CameraHandle=DCAM4Open(obj.CameraIndex);
            obj.setCamProperties(obj.CameraSetting);
        end
        
        function status=HtsuGetStatus(obj)
            StatusInt = DCAM4Status(obj.CameraHandle);
            switch (StatusInt)
                case 0
                    status='Error';
                case 1
                    status='Busy';
                case 2
                    status='Ready';
                case 3
                    status='Stable';
                case 4
                    status='Unstable';
            end
        end
        function [temp, status] = call_temperature(obj)
            [temp, status]=gettemperature(obj);
        end
        function build_guiDialog(obj,GuiCurSel)
            % build GuiDialog based on current selected camera parameters
            % handles dependencies in user settables
            % also defines what is user configurable
            % GuiCurSel: current selection of Gui parameters
            
            % GuiDialog.Binning: fixed options
            % GuiDialog.TriggerMode: fixed options
            % GuiDialog.ScanMode: fixed options
            
            obj.GuiDialog.Binning.Desc={'1 x 1 binning','2 x 2 binning', '4 x 4 binning'};
            obj.GuiDialog.Binning.Bit=[1,2,4];
            obj.GuiDialog.TriggerMode.Desc=...
                {'Internal','External','Software','MasterPulse'};
            obj.GuiDialog.TriggerMode.Bit=int32([1, 2, 3, 4]);
            obj.GuiDialog.ScanMode.Desc={'Slow','Fast'};
            obj.GuiDialog.ScanMode.Bit=[1,2];
            obj.GuiDialog.DefectCorrection.Desc={'OFF','ON'};
            obj.GuiDialog.DefectCorrection.Bit=[1,2];
            % now have defined what does to GUI, transfer uiType, current
            % selection
            guiFields = fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                obj.GuiDialog.(guiFields{ii}).uiType = 'select';
                obj.GuiDialog.(guiFields{ii}).curVal = GuiCurSel.(guiFields{ii}).Val;
            end
        end
        
        function apply_camSetting(obj)
            % update CameraSetting struct from GUI
            guiFields = fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                disp(['Writing ',guiFields{ii},' in CameraSetting...']);
                ind=obj.GuiDialog.(guiFields{ii}).curVal;
                obj.CameraSetting.(guiFields{ii}).Ind=ind;
                obj.CameraSetting.(guiFields{ii}).Bit=obj.GuiDialog.(guiFields{ii}).Bit(ind);
            end
        end
        
        function setCamProperties(obj,Infield)
            Fields = fields(Infield);
            for ii=1:length(Fields)
                obj.(Fields{ii})=Infield.(Fields{ii}).Bit;
            end
            
            % Set binning.
            % DCAM_IDPROP_BINNING <-> 0x00401110 <-> 4198672
            obj.setProperty(obj.CameraHandle, 4198672, obj.Binning);
            
            % Set the scan mode.
            % DCAM_IDPROP_READOUTSPEED <-> 0x00400110 <-> 4194576
            % DCAMPROP_READOUTSPEED__SLOWEST <-> 1
            % DCAMPROP_READOUTSPEED__FASTEST <-> 2 (dcamprop.h seems wrong!)
            obj.setProperty(obj.CameraHandle, 4194576, obj.ScanMode);
            
            % Set the trigger mode.
            % DCAM_IDPROP_TRIGGERSOURCE <-> 0x00100110 <-> 1048848
            obj.setProperty(obj.CameraHandle, 1048848, obj.TriggerMode);
            
            % Set defect correction.
            % DCAM_IDPROP_DEFECTCORRECT_MODE <-> 0x00470010 <-> 4653072
            obj.setProperty(obj.CameraHandle, 4653072, obj.DefectCorrection);
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            %Get default properties
            Attributes=obj.exportParameters();
            Data=[];
            Children=[];
            %Add anything else we want to State here:.
        end
        
        %---SET
        %METHODS-----------------------------------------------------------------
        function set.ROI(obj,ROI)
            obj.ReadyForAcq=0;
            status=obj.HtsuGetStatus();
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
            end
            Step=4/obj.Binning;
            Hoffset=round((ROI(1)-1)/Step)*Step;
            HWidth=round((ROI(2)-ROI(1)+1)/Step)*Step;
            HWidth(HWidth<Step)=Step;
            HWidth(HWidth>(obj.XPixels/obj.Binning-Hoffset))=obj.XPixels/obj.Binning-Hoffset;
            
            Voffset=round((ROI(3)-1)/Step)*Step;
            VWidth=round((ROI(4)-ROI(3)+1)/Step)*Step;
            VWidth(VWidth<Step)=Step;
            VWidth(VWidth>(obj.YPixels/obj.Binning-Voffset))=obj.YPixels/obj.Binning-Voffset;
            fprintf('\nROI(1) and ROI(3) should be from %d to %d in step of %d',1,obj.XPixels/obj.Binning-Step+1,Step);
            fprintf('\nROI(2) and ROI(4) should be from %d to %d in step of %d\n',Step,obj.XPixels/obj.Binning,Step);
            
            obj.ROI=[Hoffset+1,Hoffset+HWidth,Voffset+1,Voffset+VWidth];
            obj.ImageSize=[HWidth,VWidth];
            
            % Set the appropriate ROI properties:
            % DCAM_IDPROP_SUBARRAYMODE <-> 0x00402150 <-> 4202832
            % DCAMPROP_MODE__ON <-> 2
            % DCAM_IDPROP_SUBARRAYHPOS <-> 0x00402110 <-> 4202768
            % DCAM_IDPROP_SUBARRAYHSIZE <-> 0x00402120 <-> 4202784
            % DCAM_IDPROP_SUBARRAYVPOS <-> 0x00402130 <-> 4202800
            % DCAM_IDPROP_SUBARRAYVSIZE <-> 0x00402140 <-> 4202816
            % NOTE: Depending on the values being set, errors can occur due
            %       to inconsistencies between offset and width, hence I'm
            %       setting the offset to 0 temporarily before setting the
            %       desired value.
            obj.setProperty(obj.CameraHandle, 4202832, 2)
            obj.setProperty(obj.CameraHandle, 4202768, 0);
            obj.setProperty(obj.CameraHandle, 4202800, 0);
            obj.setProperty(obj.CameraHandle, 4202784, HWidth);
            obj.setProperty(obj.CameraHandle, 4202768, Hoffset);
            obj.setProperty(obj.CameraHandle, 4202816, VWidth);
            obj.setProperty(obj.CameraHandle, 4202800, Voffset);
        end
        function set.ExpTime_Focus(obj,in)
            obj.ReadyForAcq=0;
            obj.ExpTime_Focus=in;
        end
        
        function set.ExpTime_Capture(obj,in)
            obj.ReadyForAcq=0;
            obj.ExpTime_Capture=in;
        end
        
        function set.ExpTime_Sequence(obj,in)
            obj.ReadyForAcq=0;
            obj.ExpTime_Sequence=in;
        end
        
        function set.Binning(obj,in)
            obj.ReadyForAcq=0;
            obj.Binning=in;
        end
        
        function set.SequenceLength(obj,in)
            obj.ReadyForAcq=0;
            obj.SequenceLength=in;
        end
        
        function set.EventMaskString(obj, SetValue)
            % Convert the input EventMaskString to a decimal EventMask
            % (this can be slow, so it's best to do it as soon as the user
            % sets this property).
            obj.EventMaskString = SetValue;
            obj.EventMask = hex2dec(obj.propertyToHex(SetValue, obj.APIPath));
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
            Success=0;
            %Create object
            try
                A=MIC_HamamatsuCamera();
                A.ExpTime_Focus=.1;
                A.KeepData=1;
                A.setup_acquisition()
                A.start_focus()
                A.AcquisitionType='capture';
                A.ExpTime_Capture=.1;
                A.setup_acquisition()
                A.KeepData=1;
                A.start_capture()
                dipshow(A.Data)
                A.AcquisitionType='sequence';
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
        
        [HexString] = propertyToHex(PropertyString, APIFilePath);
        [PropertyString] = hexToProperty(HexString, Prefix, APIFilePath);
        setProperty(CameraHandle, Property, Value, APIFilePath);
        [Value] = getProperty(CameraHandle, Property, APIFilePath);
        [Value] = setGetProperty(CameraHandle, Property, Value, APIFilePath);
        prepareForCapture(CameraHandle, CaptureMode, NImages);
    end
end