classdef MPBLaser < mic.lightsource.abstract
    %   mic.lightsource.MPBLaser Matlab Instrument Control Class for the MPB-laser.
    %
    %   ## Description
    % This class controls the PMB-laser.
    %   The constructor do not need any info about the port, it will
    %   automatically find the available port to communicate with the
    %   laser.
    %   Because it is trying to find the port to communicate with the
    %   instrument it will send messages to different ports and if the port
    %   is not giving any feedback, which means that it's not the port that
    %   we are looking for, it will give a timeout warning which can be
    %   neglected.
    %
    % ## Features
    % - Automatic port detection for communication with the laser.
    % - Control over laser power with adjustable set points.
    % - Ability to turn the laser on and off programmatically.
    % - Retrieves and sets various laser parameters such as power limits and serial number.
    %
    % ## Requirements
    % - mic.abstract.m
    % - mic.lightsource_Abstract.m
    % - MATLAB 2014 or higher
    % - Proper installation of the laser's accompanying software.
    %
    % ## Installation Notes
    % During the initial setup, the class attempts to identify the correct communication port by sending commands
    % to potential ports and listening for valid responses. Timeout warnings during this process are expected when
    % incorrect ports do not respond and can be safely ignored.
    %
    % ## Key Methods
    % - **Constructor (`mic.lightsource.MPBLaser()`):** Initializes the laser control by automatically finding the available communication port and setting up the laser parameters.
    % - **`setPower(Power_mW)`:** Sets the laser's power to a specified value in milliwatts.
    % - **`on()`:** Turns the laser on.
    % - **`off()`:** Turns the laser off.
    % - **`send(Message)`:** Sends a specified command to the laser and reads the response.
    % - **`exportState()`:** Exports the current state of the laser, including power settings and operational status.
    % - **`shutdown()`:** Closes the communication port and prepares the system for shutdown.
    % - **`delete()`:** Destructor that ensures proper closure of the communication link and cleanup of the object.
    %
    % ## Usage Example
    % ```matlab
    % % Create an instance of the mic.lightsource.MPBLaser
    % laser = mic.lightsource.MPBLaser();
    %
    % % Set the laser power
    % laser.setPower(50);  % Set power to 50 mW
    %
    % % Turn the laser on
    % laser.on();
    %
    % % Query the current state
    % state = laser.exportState();
    % disp(state);
    %
    % % Turn the laser off and clean up
    % laser.off();
    % delete(laser);
    % ```
    % ### Citation: Sajjad Khan, Lidkelab, 2024.
    properties (SetAccess=protected)
        InstrumentName='MPBLaser647'; %Name of the instrument.
    end
    
    properties (SetAccess=protected)
        Power; %This is the power read from the instrument.
        PowerUnit = 'mW'; %This gives the unit of the power.
        MinPower; %Minimum power for this laser.
        MaxPower; %Maximum power for this laser.
        IsOn=0; %1 indicates that the laser is on and 0 means off.
    end
    
    properties
        SerialObj; %info of the port associated with this instrument.
        SerialNumber; %serial number of the laser.
        
        WaveLength = 647; %Wavelength of the laser.
        Port; %the name of the port that is used to communicate with the laser.
        StartGUI=false; %true will popup the gui automatically and false value makes the user to open the gui manually.
    end

    methods (Static) 
        
        function obj=MPBLaser
            %This is the constructor. It iteratively go through all the ports, opens them and then
            %sends a message to them to see if we get any responce. Furthermore, it makes an object of the
            %class and sets some of the properties.
            
            obj@mic.lightsource.abstract(~nargout);
            
            for ii = 1:10
                %This for-loop goes through all the ports, open them and
                %send a message to the in order to see which port responds
                %back. The port that gives a feedback is the one that this
                %laser is connected to.
                s=sprintf('COM%d',ii);
                Ac = serial(s);
                Ac.Terminator='CR';
                try 
                    fopen(Ac);
                    fprintf(Ac,'GETPOWERSETPTLIM 0');
                    Limits=fscanf(Ac);
                     if ~isempty(Limits)
                         obj.Port=s;
                        break;
                     else
                         fclose(Ac);
                         delete(Ac);
                     end
                catch
                    fclose(Ac);
                    delete(Ac);
                end
                
                
            end
            obj.SerialObj=Ac;
            obj.WaveLength=647; 
            Limits = sscanf(Limits,'%f');
            obj.MinPower=(Limits(1));
            obj.MaxPower=(Limits(2));
            obj.SerialNumber=obj.send('GETSN');
            obj.Power=str2double(obj.send('GETPOWER 0')); %Gets APC Mode set point
            obj.send('POWERENABLE 1'); %Sets APC Mode
        end
        
         function funcTest()
             %funcTest() goes through each method of the class and see if they work properly. 
             %To run this method and test the class just type
             %"mic.lightsource.MPBLaser.funcTest()" in the command line.
           try
               TestObj=mic.lightsource.MPBLaser();
               fprintf('The object was successfully created.\n');
               on(TestObj);
               fprintf('The laser is on.\n');
               setPower(TestObj,TestObj.MaxPower/2); pause(1)
               fprintf('The power is successfully set to half of the max power.\n');
                setPower(TestObj,TestObj.Minpower);
               fprintf('The power is successfully set to the MinPower.\n');
               off(TestObj);
               fprintf('The laser is off.\n');
               delete(TestObj);
               fprintf('The communication port is deleted.\n');
               fprintf('The class is successfully tested :)\n');
           catch E
               fprintf('Sorry, an error occured :(\n');
               error(E.message);
           end
         end
        
    end
    methods
        
        function Reply=send(obj,Message)
            %This method is being called inside other methods to send a
            %message and reading the feedback of the instrument.
            fprintf(obj.SerialObj,Message);
            Reply=fscanf(obj.SerialObj);
            Reply=Reply(4:end);
        end
        
        
        function setPower(obj,Power_mW)
            %This method gets the desired power as an input and sets the
            %laser power to that.
            if Power_mW<obj.MinPower
                error('MPBLaser: Set_Power: Requested Power Below Minimum')
            end
            
            if Power_mW>obj.MaxPower
                error('MPBLaser: Set_Power: Requested Power Above Maximum')
            end
            
            S=sprintf('SETPOWER 0 %g',Power_mW);
            obj.send(S);
            obj.Power=str2double(obj.send('GETPOWER 0'));
            %fprintf('MPB Laser Power Set to %g mW\n',obj.Power)
        end
        
        function on(obj)
            %This method turns the laser on.
            obj.send('SETLDENABLE 1');
            if str2double(obj.send('GETLDENABLE'))
                obj.IsOn=1;
            else
                obj.IsOn=0;
            end
        end
        
        function off(obj)
            %This method turns the laser off.
            obj.send('SETLDENABLE 0');
            obj.IsOn=0;
        end
        
        function [Attributes, Data, Children] = exportState(obj)  
            %exportState() method to export current state of the
            %instrument.
            Attributes.Power=obj.Power;
            Attributes.IsOn=obj.IsOn;
            Attributes.WaveLength=obj.WaveLength;
            Attributes.MinPower=obj.MinPower;
            Attributes.MaxPower=obj.MaxPower;
            Attributes.SerialNumber=obj.SerialNumber;
            Data = [];
            Children = [];
        end
        
        function shutdown(obj)
            %This function is called in the destructor to delete the communication port.
            Aa=instrfind('port',obj.Port);
            for ii=1:length(Aa)
               delete(Aa(ii)); 
            end
        end
        
        function delete(obj)
            %This is the destructor that call the shutdown() function to
            %delete the communication port and also deleting the object
            %created.
            obj.shutdown();
            delete(obj.GuiFigure);
            clear obj;
            
        end
        
    end
    
end
