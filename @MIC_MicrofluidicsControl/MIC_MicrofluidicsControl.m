classdef MIC_MicrofluidicsControl < MIC_Abstract
    %MIC class for control of the microfluidics system.
    % This class is used to control the microfluidics system (consisting of
    % a syringe pump(s) and valves) in a more user-friendly and safe 
    % manner than direct calling of the classes MIC_CavroSyringePump and
    % MIC_BiochemValve.  More specifically, this class organizes and
    % facilitates the use of the syringe pump/valve system in a more 
    % electrically and mechanically conscious manner than is done with
    % MIC_CavroSyringePump and MIC_BiochemValve in an attempt to minimize
    % risks to users/equipment, reduce time spent learning the system, and
    % to fail more gracefully when errors are encountered. 
    %
    % MATLAB R2017a or newer recommended. 
    %
    % CITATION: David Schodt, Lidke Lab, 2018
    
    
    properties (SetAccess = protected) % users shouldn't set these
        InstrumentName = 'MicrofluidicsSystem';
    end
    
    
    properties % (Access = protected) % would I want this???
        StartGUI;
    end
    
    
    properties
        DeviceAddress = 1; % ASCII address for device
        DeviceSearchTimeout = 10; % timeout(s) to search for a pump
        DeviceResponseTimeout = 10; % timeout(s) for valid device response
        SerialPort = '';
    end
    
    
    methods
        function delete(obj)
            %Defines a class destructor

        end
        
        exportState(obj); 
        gui(obj); 
        
        
    end
    
    
    methods (Static)
        unitTest(SerialPort); % READ WARNING IN unitTest.m BEFORE USE!!!!
    end
end