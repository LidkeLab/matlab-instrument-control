classdef TissueImager < mic.abstract

    properties (SetAccess=protected)
        InstrumentName = 'TissueImager';
    end    

    properties (Hidden)
        StartGUI = false;  % or true if you want the GUI to launch on creation
    end

    properties
        CameraVis;
    end

    methods
        function obj = TissueImager()
            obj = obj@mic.abstract(~nargout);  % Call superclass constructor

            % Visible Camera
            fprintf('Initializing Thorcam\n')
            obj.CameraVis=mic.camera.ThorlabsSICamera();
        end

        function [Attributes, Data, Children] = exportState(obj)
            % Dummy implementation for testing
            Attributes = struct();
            Data = struct();
            Children = struct();
        end
    end

    methods (Static)
        function Success = funcTest()
            try
                disp('Testing TissueImager...');
                obj = mic.TissueImager();
                obj.gui();  % test GUI call
                delete(obj);  % cleanup
                Success = true;
            catch ME
                warning('funcTest failed: %s', ME.message);
                Success = false;
            end
        end
    end
end

