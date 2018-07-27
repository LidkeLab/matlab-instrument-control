classdef MIC_GalvoAnalog < MIC_Abstract
    %  MIC_GalvoAnalog: Matlab Instrument Class for controlling Galvo Mirror
    %
    %  Controls the Galvo mirror. The galvo mirror is controlled 
    %  via output voltage of NI card. The operating range is -10:10 Volts
    %
    %  Example: obj=MIC_GalvoAnalog('Dev1','ao1');
    %  Functions: delete, exportState, setVoltage 
    %
    %  REQUIREMENTS:
    %  MIC_Abstract.m
    %  MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    %  CITATION: Marjolein Meddens, Lidke Lab 2017
    
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
        function obj=MIC_GalvoAnalog(NIDevice,AOChannel)
            % Object Constructor
            
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
            % Deletes the object
            obj.setVoltage(0);
            close(obj.GuiFigure);
            delete(obj.DAQ);
        end
        
        function setVoltage(obj,V_in)
            % Sets voltage to V_in
            obj.Voltage=max(obj.MinVoltage,V_in);
            obj.Voltage=min(obj.MaxVoltage,obj.Voltage);            
            outputSingleScan(obj.DAQ,obj.Voltage);
        end
                
        function [Attributes,Data,Children]=exportState(obj)
            % Exports the object current state
            Attributes.Voltage=obj.Voltage;
            Attributes.MinVoltage=obj.MinVoltage;
            Attributes.MaxVoltage=obj.MaxVoltage;
            Data=[];
            Children=[];
        end
    end           
    
    methods (Static=true)
        
        function unitTest(NIDevice,AOChannel)
            % Testing the functionality of the instrument
            fprintf('Creating Object\n')
            Galvo=MIC_GalvoAnalog(NIDevice,AOChannel);
            fprintf('Setting Voltage to -5V\n');
            Galvo.setVoltage(-5);
            fprintf('Setting Voltage to 0V\n');
            Galvo.setVoltage(0);
            fprintf('Setting Voltage to 5V\n');
            Galvo.setVoltage(5);
            fprintf('Deleting Object\n')
            delete(Galvo);
        end
    end
end

