classdef TestMIC_HamamatsuLCOS < matlab.unittest.TestCase
    methods (Test)
        function testMockConstructor(testCase)
            mockObj = Mock_MIC_HamamatsuLCOS();
            testCase.verifyEqual(mockObj.HorPixels, 1272);
            testCase.verifyEqual(mockObj.VerPixels, 1024);
            testCase.verifyTrue(mockObj.IsMock);
            delete(mockObj);
        end
        
        function testCalcZernikeImageMethod(testCase)
            mockObj = Mock_MIC_HamamatsuLCOS();
            
            % Set up test data for calcZernikeImage
            mockObj.PupilRadius = 100;
            mockObj.PupilCenter = [512, 512];
            mockObj.ZernikeCoef = [0.1, 0.1, 0.3, 0.5, 0.9, 0.7, 0.8,0.19]; % Example coefficients
            
            % Call the method to be tested
            mockObj.calcZernikeImage();
            
            % Verify the results
            testCase.verifyGreaterThan(mean(mean(mockObj.Image_Pattern)), 0);
            testCase.verifySize(mockObj.Image_Pattern, [mockObj.VerPixels, mockObj.HorPixels]);
            
            delete(mockObj);
        end
    end
end


% To run tests:
% results = runtests('TestMIC_HamamatsuLCOS');
% disp(results)
