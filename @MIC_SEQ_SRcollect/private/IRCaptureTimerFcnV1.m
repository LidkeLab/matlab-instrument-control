function IRCaptureTimerFcnV1(obj,event,ActRegObj,SaveDir,FileName)
ActRegObj.align2imageFit;
Params=struct(ActRegObj);
Params.CameraObj=[];
Params.StageObj=[];
event_time=datestr(event.Data.time,'mm-dd-yy-HH-MM-SS');
fn=fullfile(SaveDir,[FileName,event_time]);
save(fn,'Params');
end