classdef Mock_MIC_HamamatsuLCOS < MIC_HamamatsuLCOS
    
    methods
        function obj = Mock_MIC_HamamatsuLCOS()
            obj@MIC_HamamatsuLCOS();
            obj.setupImage(); % Call the overridden setupImage method
            obj.calcZernikeImage()
        end
        
        function setupImage(obj)
            obj.PrimaryDispSize = [1920, 1080];
            obj.Fig_Pattern = figure('Position', [1921, 0, obj.HorPixels, obj.VerPixels], ...
                                     'MenuBar', 'none', 'ToolBar', 'none', ...
                                     'resize', 'off', 'NumberTitle', 'off');
            colormap(gray(256));
            axis off;
            set(gca, 'position', [0 0 1 1], 'Visible', 'off');
            obj.Fig_Pattern.HandleVisibility = 'off';
        end
        
        function displayImage(obj)          
            displayImage@MIC_HamamatsuLCOS(obj);
            disp('display image method works')
        end
        
        function calcZernikeImage(obj)
            disp('Calc Zernike image method works');
        end
%         
        
    end
end



