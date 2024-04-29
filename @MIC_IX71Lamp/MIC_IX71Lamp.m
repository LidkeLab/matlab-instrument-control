classdef MIC_IX71Lamp < MIC_LightSource_Abstract
    % MIC_IX71Lamp Matlab Instrument Control Class for the MPB-laser.
    %
    % Controls the Olympus lamp, can turn it off and on and change the 
    % power. 
    %
    % Example: RS=MIC_IX71Lamp('Dev1','ao0','Port0/Line0');
    % Functions: constructor(), setPower(), on(), off(), exportState(),
    %            shutdown()
    %   
    % REQUIREMENTS:
    %   MIC_Abstract.m
    %   MIC_LightSource_Abstract.m
    %   MATLAB 2014 or higher.
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    % CITATION:
    % Mohamadreza Fazel and Hanieh Mazloom-Farsibaf, Lidkelab, 2017
 
    
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
        function obj=MIC_IX71Lamp(NIDevice,AOChannel,DOChannel)
            % Creates a MIC_IX71Lamp object and sets output to minimum and turns off LED. 
            % Example: RS=MIC_IX71Lamp('Dev1','ao0','Port0/Line0');
            obj=obj@MIC_LightSource_Abstract(~nargout);
            if nargin<2
                error('MIC_IX71Lamp::NIDevice, AOChannel and DOChannel must be defined.')
            end
            %Set up the NI Daq Object
            obj.DAQ_AC = daq.createSession('ni');
            %to control the lamp brightness
            addAnalogOutputChannel(obj.DAQ_AC,NIDevice,AOChannel, 'Voltage');
            %to turn off/on completely {This is required as setting V_0=0 doesn't 
            %turn off the lamp completely}
            obj.DAQ_DC = daq.createSession('ni');
            addDigitalChannel(obj.DAQ_DC,NIDevice,DOChannel, 'OutputOnly');

            %Set to minimum power
            outputSingleScan(obj.DAQ_DC,[0]);
        end
        function delete(obj)
            % Destructor
            delete(obj.GuiFigure);
            obj.shutdown();
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
                outputSingleScan(obj.DAQ_AC,V_out);
            end
            obj.updateGui;
        end
        function on(obj)
            % Turn on LED to currently set power. 
            obj.IsOn=1;
            outputSingleScan(obj.DAQ_DC,[1]);
            obj.setPower(obj.Power);
            pause(obj.LampWait);
            obj.updateGui;
        end
        function off(obj)
            % Turn off LED. 
            outputSingleScan(obj.DAQ_DC,[0]);
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
            function unitTest(NIDevice,AOChannel,DOChannel)
                % Unit test of object functionality
                
                try
                   TestObj=MIC_IX71Lamp(NIDevice,AOChannel,DOChannel);
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

