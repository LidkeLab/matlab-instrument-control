%This is how to use the new version of Reg3DTrans which is called Reg3DTransNew

%define the class: (on SPT microscope)
Cam=MIC_AndorCamera;
Stage=MIC_MCLNanoDrive();
lamp=MIC_IX71Lamp('Dev1','ao0','Port0/Line0');
R3=MIC_Reg3DTransNew(Cam,Stage);

%R3.calibrate() 
%set the Andor Camera
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.calibrate;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;

%R3.takerefimage
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.takerefimage;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;

%R3.getcurrentimage
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.getcurrentimage;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;
 
%R3.align2imageFit
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.align2imageFit;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;

%R3.collect_zstack
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.collect_zstack;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;

%R3.capture_single
CamSet = R3.CameraObj.CameraSetting; %take the saved setting
CamSet.ManualShutter.Bit=1; %set the mannualShutter be one
EMGTemp = CamSet.EMGain.Value;
CamSet.EMGain.Value = 2; % from TIRF_SRCollect & SPTCollect class
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(1);
%set the lamp
LampPower=50;
if isempty(lamp.Power) || lamp.Power==0
    lamp.setPower(LampPower);
end 
lamp.on;
R3.capture_single;
% change back camera setting to the values before using the R3DTrans class
CamSet.EMGain.Value = EMGTemp; 
CamSet.ManualShutter.Bit=0; %set the mannualShutter be one
R3.CameraObj.setCamProperties(CamSet); %set the camera properties 
R3.CameraObj.setShutter(0);
lamp.off;
