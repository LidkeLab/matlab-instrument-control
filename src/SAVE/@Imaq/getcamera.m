function getcamera(obj,AdaptorName,Format,DevID)
H=imaqhwinfo;


info=imaqhwinfo(AdaptorName);
if nargin>3
    vid = videoinput(AdaptorName,DevID,Format);
elseif nargin>2
    DevID=info.DeviceIDs{1};
    vid = videoinput(AdaptorName,DevID,Format);
else
    vid = videoinput(AdaptorName);
end
vid_src=getselectedsource(vid);
obj.CameraIndex=DevID;
obj.CameraHandle=vid;
obj.CameraCap=vid_src;
end