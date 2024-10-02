classdef ExampleInstrument<mic.abstract 
    %   ExampleInstrument: Example for classes inheriting from
    %  
    % ## Description
    %   This class is written to serve as a template for implementing 
    %   classes inheriting from mic,abstract. This class also serves as a
    %   template for the basic functions such as exportState and unitTest.
    %
    % ## Constructor
    %   Example: obj=mic.ExampleInstrument()
    %   
    % ## Key Functions
    % `exportState` & `unitTest`
    %
    % ## REQUIREMENTS: 
    %   mic.abstract.m
    %   MATLAB software version R2016b or later
    %
    % ### CITATION: Farzin Farzam, LidkeLab, 2017.
    
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
        % graphical user interface
        StartGUI = true();
    end
    
    methods        
        function obj = ExampleInstrument() 
            % Constructor
            obj = obj@mic.abstract(~nargout); % if you forget to name the object, this line will name it for you through autoname in mic,Abstract
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
        function unitTest()
        % Tests all functionality of your methods and the ability to 
        % delete the object. You need to put code here based on the 
        % instrument and it's specific functions 
            fprintf('Creating Object\n')
            ExInst=mic.ExampleInstrument();
            fprintf('Export State\n')
            A=ExInst.exportState(); disp(A); pause(1);
        end
    end
        
end 

