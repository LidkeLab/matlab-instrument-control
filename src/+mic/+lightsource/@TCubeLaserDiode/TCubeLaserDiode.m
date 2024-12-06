classdef TCubeLaserDiode < mic.lightsource.abstract
    % mic.lightsource.TCubeLaserDiode: Matlab Instrument Control Class for the ThorLabs TCube Laser Diode
    %
    % ## Description
    %   This class controls a Laser Diode through us USB connected ThorLabs TCube Laser
    %   Diode Driver TLD001.   Low level commands are via c-API functions
    %   in the ThorLabs Kinsesis API compiled to a set of mex64 functions.
    %   The max current should always be set on the TLD001 independently of
    %   this class specifically for the diode being used and before first use. 
    %   The WperA should be measured using a power meter and observing the 
    %   photodiode current in Kinesis.  
    %
    %   ## Notes:
    %  The object should never be cleared with 'clear all'.  Use
    %  'delete' or 'clear'. 
    %
    % ## Protected Properties
    %
    % ### `InstrumentName`
    % Descriptive name of the instrument.
    % **Default:** `'TCubeLaserDiode'`.
    %
    % ### `Power`
    % Currently set output power.
    % **Default:** `0`.
    %
    % ### `PowerUnit`
    % Unit for measuring power.
    % **Default:** `'mW'` (could be `mA` or `mW` depending on mode).
    %
    % ### `MinPower`
    % Minimum power setting.
    % **Default:** `0`.
    %
    % ### `MaxPower`
    % Maximum power setting.
    %
    % ### `IsOn`
    % On or off state of the device (`0` for OFF, `1` for ON).
    % **Default:** `0`.
    %
    % ### `SerialNo`
    % TCube serial number.
    %
    % ### `Mode`
    % Current or power mode.
    %
    % ### `WperA`
    % Laser diode (LD) power per ampere of photodiode (PD) current.
    %
    % ### `TIARange`
    % Photodiode current range (in mA).
    %
    % ## Hidden Properties
    %
    % ### `StartGUI`
    % Indicates whether the GUI should start when creating an instance of the class.
    % **Default:** `false`.
    %
    % ### `PowerSet`
    % Indicates if power was changed while the laser is off.
    % **Default:** `0`.
    
    % ## constructor
    % TLD=mic.lightsource.TCubeLaserDiode('64864827','Power',10,100,1)
    %
    % ## Key Functions: 
    % on, off, delete, shutdown, setPower, exportState, funcTest
    %
    % ## REQUIREMENT:
    %   mic.abstract.m
    %   mic.lightsource.abstract.m
    %   Kinesis Control Software Intalled: https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control
    %   Pre-compiled Kinesis_LD_*.mex64 files in path (typically in ../../mex64);
    %   Thorlabs.MotionControl.DeviceManager.dll and Thorlabs.MotionControl.TCube.LaserDiode
    %    must be in system path or in same folder as *.mex64 files.
    %
    % ## Serial Numbers:
    %   TIRF 642: 64838719
    %   RB 642: 64844464
    %   RB 405: 64864827
    %   SPT 642: 
    %   SEQ 405: 64841724
    %
    % ## Calibrations:
    %   TIRF 642, Feb 28, 2017:  I_LD=150 mA, I_PD=310.7 uA, P_LD=56.7 mW. WperA=182.5  
    %   RB 642, March 22, 2017:  I_LD=155.15 mA, I_PD=340.0 uA, P_LD=76.35 mW. WperA=224.6
    %   RB 405, March 22, 2017:  I_LD=69.99 mA, I_PD=981 uA, P_LD=40.15 mW. WperA=40.93
    %
    % ### CITATION: ,LidkeLab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName='TCubeLaserDiode' % Descriptive Instrument Name
        Power=0;            % Currently Set Output Power
        PowerUnit='mW'      % Power Unit mA or mW depending on mode
        MinPower=0;         % Minimum Power Setting
        MaxPower;           % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
        SerialNo;           % TCube Serial Number
        Mode;               % Current or Power Mode
        WperA;              % LD Power per A of PD current
        TIARange;           % Photodiode Current Range (mA);
    end
    
    properties (Hidden)
        StartGUI=false;     % Start gui when creating instance of class
        PowerSet;           % 0 when power is changed while laser is off. 
    end
    
    methods
        function obj=TCubeLaserDiode(SerialNo,Mode,MaxPower,WperA,TIARange)
            % Creates a mic.lightsource.TCubeLaserDiode object and sets output to minimum and turns off LED.
            
            if nargin<5
                error('mic.lightsource.TCubeLaserDiode::SerialNo,Mode,MaxPower,WperA,TIARange must be defined')
            end
            
            obj=obj@mic.lightsource.abstract(~nargout);
            
            %Save properties to object
            
            %Identify and Intialize Device
            Kinesis_LD_Identify(SerialNo);
            
            Err=Kinesis_LD_Open(SerialNo);
            if Err
                error('mic.lightsource.TCubeLaserDiode:: Could not open device')
            end
            switch Mode
                case 'Current'
                    obj.Mode=Mode;
                    Kinesis_LD_SetOpenLoopMode(SerialNo);
                    obj.PowerUnit='mA';
                case 'Power'
                    obj.Mode=Mode;
                    Kinesis_LD_SetWACalibFactor(SerialNo,single(WperA));
                    Kinesis_LD_SetClosedLoopMode(SerialNo);
                    obj.PowerUnit='mW';
                otherwise
                    error('mic.lightsource.RebelStarLED::Unknown Mode')
            end
            
            obj.MaxPower=MaxPower;
            obj.TIARange=TIARange;
            obj.WperA=WperA;
            obj.SerialNo=SerialNo;
            
            %Set to minimum power
            obj.setPower(obj.MinPower);
            obj.off();
        end
        
        function delete(obj)
            % Destructor
            obj.shutdown();
        end
        
        function setPower(obj,Power_in)
            % Sets output power in Mode dependent unit
            obj.Power=max(obj.MinPower,Power_in);
            obj.Power=min(obj.MaxPower,obj.Power);
            
            %Set Power
            switch obj.Mode
                case 'Current'
                    SetPoint=Power_in/220*32767;
                case 'Power'
                    SetPoint=Power_in/obj.WperA/obj.TIARange*32767;
            end
            
            if obj.IsOn
                [Err,SetP]=Kinesis_LD_SetLaserSetPoint(obj.SerialNo,uint32(SetPoint));
            else
                obj.PowerSet=0;
            end
                
        end
        
        function on(obj)
            % Turn on LED to currently set power.
            obj.IsOn=1;
            Kinesis_LD_EnableOutput(obj.SerialNo);
            %Set Power again if it has changed
            if ~obj.PowerSet
                obj.setPower(obj.Power); %Set Power if changed while off 
                obj.PowerSet=1;
            end
            pause(0.25)
        end
        
        function off(obj)
            % Turn off LED.
            Kinesis_LD_DisableOutput(obj.SerialNo);
            obj.IsOn=0;
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            Attributes.SerialNo=obj.SerialNo;
            Attributes.Mode=obj.Mode;
            Attributes.WperA=obj.WperA;
            Attributes.TIARange=obj.TIARange;
            Data=[];
            Children=[];
        end
        
        function shutdown(obj)
            % Set power to zero and turn off.
            obj.setPower(0);
            obj.off();
            Kinesis_LD_Close(obj.SerialNo);
        end
        
    end
    methods (Static=true)
        function Success=funcTest(SerialNo,Mode,MaxPower,WperA,TIARange)
            % Unit test of object functionality
            % Example:
            %   Success=mic.lightsource.TCubeLaserDiode.funcTest('64864827','Power',10,100,1)
            
            Success=0;
            if nargin<5
                error('mic.lightsource.TCubeLaserDiode::funcTest: SerialNo,Mode,MaxPower,WperA,TIARange must be defined')
            end
            
            fprintf('Creating Object\n')
            TLD=mic.lightsource.TCubeLaserDiode(SerialNo,Mode,MaxPower,WperA,TIARange);
            fprintf('Setting to 50 Percent Max Output\n')
            TLD.setPower(MaxPower/2);
            fprintf('Turn On\n')
            TLD.on();pause(.5);
            fprintf('Turn Off\n')
            TLD.off();pause(.5);
            fprintf('Turn On\n')
            TLD.on();pause(.5);
            fprintf('Setting to 12 Percent Output\n')
            TLD.setPower(MaxPower/8);
            
            pause(.5)
            fprintf('Delete Object\n')
            %Test Destructor
            State=TLD.exportState()
            delete(TLD);
            
            Success=1;
           
        end
        
    end
    
    
end

