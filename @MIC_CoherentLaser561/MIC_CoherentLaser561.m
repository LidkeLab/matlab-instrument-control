classdef MIC_CoherentLaser561 < MIC_LightSource_Abstract
    %.  MIC_CoherentLaser561: Matlab Instrument Class for Coherent Sapphire Laser 561
    %   
    %   The laser connects to computer using USB connection.
    %   This class requies FilterWheel and Shutter class to control power.
    %   Minpower on the laser controller is 10 mW but by using Filter and
    %   Shutter it provides continuous variation from 0 to 100 mW. 
    %
    %   Example: CL561= MIC_CoherentLaser561(COM3)
    %
    %   REQUIREMENTS:
    %.  MIC_Abstract
    %.  MIC_LightSource_Abstract
    %   MIC_FilterWheel
    %   MIC_DynamixelServo
    %   MIC_ShutterTTL
    %.  MATLAB 2016b orlater
    %
    % CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.

    
    properties (SetAccess=protected)
        InstrumentName='CoherentLaser561' % Descriptive Instrument Name
        Serial;                           % Serial number of COM port
        FilterWheel;                      % an obj for MIC_NDFilterWheel to change Filter
        Shutter;                          % an obj for MIC_ShutterTTL to control Shutter
    end
    
    properties (SetAccess=protected, GetAccess = public)
        Power;            % Currently Set Output Power
        PowerUnit='mW' % Power Unit
        MinPower=10*0.0125; % Minimum Power Setting, 0.0125 is least TransmissionFactor for FilterWheel
        MaxPower=100;       % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
        LaserStatus;        % 1=Startup, 2=Warmup, 3=Standby, 4=laser on,
        % 5=laser ready, 6=Error
        Busy=0;
    end
    properties
        StartGUI,
        
    end
    
    methods
        
        function obj=MIC_CoherentLaser561(SerialPort)
            % MIC_CoherentLaser561 contructor
            % Check the name for subclass from Abtract class
            obj=obj@MIC_LightSource_Abstract(~nargout);
            
            % INPUT: SerialPort    COM port number like 'COM4'
            s=instrfind('Type','serial','name',['Serial-',SerialPort]);
            
            if isempty(s)
                s = serial(SerialPort);
            else
                fclose(s);
                s = s(1);
            end
            
            s.BaudRate=19200;
            s.Terminator='CR/LF';
            
            % Connect to instrument
            fopen(s);
            obj.Serial=s;
            
            % Turn off the command prompt and echo
            fprintf(s,'>=0');
            ClearBuffer(obj)
            fprintf(s,'E=0');
            ClearBuffer(obj)
            
            % Make sure laser is on
            fprintf(obj.Serial,['L=1']);
            ClearBuffer(obj)
           
            % Initialize FilterWheel
            % measured the power after the FilterWheel to calibrate
            % transmission Factor. For Laser561 is = [1 0.51 0.20 0.09 0.035 0.0125]
            obj.FilterWheel=MIC_NDFilterWheel(3,[1 0.51 0.20 0.09 0.035 0.0125],[300 0 60 120 180 240]);
            
            % Initialize Shutter
            obj.Shutter=MIC_ShutterTTL('Dev1','Port1/Line1');
            
            % put initial value for Power=MinPower
            obj.GetStatus();
            obj.setPower(obj.MinPower);
        end
        
        function delete(obj)
            % Destructor
            shutdown(obj)
            fclose(obj.Serial);
            
        end
        
        %Turn on Laser
        function on(obj)
            obj.IsOn=1;
            obj.Shutter.open();
            fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            ClearBuffer(obj)
            
        end
        %Turn off Laser
        function off(obj)
            obj.Shutter.close();
            fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            ClearBuffer(obj)
            obj.IsOn=0;
        end
        
        
        function setPower(obj,Power_in)
            % Check if the Laser is ready
            obj.GetStatus();
            if obj.LaserStatus~=5
                obj.updateGui();
                return
            end
            
            % Check if power_in is in the proper range
            if Power_in<obj.MinPower
                error('MIC_CoherentLaser561: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_in>obj.MaxPower
                error('MIC_CoherentLaser561: Set_Power: Requested Power Above Maximum')
            end
            
            %Choose the FilterID
            MaxPowerFilter=obj.FilterWheel.TransmissionValues.*100;
            temp=abs(MaxPowerFilter-Power_in);
            [Val index]=min(temp);
            if Power_in <= MaxPowerFilter(index)
                FilterID=index;
            else
                FilterID=index-1;
            end
            
            % Power_in for Laser
            Power_temp=Power_in/obj.FilterWheel.TransmissionValues(FilterID);
            
            % Rotate the filter wheel
            obj.FilterWheel.setFilter(FilterID);
           
            % Set the power on laser
            fprintf(obj.Serial,['P=',num2str(Power_temp)]);
            ClearBuffer(obj)
            %             warning('It takes a few seconds to change the power')
            obj.Power=Power_in;
        end
        
        % Clear buffer
        function ClearBuffer(obj)
            while obj.Serial.BytesAvailable
                fscanf(obj.Serial);
            end
        end
        
        % Read buffer in a case to get info from instrument
        function [out]=ReadBuffer(obj)
            out=fscanf(obj.Serial);
            while obj.Serial.BytesAvailable
                [a,b]=fscanf(obj.Serial);
                out=cat(2,out,a);
            end
        end
        
        % Destructor
        function shutdown(obj)
            obj.off();
            obj.IsOn=0;
            fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            ClearBuffer(obj)
        end
        
        function  [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            % no Data is saved in this class
            Data=[];
            Children=[];
        end
        
        % Check the power on the screen
        function getCurrentPower(obj)
            ClearBuffer(obj)
            fprintf(obj.Serial,'L=1');
            fprintf(obj.Serial,'?P');
            [out]=ReadBuffer(obj);
            obj.Power=str2double(out);
        end
        
        % Check the status of instrument
        function GetStatus(obj)
            ClearBuffer(obj)
            fprintf(obj.Serial,'?STA');
            [out]=ReadBuffer(obj);
            obj.LaserStatus=str2double(out);
        end
    end
    
    
    methods (Static=true)
        function unitTest(SerialPort)
            % Unit test of object functionality
            
            if nargin<1
                error('MIC_CoherentLaser561::SerialPort must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L561=MIC_CoherentLaser561(SerialPort);
            fprintf('Setting to Max Output\n')
            L561.setPower(100);
            fprintf('Turn On\n')
            L561.on();pause(.5);
            fprintf('Turn Off\n')
            L561.off();;pause(.5);
            fprintf('Turn On\n')
            L561.on();pause(.5);
            fprintf('Setting to 1 mW Output\n')
            L561.setPower(1);
            fprintf('Show power on the screen\n')
            L561.getCurrentPower;
            fprintf('Delete Object\n')
            %Test Destructor
            delete(L561);
            clear L561;
            
            %Creating an Object and Repeat Test
            fprintf('Creating Object\n')
            L561=MIC_CoherentLaser561(SerialPort);
            fprintf('Setting to Max Output\n')
            L561.setPower(100);
            fprintf('Turn On\n')
            L561.on();pause(.5);
            fprintf('Turn Off\n')
            L561.off();;pause(.5);
            fprintf('Turn On\n')
            L561.on();pause(.5);
            fprintf('Setting to 1 mW Output\n')
            L561.setPower(50);
            fprintf('Delete Object\n')
            State=L561.exportState()
            delete(L561);
            clear L561;
            
        end
    end
end



