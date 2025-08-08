classdef IX71Lamp < mic.lightsource.abstract
% mic.lightsource.IX71Lamp Class 
% 
% ## Description
% The `mic.lightsource.IX71Lamp` class is a MATLAB Instrument Control Class used to manage the Olympus lamp, 
% which can be turned on and off and adjusted in terms of power. It is part of the microscope control framework 
% and is particularly useful for applications requiring precise light control.
% 
% ## Requirements
% - MATLAB 2014 or higher
% - Data Acquisition Toolbox
% - MATLAB NI-DAQmx driver installed via the Support Package Installer
% - mic.Abstract.m
% - mic.lightsource.abstract.m
% - Data Acquisition Toolbox Support Package for National Instruments
%   NI-DAQmx Devices: This add-on can be installed from link:
%   https://www.mathworks.com/matlabcentral/fileexchange/45086-data-acquisition-toolbox-support-package-for-national-instruments-ni-daqmx-devices
% 
% ## Protected Properties
% 
% ### `InstrumentName`  
% Descriptive name of the instrument.  
% **Default:** `'MIC_IX71Lamp'`.
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
% On or off state of the lamp (`0` for OFF, `1` for ON).  
% **Default:** `0`.
% 
% ### `LampWait`  
% Wait time (in seconds) used in the on function.  
% **Default:** `2`.
% 
% ### `V_100`  
% Voltage at which current begins to drop from 100%.  
% **Default:** `5`.
% 
% ### `V_0`  
% Voltage to completely turn off the lamp.  
% **Default:** `0`.
% 
% ### `DAQ_AC`  
% NI DAQ session for the analog channel.  
% **Default:** `[]`.
% 
% ### `DAQ_DC`  
% NI DAQ session for the digital channel.  
% **Default:** `[]`.
% 
% ## Public Properties
% 
% ### `StartGUI`  
% Indicates whether the GUI should start.
%
% ## Key Functions
% - **Constructor (`mic.lightsource.IX71Lamp(NIDevice, AOChannel, DOChannel)`):** Initializes the lamp control with specified NI DAQ channels. It sets the output to the minimum and ensures the lamp is off initially.
% - **`setPower(Power_in)`:** Sets the lamp's output power as a percentage of its maximum, with adjustments made through the DAQ device.
% - **`on()`:** Turns on the lamp using the digital channel to ensure full activation and sets the power to the previously specified level.
% - **`off()`:** Completely turns off the lamp using the digital channel.
% - **`delete()`:** Cleans up the object, ensuring the lamp is properly shut down to prevent damage or resource locking.
% - **`shutdown()`:** Safely turns off the lamp and sets its power to zero.
% - **`exportState()`:** Exports the current state of the lamp, including power settings and on/off status.
% 
% ## Usage Example
% ```matlab
% % Define the NI DAQ device and channels
% NIDevice = 'Dev1';
% AOChannel = 'ao0';
% DOChannel = 'Port0/Line0';
% 
% % Create an instance of the IX71 lamp control
% lamp = mic.lightsource.IX71Lamp(NIDevice, AOChannel, DOChannel);
% 
% % Set the lamp to 50% power and turn it on
% lamp.setPower(50);
% lamp.on();
% 
% % Turn off the lamp and clean up
% lamp.off();
% delete(lamp);
% ``` 
% ### CITATION: Mohamadreza Fazel and Hanieh Mazloom-Farsibaf, Lidkelab, 2017   
    
   properties (SetAccess=protected)
        InstrumentName='MIC_IX71Lamp' % Descriptive Instrument Name
        Power=0;            % Currently Set Output Power
        PowerUnit='Percent' % Power Unit 
        MinPower=0;         % Minimum Power Setting
        MaxPower=100;       % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
        LampWait=2;         % Wait time in the on function
   end
    
    properties (SetAccess=protected)      
        V_100=5;      % Voltage where current begins to drop from 100%
        V_0=0;          % Voltage to set completetly off
        DAQ_AC=[];         % NI DAQ Session for Analog channel
        DAQ_DC=[];  % NI DAQ Session for Digital channel
    end
    
    properties 
        StartGUI;
    end
    
    methods
        function obj=IX71Lamp(NIDevice,AOChannel,DOChannel)
            % Creates a mic.lightsource.IX71Lamp object and sets output to minimum and turns off LED. 
            % Example: RS=mic.lightsource.IX71Lamp('Dev1','ao0','Port0/Line0');
            obj=obj@mic.lightsource.abstract(~nargout);
            if nargin<2
                error('mic.lightsource.IX71Lamp::NIDevice, AOChannel and DOChannel must be defined.')
            end
            %Set up the NI Daq Object
            obj.DAQ_AC = daq("ni");
            %to control the lamp brightness
            addoutput(obj.DAQ_AC,NIDevice,AOChannel, 'Voltage');
            %to turn off/on completely {This is required as setting V_0=0 doesn't 
            %turn off the lamp completely}
            obj.DAQ_DC = daq("ni");
            addoutput(obj.DAQ_DC,NIDevice,DOChannel, 'Digital');

            %Set to minimum power
            write(obj.DAQ_DC,[0]);
        end
        function delete(obj)
            % Destructor
            delete(obj.GuiFigure);
            obj.shutdown();
            clear obj.DAQ_DC obj.DAQ_AC
        end
        function setPower(obj,Power_in)
            % Sets output power in percentage of maximum
            obj.Power=max(obj.MinPower,Power_in);
            obj.Power=min(obj.MaxPower,obj.Power);
            
            %Output voltage
            if obj.IsOn %Only set voltage if we are on
            V_out=obj.V_0-obj.Power/100*(obj.V_0-obj.V_100);
            else
                V_out=obj.V_0;  %turn off - should be redundant. 
            end    
            if ~isempty(obj.DAQ_AC) %daq not yet created
                write(obj.DAQ_AC,V_out);
            end
            obj.updateGui;
        end
        function on(obj)
            % Turn on LED to currently set power. 
            obj.IsOn=1;
            write(obj.DAQ_DC,[1]);
            obj.setPower(obj.Power);
            pause(obj.LampWait);
            obj.updateGui;
        end
        function off(obj)
            % Turn off LED. 
            write(obj.DAQ_DC,[0]);
            obj.IsOn=0;
            obj.updateGui;
            pause(obj.LampWait);
        end
        function [State, Data,Children]=exportState(obj)
            % Export the object current state
            State.instrumentName=obj.InstrumentName;
            State.Power=obj.Power;
            State.IsOn=obj.IsOn;
            Data=[];
            Children=[];
        end
        function shutdown(obj)
            % Set power to zero and turn off. 
            obj.setPower(0);
            obj.off();
        end
        
    end
        methods (Static=true)
            function funcTest(NIDevice,AOChannel,DOChannel)
                % Unit test of object functionality
                
                try
                   TestObj=mic.lightsource.IX71Lamp(NIDevice,AOChannel,DOChannel);
                   fprintf('The object was successfully created.\n');
                   on(TestObj); 
                   fprintf('The lamp power is set to 0 percent and turned on.\n');
                   setPower(TestObj,TestObj.MaxPower);
                   fprintf('The power is successfully set to the max power.\n');pause(1);
                   off(TestObj);
                   fprintf('The lamp is off.\n');pause(1);
                   delete(TestObj);
                   fprintf('The device is deleted.\n');
                   fprintf('The class is successfully tested :)\n');
               catch E
                   fprintf('Sorry, an error occured :(\n');
                   error(E.message);
               end
            end
            
        end
    
end

