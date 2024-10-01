function setCamProperties(obj,CamSetting)
%SETCAMERAPROPERTIES Summary of this function goes here
%   in: a duplicate CameraSetting structure to be checked and set
% this function sets the camera properties on the camera so that what you
% select on the gui is committed to the API

obj.ReadyForAcq=0;
%obj.CameraParameters=in;

% ADChannel;
% Amp;
% BaselineClamp;
% Cooler;
% Fan;
% HSSpeed;
% PreAmpGain;
% Shutter;
% Trigger;
% VSAmplitudes;
% VSSpeed;
% VerShiftVoltage;

setCamSDK(obj,CamSetting);
obj.get_parameters;
obj.ReadyForAcq=1;

end

function setCamSDK(obj,CamSetting)
% sub function to set the property given the input field, works on case by case basis!
% all of these are copied and pasted from other legacy code so variables
% will have to be renamed shortly!
camFields = fields(CamSetting);
debug = false;
for ii=1:length(camFields)
    switch (camFields{ii})
        case 'ManualShutter'
            obj.CameraSetting.ManualShutter.Bit = CamSetting.ManualShutter.Bit;
            
        case 'EMGain'
            obj.LastError = SetEMCCDGain(CamSetting.EMGain.Value);
            obj.errorcheck('SetEMCCDGain');
            obj.CameraSetting.EMGain.Value=CamSetting.EMGain.Value;
            if debug
                % check low level behavior
                [obj.LastError,EMGainVal] = GetEMCCDGain;
                disp(['Check EMGain: set ', num2str(CamSetting.EMGain.Value),' , get ' num2str(EMGainVal)]);
            end
        case 'ADChannel'
            obj.LastError = SetADChannel(CamSetting.ADChannel.Bit);
            obj.errorcheck('SetADChannel');
            obj.CameraSetting.ADChannel.Bit=CamSetting.ADChannel.Bit;
            if debug
                % check low level behavior
                disp(['Check ADChannel: set ', CamSetting.ADChannel.Desc]);
            end
        case 'Amp'
            obj.LastError = SetOutputAmplifier(CamSetting.Amp.Bit);
            obj.errorcheck('SetOutputAmplifier');
            obj.CameraSetting.Amp.Bit=CamSetting.Amp.Bit;
            if debug
                % check low level behavior
                disp(['Check Amp: set ', CamSetting.Amp.Desc]);
            end
        case 'HSSpeed'
            AmpBit = CamSetting.Amp.Bit;
            obj.LastError = SetHSSpeed(AmpBit,CamSetting.HSSpeed.Bit);
            obj.errorcheck('SetHSSpeed');
            obj.CameraSetting.HSSpeed.Bit=CamSetting.HSSpeed.Bit;
            if debug
                % check low level behavior
                disp(['Check HSSpeed: set ', CamSetting.HSSpeed.Desc]);
            end
        case 'BaselineClamp'
            obj.LastError = SetBaselineClamp(CamSetting.BaselineClamp.Bit);
            obj.errorcheck('SetBaselineClamp');
            obj.CameraSetting.BaselineClamp.Bit=CamSetting.BaselineClamp.Bit;
            if debug
                % check low level behavior
            disp(['Check BaselineClamp: set ', CamSetting.BaselineClamp.Desc]);
            end
        case 'Cooler'
            obj.LastError = SetCoolerMode(CamSetting.Cooler.Bit);
            obj.errorcheck('SetCoolerMode');
            obj.CameraSetting.Cooler.Bit=CamSetting.Cooler.Bit;
        case 'Fan'
            obj.LastError = SetFanMode(CamSetting.Fan.Bit);
            obj.errorcheck('SetFanMode');
            obj.CameraSetting.Fan.Bit=CamSetting.Fan.Bit;
        case 'PreAmpGain'
            obj.LastError = SetPreAmpGain(CamSetting.PreAmpGain.Bit);
            obj.errorcheck('SetPreAmpGain');
            obj.CameraSetting.PreAmpGain.Bit=CamSetting.PreAmpGain.Bit;
        case 'Shutter'
%             obj.LastError = SetShutter(value.typ{1},value.mode{1},...
%                 value.closingtime,value.openingtime);
%             obj.errorcheck('SetShutter'); 
            % Set Shutter to Auto (1) or Manual (0)
            obj.CameraSetting.ManualShutter.Bit = CamSetting.ManualShutter.Bit;
        case 'Trigger'
            obj.LastError=SetTriggerMode(CamSetting.Trigger.Bit); %   Set trigger mode; 0 for Internal
            obj.errorcheck('SetTriggerMode');
            obj.CameraSetting.Trigger.Bit=CamSetting.Trigger.Bit;
            if debug
                % check low level behavior
                disp(['Check Trigger: set ', CamSetting.Trigger.Desc]);
            end
        case 'VSAmplitude' % this is the vertical shift voltage!
            obj.LastError = SetVSAmplitude(CamSetting.VSAmplitude.Bit);
            obj.errorcheck('SetVSAmplitude');
            obj.CameraSetting.VSAmplitude.Bit=CamSetting.VSAmplitude.Bit;
            if debug
                % check low level behavior
                disp(['Check VSAmplitude: set ', CamSetting.VSAmplitude.Desc]);
            end
        case 'VSSpeed'
            obj.LastError = SetVSSpeed(CamSetting.VSSpeed.Bit);
            obj.errorcheck('SetVSSpeed');
            obj.CameraSetting.VSSpeed.Bit=CamSetting.VSSpeed.Bit;
            if debug
                % check low level behavior
                disp(['Check VSSpeed: set ', CamSetting.VSSpeed.Desc]);
            end
        case 'FrameTransferMode'
            obj.LastError = SetFrameTransferMode(CamSetting.FrameTransferMode.Bit);
            obj.errorcheck('SetFrameTransferMode');
            obj.CameraSetting.FrameTransferMode.Bit=CamSetting.FrameTransferMode.Bit;
    end
end
        
end

