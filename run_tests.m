% Run various tests on the example implementation of the Abstract 
% classes of Matlab-Instrument-Control.  

% ExampleLinearStage

fprintf('ExampleLinearStage.unitTest\n');
try
   ExampleLinearStage.unitTest()
end

% Example3DStage

fprintf('Example3DStage.unitTest\n');
try
   Example3DStage.unitTest()
end

% ExamplePowerMeter

fprintf('ExamplePowerMeter.unitTest\n');
try
   ExamplePowerMeter.unitTest()
end

% ExampleLightSource
fprintf('ExampleLightSource.unitTest\n');
try
   ExampleLightSource.unitTest()
end

% ExampleCameraModel
fprintf('ExampleCamera.unitTest\n');
try
   ExampleCamera.unitTest();
end




