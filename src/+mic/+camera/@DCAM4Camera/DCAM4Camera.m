classdef DCAM4Camera < mic.camera.abstract
    %mic.camera.DCAM4Camera contains methods to control Hamamatsu cameras.
    % This class is a modified version of mic.camera.HamamatsuCamera that uses the
    % DCAM4 API.
    
    %## Protected Properties
    %
    % ### `AbortNow`
    % Flag for stopping the acquisition process.
    %
    % ### `ErrorCode`
    % Stores the error code.
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
    % Indicates if the camera is ready for acquisition. If not, `setup_acquisition` should be called.
    % **Default:** `0`.
    %
    % ### `TextHandle`
    % Handle for text display.
    %
    % ## Protected Properties (Set Access)
    %
    % ### `CameraHandle`
    % Handle for the camera object.
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
    % ### `CameraCap`
    % Capability (all options) of camera parameters.
    %
    % ### `CameraSetting`
    % Camera-specific settings.
    %
    % ### `Capabilities`
    % Capabilities structure from the camera.
    %
    % ### `XPixels`
    % Number of pixels in the first dimension.
    %
    % ### `YPixels`
    % Number of pixels in the second dimension.
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'HamamatsuCamera'`.
    %
    % ### `TriggerPause`
    % Pause duration (in seconds) after firing a trigger in `fireTrigger()`.
    %
    % ### `IsRunning`
    % Indicates if the camera is currently running.
    % **Default:** `0`.
    %
    % ### `CameraFrameIndex`
    % Index for the camera frames.
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Defines whether the GUI starts automatically on object creation.
    % **Default:** `false`.
    %
    % ## Public Properties
    %
    % ### `Binning`
    % Binning mode, see `DCAM_IDPROP_BINNING`.
    %
    % ### `Data`
    % Last acquired data.
    % **Default:** `[]`.
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
    % Region of interest specified as `[Xstart Xend Ystart Yend]`.
    %
    % ### `SequenceLength`
    % Length of the kinetic series.
    % **Default:** `1`.
    %
    % ### `SequenceCycleTime`
    % Cycle time for the kinetic series (in seconds).
    %
    % ### `FrameRate`
    % Frame rate of the camera.
    %
    % ### `TriggerMode`
    % Trigger mode for the Hamamatsu sCMOS camera.
    %
    % ### `GuiDialog`
    % GUI dialog object.
    %
    % ### `Timeout`
    % Timeout duration for several DCAM functions (in milliseconds).
    % **Default:** `10000`.
    %
    % ### `Abortnow`
    % Flag for stopping the acquisition process (duplicated with `AbortNow`).
    %
    % ## Methods
    %
    % ### `DCAM4Camera()`
    % Constructor for creating an instance of `DCAM4Camera`.
    %
    % ### `errorcheck()`
    % Performs error checking.
    %
    % ### `getcamera()`
    % Method to retrieve camera settings (implementation not shown).
    %
    % ### `abort()`
    % Aborts the current capture.
    % - Stops capture with `DCAM4StopCapture`.
    % - Releases memory with `DCAM4ReleaseMemory`.
    %
    % ### `getlastimage()`
    % Returns the last image captured by the camera.
    % - Reshapes and returns the image data.
    %
    % ### `getoneframe()`
    % Returns a specific frame from the camera.
    % - Retrieves and reshapes a specified frame.
    %
    % ### `getdata()`
    % Grabs data from the camera based on acquisition type (`focus`, `capture`, `sequence`).
    %
    % ### `initialize()`
    % Initializes the camera and sets up default properties.
    % - Retrieves camera information.
    % - Sets default exposure times, pixel size, and properties.
    %
    % ### `setup_acquisition()`
    % Configures the acquisition settings for different acquisition types (`focus`, `capture`, `sequence`).
    %
    % ### `setup_fast_acquisition()`
    % Sets up fast acquisition mode with software triggering.
    %
    % ### `shutdown()`
    % Closes the camera and releases resources.
    % - Calls `DCAM4Close` and `DCAM4UnInit`.
    %
    % ### `prepareForCapture(NImages)`
    % Prepares the camera for capturing `NImages`.
    % - Releases and allocates memory buffers.
    %
    % ### `start_capture()`
    % Starts image capture mode.
    %
    % ### `start_focus()`
    % Starts focus mode acquisition.
    %
    % ### `start_focusWithFeedback()`
    % Starts focus mode with feedback display.
    %
    % ### `start_sequence(CaptureMode)`
    % Starts sequence acquisition mode.
    % - CaptureMode can be either `0` (snap) or `-1` (sequence).
    %
    % ### `start_scan()`
    % Begins a scanning acquisition sequence.
    %
    % ### `getlastframebundle(Nframe)`
    % Retrieves a bundle of frames during acquisition.
    %
    % ### `triggeredCapture()`
    % Performs a capture triggered by an external signal.
    %
    % ### `fireTrigger()`
    % Fires a trigger signal.
    %
    % ### `finishTriggeredCapture(numFrames)`
    % Finishes a triggered capture and retrieves the captured frames.
    %
    % ### `take_sequence()`
    % Performs a sequence capture.
    %
    % ### `reset()`
    % Resets the camera properties and reopens the camera handle.
    %
    % ### `HtsuGetStatus()`
    % Retrieves the current status of the camera.
    % - Returns a status string (`'Error'`, `'Busy'`, `'Ready'`, etc.).
    %
    % ### `call_temperature()`
    % Calls the temperature measurement function.
    %
    % ### `get_propertiesDcam()`
    % Retrieves properties and attributes from the camera.
    %
    % ### `get_propAttr(idprop)`
    % Retrieves the attributes of a specified property.
    %
    % ### `getProperty(idprop)`
    % Retrieves the value of a specified property.
    %
    % ### `setProperty(idprop, value)`
    % Sets the value of a specified property.
    %
    % ### `setgetProperty(idprop, value)`
    % Sets and retrieves the value of a specified property.
    %
    % ### `setCamProperties(Infield)`
    % Applies camera properties from an input field.
    %
    % ### `build_guiDialog(GuiCurSel)`
    % Builds a GUI dialog based on camera settings.
    %
    % ### `apply_camSetting()`
    % Applies the settings from the GUI dialog.
    %
    % ### `exportState()`
    % Exports the current state of the camera object.
    %
    % ### `set.ROI(ROI)`
    % Sets the Region of Interest (ROI).
    %
    % ### `valuecheck(propname, val)`
    % Checks and adjusts the value of a property to fit within specified bounds.
    %
    % ### `set.ExpTime_Focus(in)`
    % Sets the focus mode exposure time.
    %
    % ### `set.ExpTime_Capture(in)`
    % Sets the capture mode exposure time.
    %
    % ### `set.ExpTime_Sequence(in)`
    % Sets the sequence mode exposure time.
    %
    % ### `set.Binning(in)`
    % Sets the binning mode.
    %
    % ### `set.SequenceLength(in)`
    % Sets the sequence length.
    %
    % ## Protected Methods
    %
    % ### `get_properties()`
    % Retrieves properties of the object.
    %
    % ### `gettemperature()`
    % Retrieves the temperature of the camera.
    %
    % ## Static Methods
    %
    % ### `funcTest()`
    % Performs a unit test of the camera class.
    %
    % ### `camSet2GuiSel(CameraSetting)`
    % Converts current camera settings to GUI selections.
    %
    
    properties(Access = protected)
        AbortNow;
        ErrorCode;
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;      %If not, call setup_acquisition
        TextHandle;
        
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
        TriggerPause; % pause (seconds) after trigger firing in fireTrigger()
        IsRunning = 0;
        CameraFrameIndex;
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
        FrameRate;
        TriggerMode;        %   trigger mode for Hamamatsu sCMOS camera
        GuiDialog;
        Timeout = 10000;        % timeout sent to several DCAM functions (milliseconds)
        %EventMaskString = 'DCAMWAIT_CAPEVENT_CYCLEEND'; % wait event mask used in DCAM functions (see dcamprop.h DCAMWAIT_EVENT)
        Abortnow;
    end
    
%     properties (Hidden)
%         EventMask = 4;
%     end
    
    methods
        
        function obj=DCAM4Camera() %constructor
            obj = obj@mic.camera.abstract(~nargout);
        end
        
        function errorcheck(obj)
        end
        
        getcamera(obj);
        
%         function delete(obj)
%             obj.shutdown()
%         end
        
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

        function out = getoneframe(obj)
            % Return the frame at frameId.
            Image = DCAM4CopyOneFrame(obj.CameraHandle, obj.CameraFrameIndex,obj.Timeout);
            out = reshape(Image, obj.ImageSize(1), obj.ImageSize(2));

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
                        obj.SequenceLength, obj.Timeout);
                    Data = reshape(Data, ...
                        obj.ImageSize(1), obj.ImageSize(2), ...
                        obj.SequenceLength);
            end
        end
        
        function initialize(obj)
            %addpath(obj.SDKPath)
            if isempty(obj.CameraIndex)
                fprintf('Getting Hamamatsu Camera Info.\n')
                obj.getcamera()
            end
            
            obj.abort();
            obj.get_propertiesDcam()
            ExposureTime = obj.CameraSetting.EXPOSURE_TIME.Value;
            obj.ReturnType='matlab';
            obj.ExpTime_Focus=ExposureTime;
            obj.ExpTime_Capture=ExposureTime;
            obj.ExpTime_Sequence=ExposureTime;
            
            obj.XPixels = obj.CameraSetting.SUBARRAY_HSIZE.Value;
            obj.YPixels = obj.CameraSetting.SUBARRAY_VSIZE.Value;
            obj.ImageSize = [obj.XPixels,obj.YPixels];

            obj.CameraSetting.READOUT_SPEED.Value = 1;
            obj.CameraSetting.DEFECT_CORRECT_MODE.Ind = 1;
            obj.CameraSetting.SUBARRAY_MODE.Ind = 1;
            obj.CameraSetting.TRIGGER_SOURCE.Ind = 1;
            obj.setCamProperties(obj.CameraSetting);
            obj.ROI = [1,obj.XPixels,1,obj.YPixels];
            GuiCurSel = mic.camera.DCAM4Camera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
            %obj.gui();
            obj.abort();
        end
        
        function setup_acquisition(obj)
            status=obj.HtsuGetStatus();
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort();
            end
            idprop = obj.CameraSetting.EXPOSURE_TIME.idprop;
            switch obj.AcquisitionType
                % Exposure time:
                case 'focus'        %Run-Till-Abort
                    TotalFrame=100;
                    obj.ExpTime_Focus = obj.setgetProperty(idprop, obj.ExpTime_Focus);
                    obj.prepareForCapture(TotalFrame);
                case 'capture'      %Single Scan
                    TotalFrame=1;
                    obj.ExpTime_Capture = obj.setgetProperty(idprop, obj.ExpTime_Capture);
                    obj.prepareForCapture(TotalFrame);
                case 'sequence'     %Kinetic Series
                    obj.ExpTime_Sequence = obj.setgetProperty(idprop, obj.ExpTime_Sequence);
                    obj.prepareForCapture(obj.SequenceLength);
            end
            
            % Update the sequence period to reflect duration of exposure +
            % readout.

            obj.SequenceCycleTime = obj.getProperty(obj.CameraSetting.INTERNAL_FRAME_INTERVAL.idprop);
            obj.Timeout = 10000+obj.SequenceCycleTime*1e3;
            obj.FrameRate = 1/obj.SequenceCycleTime;
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
            
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')
                obj.ReadyForAcq=1;
            end
            
            % set Trigger mode to Software so we can use firetrigger
            %TriggerModeIdx = 3; % Software mode
            %obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            %obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TRIGGER_SOURCE.Desc{3};

            % set to software trigger
            obj.setProperty(obj.CameraSetting.TRIGGER_SOURCE.idprop, 3);
            obj.setup_acquisition()
                        
            % Determine the trigger pause time (minimum trigger period).
            
            obj.TriggerPause = obj.getProperty(obj.CameraSetting.TIMING_MIN_TRIGGER_INTERVAL.idprop);
            
            % start capture so triggering can start
            captureMode=-1; % sequence
            DCAM4StartCapture(obj.CameraHandle, captureMode);
            %pause(1) % pause briefly before proceeding
        end
        
        function shutdown(obj)
            DCAM4Close(obj.CameraHandle);
            DCAM4UnInit();
            clear obj.CameraHandle;
        end
        function prepareForCapture(obj, NImages)
            % Release the existing memory buffer.
            DCAM4ReleaseMemory(obj.CameraHandle)
            % Allocate a new memory buffer.
            DCAM4AllocMemory(obj.CameraHandle, NImages)

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
            %pause(1) % pause briefly before proceeding
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
            %pause(1) % pause briefly before proceeding
            
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
            obj.setup_acquisition();
            
            obj.AbortNow=0;
            DCAM4StartCapture(obj.CameraHandle, CaptureMode); % what we call sequence needs snap mode
            %pause(1) % pause briefly before proceeding
            
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
        
        function start_scan(obj)
            obj.abort;
            obj.AcquisitionType='sequence';

            obj.setup_acquisition();
            CaptureMode = 0;
            obj.AbortNow=0;
            obj.Abortnow=0;
            obj.IsRunning=1;
            obj.CameraFrameIndex=0;
            obj.Data=zeros(obj.ImageSize(1), obj.ImageSize(2), ...
                        obj.SequenceLength,'uint16');
            DCAM4StartCapture(obj.CameraHandle, CaptureMode); % what we call sequence needs snap mode

        end

        function out = getlastframebundle(obj,Nframe)
            Camstatus=obj.HtsuGetStatus;

            while strcmp(Camstatus,'Busy')
                if obj.AbortNow
                    obj.abort()
                    obj.AbortNow=0;
                    obj.IsRunning=0;
                    obj.Abortnow=1;
                    break
                end

                out = getoneframe(obj);
                obj.CameraFrameIndex=obj.CameraFrameIndex+1;
                obj.Data(:,:,obj.CameraFrameIndex)=out;
                Camstatus=obj.HtsuGetStatus;
                
                if mod(obj.CameraFrameIndex,Nframe)==0
                    break;
                end
            end
            if ~strcmp(Camstatus,'Busy')
                %obj.abort;
                obj.IsRunning = 0;
            end
            out = obj.Data(:,:,obj.CameraFrameIndex-Nframe+1:obj.CameraFrameIndex);
            out = permute(out,[2,3,1]); % [y,x_scan,wave]
        end

        function triggeredCapture(obj)
            obj.fireTrigger();
            obj.displaylastimage();
            
            % Pause before returning.
            pause(obj.TriggerPause)
        end
        
        function fireTrigger(obj)
            DCAM4FireTrigger(obj.CameraHandle, obj.Timeout)
        end
        
        function out=finishTriggeredCapture(obj,numFrames)
%             obj.abort();
            imgall = DCAM4CopyFrames(obj.CameraHandle, numFrames, ...
                obj.SequenceCycleTime*numFrames);
            out=reshape(imgall,obj.ImageSize(1),obj.ImageSize(2),numFrames);
            
            % set Trigger mode back to Internal so data can be captured
            %TriggerModeIdx = 1; % Internal mode
            %obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            %obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TRIGGER_SOURCE.Desc{1};
            % set to internal trigger
            obj.setProperty(obj.CameraSetting.TRIGGER_SOURCE.idprop, 1);
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


        function get_propertiesDcam(obj)
            idprop = DCAM4GetPropNextID(obj.CameraHandle,int32(0));
            while idprop ~= 0
                pinfo = obj.get_propAttr(idprop);
                obj.CameraSetting.(pinfo.Name).idprop = idprop;
                obj.CameraSetting.(pinfo.Name).Type = pinfo.Type;
                obj.CameraSetting.(pinfo.Name).Desc = pinfo.Option;
                obj.CameraSetting.(pinfo.Name).Range = pinfo.Range;
                obj.CameraSetting.(pinfo.Name).Readable = pinfo.Readable;
                obj.CameraSetting.(pinfo.Name).Writable = pinfo.Writable;
                switch pinfo.Type
                    case 'bounded'
                        obj.CameraSetting.(pinfo.Name).Value = pinfo.Value;
                        
                    case 'enum'
                        obj.CameraSetting.(pinfo.Name).Bit = pinfo.Option{pinfo.Value};
                        obj.CameraSetting.(pinfo.Name).Ind = pinfo.Value;
                end

                idprop = DCAM4GetPropNextID(obj.CameraHandle,idprop);
            end

        end

        function Pinfo = get_propAttr(obj,idprop)
            pinfo = DCAM4GetPropInfo(obj.CameraHandle,idprop);
            
            propname = strrep(pinfo.name,' ','_');
            propname = strrep(propname,'[','');
            propname = strrep(propname,']','');
            Pinfo.Name = propname;
            ptype = pinfo.type;
            if pinfo.range(1)<0 % range is not available
                Pinfo.Range = [1,2,-1]; % 'OFF', 'ON'
            else
                Pinfo.Range = pinfo.range;
            end
            Pinfo.Writable = pinfo.writable;
            Pinfo.Readable = pinfo.readable;
            Pinfo.Unit = pinfo.unit;
            if Pinfo.Readable
                value = obj.getProperty(idprop);
            else
                value = nan;
            end
            
            if strcmp(ptype,'MODE')
                option = cell(1,Pinfo.Range(2));
                for ii = Pinfo.Range(1):Pinfo.Range(2)
                    valuetext = string(DCAM4GetPropValueText(obj.CameraHandle,idprop,ii));
                    option{ii} = valuetext{1};
                end
                type = 'enum';
            else
                type = 'bounded';
                option = 0;
            end
            Pinfo.Option = option;
            Pinfo.Type = type;
            Pinfo.Value = value;
        end

        function Value = getProperty(obj,idprop)
            Value = DCAM4GetProperty(obj.CameraHandle,idprop);
        end

        function setProperty(obj,idprop,value)
            DCAM4SetProperty(obj.CameraHandle,idprop,value);
        end

        function Value = setgetProperty(obj,idprop,value)
            DCAM4SetProperty(obj.CameraHandle,idprop,value);
            Value = DCAM4GetProperty(obj.CameraHandle,idprop);
        end

        function setCamProperties(obj,Infield)
            status = obj.HtsuGetStatus();
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
  
            end            

            % Set up properties
            fieldp=fields(Infield);
            for ii=1:length(fieldp)
                idprop = Infield.(fieldp{ii}).idprop;

                if Infield.(fieldp{ii}).Writable
                    pinfo = obj.get_propAttr(idprop);
                    switch pinfo.Type
                        case 'enum'
                            value = Infield.(fieldp{ii}).Ind;
                        case 'bounded'
                            value = Infield.(fieldp{ii}).Value;
                    end
                    if pinfo.Value ~= value
                        obj.setProperty(idprop,value);
                        
                    end
                end
            end

        end

        function build_guiDialog(obj,GuiCurSel)
            % gui building
            fieldp=fields(GuiCurSel);
            for ii=1:length(fieldp)
                pInfo= obj.CameraSetting.(fieldp{ii});
                switch pInfo.Type
                    case 'enum'
                        obj.GuiDialog.(fieldp{ii}).Desc=pInfo.Desc;
                        if (pInfo.Range(1)~=pInfo.Range(2)) && pInfo.Writable
                            obj.GuiDialog.(fieldp{ii}).uiType='select';
                        end
                    case 'bounded'
                        obj.GuiDialog.(fieldp{ii}).Range=pInfo.Range;
                        obj.GuiDialog.(fieldp{ii}).Desc=num2str(pInfo.Range);
                        if (pInfo.Range(1)~=pInfo.Range(2)) && pInfo.Writable
                            obj.GuiDialog.(fieldp{ii}).uiType='input';
                        end
                end
                if (pInfo.Range(1)~=pInfo.Range(2)) && pInfo.Writable
                    obj.GuiDialog.(fieldp{ii}).enable=1;
                else
                    obj.GuiDialog.(fieldp{ii}).enable=2;
                end
                obj.GuiDialog.(fieldp{ii}).curVal=GuiCurSel.(fieldp{ii}).Val;
            end
            
        end


        function apply_camSetting(obj)
            % update CameraSetting struct from GUI
            guiFields=fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                pInfo= obj.CameraSetting.(guiFields{ii});
                switch pInfo.Type
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
            status = obj.HtsuGetStatus();
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
                
            end            
            Hoffset = obj.valuecheck('SUBARRAY_HPOS',ROI(1)-1);
            HWidth = obj.valuecheck('SUBARRAY_HSIZE',ROI(2)-ROI(1)+1);
            Voffset = obj.valuecheck('SUBARRAY_VPOS',ROI(3)-1);
            VWidth = obj.valuecheck('SUBARRAY_VSIZE',ROI(4)-ROI(3)+1);

            % set subarray mode off.
            obj.setProperty(obj.CameraSetting.SUBARRAY_MODE.idprop,1);
            % set subarray
            obj.setProperty(obj.CameraSetting.SUBARRAY_HSIZE.idprop,HWidth);
            obj.setProperty(obj.CameraSetting.SUBARRAY_HPOS.idprop,Hoffset);
            obj.setProperty(obj.CameraSetting.SUBARRAY_VSIZE.idprop,VWidth);
            obj.setProperty(obj.CameraSetting.SUBARRAY_VPOS.idprop,Voffset);
            % set subarray mode on.
            obj.setProperty(obj.CameraSetting.SUBARRAY_MODE.idprop,2);

            obj.CameraSetting.SUBARRAY_HPOS.Value = Hoffset;
            obj.CameraSetting.SUBARRAY_HSIZE.Value = HWidth;
            obj.CameraSetting.SUBARRAY_VPOS.Value = Voffset;
            obj.CameraSetting.SUBARRAY_VSIZE.Value = VWidth;
            obj.CameraSetting.SUBARRAY_MODE.Ind = 2;

            GuiCurSel = mic.camera.DCAM4Camera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);

            obj.ROI=[Hoffset+1,Hoffset+HWidth,Voffset+1,Voffset+VWidth];
            obj.ImageSize=[HWidth,VWidth];

        end

        function out = valuecheck(obj,propname,val)
            step = obj.CameraSetting.(propname).Range(3);
            out = round(val/step)*step;
            if val<obj.CameraSetting.(propname).Range(1)
                out = obj.CameraSetting.(propname).Range(1);
            end
            if val>obj.CameraSetting.(propname).Range(2)
                out = obj.CameraSetting.(propname).Range(2);
            end

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
        
%         function set.EventMaskString(obj, SetValue)
%             % Convert the input EventMaskString to a decimal EventMask
%             % (this can be slow, so it's best to do it as soon as the user
%             % sets this property).
%             obj.EventMaskString = SetValue;
%             obj.EventMask = hex2dec(obj.propertyToHex(SetValue, obj.APIPath));
%         end
        
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
            Success=0;
            %Create object
            try
                A=mic.camera.HamamatsuCamera();
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
        %[HexString] = propertyToHex(PropertyString, APIFilePath);
        %[PropertyString] = hexToProperty(HexString, Prefix, APIFilePath);
        %setProperty(CameraHandle, Property, Value, APIFilePath);
        %[Value] = getProperty(CameraHandle, Property, APIFilePath);
        %[Value] = setGetProperty(CameraHandle, Property, Value, APIFilePath);
        %prepareForCapture(CameraHandle, CaptureMode, NImages);
    end
end
