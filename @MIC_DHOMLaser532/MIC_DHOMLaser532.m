classdef MIC_DHOMLaser532 < MIC_LightSource_Abstract
   
    % # MIC_DHOMLaser532: Matlab Instrument Class for DHOM Laser 532.
    % ## Description 
    % This class controls DHOM laser module, setting power within the range of 0 to
    % 400 mW (measured on 2/23/2017). The power modulation 
    % is done by providing input analog voltage to the laser controller 
    % from a NI card (range 0 to 5V).
    % Needs input of NI Device and AO Channel.
    % ## Usage example
    % Example: obj=MIC_DHOMLaser532('Dev2','ao1');
    % Functions: on, off, State, setPower, delete, shutdown, exportState
    %
    % ## REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_LightSource_Abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    % CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
    
    properties(SetAccess = protected)
        InstrumentName='DHOMLaser532'; %Instrument Name
    end
    properties (SetAccess=protected)
        MinPower=0; % Minimum Power of laser
        MaxPower=400; % Maximum power of laser
        PowerUnit='mW'; % Laser power units
        IsOn=0; % ON/OFF state of laser (1/0)
        Power=0; % Current power of laser
    end
    
    properties(Hidden)
        NIVolts=0; % NI Analog Voltage Initialisation
        DAQ; % NI card session
    end
    
    properties
        StartGUI; % Laser Gui
    end
    
    methods
        function obj=MIC_DHOMLaser532(NIDevice,AOChannel)
            % Set up object
            if nargin<2
                error('NIDevice and AOChannel must be defined')
            end
            obj=obj@MIC_LightSource_Abstract(~nargout);
            obj.DAQ = daq.createSession('ni'); %Set up the NI Daq object
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage'); % Adding analog channel for power control
            obj.Power=obj.MinPower; % sets laser power to min_Power
        end
        
        function on(obj)
            % Turns on Laser. 
            obj.IsOn=1; % Sets laser state to 1
            obj.setPower(obj.Power); % Sets laser power to the last set power value
        end
       
        function off(obj)
            % Turns off Laser. 
            obj.setPower(0);   % Sets power to 0
            obj.IsOn=0;   % Sets laser state to 0
        end
        

        function delete(obj)
            % Destructor
            obj.shutdown();
            clear obj.DAQ;
            delete(obj);
        end

        function shutdown(obj)
            % Shuts down obj
            obj.setPower(0);
            obj.off();
        end
        
        function [Attributes,Data,Children]=exportState(obj)     
            % Export current state of the Laser
            Attributes.IsOn=obj.IsOn;
            Attributes.Power=obj.Power;
            Data = [];
            Children = [];
        end
        
        function setPower(obj,Power_in)
            % Sets power for the Laser. Example: set.Power(obj,Power_in)
            % Power_in range : 0 - 400 mW. 
            Power=max(obj.MinPower,Power_in); % Makes sure the input power is greater than min_Power
            Power=min(obj.MaxPower,Power); % Makes sure the input power is smaller than max_power
            obj.Power=Power;
            NIVolts = 5*(obj.Power/(obj.MaxPower-obj.MinPower)); % calculates voltage corresponding to Power_in
            if obj.IsOn==1
                %disp(NIVolts);
                outputSingleScan(obj.DAQ,NIVolts); % sets voltage at NI card for Power_in
            end
        end
    end
            methods (Static=true)
            function unitTest(NIDevice,AOChannel)
                % unit test of object functionality
                % Example: DL=MIC_DHOMLaser532.unitTest('Dev2','ao1')
                fprintf('Creating Object\n')
                DL=MIC_DHOMLaser532(NIDevice,AOChannel);
                fprintf('Setting to Max Output\n')
                DL.setPower(250); pause(1);
                fprintf('Turn On\n')
                DL.on();pause(1);
                fprintf('Turn Off\n')
                DL.off();pause(1);
                fprintf('Turn On\n')
                DL.on();pause(1);
                fprintf('Setting to 50 Percent Output\n')
                DL.setPower(125); pause(1);
                fprintf('Exporting state of laser\n')
                Abc=DL.exportState();disp(Abc);pause(1);clear Abc;
                fprintf('Delete Object\n')
                delete(DL);
                fprintf('Test for delete, try turning on the laser\n')
                try
                    CL.on();
                catch E
                    error(E.message);
                end
                
            end
            
        end
 
end
