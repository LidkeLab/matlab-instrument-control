classdef PyDcam < mic.camera.abstract
% mic.camera.PyDcam Class Documentation
% 
% ## Overview
% `mic.camera.PyDcam` is a MATLAB class designed for controlling a camera through a Python interface. It extends the `mic.camera.abstract` class and includes methods for camera setup, acquisition control, and image retrieval.
% 
% ## Methods
% - **Constructor**: Initializes the camera settings.
% - `abort()`: Aborts the ongoing acquisition.
% - `shutdown()`: Closes the camera connection and cleans up.
% - `errorcheck(funcname)`: Placeholder for error checking.
% - `initialize()`: Placeholder for initialization.
% - `fireTrigger()`: Placeholder for manual trigger.
% - `initializeDcam(envpath)`: Initializes the camera with the specified Python environment path.
% - `getlastimage()`: Retrieves the last frame from the camera buffer.
% - `getdata()`: Retrieves data based on the current acquisition type.
% - `start_focus()`: Starts acquisition in focus mode.
% - `start_capture()`: Starts acquisition in capture mode.
% - `start_sequence()`: Starts acquisition in sequence mode.
% - `setup_acquisition()`: Prepares the camera for acquisition based on the current settings.
% - `setup_fast_acquisition(numFrames)`: Prepares the camera for a fast acquisition sequence.
% - `triggeredCapture()`: Captures a frame upon receiving a trigger.
% - `finishTriggeredCapture()`: Finishes the triggered capture session and retrieves data.
% - `get_PropertiesDcam()`: Retrieves camera Properties from the DCAM API.
% - `get_propAttr(idprop)`: Retrieves Property attributes from the camera.
% - `setCamProperties(Infield)`: Sets camera Properties based on the provided fields.
% - `setProperty(idprop, value)`: Sets a camera Property.
% - `getProperty(idprop)`: Gets a camera Property.
% - `setgetProperty(idprop, value)`: Sets and gets a camera Property.
% - `build_guiDialog(GuiCurSel)`: Builds the GUI dialog based on current settings.
% - `apply_camSetting()`: Applies changes from the GUI to the camera settings.
% - `valuecheck(propname, val)`: Checks and adjusts the value based on the camera setting constraints.
% - `exportState()`: Exports the current state of the camera.
% - `exportParameters()`: Exports current camera parameters.
% 
% ## Static Methods
% - `unitTest()`: Tests the functionality of the class.
% - `camSet2GuiSel(CameraSetting)`: Converts current camera settings into GUI selections.
% 
% ## Usage
% To use `mic.camera.PyDcam`, create an instance of the class and call its methods to interact with the camera. Ensure Python and required libraries are properly set up and accessible to MATLAB.
%
% ### CITATION: Sheng Liu, Lidkelab, 2024.

    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq;        %If not, call setup_acquisition
        TextHandle;
    end
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        CameraHandle;
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        CameraSetting;
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        InstrumentName = '';

    end
    properties
        Binning;            %   [binX binY]
        Data;               %   last acquired data
        ExpTime_Focus;      %   focus mode exposure time
        ExpTime_Capture;    %   capture mode exposure time
        ExpTime_Sequence;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        SequenceLength = 10;     %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
        GuiDialog;
        TimeOut = 10000;     % ms
        TriggerMode;
    end
    properties (Hidden)
        StartGUI=false;     %Defines GUI start mode.  'true' starts GUI on object creation.
    end


    methods
        function obj=PyDcam(envpath) 
            % Object constructor
            obj = obj@mic.camera.abstract(~nargout);
            obj.initializeDcam(envpath)
        end
        
        function abort(obj)
            % Abort function
            err = obj.CameraHandle.cap_stop();
            obj.ReadyForAcq=0; 
        end
        
        function shutdown(obj)
            % Object shutdown
            try
                obj.CameraHandle.dev_close();
            catch
                warning('no device opened')
            end
            out = py.dcam.Dcamapi.uninit();
            clear obj.CameraHandle;
        end
        
        function errorcheck(obj,funcname)
        end
        function initialize(obj)
        end
        function fireTrigger(obj)
        end

        function initializeDcam(obj,envpath)
            % Initialization
            
            pyenv('Version',envpath)
            
            [filepath,~,~] = fileparts(which('mic.camera.PyDcam'));
            cd([filepath,'/private'])
            py.importlib.import_module('dcam');
            py.importlib.import_module('dcamapi4');
            py.importlib.import_module('dcam_helper');

            if isempty(obj.CameraIndex)
                obj.getcamera;
            end
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
            obj.CameraSetting.SUBARRAY_MODE.Ind = 2;
            obj.CameraSetting.TRIGGER_SOURCE.Ind = 1;
            obj.setCamProperties(obj.CameraSetting);
            obj.ROI = [1,obj.XPixels,1,obj.YPixels];
            GuiCurSel = mic.camera.PyDcam.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
            obj.gui;
            err = obj.CameraHandle.buf_release();
        end


        
        function out=getlastimage(obj) 
            frameready = obj.CameraHandle.wait_capevent_frameready(py.int(obj.TimeOut));
            if frameready
               img = obj.CameraHandle.buf_getlastframedata();
               out = permute(img.uint16,[2,1]);
               
            else
                err = obj.CameraHandle.lasterr();
                disp(['Dcam.wait_capevent_frameready() fails with error: ',err.char])
                out = [];
            end
        end

        function out=getdata(obj) 
            switch obj.AcquisitionType
                case 'focus'
                    out=obj.getlastimage;
                case 'capture'
                    out=obj.getlastimage;
                case 'sequence'
                    info = obj.CameraHandle.cap_transferinfo();
                    info.nFrameCount.int16
                    %out = py.dcam_helper.dcam_get_allframes(obj.CameraHandle,py.int(obj.SequenceLength));
                    out = py.dcam_helper.dcam_get_allframes(obj.CameraHandle,info.nFrameCount);
                    out = permute(out.uint16,[3,2,1]);
                    %out = out.uint16;
            end
        end

        function out=start_focus(obj)
            obj.AcquisitionType='focus';

            obj.setup_acquisition;
            TotalFrame = 100;
            err = obj.CameraHandle.buf_alloc(py.int(TotalFrame));       
            Status = obj.getCapStatus();
            switch Status
                case 'READY'
                otherwise
                    error('Hamamatsu not ready')
            end               
            
            obj.AbortNow=0;
            err = obj.CameraHandle.cap_start();
            
            Status = obj.getCapStatus();
            while strcmp(Status,'BUSY')
                if obj.AbortNow
                    obj.abort;
                    break;
                end
                obj.displaylastimage();
                Status = obj.getCapStatus();
            end
            
%             if obj.AbortNow
%                 obj.abort;
%                 obj.AbortNow=0;                
%                 obj.CameraHandle.buf_release();
%                 return;
%             end
            
            out=[]; 
            err = obj.CameraHandle.buf_release();
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

        function out=start_capture(obj)
            obj.AcquisitionType='capture';
            obj.setup_acquisition();
            
            obj.AbortNow=1;
            TotalFrame = 1;
            err = obj.CameraHandle.buf_alloc(py.int(TotalFrame));
            status=obj.getCapStatus();
            switch status
                case 'READY'
                otherwise
                    error('Hamamatsu not ready')
            end               

            err = obj.CameraHandle.cap_snapshot();
            out=obj.getdata();
            obj.abort();
            err = obj.CameraHandle.buf_release();
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

        function out=start_sequence(obj)
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            
            obj.AbortNow=0;
            err = obj.CameraHandle.buf_alloc(py.int(obj.SequenceLength));
            status=obj.getCapStatus();
            switch status
                case 'READY'
                otherwise
                    error('Hamamatsu not ready')
            end               

            err = obj.CameraHandle.cap_snapshot();
            
            Status = obj.getCapStatus();
            while strcmp(Status,'BUSY')
                if obj.AbortNow
                    obj.abort;                    
                    break;
                end
                obj.displaylastimage;
                Status = obj.getCapStatus();
            end
            
%             if obj.AbortNow
%                 obj.abort;
%                 obj.AbortNow=0;
%                 out=[];
%                 obj.CameraHandle.buf_release();
%                 return;
%             end
            if obj.AbortNow==0
                obj.abort;
            end
            out=obj.getdata;
            err = obj.CameraHandle.buf_release();
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

        function status = getCapStatus(obj)
            status=py.dcam_helper.dcam_get_status(obj.CameraHandle);
            status = status.char;

        end

        function setup_acquisition(obj)
            status=obj.getCapStatus();
            if strcmp(status,'READY')||strcmp(status,'BUSY')
                obj.abort;
                err = obj.CameraHandle.buf_release();
            end

            idprop = obj.CameraSetting.EXPOSURE_TIME.idprop;

            switch obj.AcquisitionType
                case 'focus'        %Run-Till-Abort
                    %TotalFrame=100;
                    out = obj.setgetProperty(idprop,obj.ExpTime_Focus);
                    obj.ExpTime_Focus=out;
                    %err = obj.CameraHandle.buf_alloc(py.int(TotalFrame));
                    
                case 'capture'      %Single Scan
                    %TotalFrame=1;
                    out = obj.setgetProperty(idprop,obj.ExpTime_Capture);
                    obj.ExpTime_Capture=out;
                    %err = obj.CameraHandle.buf_alloc(py.int(TotalFrame));
                    
                case 'sequence'     %Kinetic Series
                    out = obj.setgetProperty(idprop,obj.ExpTime_Sequence);
                    obj.ExpTime_Sequence=out;
                    %err = obj.CameraHandle.buf_alloc(py.int(obj.SequenceLength));
                   
            end
            
%             status=obj.getCapStatus();
%             if strcmp(status,'READY')
%                 obj.ReadyForAcq=1;
%             else
%                 error('Hamamatsu Camera not ready. Try Reseting')
%             end
        end

        function setup_fast_acquisition(obj,numFrames)
            status=obj.getCapStatus();
            if strcmp(status,'READY')||strcmp(status,'BUSY')
                obj.abort;
                err = obj.CameraHandle.buf_release();
            end
            obj.AcquisitionType='sequence';
             
            % set Trigger mode to Software so we can use firetrigger
            idprop = obj.CameraSetting.TRIGGER_SOURCE.idprop;
            triggermode=obj.setgetProperty(idprop,3);% Software mode

            idprop = obj.CameraSetting.EXPOSURE_TIME.idprop;
            out = obj.setgetProperty(idprop,obj.ExpTime_Sequence);
            obj.ExpTime_Sequence=out;
            
            err = obj.CameraHandle.buf_alloc(py.int(numFrames));

            status=obj.getCapStatus();
            switch status
                case 'READY'
                otherwise
                    error('Hamamatsu not ready')
            end               
            
            % start capture so triggering can start
            err = obj.CameraHandle.cap_snapshot();
        end

        function out = triggeredCapture(obj)

            err = obj.CameraHandle.cap_firetrigger();            
            
            
            
            
            %frameready = obj.CameraHandle.wait_capevent_frameready(py.int(obj.TimeOut));
            info = obj.CameraHandle.cap_transferinfo();
            info.nNewestFrameIndex.int16
            %out = obj.getlastimage();
            obj.displaylastimage();
            out = [];
        end

        function out = finishTriggeredCapture(obj)
            obj.abort;
            status=obj.getCapStatus();
            while ~strcmp(status,'READY')
                obj.abort;
            end
            out = obj.getdata();            
            
            %out = [];
            err = obj.CameraHandle.buf_release();  
            status=obj.getCapStatus();
            
            % set Trigger mode back to Internal so data can be captured
            idprop = obj.CameraSetting.TRIGGER_SOURCE.idprop;
            triggermode = obj.setgetProperty(idprop,1);% Internal mode

        end

        function get_propertiesDcam(obj)
            idprop = obj.CameraHandle.prop_getnextid(py.int(0));
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

                idprop = obj.CameraHandle.prop_getnextid(idprop);
            end

        end

        

        function Pinfo = get_propAttr(obj,idprop)
            pinfo = py.dcam_helper.dcam_get_pinfo(obj.CameraHandle,idprop);
            pinfo = pinfo.struct;
            propname = strrep(pinfo.Name.char,' ','_');
            propname = strrep(propname,'[','');
            propname = strrep(propname,']','');
            Pinfo.Name = propname;
            ptype = pinfo.Type.char;
            Pinfo.Range = pinfo.Range.double;
            Pinfo.Writable = pinfo.writable;
            Pinfo.Readable = pinfo.readable;
            Pinfo.Unit = pinfo.unit.char;
            if Pinfo.Readable
                value = obj.getProperty(idprop);
            else
                value = nan;
            end
            
            if strcmp(ptype,'MODE')
                option = cell(1,Pinfo.Range(2));
                for ii = Pinfo.Range(1):Pinfo.Range(2)
                    valuetext = string(obj.CameraHandle.prop_getvaluetext(idprop,ii));
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

        function setCamProperties(obj,Infield)
            status = obj.getCapStatus();
            if strcmp(status,'READY')||strcmp(status,'BUSY')
                obj.abort;
                err = obj.CameraHandle.buf_release();
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
                        [out,err] = obj.setProperty(idprop,value);
                        
                    end
                end
            end

        end

        function [out,err] = setProperty(obj,idprop,value)
            out = obj.CameraHandle.prop_setvalue(idprop,value);
            if out==0
                err = py.str(obj.CameraHandle.lasterr());
                err = err.char;
                disp(['Dcam.prop_setvalue() fails with error: ',err])
            else
                err = 0;
            end
        end

        function [out,err] = getProperty(obj,idprop)
            out = obj.CameraHandle.prop_getvalue(idprop);
            if out==0
                err = py.str(obj.CameraHandle.lasterr());
                err = err.char;
                %disp(['Dcam.prop_getvalue() fails with error: ',err])
            else
                err = 0;
            end
        end

        function [out,err] = setgetProperty(obj,idprop,value)
            out = obj.CameraHandle.prop_setgetvalue(idprop,value);
            if out==0
                err = py.str(obj.CameraHandle.lasterr());
                err = err.char;
                %disp(['Dcam.prop_setgetvalue() fails with error: ',err])
            else
                err = 0;
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
            % Apply camera settings
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

        function set.ROI(obj,ROI)
            obj.ReadyForAcq=0;
            status = obj.getCapStatus();
            if strcmp(status,'READY')||strcmp(status,'BUSY')
                obj.abort;
                err = obj.CameraHandle.buf_release();
            end            
            Hoffset = obj.valuecheck('SUBARRAY_HPOS',ROI(1)-1);
            HWidth = obj.valuecheck('SUBARRAY_HSIZE',ROI(2)-ROI(1)+1);
            Voffset = obj.valuecheck('SUBARRAY_VPOS',ROI(3)-1);
            VWidth = obj.valuecheck('SUBARRAY_VSIZE',ROI(4)-ROI(3)+1);

            %dcamprop_setvalue( hdcam, DCAM_IDPROP_SUBARRAYMODE, DCAMPROP_MODE__OFF );
            curHpos = obj.getProperty(obj.CameraSetting.SUBARRAY_HPOS.idprop);
            curVpos = obj.getProperty(obj.CameraSetting.SUBARRAY_VPOS.idprop);
            if Hoffset>curHpos
                obj.setProperty(obj.CameraSetting.SUBARRAY_HSIZE.idprop,HWidth);
                obj.setProperty(obj.CameraSetting.SUBARRAY_HPOS.idprop,Hoffset);
            else
                obj.setProperty(obj.CameraSetting.SUBARRAY_HPOS.idprop,Hoffset);
                obj.setProperty(obj.CameraSetting.SUBARRAY_HSIZE.idprop,HWidth);
            end
            if Voffset>curVpos
                obj.setProperty(obj.CameraSetting.SUBARRAY_VSIZE.idprop,VWidth);
                obj.setProperty(obj.CameraSetting.SUBARRAY_VPOS.idprop,Voffset);
            else
                obj.setProperty(obj.CameraSetting.SUBARRAY_VPOS.idprop,Voffset);
                obj.setProperty(obj.CameraSetting.SUBARRAY_VSIZE.idprop,VWidth);
            end

            obj.CameraSetting.SUBARRAY_HPOS.Value = Hoffset;
            obj.CameraSetting.SUBARRAY_HSIZE.Value = HWidth;
            obj.CameraSetting.SUBARRAY_VPOS.Value = Voffset;
            obj.CameraSetting.SUBARRAY_VSIZE.Value = VWidth;

            GuiCurSel = mic.camera.PyDcam.camSet2GuiSel(obj.CameraSetting);
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

        function [Attributes,Data,Children]=exportState(obj)
            % Exports current state of camera
            Attributes=obj.exportParameters();
            Data=[];
            Children=[];
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


    methods(Static)
        
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
