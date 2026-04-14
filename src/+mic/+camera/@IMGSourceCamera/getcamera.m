function getcamera(obj)
H=imaqhwinfo;
if isempty(H.InstalledAdaptors)
    error('No image acquisition adaptors found. Please install hardware support packages.');
end
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