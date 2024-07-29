% Run various tests on the example implementation of the Abstract 
% classes of Matlab-Instrument-Control (MIC).  

% ExampleLinearStage

fprintf('ExampleLinearStage.unitTest\n');
try
   Example_LinearStage.unitTest()
end

% Example3DStage

fprintf('Example3DStage.unitTest\n');
try
   Example_3DStage.unitTest()
end

% ExamplePowerMeter

fprintf('ExamplePowerMeter.unitTest\n');
try
   Example_PowerMeter.unitTest()
end

% ExampleLightSource

fprintf('ExampleLightSource.unitTest\n');
try
   Example_LightSource.unitTest()
end

% ExampleCameraModel

fprintf('ExampleCamera.unitTest\n');
try
   Example_Camera.unitTest();
end