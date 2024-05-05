addpath 'C:\Users\lidkelab\Documents\GitHub\matlab-instrument-control\source\MIC\DCAM4\x64\Release'
NDevices = DCAM4Init()
[CameraHandle] = DCAM4Open(0);
ExpTime = 0.1;
DCAM4GetProperty(CameraHandle, 2031888)
DCAM4SetProperty(CameraHandle, 2031888, ExpTime)
DCAM4GetProperty(CameraHandle, 2031888)
% DCAM4Close(CameraHandle)
% DCAM4UnInit()

%% Sequence capture
DCAM4StopCapture(CameraHandle)
DCAM4ReleaseMemory(CameraHandle) % only needed in error conditions

NFrames = 100;
Timeout = 2 * ExpTime * NFrames * 1e3; % milliseconds
ImSize = [2304, 2304];
DCAM4SetProperty(CameraHandle, 1048848, 1) % internal trigger
DCAM4AllocMemory(CameraHandle, NFrames)
Status = DCAM4Status(CameraHandle)

DCAM4StartCapture(CameraHandle, 0)
Status = 1;
PlotAxes = axes(figure());
pause(1)
while (Status ~= 2)
    Status = DCAM4Status(CameraHandle);
    Data = DCAM4CopyLastFrame(CameraHandle, Timeout);
    imshow(reshape(Data, ImSize), [], 'Parent', PlotAxes)
    drawnow()
end
% DCAM4StopCapture(CameraHandle)
EventMask = 4; % see hex values of DCAMWAIT_EVENT in dcamapi4.h
Data = DCAM4CopyFrames(CameraHandle, NFrames, Timeout, EventMask);
Images = reshape(Data, [ImSize, NFrames]);
dipshow(Images)

% DCAM4StopCapture(CameraHandle)
% DCAM4ReleaseMemory(CameraHandle) % only needed in error conditions

%% Triggered capture testing.
DCAM4StopCapture(CameraHandle)
DCAM4ReleaseMemory(CameraHandle) % only needed in error conditions

DCAM4SetProperty(CameraHandle, 1048848, 3) % software trigger
NFrames = 10;
Timeout = 2 * ExpTime * NFrames * 1e3; % milliseconds
DCAM4AllocMemory(CameraHandle, NFrames)
ImSize = [2304, 2304];
DCAM4StartCapture(CameraHandle, -1) % use sequence for triggering
pause(1)
for ii = 1:NFrames
    disp(ii)
    DCAM4FireTrigger(CameraHandle, 2*ExpTime*1e3)
end
EventMask = 4; % see hex values of DCAMWAIT_EVENT in dcamapi4.h
Data = DCAM4CopyFrames(CameraHandle, NFrames, Timeout, EventMask);
Images = reshape(Data, [ImSize, NFrames]);

%% Focus mode
NFramesMax = 100;
DCAM4SetProperty(CameraHandle, 1048848, 1)
DCAM4AllocMemory(CameraHandle, 1)
DCAM4StartCapture(CameraHandle, -1)
for ii = 1:NFramesMax
    Data = DCAM4CopyLastFrame(CameraHandle, Timeout);
    imshow(reshape(Data, ImSize), [])
    drawnow()
end
DCAM4StopCapture(CameraHandle)

%% Repeat some of the above tests using updated MIC_DCAM4Camera
% Triggered captures.
CameraSCMOS = MIC_DCAM4Camera();
CameraSCMOS.ReturnType = 'matlab';
CameraSCMOS.gui();
ROISize = 256;
CameraSCMOS.ROI = [1024-ROISize/2, 1024+ROISize/2-1, ...
    1024-ROISize/2, 1024+ROISize/2-1];
CameraSCMOS.AcquisitionType = 'sequence';
CameraSCMOS.TriggerMode = 'software';
CameraSCMOS.SequenceLength = 1000;
CameraSCMOS.ExpTime_Sequence = 0.01;
CameraSCMOS.setup_fast_acquisition(CameraSCMOS.SequenceLength);
% CameraSCMOS.start_sequence(-1); % -1 for triggered capturing
tic;
for ii = 1:CameraSCMOS.SequenceLength
    disp(ii)
    CameraSCMOS.triggeredCapture();
end
toc
Images = CameraSCMOS.finishTriggeredCapture(CameraSCMOS.SequenceLength);



