function [Value] = setGetProperty(CameraHandle, Property, Value, APIFilePath)
%setGetProperty sets a camera property and queries the resulting setting.
%
% INPUTS:
%   CameraHandle: Integer handle to the camera.
%   Property: String identifying the property defined in dcamprop.h or
%             decimal value corresponding to that property.
%   Value: Value of the property that we'll attempt to set. 
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

% Attempt to set the desired property and query the result.
DCAM4SetProperty(CameraHandle, Property, Value)
Value = DCAM4GetProperty(CameraHandle, Property);


end