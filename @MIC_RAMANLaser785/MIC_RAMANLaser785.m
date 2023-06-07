classdef MIC_RAMANLaser785 < MIC_LightSource_Abstract
    %   MIC_RAMANLaser785: Matlab Instrument Class for controlling 785nm
    %   ONDAX laser used in RAMAN Lightsheet microscope
    %   
    %   The laser connects to computer using RS232-USB connection.
    %   Laser provides control over driver current. A calibration file is
    %   needed for current/power conversion.
    %
    %   Example: RL785= MIC_RAMANLaser785(COM3)
    %
    %   REQUIREMENTS:
    %   MIC_Abstract
    %   MIC_LightSource_Abstract
    %   MATLAB 2016b orlater
    %   Calibration.mat with 'CurrInterpol' and 'PowerInterpol'
    %
    % CITATION: Sandeep Pallikkuth, Lidkelab, 2020.

    
    properties (SetAccess=protected)
        InstrumentName='RAMANLaser785' % Descriptive Instrument Name
        Serial;                           % Serial number of COM port
    end
    
    properties (SetAccess=protected, GetAccess = public)
        Power;              % Currently Set Output Power
        PowerUnit='mW'      % Power Unit
        MinPower=0.00;      % Minimum Power Setting
        MaxPower=70;        % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
        LaserStatus;        % 1=Normal, 2=TTL modulation, 3=Laser Power Scan
        %   4=Waiting for calibrate laser power, 5=Over laser current
        %   shutdown, 6=TEC over temp shutdown, 7=Waiting temperature
        %   stable, 8=Waiting 30 seconds
        CurrInterpol;       % Interpolated current values from calibration
        PowerInterpol;      % Interpolated power values from calibration
    end
    properties
        StartGUI,
        
    end
    
    methods
        
        function obj=MIC_RAMANLaser785(SerialPort)
            % MIC_RAMANLaser785 contructor
            % Check the name for subclass from Abtract class
            obj=obj@MIC_LightSource_Abstract(~nargout);
            
            if nargin<1
                error('MIC_RAMANLaser785::SerialPort must be defined')
            end
            
            % INPUT: SerialPort    COM port number like 'COM3'
            s=instrfind('Type','serial','name',['Serial-',SerialPort]);
            
            if isempty(s)
                s = serial(SerialPort);
            else
                fclose(s);
                s = serial(SerialPort);
            end
            
            s.BaudRate=9600;
            s.Terminator='CR/LF';
            
            % Connect to instrument
            fopen(s);
            obj.Serial=s;
            
            % Current to wavelength calibration
            obj.calibrate();
                                                        
            % put initial value for Power=MinPower
            idx=0; warn7=0; warn8=0;
            while idx==0
                obj.getStatus();
                if obj.LaserStatus==8
                    idx=0;
                    if warn8==0
                        warning('MIC_RAMANLaser785: Waiting 30 seconds ...');
                        warn8=1;
                    end
                elseif obj.LaserStatus==7
                    idx=0;
                    if warn7==0
                        warning('MIC_RAMANLaser785: Waiting for temp to stabilize');
                        warn7=1;
                    end
                elseif obj.LaserStatus==1
                    obj.setPower(obj.MinPower);
                    idx=1;
                end
            end
        end
        
        function delete(obj)
            % Destructor
            obj.off();
            shutdown(obj)
            fclose(obj.Serial);
        end
        
        %Turn on Laser
        function on(obj)
            obj.IsOn=1;
        end
        %Turn off Laser
        function off(obj)
            obj.setPower(0.000);
            obj.IsOn=0;
        end
        
        function calibrate(obj)
            [p,~]=fileparts(which('MIC_RAMANLaser785'));
            if exist(fullfile(p,'Calibration.mat'),'file')
                a=load(fullfile(p,'Calibration.mat'));
%                 abc=fit(a.Current',a.Power','linearinterp');
%                 obj.CurrInterpol=1:1:400;
%                 obj.PowerInterpol=feval(abc,obj.CurrInterpol); 
                obj.CurrInterpol=a.CurrInterpol;
                obj.PowerInterpol=a.PowerInterpol;
            else
                error('MIC_RAMANLaser785: No laser calibration file detected. For the Raman Microscope, go to Y:\Projects\DOE Raman HSM\Equipment\Lasers and Lamps\785 nm Laser and run the LaserPowerCalibration code. This will generate the needed file. ')
            end            
        end
        
        function setPower(obj,Power_in)
            % Check if the Laser is ready
            obj.getStatus();
            obj.statusErrorCheck();
           
            % Check if power_in is in the proper range
            if Power_in<obj.MinPower
                error('MIC_RAMANLaser785: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_in>obj.MaxPower
                error('MIC_RAMANLaser785: Set_Power: Requested Power Above Maximum')
            end
            
            %Choose the appropriate current value
            [~,idx]=min(abs(obj.PowerInterpol-Power_in));
            setCurrent=obj.CurrInterpol(idx);
            newInput=['slc:' num2str(setCurrent)];
            
            % Set current value
            fprintf(obj.Serial,newInput);
            out=obj.ReadBuffer();
            if eq(out(1:2),'OK')
                obj.Power=Power_in;
            else
                error('MIC_RAMANLaser785: Set_Power: Unable to set power')
            end
        end
              
        % Read buffer in a case to get info from instrument
        function out=ReadBuffer(obj)
%             while obj.Serial.BytesAvailable
                out=fscanf(obj.Serial);
%             end
        end
        
        % Destructor
        function shutdown(obj)
            obj.IsOn=0;
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
            % Check if the Laser is ready
            obj.getStatus();
            obj.statusErrorCheck();

            fprintf(obj.Serial,'rli?');% Ask for current value
            out=obj.ReadBuffer();
            PresentCurr=str2double(out);
            [~,idx]=min(abs(obj.CurrInterpol-PresentCurr));
            obj.Power=obj.PowerInterpol(idx);
            fprintf('Current laser power: %f\n',obj.PowerInterpol(idx));
        end
        
        % Check the status of instrument
        function getStatus(obj)
            fprintf(obj.Serial,'rlrs?');
            out=obj.ReadBuffer();
            obj.LaserStatus=str2double(out);
       end
        
        function statusErrorCheck(obj)
            switch obj.LaserStatus
                case 4
                    error('MIC_RAMANLaser785: Waiting for calibrate laser power')
                case 5
                    error('MIC_RAMANLaser785: Over laser current shutdown')
                case 6
                    error('MIC_RAMANLaser785: TEC over temp shutdown')
                case 7
                    warning('MIC_RAMANLaser785: Waiting for temp to stabilize')
                case 8
                    warning('MIC_RAMANLaser785: Waiting 30 seconds ...')
            end
        end
    end
    
    
    methods (Static=true)
        function unitTest(SerialPort)
            % Unit test of object functionality
            
            if nargin<1
                error('MIC_RAMANLaser785::SerialPort must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L785=MIC_RAMANLaser785(SerialPort);
            fprintf('Show power on the screen\n')
            L785.getCurrentPower;
            fprintf('Setting to Max Output\n')
            L785.setPower(70);
            pause(.5);
            fprintf('Show power on the screen\n')
            L785.getCurrentPower;
            fprintf('Setting to 1 mW Output\n')
            L785.setPower(1);
            fprintf('Show power on the screen\n')
            L785.getCurrentPower;
            fprintf('Delete Object\n')
            %Test Destructor
            delete(L785);
            clear L785;
            
            %Creating an Object and Repeat Test
            fprintf('Creating Object\n')
            L785=MIC_RAMANLaser785(SerialPort);
            fprintf('Setting to Max Output\n')
            L785.setPower(70);
            pause(.5);
            fprintf('Show power on the screen\n')
            L785.getCurrentPower;
            fprintf('Setting to 1 mW Output\n')
            L785.setPower(1);
            pause(.5);
            fprintf('Show power on the screen\n')
            L785.getCurrentPower;
            fprintf('Testing exportState\n')
            State=L785.exportState()
            fprintf('Delete Object\n')
            delete(L785);
            clear L785;
            
        end
    end
end



