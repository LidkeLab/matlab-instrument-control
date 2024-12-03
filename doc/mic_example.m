% This script initialize mic instruments and collect the z-stack of beads in range of 1 micron. 
%% initialize the mic instruments 
% initialize the TCubeLaserDiode:
Laser642 = mic.lightsource.TCubeLaserDiode('64838719','Power',80,182.5,1);
Laser642.gui() % start the GUI
% initialize the camera
Camera = mic.camera.HamamatsuCamera();
Camera.gui() % start the GUI
Camera.ROI = [1, 256, 257, 512]; % setup particular region of interest
% initialize the MCLNanoDrive 3D stage
Stage = mic.stage3D.MCLNanoDrive();
Stage.gui() % start the GUI

%% Take PSF stack
NImagesPerPosition = 100; % number of images at particular z position
StagePosition = Stage.Position; % Get the stage position
ZPositions = StagePosition(3) + [-1:0.1:1, 1:-0.1:-1]; % move the z which is StagePosition(3) in range of 1 micron
ZStack = zeros(256, 256, numel(ZPositions), NImagesPerPosition); % initialize the ZStack of 256 x 256 x number of ZPositions x NImagesPerPosition
Camera.AcquisitionType = 'sequence'; % setup the camera acquisition to sequence
Camera.SequenceLength = NImagesPerPosition; % this is sequence length
Camera.ExpTime_Sequence = 0.05; % this is camera exposure time
Camera.setup_acquisition();
Laser642.on(); % turn on laser 642 before acquisition
% loop over ZPositions and acquire images and stack them in ZStack
for ii = 1:numel(ZPositions)
    Stage.setPosition([StagePosition(1:2), ZPositions(ii)]);
    pause(0.1)
    ZStack(:, :, ii, :) = Camera.start_sequence();
end
Laser642.off(); % turn off laser 642 after acquisition
Stage.setPosition(StagePosition); % set stage to its initial position
save(fullfile(tempdir, 'BeadData.mat'), 'ZPositions', 'ZStack'); % save data