function [HexString] = propertyToHex(PropertyString, APIFilePath)
%propertyToHex converts a string property name to a hex string.
%
% EXAMPLES:
%   HexString = MIC_DCAM4Camera.propertyToHex('DCAM_IDPROP_EXPOSURETIME')
%       should return HexString = '0x001F0110'
%
% INPUTS:
%   PropertyString: Property written as a char array or string (e.g.,
%                   'DCAMWAIT_CAPEVENT_CYCLEEND')
%   APIFilePath: Path to the .h api file defining the hex values for each
%                property. 
%                (Default = 'C:\Program Files\dcamsdk4\inc\dcamprop.h')
%
% OUTPUTS:
%   HexString: Hexadecimal number stored as a string corresponding to the
%              PropertyString as devined by the APIFilePath.

% Created by:
%   David J. Schodt (Lidke lab, 2022)


% Set defaults.
if (~exist('APIFilePath', 'var') || isempty(APIFilePath))
    APIFilePath = 'C:\Program Files\dcamsdk4\inc\dcamprop.h';
end

% Scan the .h file for the desired property.
APIText = fileread(APIFilePath);
HexString = regexp(APIText, ...
    sprintf('(?<=%s\\s*=\\s*)\\w*', PropertyString), 'match');
HexString = HexString{1};


end