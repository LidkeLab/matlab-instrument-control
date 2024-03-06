classdef Mock_MIC_ThorlabsLED < MIC_ThorlabsLED
    methods
        function obj = Mock_MIC_ThorlabsLED(NIDevice, AOChannel)
            % Pass an additional argument to the parent constructor to indicate a mock object
            obj = obj@MIC_ThorlabsLED(NIDevice, AOChannel, true);
            obj.NIDevice = NIDevice;
            obj.AOChannel = AOChannel;
            obj.DAQ = 'MockDAQSession';  % Simulate the DAQ session
            obj.off(); % Ensure the LED is off initially
        end
        
        function setPower(obj, Power_in)
            % Simulate setting power without interacting with hardware
            obj.Power = min(max(obj.MinPower, Power_in), obj.MaxPower);
            if obj.IsOn
                disp(['Mock: Power set to ', num2str(obj.Power), '%']);
            else
                disp('Mock: Power set, but LED is off');
            end
        end
        
        function on(obj)
            % Simulate turning on the LED
            obj.IsOn = 1;
            disp('Mock: LED turned on');
        end
        
        function off(obj)
            % Simulate turning off the LED
            obj.IsOn = 0;
            disp('Mock: LED turned off');
        end
        
        function shutdown(obj)
            % Simulate shutting down the LED
            obj.setPower(0);
            obj.off();
            disp('Mock: LED shutdown');
        end
    end
end
