classdef SyringePump < mic.abstract
    % mic.SyringePump Matlab Instrument Class for control of Syringe Pump by kdScientific (Model: LEGATO100)
    %
    % ## Description
    % This class controls the Syring Pump via a USB port. It is required to
    % install the drivers from the given CD drivers
    %
    % ## Constructor
    % obj=mic,SyringePump();
    %
    % ## Key Function: 
    % delete, getForce, getTarget, getTypeSyringe, setForce,
    % setTarget, setSyringe, setRate, run, stop, exportState, unitTest
    %
    % ## REQUIREMENTS:
    %   mic.abstract.m
    %   MATLAB software version R2016b or later
    %   Instrument Control Toolbox
    %   Syringe Pump driver installed via the CD drivers
    %
    % ### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
    properties (SetAccess=protected)
        InstrumentName='SyringPump'; %Name of instrument
        PumpAddress;                 %index for the each pump conencted to one computer
        SerialNumber;                %serial number of the device
    end
    properties
        StartGUI,                    % Starts GUI
    end
    
    properties
        S                            % Serial object
        Force;                       % force to pump in percent
        Target;                      % final volume for pumping
        Mode='Infuse Only'           % mode of pump
        Rate;                        % rate to pump
        %         Syringe;
        MaxRate;                     % maximum rate to pump, depends on the Syringe Type
        MinRate;                     % minimum rate to pump, depends on the Syringe Type
        SyringeVolume;               % Maximum volume of the syringe
        SyringeList;                 % all possible types of Syringe
        TypeSyringe='bdp'            % type of syringe
        N_typeSyringe=17;            % Number of syringe type used for this pump
        %         T_start_syringe=[];
    end
    
    methods
        function obj=SyringePump()
            
            %delete all open ports
            delete(instrfindall)
            
            %set a serial variable to connect to device
            obj.S=serial('COM3','BaudRate', 9600,'Terminator','CR/LF');
            fopen(obj.S);
            
            %define the serial number
            fprintf(obj.S,'version')
            fscanf(obj.S)
            
            %set the address, it is useful when there are more than one Syringe pump
            %fprintf(obj.S,'addr 00')
            [a b]=fscanf(obj.S)
            obj.PumpAddress=a(16:b)
            [c d]=fscanf(obj.S)
            obj.SerialNumber=c(16:d)
        end
        
        function delete(obj)
            % Destructor
            fclose(obj.S);
            delete(obj.S);
        end
        
        function out=getForce(obj)
            %read force from device
            fprintf(obj.S, 'force')
            out=fscanf(obj.S)
            obj.Force=[out(4) out(5)];
        end
        function out=getTarget(obj)
            %read target volume from device
            fprintf(obj.S,'target')
            out=fscanf(obj.S)
        end
        
        function getTypeSyringe(obj)
            %read type of syringe from device
            %                fprintf(S,'svolume')
            %? I may need to clear syringe first
            fprintf(obj.S,'syrm ?')
            
            for ii=1:obj.N_typeSyringe
                obj.SyringeList(ii)= fscanf(obj.S)
            end
        end
        function setForce(obj,fvalue)
            % set the level of force in percent
            % fvalue: valid range is 1 to 100
            if nargin<1
                error('choose an integr to set force')
            end
            if (fvalue <= 1 || fvalue >= 100)
                error('enter a positive integer between 1 to 100')
            end
            %             obj.Force=fprintf(obj.S,'force fvalue')
            fprintf(obj.S,'force fvalue')
        end
        
        function setTarget(obj,tvalue)
            fprintf(S,'ctvolume')
            
            if nargin<1
                error('enter a number to set target volume')
            end
            obj.setSyringe
            %             if
            %                 obj.Force=fprintf(obj.S,'target tvalue')
            %             end
            %
        end
        
        function setSyringe(obj)
            % if nargin<1
            %             error('enter from SyringeList to set type volume')
            % end
            
            fprintf(obj.S,'syrm')
            obj.SyringeList= fscanf(obj.S)
            % show all possible volume for a kind of Syringe.
            obj.TypeSyringe;
            % use it as a pop up menu
            fprintf(obj.S,'syrm obj.typesyringe code ?')
            
        end
        function setRate(obj,rvalue)
            %set the rate, valid range is 2.6553 nl/min to 2.75747 ml/min
            if rvalue
                fprintf(obj.S,'irate rvalue')
                
                % read the rate
                fprintf(obj.S,'irate')
                [a b]=fscanf(obj.S)
                
                
                
            end
        end
        
        function run(obj)
            fprintf(obj.S,'irun')
        end
        
        function stop(obj)
            fprintf(obj.S,'Stop')
            
        end
        
        
        
        
        
        
        
        %                 function errorcheck(obj,errorType)
        % switch errorType
        %     case  'Rate'
        %         if obj.Rate=[];
        %         error('Set the rate first, then press run')
        %         end
        %     case
        % end
        %                 end
        %
        
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export current state of the Laser (ON/OFF == 1/0)
            Attributes.Force=obj.Force;
            Attributes.Target=obj.Target;
            Attributes.SyringeType=obj.SyringeType;
            Attributes.Rate=obj.Rate;
            Data=[];
            Children=[];
        end
    end
    methods (Static=true)
        function unitTest()
            fprintf('Creating Syringe Pump object\n');
            SP=mic.SyringePump();
            fprintf('Run the pump\n');
            SP.run;
            pause(2);
            fprintf('Stop the pump\n');
            SP.stop;
            
            
            
        end
        
    end
    
end
