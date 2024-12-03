%% initialize the instruments 
Laser642 = mic.lightsource.TCubeLaserDiode('64838719','Power',80,182.5,1);
Laser642.gui()
Camera = mic.camera.HamamatsuCamera();
Camera.gui()
Camera.ROI = [1, 256, 257, 512];
Stage = mic.stage3D.MCLNanoDrive();
Stage.gui()

%% Take PSF stack
NImagesPerPosition = 500;
StagePosition = Stage.Position;
ZPositions = StagePosition(3) + [-3:0.5:3, 3:-0.5:-3];
ZStack = zeros(256, 256, numel(ZPositions), NImagesPerPosition);
Camera.AcquisitionType = 'sequence';
Camera.SequenceLength = NImagesPerPosition;
Camera.ExpTime_Sequence = 0.05;
Camera.setup_acquisition();
Laser642.on();
for ii = 1:numel(ZPositions)
    Stage.setPosition([StagePosition(1:2), ZPositions(ii)]);
    pause(0.1)
    ZStack(:, :, ii, :) = Camera.start_sequence();
end
Laser642.off();
Stage.setPosition(StagePosition);
save(['Y:\BeadData.mat'], ...
    'ZPositions', 'ZStack')