classdef MIC_HSMLaser488<MIC_LightSource_Abstract
    % MIC_HSMLaser488: Matlab Instrument Class for 488 laser on HSM
    % microscope.
    %
    % To use this class, you have to turn on the laser manually with its 
    % contorlerat the top shelf of HSM table.
    % To control the laser, use shutter and liquid crystal controller
    % (LCC)in front of the laser. A filter (No:2) in front of the laser
    % helps to not damage the LLC.
    %
    % Example: obj=MIC_HSMLaser488();
    % Functions: on, off, delete, shutdown, exportState, setPower 
    %
    % REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_LightSource_Abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %   MATLAB NI-DAQmx driver installed via the Support Package Installer
    %   MIC_Attenuator
    %   MIC_ShutterTTL
    %
    % CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
    
    
    properties (SetAccess=protected)
        InstrumentName='HSM488Laser' % Descriptive Instrument Name
        Shutter;                          % an obj for MIC_ShutterTTL to control Shutter
        Attenuator;                       % an obj for MIC_Attenuator to control Attenuator(Liquid Crystal Controller)
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
        MaxPower_LaserFilter=4.45;       % Maximum Power Setting after Filter 2 
        Max_Attenuator;
    end
    
    properties
        StartGUI,
    end
      
    methods
        
        function obj=MIC_HSMLaser488()
            % MIC_HSM488Laser contructor
            % Check the name for subclass from Abtract class
            obj=obj@MIC_LightSource_Abstract(~nargout);
            
            % Initialize Shutter
            obj.Shutter=MIC_ShutterTTL('Dev1','Port1/Line1');
            
            % Initialize Attenuator
            obj.Attenuator=MIC_Attenuator('Dev1','ao0');
            
            % Obtain MaxPower and MinPower for gui
            obj.Attenuator.loadCalibration('LaserCalib');
            obj.MaxPower=obj.Attenuator.MaxTransmission*obj.MaxPower_LaserFilter/100;
            obj.MinPower=obj.Attenuator.MinTransmission*obj.MaxPower_LaserFilter/100;
            obj.Power=obj.MinPower;
        end
        
        function delete(obj)
            % Object Destructor
            shutdown(obj);
            delete(obj.MIC_ShutterTTL);
            delete(obj.MIC_Attenuator);
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
                error('MIC_CoherentLaser561: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_in>obj.MaxPower
                error('MIC_CoherentLaser561: Set_Power: Requested Power Above Maximum')
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
        function unitTest()
            % Testing the funcionality of the class/instrument          
            %Creating an Object and Testing setPower, on, off
            fprintf('Creating Object\n')
            L488=MIC_HSMLaser488();
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
            L488=MIC_HSMLaser488();
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

