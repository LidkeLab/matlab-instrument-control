classdef CoherentLaser561 < mic.lightsource.abstract
%  mic.lightsource.CoherentLaser561 Class 
% 
% ## Description
% The `mic.lightsource.CoherentLaser561` class is a MATLAB Instrument Class for controlling the Coherent Sapphire Laser 561 via a USB connection. It integrates with additional classes like `NDFilterWheel` and `Shutter` to manage laser power output continuously from 0 to 100 mW, despite the laser controller's minimum power setting of 10 mW.
% 
% ## Requirements
% - MATLAB 2016b or later
% - mic.abstract
% - mic.lightsource.abstract
% - mic.NDFilterWheel
% - mic.DynamixelServo
% - mic.ShutterTTL
% 
% ## Installation
% Ensure that all required classes (`mic.abstract`, `mic.lightsource,abstract`, `mic.NDFilterWheel`, `mic.DynamixelServo`, `mic.ShutterTTL`) are in your MATLAB path. The laser connects via a specified COM port (e.g., 'COM3').
% 
% ## Protected Properties
% 
% ### `InstrumentName`  
% Descriptive name of the instrument.  
% **Default:** `'CoherentLaser561'`.
% 
% ### `Serial`  
% Serial number of the COM port.
% 
% ### `FilterWheel`  
% Object for `mic.NDFilterWheel` to change filters.
% 
% ### `Shutter`  
% Object for `mic.ShutterTTL` to control the shutter.
% 
% ## Protected Properties (Public Get Access)
% 
% ### `Power`  
% Currently set output power.
% 
% ### `PowerUnit`  
% Unit of power measurement.  
% **Default:** `'mW'`.
% 
% ### `MinPower`  
% Minimum power setting.  
% **Default:** `10 * 0.0125` (0.0125 is the least transmission factor for the filter wheel).
% 
% ### `MaxPower`  
% Maximum power setting.  
% **Default:** `100`.
% 
% ### `IsOn`  
% On or off state of the laser (`0` for OFF, `1` for ON).  
% **Default:** `0`.
% 
% ### `LaserStatus`  
% Status of the laser with the following states:
% - `1` = Startup
% - `2` = Warmup
% - `3` = Standby
% - `4` = Laser On
% - `5` = Laser Ready
% - `6` = Error
% 
% ### `Busy`  
% Indicates if the laser is busy (`0` for not busy).  
% **Default:** `0`.
% 
% ## Public Properties
% 
% ### `StartGUI`  
% Controls whether the GUI is started.
%
% ## Key Functions
% - **Constructor (`mic.lightsource.oherentLaser561(SerialPort)`):** Initializes the laser on a specified COM port, sets up the filter wheel and shutter, and establishes serial communication.
% - **`on()`:** Activates the laser, opening the shutter and setting the laser state to on.
% - **`off()`:** Deactivates the laser, closing the shutter and turning the laser off.
% - **`setPower(Power_in)`:** Adjusts the laser's output power. This method selects the appropriate filter based on the desired power setting and modifies the laser's power output accordingly.
% - **`getCurrentPower()`:** Fetches and displays the current power setting from the laser.
% - **`GetStatus()`:** Queries the laser for its current operational status, updating internal status Properties.
% - **`delete()`:** Safely terminates the connection to the laser, ensuring all resources are properly released.
% - **`exportState()`:** Exports a snapshot of the laser's current settings, including power and operational state.
% 
% ## Usage Example
% ```matlab
% % Create an instance of the Coherent Laser 561 on COM3
% CL561 = mic.lightsource.oherentLaser561('COM3');
% % Set power to 50 mW
% CL561.setPower(50);
% % Turn on the laser
% CL561.on();
% % Turn off the laser
% CL561.off();
% % Delete the object when done
% delete(CL561);
% ```    
% ### CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.  

    properties (SetAccess=protected)
        InstrumentName='CoherentLaser561' % Descriptive Instrument Name
        Serial;                           % Serial number of COM port
        FilterWheel;                      % an obj for mic.NDFilterWheel to change Filter
        Shutter;                          % an obj for mic.ShutterTTL to control Shutter
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
        
        function obj=CoherentLaser561(SerialPort)
            % mic.CoherentLaser561 contructor
            % Check the name for subclass from Abtract class
            obj=obj@mic.lightsource.abstract(~nargout);
            
            % INPUT: SerialPort    COM port number like 'COM4'
            %s=instrfind('Type','serial','name',['Serial-',SerialPort]);
            s = serialportfind(Tag=SerialPort);
            if isempty(s)
                %s = serial(SerialPort);
                s = serialport(SerialPort,19200,Tag=SerialPort);
            else
                delete(s);
                %s = s(1);
            end
            
            %s.BaudRate=19200;
            %s.Terminator='CR/LF';
            configureTerminator(s,"CR/LF")
            % Connect to instrument
            %fopen(s);
            obj.Serial=s;
            
            % Turn off the command prompt and echo
            %fprintf(s,'>=0');
            %ClearBuffer(obj)
            %fprintf(s,'E=0');
            %ClearBuffer(obj)
            

            obj.send('>=0')
            obj.send('E=0')

            % Make sure laser is on
            %fprintf(obj.Serial,['L=1']);
            %ClearBuffer(obj)
            obj.send('L=1')
            % Initialize FilterWheel
            % measured the power after the FilterWheel to calibrate
            % transmission Factor. For Laser561 is = [1 0.51 0.20 0.09 0.035 0.0125]
            obj.FilterWheel=mic.NDFilterWheel(3,[1 0.51 0.20 0.09 0.035 0.0125],[300 0 60 120 180 240]);
            
            % Initialize Shutter
            obj.Shutter=mic.ShutterTTL('Dev1','Port1/Line1');
            
            % put initial value for Power=MinPower
            obj.GetStatus();
            obj.setPower(obj.MinPower);
        end
        
        function delete(obj)
            % Destructor
            shutdown(obj)
            delete(obj.Serial);
            
        end
        
        %Turn on Laser
        function on(obj)
            obj.IsOn=1;
            obj.Shutter.open();
            %fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            %ClearBuffer(obj)
            obj.send(['L=', num2str(obj.IsOn)])
        end
        %Turn off Laser
        function off(obj)
            obj.Shutter.close();
            %fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            %ClearBuffer(obj)
            obj.send(['L=', num2str(obj.IsOn)])
            obj.IsOn=0;
        end
        
        function send(obj,Message)
            flush(obj.Serial)
            writeline(obj.Serial,Message)
        end

        function out = read(obj)
            Msg = readline(obj.Serial);
            out = readline(obj.Serial);
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
                error('mic.lightsource.CoherentLaser561: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_in>obj.MaxPower
                error('mic.lightsource.CoherentLaser561: Set_Power: Requested Power Above Maximum')
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
            %fprintf(obj.Serial,['P=',num2str(Power_temp)]);
            %ClearBuffer(obj)
            obj.send(['P=',num2str(Power_temp)])
            %             warning('It takes a few seconds to change the power')
            obj.Power=Power_in;
        end
        
        % Clear buffer
        %function ClearBuffer(obj)
        %    while obj.Serial.BytesAvailable
        %        fscanf(obj.Serial);
        %    end
        %end
        
        % Read buffer in a case to get info from instrument
        % function [out]=ReadBuffer(obj)
        %    out=fscanf(obj.Serial);
        %    while obj.Serial.BytesAvailable
        %        [a,b]=fscanf(obj.Serial);
        %        out=cat(2,out,a);
        %    end
        % end
        
        % Destructor
        function shutdown(obj)
            obj.off();
            obj.IsOn=0;
            %fprintf(obj.Serial,['L=', num2str(obj.IsOn)]);
            %ClearBuffer(obj)
            obj.send(['L=', num2str(obj.IsOn)]);
            flush(obj.Serial)
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
            obj.send('L=1')
            obj.send('?P')
            out = obj.read();
            %fprintf(obj.Serial,'L=1');
            %fprintf(obj.Serial,'?P');
            %[out]=ReadBuffer(obj);
            obj.Power=str2double(out);
        end
        
        % Check the status of instrument
        function GetStatus(obj)
            %ClearBuffer(obj)
            %fprintf(obj.Serial,'?STA');
            %[out]=ReadBuffer(obj);
            obj.send('?STA')
            out = obj.read();
            obj.LaserStatus=str2double(out);
        end
    end
    
    
    methods (Static=true)
        function funcTest(SerialPort)
            % Unit test of object functionality
            
            if nargin<1
                error('mic.lightsource.CoherentLaser561::SerialPort must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L561=mic.lightsource.CoherentLaser561(SerialPort);
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
            L561=mic.lightsource.CoherentLaser561(SerialPort);
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
            State=L561.exportState();
            delete(L561);
            clear L561;
            
        end
    end
end



