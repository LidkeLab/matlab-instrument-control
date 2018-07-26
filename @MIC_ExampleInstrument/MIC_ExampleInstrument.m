classdef MIC_ExampleInstrument<MIC_Abstract %by Farzin
    %ExampleInstrument Class to Demonstrate MIC_Abstract
    %   A simple implmentation of MIC_abstract
    
    properties (SetAccess=protected)  
        InstrumentName = 'ExampleInst' %your instrument name comes here
    end
    
    properties
        % here you can add all the properties that are needed for your
        % instrument
        MinPower=0.5;   
        MaxPower=2;
        Power;
        Wavelength;
        Result;
    end
    
    properties (Hidden)
        StartGUI = true();
    end
    
    methods        
        function obj = MIC_ExampleInstrument() %Constructor
            obj = obj@MIC_Abstract(~nargout); % if you forget to name the object, this line will name it for you through autoname in MIC_Abstract
            gui(obj)  %let's the gui to pop-up as the class constructor runs
        end
        
        
        function State=exportState(obj) %here you can add whatever you want to save along with the data
            State.InstrumentName=obj.InstrumentName;
        end        
        
        
        function result=unitTest(obj)  %tests all functionality of your methods and the ability to delete the object
            %you need to put code here based on the instrument and it's specific functions 
            result=obj.MinPower+obj.MaxPower;
        end
        
    end %public methods
end %classdef

