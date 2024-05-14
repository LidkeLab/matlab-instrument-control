classdef MIC_CrystaLaser561 < MIC_LightSource_Abstract
    % MIC_CrystaLaser561: Matlab Instrument Class for control of CrystaLaser 561 nm.
    % 
    % ## Description: 
    % This class Controls CrystaLaser module; can switch the laser ON/OFF, but cannot  
    % set power. Power for this laser is set using the knob on the front 
    % panel of controller.
    % Requires TTL input from the Digital Input/Output channel of NI card
    % to turn the laser ON/OFF remotely. STP CAT6 cable connection from 
    % rear board of laser controller to the NI card should have pin
    % configuration: Pins 4-5: paired (for interlock); Pin 3: TTL; 
    % Pin6: GND.
    %
    % ## Constructor
    % Example: obj=MIC_CrystaLaser561('Dev1','Port0/Line0:1');
    % 
    % ## Key Functions
    % on, off, delete, shutdown, exportState, setPower 
    %
    % ## REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_LightSource_Abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    % 
    %   ### CITATION: Sandeep Pallikkuth, LidkeLab, 2017.

    
    properties (SetAccess=protected)
        InstrumentName='CrystaLaser561'; %Name of instrument
    end
    properties (SetAccess=protected)
        MinPower=0; % Minimum Power
        MaxPower=25; %Maximum Power
        PowerUnit='mW'; %Power Units
        IsOn=0; % ON/OFF state of Laser (1/0)
        Power; % Current Power
        DAQ; % NI card session
    end
    
    properties 
        StartGUI; % Starts GUI
    end
    
    methods
        function obj=MIC_CrystaLaser561(NIDevice,DOChannel)
            % Set up the NI Daq Object
            % Example: CL=MIC_CrystaLaser561('Dev1','Port0/Line0:1');
            if nargin<2
                error('NIDevice and DOChannel must be defined')
            end
            obj=obj@MIC_LightSource_Abstract(~nargout);
            obj.DAQ = daq.createSession('ni');
            addDigitalChannel(obj.DAQ,NIDevice,DOChannel, 'OutputOnly');
            DS1='This Laser does not provide software control of power. Please use the knob on front panel of controller';
            disp(DS1);
        end
        
        function on(obj)
            % Turns on Laser. 
            outputSingleScan(obj.DAQ,[0 1]);
            obj.IsOn=1; % Sets laser state to 1
        end
       
        function off(obj)
            % Turns off Laser. 
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
            outputSingleScan(obj.DAQ,[0 0]);
            obj.off();
            clear obj;
        end
        
        function [Attributes,Data,Children]=exportState(obj)     
            % Export current state of the Laser (ON/OFF == 1/0)
            Attributes.IsOn=obj.IsOn;
            Attributes.Power=obj.Power;
            Data = [];
            Children = [];
        end
        
        function setPower(obj,Power_in)
            % Sets power for the Laser, but disengaged since the laser power can only be set manually using the laser controller. 
            % Power range : 0 - 25 mW. 
            S1=('This Laser does not provide software control of power.');
            S2=('Please set the laser power using the knob on the front panel of laser controller');
            disp(S1);
            disp(S2); 
            Power=Power_in;
        end
    end
    methods (Static=true)
        function unitTest(NIDevice,DOChannel)
            % unit test of object functionality
            % Syntax: MIC_CrystaLaser561.unitTest(NIDevice,DOChannel)
            % Example:
            % MIC_CrystaLaser561.unitTest('Dev1','Port0/Line0:1')

            fprintf('Creating Object\n')
            CL=MIC_CrystaLaser561(NIDevice,DOChannel);
            fprintf('Turn On\n')
            CL.on();pause(1);
            fprintf('State Export\n')
            A=CL.exportState(); disp(A); pause(1);
            fprintf('Turn Off\n')
            CL.off();pause(1);
            fprintf('State Export\n')
            A=CL.exportState(); disp(A); pause(1);
            fprintf('Turn On\n')
            CL.on();pause(1);
            fprintf('State Export\n')
            A=CL.exportState(); disp(A); pause(1);
            fprintf('Delete Object\n')
            clear CL;

        end
    end
end
