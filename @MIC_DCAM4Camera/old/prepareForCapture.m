function prepareForCapture(obj, NImages)
%prepareForCapture runs a few functions to prepare the camera for capturing. 
%
%
% INPUTS:
%   CameraHandle: Integer handle to the camera.
%   NImages: Number of images to be captured.

% Created by:
%   David J. Schodt (Lidke lab, 2022)


% Release the existing memory buffer.
DCAM4ReleaseMemory(obj.CameraHandle)

% Allocate a new memory buffer.
DCAM4AllocMemory(obj.CameraHandle, NImages)


end