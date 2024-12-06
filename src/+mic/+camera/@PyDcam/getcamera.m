function getcamera(obj)

out = py.dcam.Dcamapi.init();
if ~out
    err = py.str(py.dcam.Dcamapi.lasterr());
    error(['Dcamapi.init() fails with error: ',err.char])
else
    py.dcam_helper.dcam_show_device_list();
    DevID = 0;
    cam = py.dcam.Dcam(py.int(DevID));
    out = cam.dev_open();
    
    if ~out
        err = py.str(cam.lasterr());
        error(['Dcam.dev_open() fails with error: ',err.char])
    else
        obj.CameraHandle=cam;
        obj.CameraIndex=DevID;
    end
end

end