%Script for tracking and SR

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=50;
SPT.IRCameraObj.start_sequence;
IRCamera=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=30;
SPT.IRCameraObj.start_sequence;
DNP=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=2100;
SPT.IRCameraObj.start_sequence;
PMA=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=110;
SPT.IRCameraObj.start_sequence;
HANKSwash=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(20);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
FullImageafTracking=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(25);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=1;
SPT.IRCameraObj.start_sequence;
FullImagebfTracking=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(25);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=1;
SPT.IRCameraObj.start_sequence;
FullImagebfTracking=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(25);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=70;
SPT.IRCameraObj.start_sequence;
AddS2PFA2percent=SPT.IRCameraObj.Data;
 
SPT.Lamp850Obj.setPower(20);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
FullImage_afS2=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(20);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
after10minofS2=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(90);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.start_capture;
ImageROIafterFixation350=SPT.IRCameraObj.Data;



save('Y:\Hanieh\Tracking_SR (Fall 2017)\2018-05-08\Sample4.mat',...
    '',...
    'FullImage_afTracking','AddS2PFA2percent',...
    '')
   


'','FullImageROI_bfTracking',...
'PMA3', 'PMA2','PMA1', ...
    'PMA4','PMA6','PMA7','PMA8','PMA9','PMA10','PMA11','PMA12',...
    'PMA5','PMA13','PMA14')

clear FullImageROI_afTracking FullImageROI_bfTracking ImageROIafterFixation
clear ImageROIafterFixation128 ImageROIafterFixation256 IRData sequence Params
clear AddS2PFA2percent2 AndorCamera1 Image_Reference WashwithHANKS zPosition
clear HaveLatranculin HaveLatranculin1 HaveLatranculin2 HaveLatranculin3
clear HaveLatranculinmore HaveLatranculin4
clear ImageROIafterFixation350 AddLatrunculinB  HaveLatranculin4

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=200;
SPT.IRCameraObj.start_sequence;
AddTris=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=200;
SPT.IRCameraObj.start_sequence;
AddBlocking=SPT.IRCameraObj.Data;

SPT.Lamp850Obj.setPower(50);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=100;
SPT.IRCameraObj.start_sequence;
AddAlexa=SPT.IRCameraObj.Data;



AddPBS=SPT.IRCameraObj.Data;


save('Y:\Hanieh\Tracking_SR (Fall 2017)\2018-02-09 Latrunculin B, long fixation\Sample 2\Sample2',...
'AddTris','AddBlocking','AddPBS','AddAlexa');

clear AddTris AddBlocking AddPBS

SPT.Lamp850Obj.setPower(30);SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');
SPT.IRCameraObj.SequenceLength=80;
SPT.IRCameraObj.start_sequence;
AddStorm=SPT.IRCameraObj.Data;


SPT.Lamp850Obj.setPower(SPT.Lamp850Power);
SPT.Lamp850Obj.on;
SPT.IRCameraObj.ROI=SPT.getROI('IRThorlabs');

SPT.IRCameraObj.SequenceLength=200;
SPT.IRCameraObj.start_sequence;
ChangeLiveAct=SPT.IRCameraObj.Data;
SPT.IRCameraObj.SequenceLength=5;
SPT.IRCameraObj.start_sequence;
Afterexperience=SPT.IRCameraObj.Data;

save('Y:\Hanieh\Tracking_SR (Fall 2017)\2018-01-12\Sample 4\Sample4.mat','ChangeSTORM',...
    'WashPBSforphotobleaching')

clear ChangeSTORM ChangeLiveAct Afterexperience
%% script to take IR Bright Filed Image for fixative buffer
IRCam=MIC_IRSyringPump();
Lamp850=MIC_ThorlabsLED('Dev1','ao1');
Lamp850.setPower(15);
Lamp850.on;
IRCam.start_focus
IRCam.SPwaitTime=35;
IRCam.SequenceLength=700;
IRCam.start_sequence;
PFA4=IRCam.Data;

Glyoxal3noE=SPT.IRCameraObj.Data;
Glyoxal1_5E10=SPT.IRCameraObj.Data;
Glyoxal3E20=SPT.IRCameraObj.Data;
PFA4=SPT.IRCameraObj.Data;
PFA1_2=SPT.IRCameraObj.Data;
PFA0_6=SPT.IRCameraObj.Data;
GA2=SPT.IRCameraObj.Data;
GA2T0_2=SPT.IRCameraObj.Data;
GA2T0_1=SPT.IRCameraObj.Data;

