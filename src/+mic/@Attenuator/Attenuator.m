classdef Attenuator < mic.abstract
% mic.Attenuator Class
%
% ## Description
% The `mic.Attenuator` class in MATLAB is designed for controlling optical attenuators through an 
% NI DAQ card, providing precise adjustments to the attenuation level. This class integrates 
% seamlessly with MATLAB's Data Acquisition Toolbox and is part of a broader suite of instrument control classes.
% You can also use the power meter to callibrate the attenuator for a new setup and then use it. 
% Note that the attenuator does not block the beam completely. The laser damage threshold for this 
% attenuator is 1 W/cm2. The operation wavelength is 420-700 nm. The current from the LED driver 
% is regulated by the analog voltage output (0 to 5 V) of a NI DAQ card. The Constructor requires the Device and Channel details.
%
% ## Features
% - Full control over optical attenuation settings.
% - Calibration capabilities using a power meter.
% - Integration with NI DAQ for voltage control over the attenuator.
% - Suitable for wavelengths from 420-700 nm.
% - Protection against laser damage with a threshold of 1 W/cm2.
% 
% ## Requirements
% - MATLAB 2014 or higher.
% - Data Acquisition Toolbox.
% - MATLAB NI-DAQmx driver installed via the Support Package Installer.
% - An NI DAQ device.
% 
% ## Properties
% - `Transmission`: The current transmission setting (% of maximum).
% - `MinTransmission`, `MaxTransmission`: Minimum and maximum transmission settings.
% - `PowerBeforeAttenuator`: Power measured before the attenuator, useful for calibration.
% 
% ## Methods
% ### `mic.Attenuator(NIDevice, AOChannel)`
% Constructor for creating an instance of `mic.Attenuator`. Requires NI device and analog output channel specifications.
% 
% ### `loadCalibration(Name)`
% Loads a calibration file specified by `Name`, which adjusts the attenuation curve based on previously gathered data.
% 
% ### `setTransmission(Transmission_in)`
% Sets the desired transmission level, adjusting the voltage output to the attenuator accordingly.
% 
% ### `calibration(NIDevice, AOChannel, BeforeAttenuator, Name)`
% Calibrates the attenuator using a reference power measurement obtained via `findMaxPower` and saves the calibration data under the specified `Name`.
% 
% ### `shutdown()`
% Safely shuts down the attenuator, setting the transmission to zero.
% 
% ## Usage Example
% ```matlab
% % Initialize the attenuator with specific NI DAQ settings
% attenuator = mic.Attenuator('Dev1', 'ao1');
% 
% % Load calibration data
% attenuator.loadCalibration('CalibrationFile.mat');
% 
% % Set transmission to 50%
% attenuator.setTransmission(50);
% 
% % Shutdown the attenuator
% attenuator.shutdown();
% ```
% ### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

    properties (SetAccess=protected)
        InstrumentName='Attenuator' % Descriptive Instrument Name
        TransmissionUnit='Percent' % Transmission Unit 
    end
   
    properties
       MinTransmission=0;         % Minimum Transmission Setting
       MaxTransmission=100;       % Maximum Transmission Setting 
       Transmission;              % Currently Set Output Transmission
       PowerBeforeAttenuator;     % Power measured before attenuator (mW)
       NormOutTransmission;       % Normalized transmission used in callibration
       Input_Voltage              % Voltages points used to measure transmission for callibration.
    end
    
    properties (SetAccess=protected)      
        V_100=0;      % Voltage where current begins to drop from 100%
        V_0=5;          % Voltage to set completetly on
        DAQ=[];         % NI DAQ Session
    end
    
    properties 
        StartGUI;
    end
    
    methods
        function obj=Attenuator(NIDevice,AOChannel)
            % Creates a Transmission object and sets output to minimum 
            % and turns off Transmission. 
            % Example: A=mic.Attenuator('Dev1','ao1')
            % The first and second input can be found if you open 'NI MAX',
            % go to Devices and Interfaces click on the Device and then go
            % to 'test panel' on the top right.
            
            if nargin<2
                error('mic.Transmission::NIDevice and AOChannel must be defined')
            end
            obj=obj@mic.abstract(~nargout);
            %Set up the NI Daq Object
            obj.DAQ = daq.createSession('ni');
            addAnalogOutputChannel(obj.DAQ,NIDevice,AOChannel, 'Voltage');
           
        end
        
        function loadCalibration(obj,Name)
            % Loading the calibration file.
            % The input is the name of the callibration file that you
            % wants to load.
            load(Name);
            obj.Input_Voltage = Voltage;
            obj.NormOutTransmission = NormTransmission;
            obj.MaxTransmission = obj.NormOutTransmission(1);
            obj.MinTransmission = obj.NormOutTransmission(end);
            
            %Set to minimum attenuation
            obj.setTransmission(obj.MinTransmission);
        end
        
        function delete(obj)
            % Destructor
            delete(obj.GuiFigure);
            obj.shutdown();
        end
        function setVoltage(obj,Vin)
            %This function is called inside the callibration method to set
            %the voltage.
           if Vin < 0 || Vin > 5
              error('Voltage out of range. It should be in the interval [0 5].'); 
           end
           if ~isempty(obj.DAQ) %daq not yet created
              outputSingleScan(obj.DAQ,Vin);
           end
        end
        
        function setTransmission(obj,Transmission_in)
            % Sets output attenuation in percentage of maximum
            if Transmission_in >obj.MaxTransmission+0.001
               error('The input transmission is too large, setting to %d\n',obj.MaxTransmission); 
            end
            if Transmission_in<obj.MinTransmission-0.001
               error('The input transmission is too small, setting to %d\n',obj.MinTransmission); 
            end
            if isempty(obj.Input_Voltage)
               error('The suitable calibration file should be loaded. Please call loadCalibration().'); 
               
            end
            obj.updateGui(Transmission_in);
            
            %Interpolation
            DiffTrans = obj.NormOutTransmission - Transmission_in;
            Ind2 = find(DiffTrans<=0,1);
            %Ind2 = min(Index);
            Ind1 = Ind2 - 1;
           
            %Voltage
            if Ind1 >0
            V_out = (obj.Input_Voltage(Ind1)*(Transmission_in-obj.NormOutTransmission(Ind2))+...
                obj.Input_Voltage(Ind2)*(obj.NormOutTransmission(Ind1)-Transmission_in))/...
                (obj.NormOutTransmission(Ind1)-obj.NormOutTransmission(Ind2));
            else
                V_out = obj.V_100;
            end
               
            if ~isempty(obj.DAQ) %daq not yet created
                outputSingleScan(obj.DAQ,V_out);
            end
            obj.Transmission=Transmission_in;
        end
        function State=exportState(obj)
            % Export the object current state
            State.instrumentName=obj.InstrumentName;
            State.Transmission=obj.Transmission;
        end
        function shutdown(obj)
            % Set attenuation to zero and turn off. 
            obj.setTransmission(0);
        end
        
        function updateGui(obj,Power)
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            set(obj.GuiFigure.Children(8),'Value',Power);
            set(obj.GuiFigure.Children(2),'String',Power);
        end
        
    end
        methods (Static=true)
            function funcTest(NIDevice,AOChannel)
                % Unit test of object functionality
                % Example: mic.Attenuator.funcTest('Dev1','ao1')
                try
                   TestObj=mic.Attenuator(NIDevice,AOChannel);
                   fprintf('The object was successfully created.\n');
                   setTransmission(TestObj,TestObj.MaxTransmission);
                   fprintf('The attenuation is successfully set to the max attenuation.\n');pause(1);
                   fprintf('The lamp is off.\n');pause(1);
                   exportState(TestObj)
                   fprintf('The results are saved.\n');
                   delete(TestObj);
                   fprintf('The device is deleted.\n');
                   fprintf('The class is successfully tested :)\n');
               catch E
                   fprintf('Sorry, an error occured :(\n');
                   error(E.message);
                end
            end
            function Out = findMaxPower(Wavelength)
                  %To calibrate the attenuator user needs to call this
                  %function first.
                  % Wavelength is the wavelength of the beam that you want to
                  % attenuate.
                  % object for power meter
                  Pm = mic.PM100D;
                  %setting the wavelength
                  Pm.Lambda = Wavelength;
                  Pm.setWavelength;
                  %measuring the power 
                  Pm.Ask = 'power';
                  Out = Pm.measure;
                  Pm.delete();
            end
             function calibration(NIDevice,AOChannel,BeforeAttenuator,Name)
                %This function callibrates the attenuator. 
                %User should measure the input power to the attenuator
                %using the findMaxPower() function, first.
                %then put the power meter after that and call this function.
                %Then the callibration result will be saved in fill called the given "Name".
                %The input "BeforeAttenuator" is the output of findMaxPower()
                %function.
                %Example: mic.Attenuator.calibration('Dev1','ao1',Out,'Name')
                if nargin<2
                    error('mic.Transmission::NIDevice and AOChannel must be defined')
                end
                %Set up the NI Daq Object
                DAQQ = daq.createSession('ni');
                addAnalogOutputChannel(DAQQ,NIDevice,AOChannel, 'Voltage');
                Voltage = 0:0.5:5;
                a = length(Voltage);
                OutTransmission = zeros(1,a);
                Pm = mic.PM100D;
                Pm.Ask = 'power';
                for ii = 1:a
                    outputSingleScan(DAQQ,Voltage(ii));
                    pause(1)
                    OutTransmission(ii) = Pm.measure;
                    pause(0.1)
                end
                NormTransmission = OutTransmission*100/BeforeAttenuator;
                figure; plot(Voltage,NormTransmission,'o')
                xlabel('Voltage(V)')
                ylabel('Transmission(%)')
                legend('Transmission vs V')
                filedir=fullfile(pwd,'\@Attenuator');
                save(fullfile(filedir,Name),'Voltage','NormTransmission','BeforeAttenuator');
                Pm.delete();
        end
        end
    
end

