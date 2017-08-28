function [ZernikeCoefs] = optimizePupil(obj,NumCoefs)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% number of steps during optimization
NSteps = 21;
CoefRange = [-5 5];
CoefVals = linspace(CoefRange(1),CoefRange(2),NSteps);
ZernikeCoefs = zeros(NumCoefs,1);
obj.SLM.ZernikeCoef = ZernikeCoefs;
obj.ZCoefOptimized = ZernikeCoefs;
obj.SLM.Image_OptimPSF = 0;
NumMaxPix = 5; %number of pixels to sum for max intensity (highest value pixels)

% Start with uniform pupil function
obj.SLM.Image_Pattern = 0;
obj.SLM.Image_Blaze = 0;
obj.SLM.calcDisplayImage();
obj.SLM.displayImage();

% get PSFpos by mouse click
obj.Laser642.on;
Data = obj.Camera.start_focus;
obj.Laser642.off;
h = dipshow(Data);
diptruesize(h,400);
Point = dipgetcoords(h,1);
close(h);
PSFpos = [Point(2),Point(1)]; %[Y,X]
ROIsize = 12; % pixels
PSFROI=ceil([PSFpos(1)-ROIsize/2,PSFpos(1)+ROIsize/2-1,PSFpos(2)-ROIsize/2,PSFpos(2)+ROIsize/2-1]); %

% initialize figures
hf = figure;
hf.Name = 'Zernike coefficient optimization intial';
hf.Position = [21 82 560 880];
hAx1st = subplot(2,1,1); hold on;
title(['Initial optimization']);
hAx2nd = subplot(2,1,2); hold on;
title(['Refinement']);

for jj = 1 : 2
% optimize each coefficient
switch jj
    case 1
        hAx = hAx1st;
    case 2
        hAx = hAx2nd;
end
for ii = 4 : NumCoefs
    
    
    % setup camera
    obj.Camera.abort;
    obj.Camera.setup_fast_acquisition(NSteps);
    
    % run 1st coef scan
    obj.Laser642.on;
    pause(1);
    for kk=1:NSteps
        % set pupil
        obj.SLM.ZernikeCoef(ii) = CoefVals(kk);
        obj.SLM.calcZernikeImage();
        pause(.1);
        % acquire image
        obj.Camera.TriggeredCapture();
    end
    obj.Laser642.off;
    % get data
    Data=obj.Camera.FinishTriggeredCapture(NSteps);
    PSFcropped = Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:);
    Isort = sort(reshape(PSFcropped,[size(PSFcropped,1)*size(PSFcropped,2),size(PSFcropped,3)]),1);
    Imax = sum(Isort(end-NumMaxPix+1:end,:),1);
    
    % plot data
    hp = plot(hAx,CoefVals,Imax,'o');

    % fit data
    % crop data around peak
    MaxCoef = find(Imax==max(Imax));
    PeakStart = max([0,MaxCoef-5]);
    PeakEnd = min([MaxCoef+5,NSteps]);
    CVpeak = CoefVals(PeakStart:PeakEnd);
    Ipeak = Imax(PeakStart:PeakEnd);
    % fit to 3rd order polynomial
    PolyCoef = polyfit(CVpeak,Ipeak,4);
    fitGrid = linspace(min(CVpeak),max(CVpeak),100);
    Ifit = polyval(PolyCoef,fitGrid);
    Der = polyder(PolyCoef);
    r = sort(roots(Der));
    if isreal(r)
        MaxPos = r(2);
    else
        MaxPos = r(imag(r)== 0);
    end
    % plot fit
    plot(hAx,fitGrid,Ifit,'-','Color',hp.Color);
    

    ZernikeCoefs(ii) = MaxPos;
    obj.SLM.ZernikeCoef = ZernikeCoefs;
end
end

% set defocus back to zero
ZernikeCoefs(4) = 0;
obj.ZCoefOptimized = ZernikeCoefs;
% calculate optimized PSF image and store image in SLM object
obj.SLM.calcZernikeImage();
obj.SLM.Image_OptimPSF = obj.SLM.Image_Pattern;
obj.SLM.Image_Pattern = 0;
obj.SLM.calcDisplayImage;
obj.SLM.displayImage;


end


