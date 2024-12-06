function getcamera(obj)

% choose betwee a list of camera models w/ serials
[st NumCameras] = GetAvailableCameras;

if st ==obj.ErrorCode.DRV_SUCCESS
    for i=1:NumCameras
        [obj.LastError handle] = GetCameraHandle(i-1);
        obj.errorcheck('GetCameraHandle');
        
        obj.LastError = SetCurrentCamera(handle);
        obj.errorcheck('SetCurrentCamera');
        
        dummyvariable = AndorInitialize(fileparts(which('AndorInitialize')));
        %obj.errorcheck('AndorInitialize');
        %get CCD info
        [st,model] = GetHeadModel;
        [st2 cserial] = GetCameraSerialNumber;

        if st == obj.ErrorCode.DRV_SUCCESS && st2 == obj.ErrorCode.DRV_SUCCESS
            cameras{i} = [model ' ' num2str(cserial)];
        end
    end
else
    obj.LastError=st;
    obj.errorcheck('GetAvailableCameras');
end

if NumCameras > 1
    ButtonName = questdlg('Which Camera would you like to use?', 'Camera Setup', cameras{1}, cameras{2}, cameras{1});
    switch ButtonName
        case cameras{1}
            id =0;
        case cameras{2}
            id =1;
        otherwise
            return;
    end
else
    id = 0;
end

[obj.LastError obj.CameraHandle]=GetCameraHandle(id);
obj.errorcheck('GetCameraHandle');
obj.CameraIndex=id;

end

