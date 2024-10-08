classdef HSMLaser488<mic.lightsource.abstract
% mic.lightsource.HSMLaser488 Class 
% 
% ## Description
% The `mic.lightsource.HSMLaser488` class is used for controlling a 488 nm laser mounted on the HSM microscope. 
% This class facilitates the operation of the laser through a MATLAB interface, leveraging both a shutter and a 
% liquid crystal controller (LCC). The use of a specific filter (No: 2) in front of the laser is critical to prevent damage to the LCC.
% 
% ## Requirements
% - MATLAB R2016b or later
% - Data Acquisition Toolbox
% - MATLAB NI-DAQmx driver (installed via the Support Package Installer)
% - mic.abstract.m
% - mic.lightsource.abstract.m
% - mic.Attenuator
% - mic.ShutterTTL
% 
% ## Key Functions
% - **Constructor (`mic.lightsource.HSMLaser488()`):** Sets up the laser controls, initializing the shutter and attenuator, and calculates power limits based on the attenuator's transmission and laser filter settings.
% - **`on()`:** Activates the laser by opening the shutter.
% - **`off()`:** Deactivates the laser by closing the shutter.
% - **`setPower(Power_in)`:** Sets the output power of the laser, ensuring it falls within the allowable range adjusted for the filter and attenuator settings.
% - **`delete()`:** Safely shuts down the laser and cleans up resources when the object is destroyed.
% - **`shutdown()`:** Ensures the laser is turned off and all settings are safely reset.
% - **`exportState()`:** Exports the current state of the laser, including power settings and on/off status.
% 
% ## Usage Example
% ```matlab
% % Initialize the mic.lightsource.HSMLaser488 object
% laser = mic.lightsource.HSMLaser488();
% 
% % Set the laser to its maximum allowable power and turn it on
% laser.setPower(laser.MaxPower);
% laser.on();
% 
% % Display the current state of the laser
% state = laser.exportState();
% disp(state);
% 
% % Turn the laser off and delete the object
% laser.off();
% delete(laser);
% ```
% ### CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.

    properties (SetAccess=protected)
        InstrumentName='HSM488Laser' % Descriptive Instrument Name
        Shutter;                          % an obj for mic.ShutterTTL to control Shutter
        Attenuator;                       % an obj for mic.Attenuator to control Attenuator(Liquid Crystal Controller)
        %         FilterPos=[1 2 3 4 5 6];
        %         FracTransmVals=[0 0.0998 0 0.0283 0 0.0098];                     
        % I measured FracTransmVals for this Filter: Filter(1) & Filter(2) are purposly 
        % blocked due to damage threshold of the attenuator
    end
    
    properties (SetAccess=protected, GetAccess = public)
        Power;            % Currently Set Output Power
        PowerUnit='mW' % Power Unit
        MinPower; % Minimum Power Setting, 0.0125 is least TransmissionFactor for FilterWheel
        MaxPower;
        IsOn=0;             % On or Off State.  0,1 for off,on
        MaxPower_Laser=45;  %Maximum Power by LaserInstrument (without Attenuator and Filter)
        MaxPower_LaserFilter=1.8;       % Maximum Power Setting after Filter 2 
        Max_Attenuator;
    end
    
    properties
        StartGUI,
    end
      
    methods
        
        function obj=HSMLaser488()
            % HSM488Laser contructor
            % Check the name for subclass from Abtract class
            obj=obj@mic.lightsource.abstract(~nargout);
            
            % Initialize Shutter
            obj.Shutter=mic.ShutterTTL('Dev1','Port1/Line1');
            
            % Initialize Attenuator
            obj.Attenuator=mic.Attenuator('Dev1','ao0');
            
            % Obtain MaxPower and MinPower for gui
            obj.Attenuator.loadCalibration('LaserCalib');
            obj.MaxPower=obj.Attenuator.MaxTransmission*obj.MaxPower_LaserFilter/100;
            obj.MinPower=obj.Attenuator.MinTransmission*obj.MaxPower_LaserFilter/100;
            obj.Power=obj.MinPower;
        end
        
        function delete(obj)
            % Object Destructor
            shutdown(obj);
            delete(obj.mic.ShutterTTL);
            delete(obj.mic.Attenuator);
        end
        function on(obj)
            % Turns ON the laser
             obj.IsOn=1;
            obj.Shutter.open();
            obj.updateGui();
       end
        function off(obj)
            % Turns OFF the laser
            obj.IsOn=0;
            obj.Shutter.close();
            obj.updateGui();
       end
        function setPower(obj,Power_in)
            % Sets power of laser to Power_in
            % Check if power_in is in the proper range
            if Power_in<obj.MinPower
                error('mic.lightsource.CoherentLaser561: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_in>obj.MaxPower
                error('mic.lightsource.CoherentLaser561: Set_Power: Requested Power Above Maximum')
            end
            
%             if obj.IsOn
%                obj.off;
%             end 
            
            obj.Attenuator.Transmission=100*Power_in/obj.MaxPower_LaserFilter;
            if obj.Attenuator.Transmission > obj.Max_Attenuator
                error('Lower power is accesible due to Max_transmission of Attenuator')
            end
            obj.Attenuator.setTransmission(obj.Attenuator.Transmission)
            obj.Power=Power_in;
            obj.updateGui();

        end
        
        function shutdown(obj)
        % Shuts fown the object
            obj.off();
            obj.IsOn=0;
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            % no Data is saved in this class
            Data=[];
            Children=[]; % Ask Keith about Children for this class!
        end
        
        
    end
    
    methods (Static=true)
        function funcTest()
            % Testing the funcionality of the class/instrument          
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L488=mic.lightsource.HSMLaser488();
            fprintf('Setting to Max Output\n')
            L488.setPower(L488.MaxPower);
            fprintf('Turn On\n')
            L488.on();pause(2);
            fprintf('Turn Off\n')
            L488.off();;pause(.5);
            fprintf('Turn On\n')
            L488.on();pause(2);
            fprintf('Setting to 1 mW Output\n')
            L488.setPower(1);
            fprintf('Show power on the screen\n')
            delete(L488);
            clear L488;
            
            %Creating an Object and Repeat Test
            fprintf('Creating Object\n')
            L488=mic.lightsource.HSMLaser488();
            fprintf('Setting to Max Output\n')
            L488.setPower(L488.MaxPower);
            fprintf('Turn On\n')
            L488.on();pause(2);
            fprintf('Turn Off\n')
            L488.off();;pause(2);
            fprintf('Turn On\n')
            L488.on();pause(2);
            fprintf('Setting to 1 mW Output\n')
            L488.setPower(1);
            fprintf('Delete Object\n')
            State=L488.exportState()
            delete(L488);
            clear L488;
            
        end
    end
end

