classdef simulated_Instrument<mic.abstract 
    %   simulated_Instrument: Example for classes inheriting from mic.abstract
    %  
    % ## Description
    %   This class is written to serve as a template for implementing
    %   classes inheriting from mic.abstract. This class also serves as a
    %   template for the basic functions such as exportState and funcTest.
    % ## Properties
    %
    % ### Protected Properties
    %
    % #### `InstrumentName`
    % - **Description:** Name of the instrument.
    %   - **Default Value:** `'SimulatedInst'`
    %
    % ### Public Properties
    %
    % #### `MinPower`
    % - **Description:** Minimum power setting for the instrument.
    %   - **Default Value:** `0.5`
    %
    % #### `MaxPower`
    % - **Description:** Maximum power setting for the instrument.
    %   - **Default Value:** `2`
    %
    % #### `Power`
    % - **Description:** Current power setting of the instrument.
    %
    % #### `Wavelength`
    % - **Description:** Current wavelength setting of the instrument.
    %
    % #### `Result`
    % - **Description:** Holds the result data or status of the instrument's operation.
    %
    % ### Hidden Properties
    %
    % #### `StartGUI`
    % - **Description:** Indicates whether the graphical user interface (GUI) starts automatically.
    %   - **Default Value:** `true`
    %
    % ## Methods
    %
    % ### `simulated_Instrument()`
    % - **Description:** Constructor method for the `simulated_Instrument` class.
    %   - Calls the superclass constructor to auto-name the object using `mic.abstract`.
    %   - Automatically launches the GUI upon instantiation.
    %
    % ### `exportState()`
    % - **Description:** Exports the current state of the instrument.
    %   - **Returns:**
    %     - `Attributes`: A struct containing `InstrumentName`.
    %     - `Data`: An empty struct for storing data (can be customized further).
    %     - `Children`: An empty struct for storing child elements.
    %
    % ### Static Method: `funcTest()`
    % - **Description:** Tests all functionality of the instrument methods and verifies object creation and deletion.
    %   - Creates an instance of `simulated_Instrument`.
    %   - Exports and displays the state.
    %   - Cleans up after testing.
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

