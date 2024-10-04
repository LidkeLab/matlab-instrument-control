% Run various tests on the example implementation of the Abstract 
% classes of Matlab-Instrument-Control (MIC).  

% mic.linearstage.example

fprintf('mic.linearstage.example.unitTest\n');
try
   mic.linearstage.example.unitTest()
end

% mic.stage3D.example

fprintf('mic.stage3D.example.unitTest\n');
try
   mic.stage3D.example.unitTest()
end

% mic.powermeter.example

fprintf('mic.powermeter.example.unitTest\n');
try
   mic.powermeter.example.unitTest()
end

% mic.lightsource.example

fprintf('mic.lightsource.example.unitTest\n');
try
   mic.lightsource.example.unitTest()
end

% mic.camera.example

fprintf('mic.camera,example.unitTest\n');
try
   mic.camera.example.unitTest();
end
