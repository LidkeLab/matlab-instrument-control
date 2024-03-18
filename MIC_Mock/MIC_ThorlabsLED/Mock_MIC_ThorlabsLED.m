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
    
    methods (Static = true)
        function unitTest(NIDevice,AOChannel)
            NIDevice = 'Dev1';
            AOChannel = 'ao1';
            testPowerLevels = [0, 50, 100]; % Power levels to test
            
            % Create an instance of the Mock_MIC_ThorlabsLED class
            led = Mock_MIC_ThorlabsLED(NIDevice, AOChannel);
            
            % Test turning the LED on and off
            led.on();
            assert(led.IsOn == 1, 'LED should be on after calling the on() method.');
            led.off();
            assert(led.IsOn == 0, 'LED should be off after calling the off() method.');
            
            % Test setting various power levels
            for powerLevel = testPowerLevels
                led.setPower(powerLevel);
                assert(led.Power == powerLevel, sprintf('Power should be set to %d after calling setPower(%d).', powerLevel, powerLevel));
            end
            
            % Test the shutdown method
            led.shutdown();
            assert(led.IsOn == 0 && led.Power == 0, 'LED should be off and power should be 0 after calling shutdown().');
            
            disp('All tests passed.');
        end
    end
    % to run unit test: Mock_MIC_ThorlabsLED.unitTest()
end
