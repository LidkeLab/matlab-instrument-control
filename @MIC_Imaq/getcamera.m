function getcamera(obj, AdaptorName)
H=imaqhwinfo;

info=imaqhwinfo(AdaptorName);

DevID=info.DeviceIDs{1};
Format=info.DeviceInfo(DevID).SupportedFormats{1};
vid = videoinput(ADname,DevID,Format);
vid_src=getselectedsource(vid);
obj.CameraIndex=DevID;
obj.CameraHandle=vid;
obj.CameraCap=vid_src;
end