function [PropertyString] = hexToProperty(HexString, Prefix, APIFilePath)
%hexToProperty converts a hex string to an property name.
%
% INPUTS:
%   HexString: Hexadecimal stored in a char error/string corresponding to
%              an error in the APIFilePath.
%   Prefix: Property prefix that can be used to avoid degenerate hex 
%           values. (Default = '')
%   APIFilePath: Path to the .h api file defining the hex values for each
%                property. 
%                (Default = 'C:\Program Files\dcamsdk4\inc\dcamapi4.h')
%
% OUTPUTS:
%   PropertyString: String message corresponding to HexString.

% Created by:
%   David J. Schodt (Lidke lab, 2022)


% Set defaults.
if (~exist('APIFilePath', 'var') || isempty(APIFilePath))
    APIFilePath = 'C:\Program Files\dcamsdk4\inc\dcamapi4.h';
end
if (~exist('Prefix', 'var') || isempty(Prefix))
    Prefix = '';
end

% If the error is '0', return manually (I haven't found the right way to
% deal with this in the regexp below).
if strcmp(HexString, '0')
    PropertyString = 'DCAMERR_NONE';
    return
end

% Scan the .h file for the desired error.
APIText = fileread(APIFilePath);
PropertyString = regexp(APIText, ...
    sprintf('%s\\w*(?=\\s*=\\s*%s)', Prefix, HexString), 'match');
if isempty(PropertyString)
    return
end
PropertyString = PropertyString{1};


end