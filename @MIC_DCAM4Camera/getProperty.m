function [Value] = getProperty(CameraHandle, Property, APIFilePath)
%getProperty gets the current value of a camera property.
%
% EXAMPLES:
%   To query the exposure time, you can use
%       ExpTime = MIC_DCAM4Camera.getProperty(CameraHandle, ...
%           'DCAM_IDPROP_EXPOSURETIME');
%       or the faster version
%       ExpTime = MIC_DCAM4Camera.getProperty(CameraHandle, 2031888);
%
% INPUTS:
%   CameraHandle: Integer handle to the camera.
%   Property: String identifying the property defined in dcamprop.h or
%             decimal value corresponding to that property.
%   APIFilePath: Path to the .h api file defining the hex values for each
%                property. 
%                (Default = 'C:\Program Files\dcamsdk4\inc\dcamprop.h')
%
% OUTPUTS:
%   Value: Value of the requested camera property.

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
Value = DCAM4GetProperty(CameraHandle, Property);


end