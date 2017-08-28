function getcamera(obj)

% choose betwee a list of camera models w/ serials
[CameraInd]=DcamGetCameras
NumCameras=length(CameraInd)
if NumCameras > 1
    cameras{1}=[Index '' num2str(CameraInd(1))];
    cameras{2}=[Index '' num2str(CameraInd(2))];
    ButtonName = questdlg('Which Camera would you like to use?', 'Camera Setup', cameras{1}, cameras{2}, cameras{1});
    switch ButtonName
        case cameras{1}
            id =CameraInd(1);
        case cameras{2}
            id =CameraInd(2);
        otherwise
            return;
    end
else
    id = CameraInd(1);
end

[Hdcam]=DcamOpen(id);
obj.CameraHandle=Hdcam;
obj.CameraIndex=id;
end