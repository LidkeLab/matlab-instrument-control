% Run various tests on the core functionality of MIC_Mock claases.

% Check Mock_MIC_ThorlabsLED 
fprintf('run Mock_MIC_ThorlabsLED unit test\n');
try
   Mock_MIC_ThorlabsLED.unitTest()
end

% check Mock_MIC_HamamatsuLCOS
fprintf('run Mock_MIC_HamamatsuLCOS unit test\n');
try
    Mock_MIC_HamamatsuLCOS.unitTest()
end

% Check MIC_NanoMax_Mock
fprintf('run MIC_NanoMax_Mock unit test\n');
try
    MIC_NanoMax_Mock.unitTest()
end
