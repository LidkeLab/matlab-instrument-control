function IRCaptureTimerFcn(obj,event,IRcam,SaveDir,FileName)
out=IRcam.start_capture;
event_time=datestr(event.Data.time,'mm-dd-yy-HH-MM-SS');
fn=fullfile(SaveDir,[FileName,event_time]);
save(fn,'out');
end