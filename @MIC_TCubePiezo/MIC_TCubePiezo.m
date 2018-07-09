classdef MIC_TCubePiezo < MIC_LinearStage_Abstract
    % MIC_TCubePiezo Matlab Instrument Control Class for ThorLabs TCube Piezo
    %
    %   This class controls a linear piezo stage using the Thorlabs TCube Piezo
    %   controller TPZ001 and TCube strain gauge controller TSG001. It uses the Thorlabs 
    %   Kinesis C-API via pre-complied mex files. 
    %   
    % USAGE:
    %   PX=MIC_TCubePiezo(SerialNoTPZ001,SerialNoTSG001,AxisLabel)
    %   PX.gui()
    %   PX.setPosition(10);
    %
    % Kinesis Setup:
    %   change these settings in Piezo device on Kinesis Software GUI before you create object:
    %   1-set on "External SMA signal" (in Advanced settings: Drive Input Settings)
    %   2-set on "Software+Potentiometer" (in Advanced settings: Input Source)
    %   3-set on "closed loop" (in Control: Feedback Loop Settings>Loop Mode)
    %   4-check box of "Persist Settings to the Device" (in Settings)
    %
    % REQUIRES: 
    %   MIC_Abstract.m
    %   MIC_LinearStage_Abstract.m
    %   Precompiled set of mex files Kinesis_PCC_*.mex64 and Kinesis_SG_*.mex64
    %   The following dll must be in system path or same directory as mex files: 
    %   Thorlabs.MotionControl.TCube.Piezo.dll
    %   Thorlabs.MotionControl.TCube.StrainGauge.dll
    %   Thorlabs.MotionControl.DeviceManager.dll
    %
    % CITATION: Keith Lidke, LidkeLab, 2017.
    
    properties (SetAccess=protected)
        PositionUnit='um';          % Units of position parameter (eg. um/mm)
        CurrentPosition=0;          % Current position of device
        MinPosition=0;              % Lower limit position 
        MaxPosition=20;             % Upper limit position
        Axis;                       % Stage axis (X, Y or Z)
        SerialNoTPZ001;             % Serial Number of TCube Piezo Controller
        SerialNoTSG001;             % Serial Number of TCube Strain Gauge Controller
        Slope;                      % Strain Gauge Calibration Parameter
        Offset;                     % Strain Gauge Calibration Parameter
        InstrumentName='TCubePiezo' % Instrument name. 
    end
    
    properties (SetAccess=protected)
        WaitTime=0;                 %Time to wait before returning after a setPosition (s)
    end
    
    properties (Hidden)
        StartGUI; % Start gui when creating instance of class
    end
    
    methods
        function obj=MIC_TCubePiezo(SerialNoTPZ001,SerialNoTSG001,AxisLabel)
            % Creates a MIC_TCubePiezo object and centers the stage.  
            % Example: PX=MIC_TCubePiezo('81843229','84842506','X')
            obj=obj@MIC_LinearStage_Abstract(~nargout);
           
            if nargin<3
                error('MIC_TCubePiezo::SerialNoTPZ001,SerialNoTSG001,AxisLabel must be defined')
            end
            
            obj.SerialNoTPZ001=SerialNoTPZ001;
            obj.SerialNoTSG001=SerialNoTSG001;
            obj.Axis=AxisLabel;
            
            %Open Devices (This may crash)
            obj.openDevices();
            
            %Zero the Strain Gauge
            obj.zeroStainGauge();
            
            %Calibrate the Strain Gauge
            obj.calibrateStrainGauge();
            
            %Center
            obj.center();
            
        end
        function delete(obj)
            % Destructor.  
            obj.shutdown();
        end
        
        function Err=openDevices(obj)
            % Opens communications to PZ and SG with Kinesis C-API via mex
            
             Kinesis_TLI_BuildDeviceList(); 
            pause(1);  %Try to prevent crash
            
            ErrSG=Kinesis_SG_Open(obj.SerialNoTSG001);
            if ErrSG
                error('openDevices::Error opening strain gauge controller')
            end
            
            ErrPZ=Kinesis_PCC_Open(obj.SerialNoTPZ001);
            if ErrPZ
                error('openDevices::Error opening piezo controller')
            end
            Err=(ErrSG==0)&(ErrPZ==0);
            
        end
        
        function closeDevices(obj)
            % Closes communications to PZ and SG with Kinesis C-API via mex
            % This must be done before using Kinesis or creating new
            % objects. 
            Kinesis_PCC_Close(obj.SerialNoTPZ001)
            Kinesis_SG_Close(obj.SerialNoTSG001)
        end
        
        function resetDevices(obj)
            % Close and Reopen Devices.  
           obj.closeDevices();
           obj.openDevices();
        end
        
        function zeroStainGauge(obj)
            % Intiates automatic Voltage-Position Calibration of the 
            SN=obj.SerialNoTPZ001;
            SNSG=obj.SerialNoTSG001;
            
            %Set to open loop and voltage to zero
            Kinesis_PCC_SetPositionControlMode(SN,uint16(2))
            Kinesis_PCC_SetPosition(SN,uint32(0))
            pause(4)
            Kinesis_PCC_SetPositionControlMode(SN,uint16(1))
            Kinesis_PCC_SetPosition(SN,uint32(0))
            
            %Zero strain gauge
            Kinesis_SG_SetZero(SNSG) % This needs wait till finished inside mex.
            
            %Set to closed loop and voltage to zero
            Kinesis_PCC_SetPositionControlMode(SN,uint16(2))
        end
        
        function calibrateStrainGauge(obj)
            %Calibrate the Piezo/Strain Gauge.  Required for accurate positions.
            SN=obj.SerialNoTPZ001;
            SNSG=obj.SerialNoTSG001;
            
            %Calibration
            Kinesis_PCC_SetPosition(SN,uint32(0.2*2^16));
            pause(5)
            PZ20=Kinesis_SG_GetReading(SNSG)/2^15*20;
            
            Kinesis_PCC_SetPosition(SN,uint32(0.8*2^16));
            pause(5)
            PZ80=Kinesis_SG_GetReading(SNSG)/2^15*20;
            
            obj.Slope=0.6*2^16/(PZ80-PZ20);
            obj.Offset=0.2*2^16/obj.Slope-PZ20;  
        end
        
        
        function setPosition(obj,Position)
            % Sets Piezo Stage Position in microns. 
            obj.CurrentPosition=max(obj.MinPosition,Position);
            obj.CurrentPosition=min(obj.MaxPosition,obj.CurrentPosition);
            
            Kinesis_PCC_SetPosition(obj.SerialNoTPZ001,uint32((obj.CurrentPosition+obj.Offset)*obj.Slope)); 
            pause(obj.WaitTime);
            obj.updateGui();
            
        end
        
        function Position=getPosition(obj)
            %Returns the currently set position
            Position=obj.CurrentPosition;
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.PositionUnit=obj.PositionUnit;
            Attributes.CurrentPosition=obj.CurrentPosition;
            Attributes.MinPosition=obj.MinPosition;
            Attributes.MaxPosition=obj.MaxPosition;
            Attributes.Axis=obj.Axis;
            Attributes.SerialNoTPZ001=obj.SerialNoTPZ001;
            Attributes.SerialNoTSG001=obj.SerialNoTSG001;
            Attributes.Offset=obj.Offset;
            Attributes.Slope=obj.Slope;
            Attributes.InstrumentName=obj.InstrumentName;
            Data=[];
            Children=[];
        end
        
        function shutdown(obj)
            % Set power to zero and turn off. 
            obj.closeDevices();
        end
        
    end
        methods (Static=true)
            function Success=unitTest(SNP,SNSG,AxisLabel)
                % Unit test of object functionality
                % Example: MIC_TCubePiezo.unitTest('81843229','84842506','X')
                
                if nargin<3
                    error('MIC_TCubePiezo::SerialNoTPZ001,SerialNoTSG001,AxisLabel must be defined')
                end
                
                try
                    %Creating an Object and Testing setPower, on, off
                    fprintf('Creating Object and testing...\n')
                    P=MIC_TCubePiezo(SNP,SNSG,AxisLabel);
                    P.gui;
                    P.setPosition(P.MaxPosition/8);
                    pause(1);
                    P.center();
                    pause(1);
                    P.setPosition(P.MaxPosition*7/8);
                    pause(1);
                    P.exportState()
                    delete(P);
                    fprintf('Deleteing Object.\n')
                    clear RS;
                    Success=1;
                catch
                    warning('MIC_TCubePiezo:: Failed Unit Test');
                    clear RS;
                    Success=0;
                end
                
            end
            
        end
        
    
end