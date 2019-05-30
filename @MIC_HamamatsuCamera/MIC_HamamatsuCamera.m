classdef MIC_HamamatsuCamera < MIC_Camera_Abstract
       %MIC_HamamatsuCamera class 
       
    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        ErrorCode;
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq=0;      %If not, call setup_acquisition
        TextHandle;
        CameraHandle;
        SDKPath;
    end
    
    properties(SetAccess=protected)
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
        Binning;            %   [binX binY]        
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
    end
    
    methods
        
        function obj=MIC_HamamatsuCamera() %constructor
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function delete(obj) %destructor
            obj.shutdown
        end
        
        function abort(obj) %?
            DcamAbort(obj.CameraHandle);
            obj.ReadyForAcq=0;
        end
        
        function errorcheck(obj,funcname) %?
            
        end
        
        function out=getlastimage(obj) %?
            if obj.TriggerMode == 32
                [img]=DcamGetLastImageFast(obj.CameraHandle);
            else
                [img]=DcamGetNewestFrame(obj.CameraHandle);
            end
            out=reshape(img,obj.ImageSize(1),obj.ImageSize(2));
        end

        function out=getdata(obj) 
            switch obj.AcquisitionType
                case 'focus'
                    out=obj.getlastimage;
                case 'capture'
                    out=obj.getlastimage;
                case 'sequence'
                    [imgall]=DcamGetAllFrames(obj.CameraHandle,obj.SequenceLength);
                    out=reshape(imgall,obj.ImageSize(1),obj.ImageSize(2),obj.SequenceLength);
            end
        end
        
        function initialize(obj)
            %basepath=userpath;
           % addpath([basepath(1:end-1) '\Instrumentation\development\DCAMmex']); 
            if isempty(obj.CameraIndex)
                fprintf('Getting Hamamatsu Camera Info.\n')
                obj.getcamera
            end
            obj.Binning=1; 
            obj.ScanMode=1; %scan mode is slow
            obj.DefectCorrection=1;% defection correction is off
            obj.XPixels=2048;
            obj.YPixels=2048;
            obj.ImageSize=[obj.XPixels,obj.YPixels];
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
            %GuiCurSel = HamamatsuCamera.camSet2GuiSel(obj.CameraSetting); % FF 
            GuiCurSel = MIC_HamamatsuCamera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
           % obj.gui;
        end
        
        function setup_acquisition(obj)
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
            end
            status=obj.HtsuGetStatus;
            switch obj.AcquisitionType
                case 'focus'        %Run-Till-Abort
                    captureMode=1; %sequence
                    TotalFrame=100;
                    [currentET]=DcamSetExposureTime(obj.CameraHandle,obj.ExpTime_Focus);
                    DcamCaptureSettings(obj.CameraHandle,captureMode,TotalFrame);
                    obj.ExpTime_Focus=currentET;
                case 'capture'      %Single Scan
                    captureMode=0; %snap
                    TotalFrame=1;
                    [currentET]=DcamSetExposureTime(obj.CameraHandle,obj.ExpTime_Capture);
                    DcamCaptureSettings(obj.CameraHandle,captureMode,TotalFrame);
                    obj.ExpTime_Capture=currentET;
                case 'sequence'     %Kinetic Series
                    captureMode=0; %snap
                    [currentET]=DcamSetExposureTime(obj.CameraHandle,obj.ExpTime_Sequence);
                    % allocate memory for capturing data
                    DcamCaptureSettings(obj.CameraHandle,captureMode,obj.SequenceLength);
                    obj.ExpTime_Sequence=currentET;
            end
            
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')
                obj.ReadyForAcq=1;
            else
                error('Hamamatsu Camera not ready. Try Reseting')
            end
        end
        
        function setup_fast_acquisition(obj,numFrames)
            obj.AcquisitionType='sequence';
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')||strcmp(status,'Busy')
                obj.abort;
            end
            captureMode=0; %snap
            [currentET]=DcamSetExposureTime(obj.CameraHandle,obj.ExpTime_Sequence);
            % allocate memory for capturing data
            DcamCaptureSettings(obj.CameraHandle,captureMode,numFrames);
            obj.ExpTime_Sequence=currentET;
            
            status=obj.HtsuGetStatus;
            if strcmp(status,'Ready')
                obj.ReadyForAcq=1;
            end
            
            % set Trigger mode to Software so we can use firetrigger
            TriggerModeIdx = 4; % Software mode
            obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TriggerMode.Bit;
            % apply trigger mode
            DcamSetTriggerMode(obj.CameraHandle,obj.TriggerMode);
            
            % start capture so triggering can start
            DcamCapture(obj.CameraHandle);
        end
        
        function shutdown(obj)
            DcamClose(obj.CameraHandle);
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
            DcamCapture(obj.CameraHandle);
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

            obj.setup_acquisition;
                   
            [Status]=obj.HtsuGetStatus();
            switch Status
                case 'Ready'
                otherwise
                    error('Hamamatsu not ready')
            end               
            
            obj.AbortNow=0;
            DcamCapture(obj.CameraHandle);
            
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
            DcamCapture(obj.CameraHandle);
            
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
        
        function out=start_sequence(obj)
            %obj.AcquisitionType='sequence';
            obj.abort;
            obj.AcquisitionType='sequence';
%             status=obj.HtsuGetStatus;
%             if strcmp(status,'Ready')||strcmp(status,'Busy')
%                 obj.abort;
%             end
            obj.setup_acquisition;
            
            obj.AbortNow=0;
            DcamCapture(obj.CameraHandle);
            
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
        
        function TriggeredCapture(obj)
            DcamFireTrigger(obj.CameraHandle)
            obj.displaylastimage;
        end
        
        function out=FinishTriggeredCapture(obj,numFrames)
            %obj.abort;
            [imgall]=DcamGetAllFrames(obj.CameraHandle,numFrames);
            out=reshape(imgall,obj.ImageSize(1),obj.ImageSize(2),numFrames);
                        
            % set Trigger mode back to Internal so data can be captured
            TriggerModeIdx = 1; % Internal mode
            obj.CameraSetting.TriggerMode.Ind = TriggerModeIdx;
            % need to refer to GuiDialog to get right Bit value
            obj.CameraSetting.TriggerMode.Bit = obj.GuiDialog.TriggerMode.Bit(TriggerModeIdx);
            obj.TriggerMode = obj.CameraSetting.TriggerMode.Bit;
            % apply trigger mode
            DcamSetTriggerMode(obj.CameraHandle,obj.TriggerMode);
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
            DcamCapture(obj.CameraHandle)
            
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
            DcamClose(obj.CameraHandle)
            DcamGetCameras;
            obj.CameraHandle=DcamOpen(obj.CameraIndex);
            obj.setCamProperties(obj.CameraSetting);
        end
        
        function status=HtsuGetStatus(obj)
            [stat]=DcamGetStatus(obj.CameraHandle);
            switch (stat)
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
            obj.GuiDialog.TriggerMode.Desc={'Internal','Edge','Level', 'Software',...
                                            'Start','SyncreADout'};
            obj.GuiDialog.TriggerMode.Bit=int32([hex2dec('0001'),hex2dec('0002'),hex2dec('0004'),...
                                            hex2dec('0020'),hex2dec('0200'),hex2dec('0400')]);                            
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
            DcamSetBinning(obj.CameraHandle,obj.Binning);
            DcamSetScanMode(obj.CameraHandle,obj.ScanMode);
            DcamSetTriggerMode(obj.CameraHandle,obj.TriggerMode);
            DCAMSetDefectCorrection(obj.CameraHandle,obj.DefectCorrection);
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
            status=obj.HtsuGetStatus;
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
            DcamSetSubArray(obj.CameraHandle,Hoffset,HWidth,Voffset,VWidth);   

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
                
    end
end