classdef simulated_Instrument<mic.abstract 
    %   simulated_Instrument: Example for classes inheriting from mic.abstract
    %  
    % ## Description
    %   This class is written to serve as a template for implementing 
    %   classes inheriting from mic.abstract. This class also serves as a
    %   template for the basic functions such as exportState and funcTest.
    %
    % ## Constructor
    %   Example: obj=mic.simulated_Instrument()
    %   
    % ## Key Functions
    % `exportState` & `funcTest`
    %
    % ## REQUIREMENTS: 
    %   mic.abstract.m
    %   MATLAB software version R2016b or later
    %
    % ### CITATION: Farzin Farzam, LidkeLab, 2017.
    
    properties (SetAccess=protected)  
        InstrumentName = 'SimulatedInst' %your instrument name comes here
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
        % graphical user interface
        StartGUI = true();
    end
    
    methods        
        function obj = simulated_Instrument() 
            % Constructor
            obj = obj@mic.abstract(~nargout); % if you forget to name the object, this line will name it for you through autoname in mic.abstract
            gui(obj)  %let's the gui to pop-up as the class constructor runs
        end
        
        
        function [Attributes,Data,Children]=exportState(obj) 
            % Exports the current state of the insrtument
            Attributes.InstrumentName=obj.InstrumentName;
            Data=[];
            Children=[];
        end        
    end 
        
    methods (Static=true)
        function funcTest()
        % Tests all functionality of your methods and the ability to 
        % delete the object. You need to put code here based on the 
        % instrument and it's specific functions 
            fprintf('Creating Object\n')
            ExInst=mic.simulated_Instrument();
            fprintf('Export State\n')
            A=ExInst.exportState(); disp(A); pause(1);
        end
    end
        
end 

