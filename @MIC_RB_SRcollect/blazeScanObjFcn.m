function [f] = blazeScanObjFcn(X,I,BlazeWidth)
%blazeScanObjFcn Objective function to fit blaze scan result
%
% Objective function consists of 4 parts:
%       1. Pupil function is unblazed
%       2. Less than half of pupil is blazed
%       3. More than half of pupil is blazed
%       4. Pupil is completely blazed
% Intensity is calculated as follows:
%       Icalc = Ibead * (AreaUnblazed/AreaTotal) + Ibg
%       where the area's are of the pupil
% Cost parameter f is calculated as sum of squared errors
%
% INPUTS:
%   X:          Vector containing parameters to be optimized:
%       X(1):   Integrated intensity of bead without blaze
%       X(2):   Background intensity when pupil is completely blazed
%       X(3):   Position of pupil center (pixels)
%       X(4):   Pupil radius (pixels)
%   I:          Measured integrated intensity of a bead during blaze scan
%   BlazeWidth: Width of blaze (pixels)     
%
% OUTPUTS:
%   f:          value to minimize in fminsearch
%   
% Marjolein Meddens 2017, Lidke Lab

Imeas = I;
Icalc = zeros(size(Imeas));
Ibead = X(1);
Ibg = X(2);
PupilPos = X(3);
Rpupil = X(4);

for ii = 1 : numel(BlazeWidth)
    Icalc(ii) = MIC_RB_PSFEng.blazeScanIntensity(BlazeWidth(ii),Ibead,Ibg,PupilPos,Rpupil);
end

% cost function SSE
f = sum((Icalc-Imeas).^2);

end

