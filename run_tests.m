% Run various tests on the example implementation of the Abstract 
% classes of Matlab-Instrument-Control (MIC).  

% mic.camera.example

fprintf('mic.camera,example.funcTest ...\n');
try
   mic.camera.example.funcTest();
end

% mic.lightsource.example

fprintf('mic.lightsource.example.funcTest ...\n');
try
   mic.lightsource.example.funcTest()
end

% mic.linearstage.example

fprintf('mic.linearstage.example.funcTest ...\n');
try
   mic.linearstage.example.funcTest()
end

% mic.powermeter.example

fprintf('mic.powermeter.example.funcTest ...\n');
try
   mic.powermeter.example.funcTest()
end

% mic.stage3D.example

fprintf('mic.stage3D.example.funcTest ...\n');
try
   mic.stage3D.example.funcTest()
end
