function getcamera(obj)
H=imaqhwinfo;
ADname=H.InstalledAdaptors{1};
info=imaqhwinfo(ADname);

DevID=info.DeviceIDs{1};
Format=info.DeviceInfo(DevID).SupportedFormats{1};
vid = videoinput(ADname,DevID,Format);
vid_src=getselectedsource(vid);
obj.CameraIndex=DevID;
obj.CameraHandle=vid;
obj.CameraCap=vid_src;
end