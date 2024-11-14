classdef ThorlabsLED < mic.lightsource.abstract
    % mic.lightsource.ThorlabsLED Matlab Instrument Class for control of the Thorlabs LED
    %
    %  ## Description
    % This class controls a LED lamp with different wavelength from Thorlabs.
    % Requires TTL input from the Analogue Input/Output channel of NI card
    % to turn the laser ON/OFF as well as set the power remotely.
    % BNC cable is needed to connect to device.
    % Set Trig=MOD on control device for Lamp and turn on knob manually
    % more than zero to control from computer.
    %
    % ## Requirements
    % - `mic.abstract.m`
    % - `mic.lightsource.abstract.m`
    % - MATLAB (R2016b or later)
    % - Data Acquisition Toolbox
    % - MATLAB NI-DAQmx driver (installed via the Support Package Installer)
    %
    % ## Installation
    % Ensure all required files are in the MATLAB path and that the NI-DAQmx driver is correctly installed and configured on your system.
    %
    % ## Protected Properties
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'ThorlabsLED'`.
    %
    % ### `Power`
    % Currently set output power.
    % **Default:** `0`.
    %
    % ### `PowerUnit`
    % Unit of power measurement.
    % **Default:** `'Percent'`.
    %
    % ### `MinPower`
    % Minimum power setting.
    % **Default:** `0`.
    %
    % ### `MaxPower`
    % Maximum power setting.
    % **Default:** `100`.
    %
    % ### `IsOn`
    % On or off state of the device (`0` for OFF, `1` for ON).
    % **Default:** `0`.
    %
    % ### `NIDevice`
    % NIDAQ device name (e.g., `Dev1`).
    %
    % ### `AOChannel`
    % Name of the analog output (AO) channel for the LED on the NIDAQ port (e.g., `ao1`).
    %
    % ### `physicalChannel`
    % Name of the NIDAQ port used for communication.
    %
    % ### `V_100`
    % Voltage at which the current begins to drop from 100%.
    % **Default:** `5`.
    %
    % ### `V_0`
    % Voltage setting to completely turn off the device.
    % **Default:** `0`.
    %
    % ### `DAQ`
    % NI DAQ session object.
    % **Default:** `[]`.
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Indicates whether the GUI should start.
    % **Default:** `false`.
    %
    % ## Functions:
    %   on(obj)
        %       - Turns the LED lamp ON.
        %       - Usage: obj.on();
        %
        %   off(obj)
        %       - Turns the LED lamp OFF.
        %       - Usage: obj.off();
        %
        %   setPower(obj, Power_in)
        %       - Sets the power level of the lamp.
        %       - Power_in must be between obj.MinPower and obj.MaxPower.
        %       - Usage: obj.setPower(50); % Sets power to 50%
        %
        %   exportState(obj)
        %       - Exports the current state of the lamp.
        %       - Returns a structure with fields for Power and IsOn.
        %       - Usage: state = obj.exportState();
        %
        %   delete(obj)
        %       - Cleans up resources, called before clearing the object.
        %       - Usage: delete(obj);
        %
        %   shutdown(obj)
        %       - Sets power to zero, turns off the lamp, and cleans up resources.
        %       - Usage: obj.shutdown();
        %
    % ## Usage Example
    % To create an instance of the `mic.lightsource.ThorlabsLED` class:
    % ```matlab
    % obj = mic.lightsource.ThorlabsLED('Dev1', 'ao1');
    % Create an object
    % led = mic.lightsource.ThorlabsLED('Dev1', 'ao1');
    
    % Set power to maximum
    % led.setPower(100);
    
    % Turn the LED on
    % led.on();
    
    % Wait for 1 second
    % pause(1);
    
    % Turn the LED off
    % led.off();
    %
    % Clean up
    % led.delete();
    % ```
    % ### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
    properties (SetAccess=protected)
        InstrumentName='ThorlabsLED'  %Name of instrument
        Power=0;            % Currently Set Output Power
        PowerUnit='Percent' % Power Unit
        MinPower=0;         % Minimum Power Setting
        MaxPower=100;       % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
    end
    properties (SetAccess=protected)
        NIDevice;       % NIDAQ name like Dev1
        AOChannel;      % Name of the LED on the NIDAQ port like ao1
        physicalChannel;% Name of the NIDAQ port to communicate on
        V_100=5;        % Voltage where current begins to drop from 100%
        V_0=0;          % Voltage to set completetly off
        DAQ=[];         % NI DAQ Session
    end
    properties (Hidden)
        StartGUI=false; % Starts GUI 
    end
    
    methods
        function obj=ThorlabsLED(NIDevice,AOChannel)
            % Example, NIDevice= 'Dev1', AOChannel='ao0'
            obj=obj@mic.lightsource.abstract(~nargout);
            if nargin<2
                error('mic.lightsource.ThorlabsLED::NIDevice and AOChannel must be defined')
            end
            %Set up the NI Daq Object
            obj.DAQ = daq.createSession('ni');
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage');
            
            %Set to minimum power
            obj.setPower(obj.MinPower);
            obj.off();
        end
        
        function delete(obj)
            % Destructor
            obj.shutdown();
        end
        function setPower(obj,Power_in)
            % Sets power for the Lamp
            % Check if power_in is in the proper range
            if Power_in<obj.MinPower
                error('MPBLaser: Set_Power: Requested Power Below Minimum')
            end
            if Power_in>obj.MaxPower
                error('MPBLaser: Set_Power: Requested Power Above Maximum')
            end
            % Sets output power in percentage of maximum
            obj.Power=max(obj.MinPower,Power_in);
            obj.Power=min(obj.MaxPower,obj.Power);
            
            %Output voltage
            if obj.IsOn %Only set voltage if we are on
                V_out=obj.V_0-obj.Power/100*(obj.V_0-obj.V_100);
            else
                V_out=obj.V_0;  %turn off - should be redundant.
            end
            if ~isempty(obj.DAQ) %daq not yet created
                outputSingleScan(obj.DAQ,V_out);
            end
            obj.updateGui();  %update gui from current properties
            
        end
        
        function on(obj)
            % Turn on LED lamp
            obj.IsOn=1;
            obj.setPower(obj.Power);
        end
        
        function off(obj)
            % Turn off LED lamp
            V_out=obj.V_0;
            if ~isempty(obj.DAQ) %daq not yet created
                outputSingleScan(obj.DAQ,V_out);
            end
            obj.IsOn=0;
        end
        function [Attributes,Data,Children]=exportState(obj)
            % Export current state of the Laser (ON/OFF == 1/0)
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            % no Data is saved in this class
            Data=[];
            Children=[];
        end
        function shutdown(obj)
            % Set power to zero and turn it off.
            obj.setPower(0);
            obj.off();
            delete(obj.DAQ); % clear the port
            
        end
    end
    methods (Static=true)
        function funcTest(NIDevice,AOChannel)
            % Unit test of object functionality
            % Syntax: mic.lightsource.ThorlabsLED.funcTest(NIDevice,DOChannel)
            % Example:
            % mic.lightsource.ThorlabsLED.funcTest('Dev1','ao1');
            if nargin<2
                error('mic.lightsource.RebelStarLED::NIDevice and AOChannel must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            T_LED=mic.lightsource.ThorlabsLED(NIDevice,AOChannel);
            fprintf('Setting to Max Output\n')
            T_LED.setPower(100);
            fprintf('Turn On\n')
            T_LED.on();pause(1);
            fprintf('Turn Off\n')
            T_LED.off();;pause(1);
            fprintf('Turn On\n')
            T_LED.on();pause(1);
            fprintf('Setting to 50 Percent Output\n')
            T_LED.setPower(50);
            fprintf('Delete Object\n')
            State=exportState(T_LED);
            fprintf('State.Power=%d, State.IsOn=%d',State.Power,State.IsOn);
            fprintf('StateExport function is tested.');
            %Test Destructor
            clear T_LED;
            
            %Creating an Object and Repeat Test (to check if the port is clear completely)
            fprintf('Creating Object\n')
            T_LED=mic.lightsource.ThorlabsLED(NIDevice,AOChannel);
            fprintf('Setting to Max Output\n')
            T_LED.setPower(100);
            fprintf('Turn On\n')
            T_LED.on();pause(1);
            fprintf('Turn Off\n')
            T_LED.off();;pause(.5);
            fprintf('Turn On\n')
            T_LED.on();pause(.5);
            fprintf('Setting to 50 Percent Output\n')
            T_LED.setPower(50);
            fprintf('Delete Object\n')
            clear T_LED;
        end
        
    end
    
end
