function setProperty(CameraHandle, Property, Value, APIFilePath)
%setProperty sets a camera property to the specified value.
%
% EXAMPLES:
%   To set the exposure time, you can use
%       ExpTime = 0.1; % seconds
%       MIC_DCAM4Camera.setProperty(CameraHandle, ...
%           'DCAM_IDPROP_EXPOSURETIME', ExpTime);
%       or the faster version
%       MIC_DCAM4Camera.setProperty(CameraHandle, 2031888, ExpTime);
%
% INPUTS:
%   CameraHandle: Integer handle to the camera.
%   Property: String identifying the property defined in dcamprop.h or
%             decimal value corresponding to that property.
%   Value: Value of the property that we'll attempt to set. 
%   APIFilePath: Path to the .h api file defining the hex values for each
%                property. 
%                (Default = 'C:\Program Files\dcamsdk4\inc\dcamprop.h')

% Created by:
%   David J. Schodt (Lidke lab, 2022)


% Set defaults.
if (~exist('APIFilePath', 'var') || isempty(APIFilePath))
    APIFilePath = 'C:\Program Files\dcamsdk4\inc\dcamprop.h';
end

% Convert 'Property' to a decimal value if needed.
if ~isnumeric(Property)
    Property = hex2dec(MIC_DCAM4Camera.propertyToHex(Property, APIFilePath));
end

% Attempt to set the desired property.
DCAM4SetProperty(CameraHandle, Property, Value)


end