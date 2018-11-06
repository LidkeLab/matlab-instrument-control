classdef MIC_AndorCamera < MIC_Camera_Abstract
    %MIC_AndorCamera class 
    %   
    %   Usage:
    %           CAM=AndorCamera
    %           CAM.gui
    %
    %   Requires:
    %       Andor MATLAB SDK 2.94.30005 or higher
    %       
    
    %   TODO:
    %   Add quarter CCD left, right ROI selection (for TIRF system). 
    %   Fix warning error about not acquiring
    %   Add shutter options so capture can be run with/without shutter
    %   GUI doesn't show programic updates to CameraSettings
    %   Clear of object doesn't warm up to shutdown. 
    
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
    end
    
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        
        CameraCap;      % capability (all options) of camera parameters created by qw
        CameraSetting;  % current setting of camera parameters created by qw
        
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
        
        Capabilities;       % Capabilities structure from camera
       
        InstrumentName='AndorCamera' 
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  'true' starts GUI on object creation. 
    end
      
    properties 
        Binning=[1 1];              %   [binX binY]
        Data=[];                    %   last acquired data
        ExpTime_Focus=0;            %   focus mode exposure time
        ExpTime_Capture=0;          %   capture mode exposure time
        ExpTime_Sequence=0;         %   sequence mode expsoure time
        ROI;                        %   [Xstart Xend Ystart Yend]
        SequenceLength=1;           %   Kinetic Series length
        SequenceCycleTime;          %   Kinetic Series cycle time (1/frame rate)
        GuiDialog;                  % GUI dialog for the CameraParameters
                                    % consider making GuiDialog abstract??
        AcquisitionTimeOutOffset
        NumImage
    end
    
    methods
        
        function obj=MIC_AndorCamera()
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function delete(obj)
            obj.shutdown();
        end
        
        function abort(obj)
            obj.setcurrentcamera;
            obj.LastError=AbortAcquisition;
            %obj.errorcheck('AbortAcquisition'); %FIX
        end
        
        function out=getlastimage(obj)
            obj.setcurrentcamera;
            [obj.LastError, out]=GetMostRecentImage16(prod(obj.ImageSize));
            obj.errorcheck('GetMostRecentImage16');
            out=reshape(out,[obj.ImageSize(1) obj.ImageSize(2)]);
        end
        
        function out=getdata(obj)
            switch obj.AcquisitionType
                case 'focus'
                    out=obj.getlastimage();
                case 'capture'
                    out=obj.getlastimage();
                case 'sequence'
                    obj.setcurrentcamera();
                    %get data based on the number of taken images instead
                    %of SequenceLength
                    [a b NumImages] =GetNumberAvailableImages;
%                     c=GetImages;
                    [obj.LastError, out]=GetAcquiredData16(prod(obj.ImageSize)*NumImages);
                    obj.errorcheck('GetAcquiredData16');
                    out=reshape(out,[obj.ImageSize(1) obj.ImageSize(2) NumImages]);  
            end
        end
        
        function start(obj)  %  I might put this in initialize later, need to test it out first...
           obj.initialize;
           obj.get_capabilities;
        end
        
        function initialize(obj)
            obj.set_errorcodes; 
            
            [p,~]=fileparts(which('MIC_AndorCamera'));
            if exist(fullfile(p,'AndorCamera_Properties.mat'),'file')
                a=load(fullfile(p,'AndorCamera_Properties.mat'));
                if exist(a.SDKPath,'dir')
                    obj.SDKPath=a.SDKPath;
                else
                    error('Not a valid path')
                end
                clear a;
            else
                [SDKPath]=uigetdir(matlabroot,'Select Andor SDK Toolbox Directory')
                obj.SDKPath=SDKPath;
                if exist(obj.SDKPath,'dir')
                    save(fullfile(p,'AndorCamera_Properties.mat'),'SDKPath');
                else
                    error('Not a valid path')
                end
            end
            
            addpath(obj.SDKPath)
            
            %This is ugly fix for Andor MATLAB SDK issue
            tmppath=pwd;
            cd(fullfile(obj.SDKPath,'Camera Files'))
            obj.LastError=AndorInitialize('');
            cd(tmppath)
            %end ugly fix
            
            obj.errorcheck('AndorInitialize');
            if isempty(obj.CameraIndex)
                obj.getcamera;
            end
            obj.setcurrentcamera;
            
            obj.Manufacturer = 'Andor';
            
            obj.get_properties;
            obj.Binning=[1 1];
            obj.ExpTime_Focus=0;
            obj.ExpTime_Capture=0;
            obj.ExpTime_Sequence=0;
            obj.ROI=[1 obj.XPixels 1 obj.YPixels];
            obj.ImageSize=[obj.ROI(2)-obj.ROI(1)+1 obj.ROI(4)-obj.ROI(3)+1];
            obj.SequenceLength=1;
            
            % load up camera params and capabilities
            obj.get_parameters;
            obj.get_capabilities;
            % set the camera properties
%             obj.setCameraProperties(obj.CameraParameters);
            % set the camera to default settings
            obj.setCamProperties(obj.CameraSetting);

            % set temperature and turn on camera cooler
            % set temperature will not work on Luca R cameras!
            if obj.Capabilities.ulCameraType ~= 11 % not luca
                obj.change_temperature(-80); % set the temperature
            end
            obj.LastError = CoolerON; % turn on the cooler!!!
            obj.errorcheck('CoolerON');
            
        end
        
        % making a function to call in the gui
        function change_temperature(obj,temp)
            obj.LastError = SetTemperature(temp);
            obj.errorcheck('SetTemperature');
        end
        
        % overloading this for a moment...
        function [temp, status] = call_temperature(obj)
            [temp, status]=gettemperature(obj);
        end
       
        function setShutter(obj,in)
            ismanual=obj.CameraSetting.ManualShutter.Bit;
            if ~ismanual
                warning('setShutter: Manual shutter mode not enabled')
                return;
            end
            switch in
                case 1
                    obj.openShutter;
                case 0
                    obj.closeShutter;
            end       
        end
        
        
        function setup_acquisition(obj)
            obj.setcurrentcamera;
            obj.LastError=AbortAcquisition;
            obj.errorcheck('AbortAcquisition');
            switch obj.AcquisitionType    
                case 'focus'
                    acquisitionMode=5; %Run-Till-Abort
                    [obj.LastError] = SetAcquisitionMode(acquisitionMode);
                    obj.errorcheck('SetAcquisitionMode');
                    obj.LastError = SetExposureTime(obj.ExpTime_Focus);
                    obj.errorcheck('SetExposureTime');
                case 'capture'
                     acquisitionMode=1; %Single Scan
                     [obj.LastError] = SetAcquisitionMode(acquisitionMode);
                     obj.errorcheck('SetAcquisitionMode');
                     obj.LastError = SetExposureTime(obj.ExpTime_Capture);
                     obj.errorcheck('SetExposureTime');
                case 'sequence'
                    acquisitionMode=3; %Kinetic Series
                    obj.LastError = SetAcquisitionMode(acquisitionMode);
                    obj.errorcheck('SetAcquisitionMode');
                    obj.LastError = SetExposureTime(obj.ExpTime_Sequence);
                    obj.errorcheck('SetExposureTime'); 
                    obj.LastError = SetNumberKinetics(obj.SequenceLength);
                    obj.errorcheck('SetNumberKinetics'); 
            end
           
            readmode=4;
            obj.LastError = SetReadMode(readmode);
            obj.errorcheck('SetReadMode');
            [obj.LastError]=SetImage(obj.Binning(1),obj.Binning(2),...
                obj.ROI(1),obj.ROI(2),obj.ROI(3),obj.ROI(4));
            obj.errorcheck('SetImage');
            
            %get back actual timings
            obj.get_parameters();
            switch obj.AcquisitionType    
                case 'focus'
                    obj.ExpTime_Focus=obj.CameraParameters.ExposureTime;
                case 'capture'
                    obj.ExpTime_Capture=obj.CameraParameters.ExposureTime;
                case 'sequence'
                   obj.ExpTime_Sequence=obj.CameraParameters.ExposureTime;
            end
            
            
            obj.ReadyForAcq=1;
 
        end
        
        function shutdown(obj)
            obj.setcurrentcamera;
            [ret] = AndorShutDown(); %SDK
        end
        
        function out = start_capture(obj)
             obj.AcquisitionType='capture';
            if obj.ReadyForAcq==0
                obj.setup_acquisition;
            end
            
%             if ~obj.CameraSetting.ManualShutter.Bit
                obj.openShutter;    
%             end
         
            obj.setcurrentcamera();
            obj.LastError = StartAcquisition();
            obj.errorcheck('StartAcquisition');
            [obj.LastError,gstatus]=AndorGetStatus();
            obj.errorcheck('AndorGetStatus');
            obj.LastError=WaitForAcquisition();
            out=obj.getdata();
          
%             if ~obj.CameraSetting.ManualShutter.Bit
                obj.closeShutter();  
%             end
            
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
        
        function out=start_focus(obj)
            obj.AcquisitionType='focus';
            obj.openShutter;
             
            if obj.ReadyForAcq==0
                obj.setup_acquisition;
            end
  
            obj.setcurrentcamera;
            obj.AbortNow=0;
            [obj.LastError, aqstatus]= AndorGetStatus;
            obj.errorcheck('AndorGetStatus');
            obj.LastError = StartAcquisition();
            obj.errorcheck('StartAcquisition');
            obj.LastError=WaitForAcquisition;
            obj.errorcheck('WaitForAcquisition');
            [obj.LastError, aqstatus]= AndorGetStatus;
          
            while aqstatus==20072
                
                if obj.AbortNow
                    obj.LastError=AbortAcquisition;
                    obj.AbortNow=0;
                    break
                end
                
               
                obj.LastError=WaitForAcquisition;
            
                obj.displaylastimage;
                [obj.LastError, aqstatus]= AndorGetStatus;  
                
            end
    
            obj.closeShutter;
            
            if obj.AbortNow
                    obj.LastError=AbortAcquisition;
                    obj.AbortNow=0;
                    out=obj.getlastimage;
                    return
            end
                
            out=obj.getlastimage;
             
            if obj.KeepData
                obj.Data=out;
            end
            
            switch obj.ReturnType
                case 'dipimage'
                    out=dip_image(out,'uint16');
                case 'matlab'
                    %already in uint16
            end
            
            if nargout<1
                clear out
            end
            
        end
        
        function out=start_sequence(obj)
            obj.AcquisitionType='sequence';
 
%             if ~obj.CameraSetting.ManualShutter.Bit
                obj.openShutter();    
%             end
            
            if obj.ReadyForAcq==0
                obj.setup_acquisition();
            end
  
            obj.setcurrentcamera();
            obj.AbortNow=0;
            [obj.LastError, ~]= AndorGetStatus();
            
            obj.errorcheck('AndorGetStatus');
            obj.LastError = StartAcquisition();
            obj.errorcheck('StartAcquisition');
            [obj.LastError, aqstatus]= AndorGetStatus();
            obj.errorcheck('AndorGetStatus');
            while aqstatus==obj.ErrorCode.DRV_ACQUIRING
                if obj.AbortNow
                    obj.LastError=AbortAcquisition();
                    obj.AbortNow=0;
                    out=[];
                    break
                end
                % fprintf('about to  WaitForAcquisition\n')
                % we replaced WaitForAcquisition with WaitForAcquisitionTimeOut to run
                % Andor and IR camera at the same time.
                obj.LastError=WaitForAcquisitionTimeOut(1000*obj.SequenceCycleTime+obj.AcquisitionTimeOutOffset);
%                 fprintf('finished WaitForAcquisition\n')
                if obj.LastError==20024
                    % This conditions isn't usually satisfied in regular
                    % SRCollect
                    warning('Andor Camera Timeout Reached');
                    %abort acquisition in the case of not collecting data
                    %as NumFrame
                    obj.LastError=AbortAcquisition();
                    break % out of acquiring data        
                end 
                    
                obj.errorcheck('WaitForAcquisitionTimeOut');
                obj.displaylastimage;
                [obj.LastError, aqstatus]= AndorGetStatus;  
                obj.errorcheck('AndorGetStatus');
            end
<<<<<<< HEAD
            [a b obj.NumImage] =GetNumberAvailableImages;

            % close shutter
            if ~obj.CameraSetting.ManualShutter.Bit
=======
            
%             close shutter
%             if ~obj.CameraSetting.ManualShutter.Bit
>>>>>>> remotes/origin/Fix_Reg3DTrans_New
                obj.closeShutter;  
%             end
            
            if obj.AbortNow
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
            
            if nargout<1
                clear out
            end
    
        end
        
        function apply_camSetting(obj)
            % update CameraSetting struct from GUI
            guiFields = fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                disp(['Writing ',guiFields{ii},' in CameraSetting...']);
                switch obj.CameraCap.(guiFields{ii})(1,1).uiType
                    case 'select' 
                        ind = obj.GuiDialog.(guiFields{ii}).curVal;
                        obj.CameraSetting.(guiFields{ii}).Ind = ind;
                        obj.CameraSetting.(guiFields{ii}).Bit = obj.GuiDialog.(guiFields{ii}).Bit(ind);
                        obj.CameraSetting.(guiFields{ii}).Desc = obj.GuiDialog.(guiFields{ii}).Desc{ind};
                    case 'input'
                        val = obj.GuiDialog.(guiFields{ii}).curVal;
                        obj.CameraSetting.(guiFields{ii}).Value = val;
                    case 'binary'
                        ind = obj.GuiDialog.(guiFields{ii}).curVal;
                        obj.CameraSetting.(guiFields{ii}).Ind = ind;
                        obj.CameraSetting.(guiFields{ii}).Bit = obj.GuiDialog.(guiFields{ii}).Bit(ind);
                        obj.CameraSetting.(guiFields{ii}).Desc = obj.GuiDialog.(guiFields{ii}).Desc{ind};
                    otherwise
                        warning('AndorCamera::apply_camSetting: unexpected field.uiType');
                end
            end
        end
        
        function build_guiDialog(obj,GuiCurSel)    
            % build GuiDialog based on current selected camera parameters
            % handles dependencies in user settables
            % also defines what is user configurable
            % GuiCurSel: current selection of Gui parameters
            
            % GuiDialog.ADChannel: fixed options
            % GuiDialog.PreAmpGain: fixed options 
            % GuiDialog.VSSpeed: fixed options
            % GuiDialog.HSSpeed options depends on ADChannel and Amp
            % GuiDialog.Amp: fixed options
            %   if not Luca
            %   GuiDialog.BaselineClamp: fixed options
            %   GuiDialog.Cooler:   fixed options
            %   GuiDialog.VSAmplitudes: fixed options
            % GuiDialog.Trigger: fixed options
            % GuiDialog.Fan: fixed options
            % GuiDialog.FrameTransferMode: Always available?
            % GuiDialog.EMGain: depends on which amp
            % GuiDialog.Shutter: Has a check box for manual mode or not
            
            
            % explicitly declare what goes into the GUI parameters
            obj.GuiDialog.ADChannel = obj.CameraCap.ADChannel;
            % triggers GUI rebuild
            obj.GuiDialog.ADChannel.rebuild = true;
            
            obj.GuiDialog.PreAmpGain = obj.CameraCap.PreAmpGain;
            
            obj.GuiDialog.VSSpeed = obj.CameraCap.VSSpeed;
            
            % get currently selected Amp
            AmpInd = GuiCurSel.Amp.Val;  
            % currently selected ADCh
            ADCInd = GuiCurSel.ADChannel.Val;
            
            obj.GuiDialog.HSSpeed.Bit = obj.CameraCap.HSSpeed(ADCInd,AmpInd).Bit;
            obj.GuiDialog.HSSpeed.Desc = obj.CameraCap.HSSpeed(ADCInd,AmpInd).Desc;
            
            obj.GuiDialog.Amp = obj.CameraCap.Amp;
            % triggers regeneration of options
            obj.GuiDialog.Amp.rebuild = true;
            
            obj.GuiDialog.Trigger = obj.CameraCap.Trigger;
            
            if isfield(obj.CameraCap,'Fan')
             obj.GuiDialog.Fan = obj.CameraCap.Fan;
            end 
            obj.GuiDialog.FrameTransferMode = obj.CameraCap.FrameTransferMode;
            
            % we are only propagating manual mode for the shutter,
            % hard-coding options here!
            if isfield(obj.CameraCap,'ManualShutter')
                obj.GuiDialog.ManualShutter = obj.CameraCap.ManualShutter;
            end
            
            obj.GuiDialog.EMGain = obj.CameraCap.EMGain;
            switch AmpInd
                case 1
                    % EM
                    obj.GuiDialog.EMGain.enable = true;
                case 2
                    % conventional
                    obj.GuiDialog.EMGain.enable = false;
            end
            
            if isfield(obj.CameraCap,'BaselineClamp')
                % has baselineClamp
                obj.GuiDialog.BaselineClamp = obj.CameraCap.BaselineClamp;
            end
            
            if isfield(obj.CameraCap,'VSAmplitude')
                % VSAmplitude user settable
                obj.GuiDialog.VSAmplitude = obj.CameraCap.VSAmplitude;
            end
            
            % now have defined what does to GUI, transfer uiType, current
            % selection
            guiFields = fields(obj.GuiDialog);
            for ii=1:length(guiFields)
                obj.GuiDialog.(guiFields{ii}).uiType = obj.CameraCap.(guiFields{ii})(1,1).uiType;
                obj.GuiDialog.(guiFields{ii}).curVal = GuiCurSel.(guiFields{ii}).Val; 
            end
            % debug
            assignin('base','GuiDialog',obj.GuiDialog);
        end

        function [Attributes,Data,Children]=exportState(obj)
            
            %Get default properties
            Attributes=obj.exportParameters();
            Data=[];
            Children=[];
            
            %Add anything else we want to State here:

        end
        
        
        
        %- SET METHODS--------------------------------------------------
        function set.ROI(obj,ROI)
            obj.setcurrentcamera;
            obj.ReadyForAcq=0;
            [obj.LastError]=SetImage(obj.Binning(1),obj.Binning(2),...
                ROI(1),ROI(2),ROI(3),ROI(4));
            if obj.LastError==obj.ErrorCode.DRV_SUCCESS
                obj.ROI=ROI;
                obj.ImageSize=[obj.ROI(2)-obj.ROI(1)+1 obj.ROI(4)-obj.ROI(3)+1];
                obj.FigurePos=[];
                if (~isempty(obj.FigureHandle)&&ishandle(obj.FigureHandle))
                    close(obj.FigureHandle);
                    obj.FigurePos=[];
                end
            else
                warning('Improper ROI. Not changed');
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
        
    end
    
    methods(Access=protected)
        % shutter control, internal control only...
        function openShutter(obj)
            if isfield(obj.CameraSetting,'ManualShutter')
            extTTL = 1;
            mode = 1;
            closingtime = 50;
            openingtime = 50;
            
            obj.LastError = SetShutter(extTTL,mode,closingtime,openingtime);
            obj.errorcheck('SetShutter');
            end
        end
        function closeShutter(obj)
            if isfield(obj.CameraSetting,'ManualShutter')
            extTTL = 1;
            mode = 2;
            closingtime = 50;
            openingtime = 50;
            
            obj.LastError = SetShutter(extTTL,mode,closingtime,openingtime);
            obj.errorcheck('SetShutter');
            end
        end
        function obj=get_capabilities(obj)
           %things with selectable modes
            
            % CameraParameters;
            %%
%             ADChannel;
%             Amp;
%             BaselineClamp;
%             Cooler;
%             Fan;
%             HSSpeed;
%             PreAmpGain;
%             Shutter;
%             Trigger;
%             VSAmplitudes;
%             VSSpeed;
%       REMOVEDL      VerShiftVoltage; - I think this is still the VSAmplitude...
%             FrameTransferMode;
%             EMCCD;

            % build capabilities structure
            [obj.LastError, Caps.ulSize, Caps.ulAcqModes, Caps.ulReadModes, Caps.ulTriggerModes, ...
                Caps.ulCameraType, Caps.ulPixelMode, Caps.ulSetFunctions, Caps.ulGetFunctions, ...
                Caps.ulFeatures, Caps.ulPCICard, Caps.ulEMGainCapability]=GetCapabilities;
            
            % set capabilities structure
            obj.Capabilities = Caps;
            clear Caps; %otherwise library unload is blocked
            obj.errorcheck('GetCapabilities');
            
            % Determine Capability Structure and Array sizes
            [obj.LastError,NumChannels] = GetNumberADChannels;
            obj.errorcheck('GetNumberADChannels');
            [obj.LastError,NumAmps] = GetNumberAmp;
            obj.errorcheck('GetNumberAmp');
            [obj.LastError,NumPreAmpGains] = GetNumberPreAmpGains;
            obj.errorcheck('GetNumberPreAmpGains');
            
            if bitget(obj.Capabilities.ulSetFunctions, obj.ErrorCode.AC_SETFUNCTION_VSAMPLITUDE)
                [obj.LastError,NumVSAmplitudes] = GetNumberVSAmplitudes;
                obj.errorcheck('GetNumberVSAmplitudes');
            else
                NumVSAmplitudes = 1; % Luca
            end
            [obj.LastError,NumVSSpeeds] = GetNumberVSSpeeds;
            obj.errorcheck('GetNumberVSSpeeds');
            
            % Allocate Memory for capability properties
            generic = struct('Desc',[],'Bit',[]);
            
            PreAmpGain = generic;
            VSSpeed = generic;
            ADChannel = generic;
            NumberHSSpeeds = zeros(NumChannels,NumAmps);
            HSSpeed(NumChannels,NumAmps) = generic;
            Amp = struct('Desc',[],'MaxSpeed',[],'Bit',[]);
            VSAmplitude = generic;
            BaselineClamp = generic;
            Cooler = generic;
            Fan = generic;
            FrameTransferMode = generic;
            EMCCD = struct('Value',[],'Desc',[],'Range',[]);
            Shutter = struct('typ',[],'mode',[],'closingtime',[],'openingtime',[],'DescTyp',[],'DescMode',[]);
            
            %% start generating camera parameters
            
            % get Pre Amp Gains
            for ii=1:NumPreAmpGains
                [obj.LastError,PreAmpGain.Desc{ii}] = GetPreAmpGain(ii-1);
                PreAmpGain.Desc{ii} = [num2str(PreAmpGain.Desc{ii}) ' gain factor'];
                PreAmpGain.Bit(ii) = ii-1;
                obj.errorcheck('GetPreAmpGain');
            end
            obj.CameraCap.PreAmpGain = PreAmpGain;
            obj.CameraCap.PreAmpGain.uiType = 'select';
            
            % default camera preAmpGain
            obj.CameraSetting.PreAmpGain.Ind = 1;
            obj.CameraSetting.PreAmpGain.Bit = PreAmpGain.Bit(1);
            obj.CameraSetting.PreAmpGain.Desc = PreAmpGain.Desc{1};
            
            % get the vertical shift speed options
            for ii=1:NumVSSpeeds
                [obj.LastError, VSSpeed.Desc{ii}] = GetVSSpeed(ii-1);
                VSSpeed.Desc{ii} = [num2str(VSSpeed.Desc{ii}) ' microseconds per pixel shift'];
                VSSpeed.Bit(ii) = ii-1;
                obj.errorcheck('GetVSSpeed');
            end
            obj.CameraCap.VSSpeed = VSSpeed;
            obj.CameraCap.VSSpeed.uiType = 'select';
            
            [obj.LastError,RecommendedVSIndex,RecommendedVSSpeed] = GetFastestRecommendedVSSpeed;
            obj.errorcheck('GetFastestRecommendedVSSpeed');
            
            %default camera VSSpeed
            obj.CameraSetting.VSSpeed.Ind = RecommendedVSIndex + 1;
            obj.CameraSetting.VSSpeed.Bit = VSSpeed.Bit(RecommendedVSIndex + 1);
            obj.CameraSetting.VSSpeed.Desc = VSSpeed.Desc{RecommendedVSIndex + 1};
            
            % set VSAmplitude
            % five states, 0, 1, 2, 3, 4, +state*Volt
            % needs to change for the LUCA camera....
            for ii = 1:NumVSAmplitudes
                VSAmplitude.Bit(ii) = ii-1;
                VSAmplitude.Desc{ii} = ['+' num2str(ii-1) ' Volts'];
            end
            
            VSAmplitude.Recommended.Bit = RecommendedVSIndex;
            VSAmplitude.Recommended.Desc = [num2str(RecommendedVSSpeed) ' microseconds per pixel shift'];
             if bitget(obj.Capabilities.ulSetFunctions, obj.ErrorCode.AC_SETFUNCTION_VSAMPLITUDE)
                obj.CameraCap.VSAmplitude = VSAmplitude;
                obj.CameraCap.VSAmplitude.uiType = 'select';
            
                % default camera VSAmplitudes
                obj.CameraSetting.VSAmplitude.Ind = 1;
                obj.CameraSetting.VSAmplitude.Bit = VSAmplitude.Bit(1);
                obj.CameraSetting.VSAmplitude.Desc = VSAmplitude.Desc{1};
             end
             
            % info on amps            
            for ii=1:NumAmps
                % are we missing something here?
                NumInd = ii-1;

                [obj.LastError,temp_desc] = GetAmpDesc(NumInd,21);

                obj.errorcheck('GetAmpDesc');
                if obj.LastError == obj.ErrorCode.DRV_SUCCESS
                    Amp.Desc{ii} = num2str(temp_desc);
                end
                [obj.LastError,Amp.MaxSpeed(ii)] = GetAmpMaxSpeed(ii-1);
                Amp.Bit(ii) = NumInd;

                obj.errorcheck('GetAmpMaxSpeed');
            end
            obj.CameraCap.Amp = Amp;
            obj.CameraCap.Amp.uiType = 'select';
            
            % default camera amp
            AmpInd = 1; % EM amplifier
            obj.CameraSetting.Amp.Ind = AmpInd; 
            obj.CameraSetting.Amp.Bit = Amp.Bit(AmpInd);
            obj.CameraSetting.Amp.Desc = Amp.Desc{AmpInd};

            %  info on ADChanels
            for ii = 1:NumChannels
                [obj.LastError,ADChannel.Desc{ii}] = GetBitDepth(ii-1);
                ADChannel.Desc{ii} = [num2str(ADChannel.Desc{ii}) ' bits for dynamic range'];
                ADChannel.Bit(ii) = ii-1;
                obj.errorcheck('GetBitDepth');
                for jj=1:NumAmps
                    [obj.LastError,NumberHSSpeeds(ii,jj)] = GetNumberHSSpeeds(ii-1,jj-1);
                     obj.errorcheck('GetNumberHSSpeeds');
                    for kk=1:NumberHSSpeeds(ii,jj)
                        [obj.LastError,tmpHSSpeedMHz] = GetHSSpeed(ii-1,jj-1,kk-1);
                        % speed in MHz
                        HSSpeed(ii,jj).Desc{kk} = [num2str(1/tmpHSSpeedMHz) ' microseconds per pixel shift'];
                        HSSpeed(ii,jj).Bit(kk) = kk-1;
                        obj.errorcheck('GetHSSpeed');
                    end
                end
            end
            obj.CameraCap.ADChannel = ADChannel;
            obj.CameraCap.ADChannel.uiType = 'select';

            % default camera ADChannel
            ADCInd = 1;
            obj.CameraSetting.ADChannel.Ind = ADCInd;
            obj.CameraSetting.ADChannel.Bit = ADChannel.Bit(ADCInd);
            obj.CameraSetting.ADChannel.Desc = ADChannel.Desc{ADCInd};
            
            obj.CameraCap.HSSpeed = HSSpeed;
%             assignin('base','HSSpeed',obj.CameraCap.HSSpeed);
            % HSSpeed might be an array
            for ii = 1:NumChannels
                for jj=1:NumAmps
                    obj.CameraCap.HSSpeed(ii,jj).uiType = 'select';
                end
            end
            % default camera HSSpeed
            obj.CameraSetting.HSSpeed.ADCInd = ADCInd;
            obj.CameraSetting.HSSpeed.AmpInd = AmpInd;
            obj.CameraSetting.HSSpeed.Ind = 1;
            obj.CameraSetting.HSSpeed.Bit = HSSpeed(ADCInd,AmpInd).Bit(1);
            obj.CameraSetting.HSSpeed.Desc = HSSpeed(ADCInd,AmpInd).Desc{1};
            
            % set up BaseLineClamp and Shutter
            if bitget(obj.Capabilities.ulSetFunctions, obj.ErrorCode.AC_SETFUNCTION_BASELINECLAMP)            
                % can be set to 1 or 0, the baseline clamp.
                BaselineClamp.Bit = [0 1];
                BaselineClamp.Desc = {'Baseline Clamp Disabled', 'Baseline Clamp Enabled'};
                obj.CameraCap.BaselineClamp = BaselineClamp;
                obj.CameraCap.BaselineClamp.uiType = 'binary';
                
                % needs to add baselineClampOffset
                
                % default BaselineClamp
                obj.CameraSetting.BaselineClamp.Ind = 1;
                obj.CameraSetting.BaselineClamp.Bit = BaselineClamp.Bit(1);
                obj.CameraSetting.BaselineClamp.Desc = BaselineClamp.Desc{1};
            end
 
            % Shutter is NOT in CameraSetting struct yet...
            if bitget(obj.Capabilities.ulSetFunctions, obj.ErrorCode.AC_FEATURES_SHUTTER)
                %Shutter
                % typ has 0 1; 0 = low TTL; 1 = high TTL
                % mode has 0 1 2; 0 = auto; 1 = open; 2 = close
                Shutter.typ = [0 1];
                Shutter.mode = [0 1 2];
                Shutter.DescTyp = {'low TTL','high TTL'};
                Shutter.DescMode = {'Auto','Open','Close'};
                Shutter.closingtime = 0; %ms
                Shutter.openingtime = 0; %ms
                obj.CameraCap.Shutter = Shutter;
                obj.CameraCap.Shutter.uiType = 'unknown';
                % set the camera manual setting
                obj.CameraCap.ManualShutter.Desc = {'Auto','Manual'};
                obj.CameraCap.ManualShutter.Bit = [0 1];
                obj.CameraCap.ManualShutter.uiType = 'binary';
                obj.CameraSetting.ManualShutter.Bit = 0;
                obj.CameraSetting.ManualShutter.Ind = 1;
                
            else
                % no Shutter control on luca, but leave things here for
                % compability
                
                % typ has 0 1; 0 = low TTL; 1 = high TTL
                % mode has 0 1 2; 0 = auto; 1 = open; 2 = close
                Shutter.typ = [0 1];
                Shutter.mode = [0 1 2];
                Shutter.DescTyp = {'low TTL','high TTL'};
                Shutter.DescMode = {'Auto','Open','Close'};
                Shutter.closingtime = 0; %ms
                Shutter.openingtime = 0; %ms
                obj.CameraCap.Shutter = Shutter;
                obj.CameraCap.Shutter.uiType = 'unknown';
            end
            
            %Cooler;
            % cooler is either 1 or 0 if its not a luca
            %set cooler to warm to ambient on shutdown
            %do not try on a luca R type -did I write this?
            
            if obj.Capabilities.ulCameraType ~= 11 % not luca
                Cooler.Bit = [0 1];
                Cooler.Desc = {'Cooler is Off on Andor ShutDown', 'Cooler Always Remains On'};
                obj.CameraCap.Cooler = Cooler;
                obj.CameraCap.Cooler.uiType = 'binary';
                
                % default camera Cooler
                obj.CameraSetting.Cooler.Ind = 1;
                obj.CameraSetting.Cooler.Bit = Cooler.Bit(1);
                obj.CameraSetting.Cooler.Desc = Cooler.Desc{1};
            end
            
            %Fan;
            % fan mode: full(0), low(1), off(2)
            %make sure the fan is on
            if bitget(obj.Capabilities.ulFeatures, obj.ErrorCode.AC_FEATURES_FANCONTROL)
                if bitget(obj.Capabilities.ulFeatures, obj.ErrorCode.AC_FEATURES_MIDFANCONTROL)
                    Fan.Bit = [0 1 2];
                    Fan.Desc = {'fan on full', 'fan on low', 'fan off'};
                else
                    % no mid fan level, Luca
                    Fan.Bit = [0 2];
                    Fan.Desc = {'fan on full', 'fan off'};
                end
                obj.CameraCap.Fan = Fan;
                obj.CameraCap.Fan.uiType = 'select';
                
                % default camera Fan
                obj.CameraSetting.Fan.Ind = 1;
                obj.CameraSetting.Fan.Bit = Fan.Bit(1);
                obj.CameraSetting.Fan.Desc = Fan.Desc{1};

            end
            
            % FrameTransferMode
            FrameTransferMode.Bit = [0 1];
            FrameTransferMode.Desc = {'Frame Transfer Mode Off' 'Frame Transfer Mode On'};
            obj.CameraCap.FrameTransferMode = FrameTransferMode;
            obj.CameraCap.FrameTransferMode.uiType = 'binary';
            
            % default camera FrameTransferMode
            obj.CameraSetting.FrameTransferMode.Ind = 1;
            obj.CameraSetting.FrameTransferMode.Bit = FrameTransferMode.Bit(1);
            obj.CameraSetting.FrameTransferMode.Desc = FrameTransferMode.Desc{1};

            
            %EMCCDGain;
            [obj.LastError, EMrange(1), EMrange(2)] = GetEMGainRange;
            EMCCD.Range = EMrange;
            EMCCD.Value = 2;
            EMCCD.Desc = 'EM Gain';
            obj.CameraCap.EMGain.Range = EMCCD.Range;
            obj.CameraCap.EMGain.Desc = EMCCD.Desc;
            obj.CameraCap.EMGain.uiType = 'input';

            % default EMGain
            obj.CameraSetting.EMGain = EMCCD;            
            %SetEMCCDGain(int gain)
            
            %Trigger;
            % Trigger mode values:
            % 0 = internal; 1 = external; 6 = external start; 7 = external
            % exposure (bulb); 9 = External FVB EM; 10 = software trigger;
            % 12 = external charge shifting.
            % need to redo to set the current
            Trigger.Bit = [0 1 6 7 9 10 12];
            Trigger.Desc = {'Internal','External','External Start','External Exposure(bulb)',...
                'External FVB EM','software trigger','external charge shifting'};

            obj.CameraCap.Trigger = Trigger;
            obj.CameraCap.Trigger.uiType = 'select';
            
            % default camera trigger
            obj.CameraSetting.Trigger.Ind = 1;
            obj.CameraSetting.Trigger.Bit = Trigger.Bit(1);
            obj.CameraSetting.Trigger.Desc = Trigger.Desc{1};
            
            % initialize current selection of parameters
            GuiCurSel = MIC_AndorCamera.camSet2GuiSel(obj.CameraSetting);
            % build GuiDialog
            obj.build_guiDialog(GuiCurSel);
        
        end
              
        % function name is confusing, consider changing?
        function obj=get_properties(obj)
            obj.setcurrentcamera;
            [obj.LastError,obj.XPixels,obj.YPixels] = GetDetector;
            obj.errorcheck('GetDetector')
            [obj.LastError,obj.Model]=GetHeadModel;
        end
        
        % function name is confusing, consider changing?
        function obj=get_parameters(obj)
            obj.setcurrentcamera;
           [obj.LastError,obj.CameraParameters.ExposureTime,...
               obj.CameraParameters.AccumulationTime,obj.SequenceCycleTime] = GetAcquisitionTimings();
        end
        
        function [temp, status]=gettemperature(obj)
            %output status
                %0: temp not available
                %1: temp has stabilized
                %2: temp not stabilized 
                %3: temp drifted after stabilzation
            obj.setcurrentcamera;
            [tmpstatus, temp]=GetTemperature;
            switch tmpstatus
                case obj.ErrorCode.DRV_ACQUIRING
                    status=0;  
                case obj.ErrorCode.DRV_TEMP_STABILIZED
                    status=1;
                case obj.ErrorCode.DRV_TEMP_NOT_REACHED
                    status=2;
                case obj.ErrorCode.DRV_TEMP_DRIFT
                    status=3;
                case obj.ErrorCode.DRV_TEMP_NOT_STABILIZED
                    status=2;
                otherwise
                    obj.LastError=tmpstatus;
                    obj.errorcheck('GetTemperature')
            end   
        end
        
        function setcurrentcamera(obj)
            obj.LastError=SetCurrentCamera(obj.CameraHandle);
            obj.errorcheck('SetCurrentCamera')
        end
        
    end
    
    methods (Static)
        
        function Success=unitTest()
            Success=0;
            %Create object
            try 
                A=MIC_AndorCamera();
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
