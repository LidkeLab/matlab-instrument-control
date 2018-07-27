function errorcheck(obj,fname,successflag)
%             if nargin ~= 2
%                 error('AndorCamera:WrongNumberOfInputs','errorcheck requires the function name and return code');
%             end

% don't display successes unless explicitly stated.
if nargin < 3
    successflag = 0;
end

switch obj.LastError
    case obj.ErrorCode.DRV_SUCCESS
        switch fname
            case 'AndorInitialize'
                successmsg = ('Andor Initialized.');
            case 'AbortAcquisition'
                successmsg = ('Acquisition aborted.');
            case 'CoolerOFF'
                successmsg = ('Temperature controller switched OFF.');
            case 'CoolerON'
                successmsg = ('Temperature controller switched ON.');
            case 'GetAmpDesc'
                successmsg = ('Description returned.');
            case 'GetAmpMaxSpeed'
                successmsg = ('Speed returned.');
            case 'GetAvailableCameras'
                successmsg = ('Number of available cameras returned.');
            case 'GetBitDepth'
                successmsg = ('Depth returned.');
            case 'GetCameraHandle'
                successmsg = ('Camera handle returned.');
            case 'GetCameraSerialNumber'
                successmsg = ('Serial Number returned.');
            case 'GetCapabilities'
                successmsg = ('Capabilities returned.');
            case 'GetControllerCardModel'
                successmsg = ('Name returned.');
            case 'GetDetector'
                successmsg = ('Detector size returned.');
            case 'GetFastestRecommendedVSSpeed'
                successmsg = ([fname ' Speed returned.']);
            case 'GetHeadModel'
                successmsg = ([fname ' Name returned.']);
            case 'GetHSSpeed'
                successmsg = ('HS Speed returned.');
            case 'GetMaximumExposure'
                successmsg = ('Maximum Exposure returned.');
            case 'GetNumberADChannels'
                successmsg = ('Number of channels returned.');
            case 'GetNumberAmp'
                successmsg = ('Number of output amplifiers returned.');
            case 'GetNumberPreAmpGains'
                successmsg = ('Number of pre amp gains returned.');
            case 'GetNumberVSAmplitudes'
                successmsg = ([fname ' Number returned']);
            case 'GetNumberVSSpeeds'
                successmsg = ('Number of speeds returned.');
            case 'GetPixelSize'
                successmsg = ('Pixel size returned.');
            case 'GetPreAmpGain'
                successmsg = ([fname ' Gain returned.']);
            case 'GetStatus'
                successmsg = ('Status returned.');
            case 'GetVSSpeed'
                successmsg = ('VS Speed returned.');
            case 'IsPreAmpGainAvailable'
                successmsg = ('PreAmpGain status returned.');
            case 'SetAcquisitionMode'
                successmsg = ('Acquisition mode set.');
            case 'SetBaselineClamp'
                successmsg = ('Baseline Clamp Parameters set.');
            case 'SetCoolerMode'
                successmsg = ('CoolerMode Parameters set.');
            case 'SetCurrentCamera'
                successmsg = ('Camera successfully selected.');
            case 'SetEMGainMode'
                successmsg = ('Mode set.');
            case 'SetFanMode'
                successmsg = ([fname ' Value for mode accepted.']);
            case 'SetImage'
                successmsg = ([fname ' All parameters accepted.']);
            case 'SetKineticCycleTime'
                successmsg = ('Cycle time accepted.');
            case 'SetReadMode'
                successmsg = ('Readout mode set.');
            case 'SetShutter'
                successmsg = ('Shutter set.');
            case 'SetTemperature'
                successmsg = ('Temperature set.');
            case 'SetTriggerMode'
                successmsg = ('Trigger mode set.');
            case 'Shutdown'
                successmsg = ('Camera System shut down.');
            case 'StartAcquisiton'
                successmsg = ('Acquisition started.');
            case 'WaitForAcquisition'
                successmsg =  ('Acquisition Event occurred');
            case 'WaitForAcquisitionByHandle'
                successmsg =  ('Acquisition Event occurred');
            case 'WaitForAcquisitionByHandleTimeOut'
                successmsg =  ('Acquisition Event occurred');
            otherwise
                successmsg = ([fname ' Unknown success']);
        end
        
        if successflag
            disp(successmsg);
        end
    case obj.ErrorCode.DRV_ACQUISITION_ERRORS
        error([fname ' error: Acquisition settings invalid.']);
    case obj.ErrorCode.DRV_ACQUIRING
        error([fname ' error: Acquisition in progress.']);
    case obj.ErrorCode.DRV_BINNING_ERROR
        error([fname ' error: Range not multiple of horizontal binning.']);
    case obj.ErrorCode.DRV_ERROR_ACK
        error([fname ' error: Unable to communicate with card.']);
    case obj.ErrorCode.DRV_ERROR_PAGELOCK
        error([fname ' error: Unable to allocate memory.']);
    case obj.ErrorCode.DRV_IDLE
        %warning('AndorCamera:DRV_IDLE',[fname ' warning: The system is not currently acquiring.']);
    case obj.ErrorCode.DRV_INIERROR
        error([fname ' error: Error reading “DETECTOR.INI”.']);
    case obj.ErrorCode.DRV_INVALID_FILTER
        error([fname ' error: Filter not available for current acquisition.']);
    case obj.ErrorCode.DRV_I2CTIMEOUT
        error([fname ' error: I2C command timed out.']);
    case obj.ErrorCode.DRV_I2CDEVNOTFOUND
        error([fname ' error: I2C device not present.']);
    case obj.ErrorCode.DRV_NO_NEW_DATA
        error([fname ' error: Non-Acquisition Event occurred.']);
    case obj.ErrorCode.DRV_NOT_AVAILABLE
        error([fname ' error: Your system does not support this feature']);
    case obj.ErrorCode.DRV_NOT_INITIALIZED
        error([fname ' error: System not initialized.']);
    case obj.ErrorCode.DRV_NOT_SUPPORTED
        switch fname
            case 'CoolerOFF'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: Camera does not support switching cooler off.']);
            case 'GetNumberVSAmplitudes'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: Your system does not support this feature']);
            case 'SetBaselineClamp'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: Baseline Clamp not available for this camera']);
            case 'SetCoolerMode'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: Camera does not support cooling.']);
            case 'SetTemperature'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: The camera does not support setting the temperature.']);
            case 'SetShutter'
                warning('AndorCamera:DRV_NOT_SUPPORTED',[fname ' warning: The camera does not support setting the shutter.']);
            otherwise
                disp([fname ' Unknown not supported']);
        end
    case obj.ErrorCode.DRV_P1INVALID
        switch fname
            case 'GetAmpDesc'
                error('AndorCamera:DRV_P1INVALID','GetAmpDesc (int index , char* name, int len) error: The amplifier index is not valid.');
            case 'GetAmpMaxSpeed'
                error('AndorCamera:DRV_P1INVALID','GetAmpMaxSpeed (int index , float* speed) error: The amplifier index is not valid');
            case 'GetBitDepth'
                error('AndorCamera:DRV_P1INVALID','GetBitDepth(int channel, int* depth) error: Invalid channel');
            case 'GetCapabilities'
                error('AndorCamera:DRV_P1INVALID','GetCapabilities(AndorCapabilities* caps) error: Invalid caps parameter (i.e. NULL).');
            case 'GetHSSpeed'
                error('AndorCamera:DRV_P1INVALID','GetHSSpeed(int channel, int typ, int index, float* speed) error: Invalid channel.');
            case 'GetMaximumExposure'
                error('AndorCamera:DRV_P1INVALID','GetMaximumExposure (float* MaxExp) error: Invalid MaxExp value (i.e. NULL)');
            case 'GetMinimumImageLength'
                error('AndorCamera:DRV_P1INVALID','GetMinimumImageLength (int* MinImageLength) error: Invalid MinImageLength value (i.e. NULL)');
            case 'GetVSSpeed'
                error('AndorCamera:DRV_P1INVALID','GetVSSpeed(int index, float* speed) error: Invalid index.');
            case 'Gain returned'
                error('AndorCamera:DRV_P1INVALID','GetPreAmpGain(int index, float* gain) error: Invalid index.');
            case 'IsPreAmpGainAvailable'
                error('AndorCamera:DRV_P1INVALID','IsPreAmpGainAvailable(int channel, int amplifier, int index, int pa, int* status) error: Invalid channel.');
            case 'SetAcquisitionMode'
                error('AndorCamera:DRV_P1INVALID','SetAcquisitionMode(int mode) error: Acquisition Mode invalid.');
            case 'SetBaselineClamp'
                error('AndorCamera:DRV_P1INVALID','SetBaselineClamp(int state) error: State parameter was not zero or one.');
            case 'SetCurrentCamera'
                error('AndorCamera:DRV_P1INVALID','SetCurrentCamera(long cameraHandle) error: Invalid camera handle.');
            case 'SetCoolerMode'
                error('AndorCamera:DRV_P1INVALID','SetCoolerMode(int mode) error: State parameter was not zero or one.');
            case 'SetFanMode'
                error('AndorCamera:DRV_P1INVALID','SetFanMode(int mode) error: Mode value invalid.');
            case 'SetImage'
                error('AndorCamera:DRV_P1INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Binning parameters invalid.');
            case 'SetKineticCycleTime'
                error('AndorCamera:DRV_P1INVALID','SetKineticCycleTime(float time) error: Time invalid.');
            case 'SetReadMode'
                error('AndorCamera:DRV_P1INVALID','SetReadMode(int mode) error: Invalid readout mode passed.');
            case 'SetShutter'
                error('AndorCamera:DRV_P1INVALID','SetShutter(int typ, int mode, int closingtime, int openingtime) error: Invalid TTL type.');
            case 'SetTemperature'
                error('AndorCamera:DRV_P1INVALID','SetTemperature(int temperature) error: Temperature invalid.');
            case 'SetTriggerMode'
                error('AndorCamera:DRV_P1INVALID','SetTriggerMode(int mode) error: Trigger mode invalid.');
            case 'WaitForAcquisitionByHandle'
                error('AndorCamera:DRV_P1INVALID','WaitForAcquisitionByHandle(long cameraHandle) error: Handle not valid.');
            case 'WaitForAcquisitionByHandleTimeOut'
                error('AndorCamera:DRV_P1INVALID','WaitForAcquisitionByHandleTimeOut(long cameraHandle, int iTimeOutMs) error: Handle not valid.');
            otherwise
                disp([fname ' Unknown P1INVALID']);
        end
    case obj.ErrorCode.DRV_P2INVALID
        switch fname
            case 'GetAmpDesc'
                error('AndorCamera:DRV_P2INVALID','GetAmpDesc (int index , char* name, int len) error: The desc pointer is null.');
            case 'GetHSSpeed'
                error('AndorCamera:DRV_P2INVALID','GetHSSpeed(int channel, int typ, int index, float* speed) error: Invalid horizontal read mode.');
            case 'IsPreAmpGainAvailable'
                error('AndorCamera:DRV_P2INVALID','IsPreAmpGainAvailable(int channel, int amplifier, int index, int pa, int* status) error: Invalid amplifier.');
            case 'SetImage'
                error('AndorCamera:DRV_P2INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Binning parameters invalid.');
            case 'SetShutter'
                error('AndorCamera:DRV_P2INVALID','SetShutter(int typ, int mode, int closingtime, int openingtime) error: Invalid mode.');
            case 'WaitForAcquisitionByHandleTimeOut'
                error('AndorCamera:DRV_P2INVALID','WaitForAcquisitionByHandleTimeOut (long cameraHandle, int iTimeOutMs) error: invalid time');
            otherwise
                disp([fname ' Unknown P2INVALID']);
        end
    case obj.ErrorCode.DRV_P3INVALID
        switch fname
            case 'GetAmpDesc'
                error('AndorCamera:DRV_P3INVALID','GetAmpDesc (int index , char* name, int len) error: The len parameter is invalid (less than 1)');
            case 'GetHSSpeed'
                error('AndorCamera:DRV_P3INVALID','GetHSSpeed(int channel, int typ, int index, float* speed) error: Invalid index.');
            case 'IsPreAmpGainAvailable'
                error('AndorCamera:DRV_P3INVALID','IsPreAmpGainAvailable(int channel, int amplifier, int index, int pa, int* status) error: Invalid speed index.');
            case 'SetImage'
                error('AndorCamera:DRV_P3INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Sub-area co-ordinate is invalid.');
            case 'SetShutter'
                error('AndorCamera:DRV_P3INVALID','SetShutter(int typ, int mode, int closingtime, int openingtime) error: Invalid time to close.');
            otherwise
                disp([fname ' Unknown P3INVALID']);
        end
    case obj.ErrorCode.DRV_P4INVALID
        switch fname
            case 'IsPreAmpGainAvailable'
                error('AndorCamera:DRV_P4INVALID','IsPreAmpGainAvailable(int channel, int amplifier, int index, int pa, int* status) error: Invalid gain.');
            case 'SetImage'
                error('AndorCamera:DRV_P4INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Sub-area co-ordinate is invalid.');
            case 'SetShutter'
                error('AndorCamera:DRV_P4INVALID','SetShutter(int typ, int mode, int closingtime, int openingtime) error: Invalid time to open.');
            otherwise
                disp([fname ' Unknown P4INVALID']);
        end
    case obj.ErrorCode.DRV_P5INVALID
        switch fname
            case 'SetImage'
                error('AndorCamera:DRV_P5INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Sub-area co-ordinate is invalid.');
            otherwise
                disp([fname ' Unknown P5INVALID']);
        end
    case obj.ErrorCode.DRV_P6INVALID
        switch fname
            case 'SetImage'
                error('AndorCamera:DRV_P6INVALID','SetImage(int hbin, int vbin, int hstart, int hend, int vstart, int vend) error: Sub-area co-ordinate is invalid.');
            otherwise
                disp([fname ' Unknown P6INVALID']);
        end
    case obj.ErrorCode.DRV_TEMP_OFF
        error('AndorCamera:DRV_TEMP_OFF',[fname ' error: Temperature is OFF.']);
    case obj.ErrorCode.DRV_TEMP_STABILIZED
        disp('Temperature has stabilized at set point.');
    case AndorCamera.DRV_TEMP_NOT_REACHED
        disp('Temperature has not reached set point.');
    case obj.ErrorCode.DRV_TEMP_DRIFT
        warning('AndorCamera:DRV_TEMP_DRIFT',[fname ' warning: Temperature had stabilized but has since drifted.']);
    case obj.ErrorCode.DRV_TEMP_NOT_STABILIZED
        disp('Temperature reached but not stabilized');
    case obj.ErrorCode.DRV_VXDNOTINSTALLED
        error('AndorCamera:DRV_VXDNOTINSTALLED',[fname ' error: VxD not loaded.']);
    otherwise
        error('AndorCamera:Unknown',[fname 'Unknown error code' code]);
end
end