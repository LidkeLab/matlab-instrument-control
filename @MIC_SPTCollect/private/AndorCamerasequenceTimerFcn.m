function AndorCamerasequenceTimerFcn(obj,event,CameraObj)
fprintf('Andor is running/n')
CameraObj.start_sequence();
end 