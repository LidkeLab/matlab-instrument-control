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
        LCTF;
        LED;
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

            % LCTF
            fprintf('Initializing Liquid Crystal Tunable Filter\n')
            obj.LCTF=mic.KuriosFilter('COM3');

            % LEDs
            fprintf('Initializing LEDs\n')
            obj.LED=mic.lightsource.ThorlabsLED('Dev1','ao1');

            obj.gui();
        end

        function gui(obj)

        end

        function delete(obj)
            %try delete(obj.GuiFigure); end
            try delete(obj.CameraVis); end
            try delete(obj.IRCamera); end
            try delete(obj.Flip); end
            try delete(obj.LCTF); end
            try delete(obj.LED); end
            close all force;
        end





        function [Attributes, Data, Children] = exportState(obj)
            [Children.CameraVis.Attributes,Children.CameraVis.Data,Children.CameraVis.Children]=...
                    obj.CameraVis.exportState();

             [Children.IRCamera.Attributes,Children.IRCamera.Data,Children.IRCamera.Children]=...
                    obj.IRCamera.exportState();

             [Children.Flip.Attributes,Children.Flip.Data,Children.Flip.Children]=...
                    obj.Flip.exportState();

             [Children.LCTF.Attributes,Children.LCTF.Data,Children.LCTF.Children]=...
                    obj.LCTF.exportState();

             [Children.LED.Attributes,Children.LED.Data,Children.LED.Children]=...
                    obj.LED.exportState();

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

