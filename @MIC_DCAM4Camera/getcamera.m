function getcamera(obj)

% Print out a list of the available cameras.
NCameras = DCAM4PrintCameraList(); 

% If needed, ask the user to select the desired camera.  If we have more
% than two cameras, this will just select the first camera!
if (NCameras== 2)
    % Ask the user to select the camera index they wish to connect to.  If
    % there are more than two cameras, this cod
    ButtonResult = questdlg('Which Camera would you like to use?', ...
        'Camera Selection', ...
        'Camera index 0', 'Camera index 1', ...
        'Camera index 0');
    switch ButtonResult
        case 'Camera index 0'
            obj.CameraIndex = int32(0);
        case 'Camera index 1'
            obj.CameraIndex = int32(1);
        otherwise
            return;
    end
else
    % Default selection of the first camera.
    obj.CameraIndex = int32(0);
end

% Open the camera.
obj.CameraHandle = DCAM4Open(obj.CameraIndex);


end