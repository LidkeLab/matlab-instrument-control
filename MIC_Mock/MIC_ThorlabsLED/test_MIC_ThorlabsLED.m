function test_MIC_ThorlabsLED()
    % Test parameters
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
