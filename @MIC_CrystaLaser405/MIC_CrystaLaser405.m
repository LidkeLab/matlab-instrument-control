classdef MIC_CrystaLaser405 < MIC_LightSource_Abstract
    % MIC_CrystaLaser405: Matlab Instrument Class for CrystaLaser 405 nm.
    %
    % ## Description
    % Controls CrystaLaser module; setting power within the range of 0 to
    % 10 mW (The values measured on 2/23/2017 are 0.25 to 8.5 mW). 
    % The ON/OFF funtion is controlled by a TTL pulse and the power variation 
    % is acheived by providing analog voltage to the laser controller (range 0 to 10V).
    % The TTL pulse and analog voltage are provided by an NI card.
    % An STP CAT6 cable connection is needed from the rear board of the
    % laser controller to the Digital/Analog Input/Output channels of NI card. The
    % cable pin configuration is: 
    % Pins 4-5: paired (for interlock); Pin 2: Analog; Pin 3: TTL; Pin6: GND.
    % The power range of the laser is set using the knob on front panel of
    % controller.
    %
    % ## Note:
    % Please check the laser is turned on at the controller before calling funtions in 
    % this class
    %
    % ## Usage Example
    % Example: obj=MIC_CrystaLaser405('Dev1','ao1','Port0/Line3');
    %
    % ## Key Functions: 
    % on, off, State, setPower, delete, shutdown, unitTest
    %
    % ## REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_LightSource_Abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    % ### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
    
    properties(SetAccess = protected)
        InstrumentName='CrystaLaser405'; % Name of the instrument
    end
    properties (SetAccess=protected)
        NIVolts=0; % Analog voltage from NI card
        MinPower=0.25; % Minimum Power
        MaxPower=8.5; % Maximum Power
        PowerUnit='mW'; % Power Unit
        IsOn=0; % ON/OFF state of the laser (1/0)
        Power=0; % Current set power
        DAQ; % NI session
    end
    
    properties
        StartGUI; % Starts the gui
    end
    
    methods
        function obj=MIC_CrystaLaser405(NIDevice,AOChannel,DOChannel)
            %Set up the NI Daq Object
            if nargin<3
                error('NIDevice, AOChannel and DOChannel must be defined')
            end % checking for inputs
            obj = obj@MIC_LightSource_Abstract(~nargout); 
            obj.DAQ = daq.createSession('ni');
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage'); %Adds analog chennal for NI session
            addDigitalChannel(obj.DAQ,NIDevice,DOChannel, 'OutputOnly'); % Adds digital channel for NI session
            obj.Power=obj.MinPower; % sets laser power to min_Power
        end
        
        function on(obj)
            % Turns on Laser. 
            NIVolts = 5*(obj.Power/(obj.MaxPower-obj.MinPower)); % calculates voltage corresponding to Power_in
            outputSingleScan(obj.DAQ,[NIVolts 1]);
            obj.IsOn=1; % Sets laser state to 1
        end
       
        function off(obj)
            % Turns off Laser. 
            NIVolts = 5*(obj.Power/(obj.MaxPower-obj.MinPower)); % calculates voltage corresponding to Power_in
            outputSingleScan(obj.DAQ,[0 0]);
            obj.IsOn=0;   % Sets laser state to 0
        end
        

        function delete(obj)
            % Destructor
            obj.shutdown();
            clear obj.DAQ;
        end

        function shutdown(obj)
            % Shuts down obj
            obj.setPower(0);
            obj.off();
        end
        
        function [Attribute,Data,Children]=exportState(obj)     
            % Export current state of the Laser
            Attribute.Power=obj.Power;
            Attribute.IsOn=obj.IsOn;
            % no Data is saved in this class        
            Data=[];
            Children=[];

        end
        
        function setPower(obj,Power_in)
            % Sets power for the Laser. Example: setPower(obj,Power_in)
            % Power_in range : 0 - 10 mW. 
            if Power_in<obj.MinPower
                fprintf('Input value outside the range of laser power. Set to Minimum Power\n');
            elseif Power_in>obj.MaxPower
                fprintf('Input value outside the range of laser power. Set to Maximum Power\n');
            end
            Power=max(obj.MinPower,Power_in); % Makes sure the input power is greater than min_Power
            Power=min(obj.MaxPower,Power); % Makes sure the input power is smaller than max_power
                obj.Power=Power;
                NIVolts = 5*(obj.Power/(obj.MaxPower-obj.MinPower)); % calculates voltage corresponding to Power_in
                if obj.IsOn==1
                    outputSingleScan(obj.DAQ,[NIVolts 1]); % sets analog voltage at NI card for Power_in
%                    properties2gui();
                end
        end
    end
            methods (Static=true)
            function unitTest(NIDevice,AOChannel,DOChannel)
                % unit test of object functionality. 
                % This function cannot be called while the MIC_CrystaLaser405 class is being run.
                % Please use delete(obj) and then run unitTest.
                % Example:
                % MIC_CrystaLaser405.unitTest('Dev1','ao1','Port0/Line3')
                fprintf('Creating Object\n')
                CL=MIC_CrystaLaser405(NIDevice,AOChannel,DOChannel);
                fprintf('Turn On\n')
                CL.on();pause(1);
                fprintf('Setting to Max Output\n')
                CL.setPower(70); pause(1);
                fprintf('Turn Off\n')
                CL.off();pause(1);
                fprintf('Turn On\n')
                CL.on();pause(1);
                fprintf('Setting to 50 Percent Output\n')
                CL.setPower((CL.MaxPower-CL.MinPower)/2); pause(1);
                fprintf('Turn Off\n')
                CL.off();pause(1);
                fprintf('Delete Object\n')
                delete(CL);
 %               clear CL;
                fprintf('Test for delete, try turning on the laser\n')
                try
                    CL.on();
                catch E
                    error(E.message);
                end
            end
            
        end
end
