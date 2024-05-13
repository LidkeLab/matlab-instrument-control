classdef MIC_HSM488Laser<MIC_LightSource_Abstract

% MIC_HSM488Laser Class 
% 
% ## Description
% The `MIC_HSM488Laser` class is used for controlling the HSM 488 nm laser, part of the MIC framework. 
% The laser control involves manual operation as well as automated control via a shutter and an attenuator. 
% This class assumes the laser is manually turned on using its controller on the top shelf of the HSM table and is 
% controlled programmatically using a shutter and an LCC in front of the laser.
% 
% ## Requirements
% - MIC_LightSource_Abstract.m
% - MIC_ShutterTTL.m
% - MIC_Attenuator.m
% 
% ## Key Functions
% - **Constructor (`MIC_HSM488Laser()`):** Initializes the laser, setting up the shutter and attenuator for operational control.
% - **`on()`:** Opens the shutter and sets the laser transmission to the current value, effectively turning the laser on.
% - **`off()`:** Closes the shutter and sets the laser transmission to the minimum value, turning the laser off.
% - **`setPower(Power_in, FilterID)`:** Sets the desired output power of the laser. `FilterID` can only be 2, 4, or 6, with other IDs blocking the beam due to the damage threshold of the attenuator.
% - **`delete()`:** Properly cleans up and shuts down the laser connection when the object is deleted.
% - **`shutdown()`:** A method that mirrors the functionality of `off()`, ensuring the laser is safely turned off.
% - **`exportState()`:** Exports the current operational state of the laser, including power settings and on/off status.
% 
% ## Usage Example
% ```matlab
% % Create an instance of the HSM 488 nm laser
% laser = MIC_HSM488Laser();
% 
% % Set the laser power to 10 mW using FilterID 2
% laser.setPower(10, 2);
% 
% % Turn the laser on
% laser.on();
% 
% % Display the current state of the laser
% state = laser.exportState();
% disp(state);
% 
% % Turn the laser off
% laser.off();
% 
% % Clean up on completion
% delete(laser);
% ```  
%  Citation: Sajjad Khan, Lidkelab, 2024
 
    properties (SetAccess=protected)
        InstrumentName='HSM488Laser' % Descriptive Instrument Name
        Shutter;                          % an obj for MIC_ShutterTTL to control Shutter
        Attenuator;                       % an obj for MIC_Attenuator to control Attenuator(Liquid Crystal Controller)
        Filter=[0 0.0989 0 0.0278 0 0.0095];                     
        % I measured FracTransmVals for this Filter: Filter(1) & Filter(2) are purposly 
        % blocked due to damage threshold of the attenuator
    end
    
    properties (SetAccess=protected, GetAccess = public)
        Power=0;            % Currently Set Output Power
        PowerUnit='mW' % Power Unit
        MinPower=0; % Minimum Power Setting, 0.0125 is least TransmissionFactor for FilterWheel
        MaxPower;       % Maximum Power Setting
        IsOn=0;             % On or Off State.  0,1 for off,on
        MaxoutputPower=45;  %Maximum Power by LaserInstrument (without Attenuator and Filter)
    end
    properties
        StartGUI,
      end
    methods
        
        function obj=MIC_HSM488Laser()
            % MIC_HSM488Laser contructor
            % Check the name for subclass from Abtract class
            obj=obj@MIC_LightSource_Abstract(~nargout);
            
            % Initialize Shutter
            obj.Shutter=MIC_ShutterTTL('Dev1','Port1/Line2');
            
            % Initialize Attenuator
            obj.Attenuator=MIC_Attenuator('Dev1','ao1');
            obj.Attenuator.MinTransmission=0.25; % I measured for HSM microscope
            obj.Attenuator.MaxTransmission=70;
            
            %give maxvalue for power based on Attenuator
            obj.MaxPower=obj.MaxoutputPower*obj.Attenuator.MaxTransmission/100*obj.Filter(2);
        end
        
        function delete(obj)
            % Destructor
            shutdown(obj)
            
        end
        function on(obj)
            obj.IsOn=1;
            obj.Shutter.open();
            obj.Attenuator.setTransmission(obj.Attenuator.Transmission)
        end
        function off(obj)
            obj.Shutter.close();
            obj.Attenuator.setTransmission(obj.Attenuator.MinTransmission);
            obj.IsOn=0;
        end
        function setPower(obj,Power_in,FilterID)
            % FilterID can only be 2,4,6. Others blocked the beam.
            if nargin <3 
                FilterID=2;
            end 
            obj.Attenuator.Transmission=100*Power_in/obj.Filter(FilterID)/obj.MaxoutputPower;
            obj.Power=Power_in;
        end 
        
        % Destructor
        function shutdown(obj)
            obj.off();
            obj.IsOn=0;
        end
        
        function State=exportState(obj)
            % Export the object current state
            State.Power=obj.Power;
            State.IsOn=obj.IsOn;
        end
        
        
    end
    
    methods (Static=true)
        function unitTest()
            % Unit test of object functionality
            if nargin<1
                error('MIC_CoherentLaser561::SerialPort must be defined')
            end
            
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L488=MIC_HSM488Laser();
            fprintf('Setting to Max Output\n')
            L488.setPower();
            fprintf('Turn On\n')
            L488.on();pause(.5);
            fprintf('Turn Off\n')
            L488.off();;pause(.5);
            fprintf('Turn On\n')
            L488.on();pause(.5);
            fprintf('Setting to 1 mW Output\n')
            L488.setPower(1);
            fprintf('Show power on the screen\n')
            L488.getCurrentPower;
            fprintf('Delete Object\n')
            %Test Destructor
            delete(L488);
            clear L561;
            
            %Creating an Object and Repeat Test
            fprintf('Creating Object\n')
            L488=MIC_HSM488Laser();
            fprintf('Setting to Max Output\n')
            L488.setPower(100);
            fprintf('Turn On\n')
            L488.on();pause(.5);
            fprintf('Turn Off\n')
            L488.off();;pause(.5);
            fprintf('Turn On\n')
            L488.on();pause(.5);
            fprintf('Setting to 1 mW Output\n')
            L488.setPower(50);
            fprintf('Delete Object\n')
            State=L488.exportState()
            delete(L488);
            clear L561;
            
        end
    end
end

