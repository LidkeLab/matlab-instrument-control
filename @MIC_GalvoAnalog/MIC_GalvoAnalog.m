classdef MIC_GalvoAnalog < MIC_Abstract
    %MIC_GalvoAnalog controls Galvo Mirror
    %
    %  Instrument control class for Galvo mirror
    %  Control is via output voltage of NI card. Range is -10:10 Volt
    %
    %  REQUIREMENTS:
    %  MIC_Abstract.m
    %  MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    %  Example: obj=MIC_GalvoAnalog('Dev1','ao1');
    %
    
    % Marjolein Meddens, Lidke Lab 2017
    
    properties(SetAccess=protected)
        InstrumentName='GalvoAnalog' % Descriptive Instrument Name
        Voltage; % Current Voltage
        DAQ;    % NI daq session
        MinVoltage = -10; % Minimum output voltage of NI card
        MaxVoltage = 10;  % Maximum output voltage of NI card
    end
    
    properties (Hidden)
        StartGUI=false;    % to pop up gui by creating an object for this class
    end
            
    methods
        % Constructor 
        function obj=MIC_GalvoAnalog(NIDevice,AOChannel)
            % Example: GMirror=MIC_GalvoAnalog('Dev1','ao1');
            
            % for file naming convention
            obj=obj@MIC_Abstract(~nargout);
            
            % check input
            if nargin<2
                error('NIDevice and AOChannel must be defined')
            end
            
            % intialize nidaq session
            obj.DAQ = daq.createSession('ni');
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage');
            
            % start at 0V
            obj.setVoltage(0);
        end
        
        % Destructor
        function delete(obj)
            obj.setVoltage(0);
            close(obj.GuiFigure);
            delete(obj.DAQ);
        end
        
        function setVoltage(obj,V_in)
            obj.Voltage=max(obj.MinVoltage,V_in);
            obj.Voltage=min(obj.MaxVoltage,obj.Voltage);            
            outputSingleScan(obj.DAQ,obj.Voltage);
        end
                
        function [State,Data,Children]=exportState(obj)
            % Export the object current state
            State.Voltage=obj.Voltage;
            State.MinVoltage=obj.MinVoltage;
            State.MaxVoltage=obj.MaxVoltage;
            Data=[];
            Children=[];
        end
    end           
    
    methods (Static=true)
        
        function unitTest(NIDevice,AOChannel)
            Galvo=MIC_GalvoAnalog(NIDevice,AOChannel);
            delete(Galvo);
        end
    end
end

