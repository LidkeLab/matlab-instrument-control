classdef MIC_Triggerscope < MIC_Abstract
    %MIC_Triggerscope contains methods to control a Triggerscope.
    % This class is designed for the control of a Triggerscope (written for
    % Triggerscope 3B and 4). All functionality present in the Triggerscope
    % documentation should be included (see documents in
    % Z:\Manuals\AdvancedResearch).
    %
    % REQUIRES:
    %   Triggerscope 3B, Triggerscope 4 (https://arc.austinblanco.com/)
    %       connected via an accessible serial port
    %   MATLAB 2019b or later (for updated serial communications, e.g.,
    %       serialport())
    %   Windows operating system recommended (Unix based systems might 
    %       require changes to, e.g., usage/definition of obj.SerialPort,
    %       or perhaps more serious changes)
    
    % Created by:
    %   David J. Schodt (Lidke Lab, 2020)
    
    
    properties
        % Triggerscope response timeout. (seconds)(Default = 10)
        DeviceTimeout = 10;
        
        % Serial port Triggerscope is connected to (char)(Default = 'COM3')
        SerialPort = 'COM3';
    end
        
    properties (SetAccess = protected)
        % Graphics object parent of the GUI.
        GUIParent;
        
        % Meaningful name of instrument. (char)(Default = 'Triggerscope')
        InstrumentName = 'Triggerscope';
        
        % Indicates the Triggerscope status. (logical)(Default = false)
        IsConnected = false; 
        
        % Serial port device for the Triggerscope.
        Triggerscope;
        
        % Communication rate for Triggerscope. (integer)(Default = 115200)
        BaudRate = 115200;
        
        % Number of bits per serial comm. character. (integer)(Default = 8)
        DataBits = 8;
        
        % Serial communication command terminator. (char)(Default = 'LF')
        Terminator = 'LF';
        
        % List of commands present in the Triggerscope documentation.
        CommandList = {'*', 'DAC', 'FOCUS', 'TTL', 'RANGE', 'CAM', ...
            'STAT?', 'TEST?', 'CLEARTABLE', 'PROG', 'STEP', 'ARM', ...
            'ARRAY', 'CLEARALL', 'RANGE', ...
            'PROG_FOCUS', 'PROG_TTL', 'PROG_DAC', 'PROG_DEL', ...
            'TIMECYCLES', 'TRIGMODE'};
    end
    
    properties (SetObservable)
        % Message describing current action. (char)(Default = '')
        ActivityMessage = '';        
    end
       
    properties (Hidden)
        % Determines if GUI starts on instantiation. (Default = false)
        StartGUI = false;
    end
    
    methods
        function obj = MIC_Triggerscope(SerialPort, DeviceTimeout)
            %MIC_Triggerscope is the class constructor.
                       
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@MIC_Abstract(~nargout);
            
            % Set a property listener for the ActivityMessage property.
            addlistener(obj, 'ActivityMessage', ...
                'PostSet', @obj.updateStatus);
            
            % Set inputs to class properties if needed.
            if (exist('SerialPort', 'var') && ~isempty(SerialPort))
                obj.SerialPort = SerialPort;
            end
            if (exist('DeviceTimeout', 'var') && ~isempty(DeviceTimeout))
                obj.DeviceTimeout = DeviceTimeout;
            end
        
        end
                
        function updateStatus(obj, ~, ~)
            % Listener callback for a change of the object property
            % ActivityMessage.         
        end
                
        [Response] = executeCommand(obj, Command);
        connectTriggerscope(obj)
        disconnectTriggerscope(obj)
        delete(obj)
        exportState(obj)
        gui(obj, GUIParent);
        unitTest(obj)
        
    end
    
    methods (Access = protected)
        % These methods are protected because it is not anticipated that a
        % user would want to access these. Any methods in this section
        % should have public calling methods that make them more 
        % user-friendly while providing the same functionality.
        
        writeCommand(obj, Command);
        [Response] = readResponse(obj);
        
    end
    
    methods (Static)

    end
    
    
end