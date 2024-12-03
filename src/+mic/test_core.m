classdef test_core < matlab.unittest.TestCase

% Run various tests on the core abstract functionality of MIC.

% In the MATLAB unittest context, run in the following manner:
%    testCase = mic.test_core
%    results = testCase.run

methods (Test)

   function test_simulated_Camera(testCase)
      fprintf('mic.simulated_Camera.funcTest\n');
      results = mic.simulated_Camera.funcTest();
      testCase.verifyEqual(results, true);
   end

   function test_simulated_Instrument(testCase)
      fprintf('mic.simulated_Instrument.funcTest\n');
      results = mic.simulated_Instrument.funcTest();
      testCase.verifyEqual(results, true);
   end

   function test_simulated_LightSource(testCase)
      fprintf('mic.simulated_LightSource.funcTest\n');
      results = mic.simulated_LightSource.funcTest();
      testCase.verifyEqual(results, true);
   end

   function test_simulated_LinearStage(testCase)
      fprintf('mic.simulated_LinearStage.funcTest\n');
      results = mic.simulated_LinearStage.funcTest();
      testCase.verifyEqual(results, true);
   end

   function test_simulated_PowerMeter(testCase)
      fprintf('mic.simulated_PowerMeter.funcTest\n');
      results = mic.simulated_PowerMeter.funcTest();
      testCase.verifyEqual(results, true);
   end

   function test_simulated_Stage3D(testCase)
      fprintf('mic.simulated_Stage3D.funcTest\n');
      results = mic.simulated_Stage3D.funcTest();
      testCase.verifyEqual(results, true);
   end

end % Methods

end
