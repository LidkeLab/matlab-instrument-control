classdef TIRFLaser488 < mic.lightsource.abstract
    % mic.lightsource.NewportLaser488: Matlab Instrument Class for Newport Cyan Laser 488 on TIRF microscope.
    %
    % ## Description
    %      The `mic.lightsource.TIRFLaser488` is a MATLAB instrument class for controlling the Newport Cyan Laser 488 used in
    %      TIRF (Total Internal Reflection Fluorescence) microscopy setups. It integrates functionalities for managing
    %      laser power through ND (Neutral Density) filter wheels and a shutter for toggling the laser ON and OFF.
    %
    % ## Requirements
    % - `mic.abstract.m`
    % - `mic.lightsource.abstract.m`
    % - `mic.NDFilterWheel.m`
    % - `mic.DynamixelServo.m`
    % - `mic.ShutterTTL.m`
    % - MATLAB (R2016b or later)
    % - Data Acquisition Toolbox
    %
    % ## Installation
    % Ensure all required files are in the MATLAB path and that your system is properly configured to interface with the hardware components.
    %
    % ## Protected Properties
    %
    % ### `InstrumentName`
    % Instrument name.
    % **Default:** `'TIRFLaser488'`.
    %
    % ### `PowerUnit`
    % Power unit based on each device.
    % **Default:** `'mW'`.
    %
    % ### `Power`
    % Currently set power based on the power limit.
    %
    % ### `IsOn`
    % Laser status (`1` for ON, `0` for OFF).
    % **Default:** `0`.
    %
    % ### `MinPower`
    % Lower limit for power.
    % **Default:** `0`.
    %
    % ### `MaxPower`
    % Upper limit for power.
    % **Default:** `100`.
    %
    % ## Private Properties (with Public Get Access)
    %
    % ### `LaserState`
    % State of the laser (`0` for OFF, other values for ON).
    % **Default:** `0`.
    %
    % ### `LaserStatus`
    % Status of the laser.
    %
    % ## Public Properties
    %
    % ### `VecIndex`
    % Finds the filter wheels combination closest to the user input power.
    %
    % ### `ShutterObj`
    % Shutter object.
    %
    % ### `FilterWheelObj1`
    % First filter wheel object.
    %
    % ### `FilterWheelObj2`
    % Second filter wheel object.
    %
    % ### `FilterPos`
    % Angle vector showing the position of all ND filters in a wheel.
    %
    % ### `FracTransmVals`
    % Transmission percentage vector for a set of ND filters.
    %
    % ### `Transmission`
    % Transmission percentage of both filter wheels.
    %
    % ### `StartGUI`
    % GUI control for the laser.
    % **Default:** `0`.
    %
    % ### `Laser488`
    % Laser object for the 488nm laser.
    %
    % ### `LaserPower`
    % Power of the laser.
    %
    % ### `LaserTag`
    % Tag identifier for the laser.
    %
    % ### `Serial`
    % Serial number of the 488 Laser COM port.
    %
    % ### `DOChannel`
    % Digital Output channel.
    %
    % ### `PowerIn`
    % User input for power.
    %
    % ### `PowerVector`
    % Vector showing different combinations of ND filters in two filter wheels.
    %
    % ### `DAQ`
    % Data acquisition (DAQ) object.
    % **Default:** `[]`.
    %
    % ## Key Functions:
    %       - on(obj): Opens the shutter to turn the laser ON.
    %       - Usage: obj.on();
    %
    %       - off(obj): Closes the shutter to turn the laser OFF.
    %       - Usage: obj.off();
    
    %       - setPower(obj, PowerIn): Sets the laser power by selecting the appropriate ND filters.
    %       - PowerIn should be within the allowed range of obj.MinPower to obj.MaxPower.
    %       - Usage: obj.setPower(50); % Sets power to 50 mW
    
    %       - exportState(obj): Exports the current state of the laser.
    %       - Returns a structure with fields for Power, IsOn, and InstrumentName.
    %       - Usage: state = obj.exportState();
    
    %       - delete(obj): Destructs the object and cleans up resources such as shutter and filter wheels.
    %       - Usage: delete(obj);
    
    %       - shutdown(obj): Safely shuts down the laser by turning it off and setting the power to zero.
    %       - Usage: obj.shutdown();
    % 
    % ## Usage
    % To create an instance of the `mic.lightsource.TIRFLaser488` class:
    % ```matlab
    % obj = mic.lightsource.TIRFLaser488();
    % % Create an object
    % laser = mic.lightsource.TIRFLaser488();
    %
    % % Set power to 70 mW
    % laser.setPower(70);
    %
    % % Turn the laser on
    % laser.on();
    %
    % % Wait for a moment
    % pause(1);
    %
    % % Turn the laser off
    % laser.off();
    %
    % % Clean up
    % laser.delete();
    % ```
    % ### CITATION: Sandeep Pallikkuth, Lidkelab, 2017.
    properties (SetAccess=protected)  
        InstrumentName = 'TIRFLaser488' %instrument name
    end
    
    properties (SetAccess = private, GetAccess = public)
        LaserState=0;
        LaserStatus;
    end
    
    properties
        VecIndex;  %finds the filterwheels combination closest to the user input power   
        ShutterObj;
        FilterWheelObj1;
        FilterWheelObj2;
        FilterPos; %angle vector to show position of all NDfilters in a wheel
        FracTransmVals; %transmission percentage vector for set of NDfilters
        Transmission; %transmission percentage of both 2 filter wheels
        StartGUI=0;
        Laser488;
        LaserPower;
        LaserTag;
        Serial; %Serial number of 488 Laser COM port
        DOChannel;
        PowerIn; %user power input
        PowerVector; %vector that shows different combinations of NDfilters in two filterwheels
        DAQ=[];
    end
    
    properties (SetAccess=protected)
        PowerUnit='mW';          % Power Unit based on each Device.
        Power;              % Currently Set Power based on Power Limit
        IsOn=0;               % LaserStatus, On=1, Off=0
        MinPower=0;           % Lower limit for power
        MaxPower=100;           % Upper limit for power
    end
    
    methods
        function obj=TIRFLaser488() %Constructor
            % inheritance:
            obj=obj@mic.lightsource.abstract(~nargout);
            % setup the shutter
            obj.ShutterObj=mic.ShutterTTL('Dev1','Port0/Line4');
            % setup the filterWheels
            obj.FracTransmVals=[1 0.51 0.28 0.11 0.065 0.017]; %transmission
            obj.Transmission=obj.FracTransmVals.*obj.FracTransmVals;
            obj.FilterPos=[0 60 120 180 240 300];
            obj.FilterWheelObj1=mic.NDFilterWheel(1, obj.FracTransmVals, [0 60 120 180 240 300]); 
            obj.FilterWheelObj2=mic.NDFilterWheel(2, obj.FracTransmVals, [0 60 120 180 240 300]); 
            % ND transmission calculation
            A=obj.FracTransmVals;
            indexCounter=1;
            for ii=1:6
                for jj=ii:6 %we don't want to have repetitive values
                        B(indexCounter,1)=ii;
                        B(indexCounter,2)=jj;
                        B(indexCounter,3)=A(ii).*A(jj);
                        indexCounter=indexCounter+1; 
                end
            end
            obj.Transmission=B;
            obj.PowerVector=obj.MaxPower.*obj.Transmission(:,3);
            obj.off(); 
        end
        
        
        function setPower(obj,PowerIn)
            % choose which combination of ND filters to use based on PowerIn
            if PowerIn<obj.MinPower
                fprintf('Input value outside the range of laser power. Set to Minimum Power\n');
            elseif PowerIn>obj.MaxPower
                fprintf('Input value outside the range of laser power. Set to Maximum Power\n');
            end
            PowerIn=max(obj.MinPower,PowerIn); % Makes sure the input power is greater than min_Power
            PowerIn=min(obj.MaxPower,PowerIn); % Makes sure the input power is smaller than max_power
            
               [obj.VecIndex]=find(min(abs(obj.PowerVector-PowerIn))==abs(obj.PowerVector-PowerIn));
               % Workaround for the issue of slot 3 on FilterWheel 2 not
               % functioning properly
               if obj.Transmission(obj.VecIndex,2)==3
                   obj.Transmission(obj.VecIndex,2)=obj.Transmission(obj.VecIndex,1);
                   obj.Transmission(obj.VecIndex,1)=3;
               end
               obj.FilterWheelObj1.setFilter(obj.Transmission(obj.VecIndex,1));
               obj.FilterWheelObj2.setFilter(obj.Transmission(obj.VecIndex,2));
               obj.Power=obj.PowerVector(obj.VecIndex);
               obj.updateGui();
        end
        
        
        function [Attribute,Data,Children]=exportState(obj)
            % Export the object current state
            Attribute.Power=obj.Power;
            Attribute.IsOn=obj.IsOn;
            Attribute.InstrumentName=obj.InstrumentName;
            Data=[];
            Children=[];
            
        end
        
        function on(obj) 
            % Turns ON laser by opening the shutter
            obj.IsOn=1;
            obj.ShutterObj.open; 
            obj.updateGui();
        end
       
        function off(obj) 
            % Turns OFF laser by closeing the shutter
            obj.IsOn=0;
            obj.ShutterObj.close;   % Sets laser state to 0
            obj.updateGui();
        end
        
        function delete(obj)
            % Destructor
            obj.shutdown();
            delete(obj.ShutterObj);
            delete(obj.FilterWheelObj1);
            delete(obj.FilterWheelObj2);
        end

        function shutdown(obj)
            % shutdown Laser
            obj.setPower(0);
            obj.off();
        end
        
    end

    methods (Static=true)
        function funcTest()
            %test of functionality 
            fprintf('Creating Object\n')
            NL=mic.lightsource.TIRFLaser488();
            fprintf('Setting to Max Output\n')
            NL.setPower(70); pause(1);
            fprintf('Turn Off\n')
            NL.off();pause(1);
            fprintf('Turn On\n')
            NL.on();pause(1);
            fprintf('Setting to 50 Percent Output\n')
            NL.setPower(25); pause(1);
            fprintf('Delete Object\n')
            clear NL;
            
        end
        
    end
    
end
