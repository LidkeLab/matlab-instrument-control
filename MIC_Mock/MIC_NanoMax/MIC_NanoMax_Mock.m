classdef MIC_NanoMax_Mock < MIC_NanoMax
    % MIC_NanoMax_Mock: Mock class for testing MIC_NanoMax without hardware

    methods
        function obj = MIC_NanoMax_Mock()
            % Constructor for mock class
            % Disable hardware setup in the constructor
            obj = obj@MIC_NanoMax();
        end
        
        function setup_Stage_Piezo(obj)
            % Mock setup for Piezo stage
            fprintf('Mock setup for Piezo stage\n');
            % Simulate piezo stages without hardware connection
            obj.Stage_Piezo_X = 'Mock Piezo X';
            obj.Stage_Piezo_Y = 'Mock Piezo Y';
            obj.Stage_Piezo_Z = 'Mock Piezo Z';
        end
        
        function setup_Stage_Stepper(obj)
            % Mock setup for stepper motor stage
            fprintf('Mock setup for Stepper Motor stage\n');
            % Simulate stepper motor without hardware connection
            obj.Stage_Stepper = 'Mock Stepper Motor';
        end
        
        % Override other methods as needed to simulate behavior without hardware
    end
    
    methods (Static=true)
        function unitTest()
            % Unit test for mock class
            fprintf('Creating Mock Object\n');
            NM = MIC_NanoMax_Mock();
            fprintf('State Export\n');
            NM.exportState(); % No need to assign output to a variable
            fprintf('Delete Mock Object\n');
            clear NM;
        end
    end

end
