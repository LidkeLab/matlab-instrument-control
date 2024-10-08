classdef VortranLaser488 < mic.lightsource.abstract
    % mic.lightsource.VortranLaser488: Matlab Instrument Class for Vortran Laser 488.
    %
    % ## Description
    % Controls Vortran laser module, setting power within the range of 0 to
    % 50 mW. This is acheived by providing input voltage to the laser 
    % controller from a NI card (range 0 to 5V).
    % Needs input of NI Device and AO Channel.
    % The "External Control" and Max Power Range" for the laser needs to
    % be set by connecting the laser to the computer by miniUSB-USB cable
    % and using the Vortran_Stradus Laser Control Software Version 4.0.0
    % (CD located in second draw of filing cabinet in room 118).
    %
    % ## Constructor
    % obj=mic.lightsource.VortranLaser488('Dev1','ao1');
    % ## Key Functions: 
    % on, off, exportState, setPower, delete, shutdown
    %
    % ## REQUIREMENTS: 
    %   mic.Abstract.m
    %   mic.lightsource.abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    % ### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
    
    properties(SetAccess = protected)
        InstrumentName='VortranLaser488'; %Instrument Name
    end
    properties (SetAccess=protected)
        NIVolts=0; % NI Analog Voltage Initialisation
        MinPower=0; % Minimum Power of laser
        MaxPower=50; % Maximum power of laser
        PowerUnit='mW'; % Laser power units
        IsOn=0; % ON/OFF state of laser (1/0)
        Power=0; % Current power of laser
        DAQ; % NI card session
    end
    
    properties
        StartGUI; % Laser Gui
    end
    
    methods
        function obj=VortranLaser488(NIDevice,AOChannel)
            % Object constructor
            % Set up the NI Daq Object
            if nargin<2
                error('NIDevice and AOChannel must be defined')
            end
            obj=obj@mic.lightsource.abstract(~nargout);
            obj.DAQ = daq.createSession('ni');
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage');
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
            % Object Destructor
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
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            Data = [];
            Children = [];
        end
        
        function setPower(obj,Power_in)
            % Sets power for the Laser. Example: set.Power(obj,Power_in)
            % Power_in range : 0 - 50 mW. 
            Power=max(obj.MinPower,Power_in); % Makes sure the input power is greater than min_Power
            Power=min(obj.MaxPower,Power); % Makes sure the input power is smaller than max_power
            obj.Power=Power;
            NIVolts = 5*(obj.Power/(obj.MaxPower-obj.MinPower)); % calculates voltage corresponding to Power_in
            if obj.IsOn==1
            outputSingleScan(obj.DAQ,NIVolts); % sets voltage at NI card for Power_in
            end
        end
    end
            methods (Static=true)
            function funcTest(NIDevice,AOChannel)
                % unit test of object functionality
                % Example: VL=mic.lightsource.Vortranlaser488.funcTest('Dev1','ao1')
                fprintf('Creating Object\n')
                VL=mic.lightsource.VortranLaser488(NIDevice,AOChannel);
                fprintf('Setting to Max Output\n')
                VL.setPower(70); pause(1);
                fprintf('Turn Off\n')
                VL.off();pause(1);
                fprintf('Turn On\n')
                VL.on();pause(1);
                fprintf('Setting to 50 Percent Output\n')
                VL.setPower(25); pause(1);
                fprintf('Delete Object\n')
                clear VL;
                
            end
            
        end
 
end
