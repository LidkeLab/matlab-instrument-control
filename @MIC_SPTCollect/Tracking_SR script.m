%Script for tracking and SR

SPT.Lamp850Obj.setPower(10);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=110;
SPT.IRCameraObj.start_sequence;
WashwithHANKS=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(10);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
FullImageROI_bfTracking=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(15);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
FullImageROI_afTracking=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(15);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=120;
SPT.IRCameraObj.start_sequence;
AddS2PFA2percent=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(90);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
ImageROIafterFixation128=SPT.IRCameraObj.Data;



save('Y:\Hanieh\Tracking_SR (Fall 2017)\17-12-05\Sample6','WashwithHANKS',...
    '', 'FullImageROI_afTracking','FullImageROI_bfTracking', ...
    'AddS2PFA2percent','ImageROIafterFixation350','ImageROIafterFixation128','',...
    '','ImageROIafterFixation256','ImageROIafterFixation')

clear FullImageROI_afTracking FullImageROI_bfTracking ImageROIafterFixation
clear ImageROIafterFixation128 ImageROIafterFixation256 IRData sequence Params
clear AddS2PFA2percent AndorCamera1 Image_Reference WashwithHANKS zPosition

clear ImageROIafterFixation350


SPT.Lamp850Obj.setPower(15);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');

SPT.IRCameraObj.SequenceLength=150;
SPT.IRCameraObj.start_sequence;
ChangeSTORM=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(SPT.Lamp850Power);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');

SPT.IRCameraObj.SequenceLength=200;
SPT.IRCameraObj.start_sequence;
ChangeLiveAct=SPT.IRCameraObj.Data;
SPT.IRCameraObj.SequenceLength=5;
SPT.IRCameraObj.start_sequence;
Afterexperience=SPT.IRCameraObj.Data;

save('Y:\Hanieh\Tracking_SR (Fall 2017)\17-12-05\Sample 1\Sample1.mat','ChangeSTORM')

clear ChangeSTORM ChangeLiveAct Afterexperience
