
classdef MIC_TIRF488Laser < MIC_LightSource_Abstract
    %MIC_NewportLaser488 Matlab Instrument Class for Newport Cyan Laser 488
    %on TIRF microscope
    % REQUIREMENTS:
    % NiDAQ card 
    % Shutter
    % filterwheel
    % MIC_DynamixelServo
    
    % Functions: on, off, State, setPower, delete, shutdown, unitTest
        
    properties (SetAccess=protected)  
        InstrumentName = 'NewportLaser488' %instrument name
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
        function obj=MIC_TIRF488Laser() %Constructor
            %inheritance:
            obj=obj@MIC_LightSource_Abstract(~nargout);
            %setup the shutter
            obj.ShutterObj=MIC_ShutterTTL('Dev1','Port0/Line4');
            %setup the filterWheels
            obj.FracTransmVals=[1 0.51 0.28 0.11 0.065 0.017]; %transmission
            obj.Transmission=obj.FracTransmVals.*obj.FracTransmVals;
            obj.FilterPos=[0 60 120 180 240 300];
            obj.FilterWheelObj1=MIC_NDFilterWheel(1, obj.FracTransmVals, [0 60 120 180 240 300]); 
            obj.FilterWheelObj2=MIC_NDFilterWheel(2, obj.FracTransmVals, [0 60 120 180 240 300]); 
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
            %choose which combination of ND filters to use based on PowerIn
            if PowerIn<obj.MinPower
                fprintf('Input value outside the range of laser power. Set to Minimum Power\n');
            elseif PowerIn>obj.MaxPower
                fprintf('Input value outside the range of laser power. Set to Maximum Power\n');
            end
            PowerIn=max(obj.MinPower,PowerIn); % Makes sure the input power is greater than min_Power
            PowerIn=min(obj.MaxPower,PowerIn); % Makes sure the input power is smaller than max_power
            
               [obj.VecIndex]=find(min(abs(obj.PowerVector-PowerIn))==abs(obj.PowerVector-PowerIn));
               obj.FilterWheelObj1.setFilter(obj.Transmission(obj.VecIndex,1));
               obj.FilterWheelObj2.setFilter(obj.Transmission(obj.VecIndex,2));
               obj.Power=obj.PowerVector(obj.VecIndex);
               obj.updateGui();
        end
        
        
        function [Attribute  Data]=exportState(obj)
            % Export the object current state
            Attribute.Power=obj.Power;
            Attribute.IsOn=obj.IsOn;
            Attribute.InstrumentName=obj.InstrumentName;
            % no Data is saved in this class
            Data=[];
            
        end
        
        function on(obj) %opens the shutter
            obj.IsOn=1;
            obj.ShutterObj.open; 
            obj.updateGui();
        end
       
        function off(obj) %closes the shutter
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
            obj.setPower(0);
            obj.off();
        end
        
    end

    methods (Static=true)
        function unitTest()
            %test of functionality 
            fprintf('Creating Object\n')
            NL=MIC_NewportLaser488();
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