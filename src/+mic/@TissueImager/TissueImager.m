classdef TissueImager < mic.abstract

    properties (SetAccess=protected)
        InstrumentName = 'TissueImager';
    end    

    properties (Hidden)
        StartGUI = false;  % or true if you want the GUI to launch on creation
    end

    properties
        CameraVis;
        IRCamera;
        Flip;
    end

    methods
        function obj = TissueImager()
            %obj = obj@mic.abstract(~nargout);  % Call superclass constructor

            % Visible Camera
            fprintf('Initializing Thorcam\n')
            obj.CameraVis=mic.camera.ThorlabsSICamera();

            % IR Camera
            fprintf('Initializing IRCam\n')
            obj.IRCamera=mic.camera.IMGSourceCamera();

            % Flip Mount
            fprintf('Initializing Flip Mount\n')
            obj.Flip=mic.FlipMountTTL('Dev1', 'port0/line0');

            obj.gui();
        end

        function gui(obj)

        end

        %function delete(obj)

            % superclass delete
         %   delete@mic.abstract(obj);

            %delete all objects
          %  delete(obj.GuiFigure);
           % close all force;
            %clear;
            %delete all equipment objects
            %obj.CameraVis = [];
            %obj.IRCamera = [];
            %obj.Flip = [];

        %end




        function [Attributes, Data, Children] = exportState(obj)
            [Children.CameraVis.Attributes,Children.CameraVis.Data,Children.CameraVis.Children]=...
                    obj.CameraVis.exportState();

             [Children.IRCamera.Attributes,Children.IRCamera.Data,Children.IRCamera.Children]=...
                    obj.IRCamera.exportState();

             [Children.Flip.Attributes,Children.Flip.Data,Children.Flip.Children]=...
                    obj.Flip.exportState();

             Data=[];
            
             Attributes=[];
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

