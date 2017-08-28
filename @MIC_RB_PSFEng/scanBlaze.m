function [HInt,HScan,VInt,VScan]=scanBlaze(obj)
% scanBlaze scans a blaze across the SLM to measure pupil position
%
% OUTPUTS
%   HInt:   Result of horizontal scan, Intensity 
%   VInt:   Result of vertical scan, Intensity 
%
% REQUIRES
%
% Marjolein Meddens, Lidke Lab 2017

% reset SLM image
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

%Horizontal scan of blaze
ScanStep = 10;
HScan=(1:ScanStep:obj.SLM.HorPixels);

% setup camera
nFrames = length(HScan);
obj.Camera.abort;
obj.Camera.setup_fast_acquisition(nFrames);

% run horizontal scan
obj.Laser642.on;
pause(1);
for ii=1:length(HScan)
    obj.SLM.calcBlazeImage(.1,[1 1 obj.SLM.VerPixels HScan(ii)])
    obj.SLM.calcDisplayImage()
    obj.SLM.displayImage()
    obj.Camera.TriggeredCapture();
end
obj.Laser642.off;
Data=obj.Camera.FinishTriggeredCapture(nFrames);
HInt=squeeze(sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:),1),2));

%Verticl scan of blaze at size of pupil
VScan=(1:ScanStep:obj.SLM.VerPixels);

% setup camera
nFrames = length(VScan);
obj.Camera.abort;
obj.Camera.setup_fast_acquisition(nFrames);

% reset pattern
obj.SLM.Image_Pattern = 0;
obj.SLM.Image_Blaze = 0;
obj.SLM.calcDisplayImage();
obj.SLM.displayImage();
%run vertical scan
obj.Laser642.on;
pause(1);

for ii=1:length(VScan)
    obj.SLM.calcBlazeImage(.1,[1 1 VScan(ii) obj.SLM.HorPixels])
    obj.SLM.calcDisplayImage()
    obj.SLM.displayImage()
    obj.Camera.TriggeredCapture();
end
obj.Laser642.off;
Data=obj.Camera.FinishTriggeredCapture(nFrames);
VInt=squeeze(sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4),:),1),2));

end