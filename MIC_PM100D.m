classdef MIC_PM100D < MIC_PowerMeter_Abstract 
    % MIC_PM100D: Matlab Instrument class to control power meter PM100D.
    % 
    % Controls power meter PM100D, gets the current power. It can also gets
    % the current temperature. The wavelenght of the light can also be
    % set for power measurement, where the range of the wavelength is
    % 400nm < Lambda < 1100nm. The gui shows a movie of the plot of the
    % measured power where the shown period can be modified. It also shows
    % the current power and the maximum measured power. To run this code 
    % you need the power meter to be connected to the machine.
    %
    % Example: P = MIC_PM100D; P.gui
    % Functions: constructor(), exportState(), send(), minMaxWavelength()
    %            getWavelength(), measure(), setWavelength(), shutdown()
    %
    % REQUIREMENTS:
    %    NI_DAQ should be installed.
    %    MATLAB 2014 or higher.
    %    MIC_Abstract.m
    %    MIC_PowerMeter_Abstract.m
    %
    % CITATION: Mohamadreza Fazel, Lidkelab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName='PM100D'; %Name of the instrument.
    end
    methods (Static)
        function obj=MIC_PM100D
            %This is the constructor.
            %example PM = MIC_PM100D
            obj@MIC_PowerMeter_Abstract(~nargout);    
           
            % Find a VISA-USB object.
            vendorinfo = instrhwinfo('visa','ni');
            s=vendorinfo.ObjectConstructorName{1};
            
            if isempty(obj.VisaObj)
                obj.VisaObj = eval(s);
            else
                
                fclose(obj.VisaObj);
                clear obj.VisaObj;
                obj.VisaObj = eval(s);
            end
            % Connect to instrument object
            fopen(obj.VisaObj);
            % Measure the limits of the wavelength.
            obj.Limits=minMaxWavelength(obj);
        end 
      function unitTest()
          %testing the class.
          try
          TestObj=MIC_PM100D();
          fprintf('Constructor is run and an object of the class is made.\n');
          Limit = minMaxWavelength(TestObj);
          fprintf('Min wavelength: %d, Max wavelength: %d\n', Limit(1),Limit(2));
          getWavelength(TestObj);
          fprintf('The current wavelength is %d nm.\n',TestObj.Lambda);
          TestObj.Lambda=600;
          setWavelength(TestObj);
          fprintf('The wavelength is set to 600 nm.\n');
          State=exportState(TestObj);
          fprintf('The exportState function was successfully tested.\n');
          TestObj.delete();
          fprintf('The port is closed and the object is deleted.\n');
          fprintf('The class is successfully tested :)\n')
          catch E
             fprintf('Sorry an error has ocured :(\n'); 
              E
          end
      end
    end
    
    methods
        
        function  State=exportState(obj)
            %Exporting the class properties to the State.
            State.InstrunetName=obj.InstrumentName;
            State.Lambda=obj.Lambda;
            State.Limits=obj.Limits;
        end
        
        function Reply=send(obj,Message)
            %Sending a message to the power-meter and getting a feedback.
            fprintf(obj.VisaObj,Message);
            Reply=fscanf(obj.VisaObj,'%s');
        end
        
        function Limits=minMaxWavelength(obj)
            %Reading the limits of the wavelength.
            R1=obj.send('CORRECTION:WAVELENGTH? MIN');
            R2=obj.send('CORRECTION:WAVELENGTH? MAX');
            Limits = [str2double(R1) str2double(R2)];
        end
        
        function getWavelength(obj)
            %Reading the current wavelength of the instrument.
            obj.Lambda=str2double(send(obj,'CORRECTION:WAVELENGTH?'));
            fprintf('Wavelength: %d nm \n',obj.Lambda);
        end
        
        function Out=measure(obj)
            %This either measures the power or temperature.
            switch obj.Ask
                case 'power'
                    Out=str2double(send(obj,'MEASURE:POWER?'))*1000;
                case 'temp'
                    Out=str2double(send(obj,'MEASURE:TEMPERATURE?'));
            end 
        end
     
     function setWavelength(obj)
         %setting the wavelength 
         if obj.Lambda < 400 || obj.Lambda > 1100
             error('The wavelength is out of the range [400nm, 1100nm].');
         end
             
         s = sprintf('CORRECTION:WAVELENGTH %g nm',obj.Lambda);
         fprintf(obj.VisaObj, s);
     end
     function shutdown(obj)
            %This function is called in the destructor to delete the communication port.
            fclose(obj.VisaObj);
        end
     function delete(obj)
         %This function close the comunication port and close the gui.
        delete(obj.GuiFigure);
        obj.shutdown(); 
        clear obj;
     end
      
   end
end