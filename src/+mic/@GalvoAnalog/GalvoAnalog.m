classdef GalvoAnalog < mic.abstract
    % miC_GalvoAnalog: Matlab Instrument Class for controlling Galvo Mirror
    %
    % ## Description
    % The `GalvoAnalog` class controls a Galvo mirror by setting its position through
    % a fixed output voltage using an NI (National Instruments) DAQ device. The Galvo mirror
    % is positioned by adjusting the analog output voltage within a specified range (-10V to 10V).
    %
    % ## Constructor
    %   obj=mic.GalvoAnalog('Dev1','ao1');
    %   - Initializes the GalvoAnalog object using the specified NI device (e.g., 'Dev1')
    %     and analog output channel (e.g., 'ao1').
    %
    % ## Key Functions
    % - **delete**: Cleans up the object and sets the output voltage to 0V.
    % - **exportState**: Exports the current state of the Galvo.
    % - **setVoltage**: Sets the Galvo position by adjusting the output voltage.
    %
    %  ## REQUIREMENTS:
    %  mic.abstract.m
    %  MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    %  ### CITATION: Marjolein Meddens, Lidke Lab 2017

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
        function obj=GalvoAnalog(NIDevice,AOChannel)
            % Object Constructor
            
            % for file naming convention
            obj=obj@mic.abstract(~nargout);
            
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
        
        function funcTest(NIDevice,AOChannel)
            % Testing the functionality of the instrument
            fprintf('Creating Object\n')
            Galvo=mic.GalvoAnalog(NIDevice,AOChannel);
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

