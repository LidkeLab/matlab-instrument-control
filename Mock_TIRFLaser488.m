classdef Mock_TIRFLaser488 < MIC_TIRFLaser488
    % Mock version of the MIC_TIRFLaser488 class for testing
    
    methods
        function obj = Mock_TIRFLaser488()
            % Constructor
            % Avoid calling the superclass constructor that initializes hardware
            obj.InstrumentName = 'MockTIRFLaser488';
        end
        
        function setPower(obj, power)
            % Simulate setting power
            obj.Power = power;
        end
        
        function on(obj)
            % Simulate turning the laser on
            obj.IsOn = true;
        end
        
        function off(obj)
            % Simulate turning the laser off
            obj.IsOn = false;
        end
        
        % You can override other methods as needed
    end
end
