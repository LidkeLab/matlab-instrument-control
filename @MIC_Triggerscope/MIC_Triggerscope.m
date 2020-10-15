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
        GUIParent
        
        % Meaningful name of instrument. (char)(Default = 'Triggerscope')
        InstrumentName = 'Triggerscope';
        
        % Serial port device for the Triggerscope.
        Triggerscope
        
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
    
    properties (SetObservable)%, SetAccess = protected)
        % Message describing current action. (char)(Default = '')
        ActivityMessage = '';
        
        % Indicates the Triggerscope status. (logical)(Default = false)
        IsConnected = false;
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
            
            % Add property listeners to observable properties.
            addlistener(obj, 'ActivityMessage', ...
                'PostSet', @obj.updateActivityDisplay);
            addlistener(obj, 'IsConnected', ...
                'PostSet', @obj.updateConnectionStatus);
            
            % Set inputs to class properties if needed.
            if (exist('SerialPort', 'var') && ~isempty(SerialPort))
                obj.SerialPort = SerialPort;
            end
            if (exist('DeviceTimeout', 'var') && ~isempty(DeviceTimeout))
                obj.DeviceTimeout = DeviceTimeout;
            end
            
        end
        
        function updateActivityDisplay(obj, ~, ~)
            % Listener callback for a change of the object property
            % ActivityMessage, which is used to update the GUI activity
            % display message.
                        
            % Find the ActivityDisplay 
            ActivityDisplay = findall(obj.GUIParent, ...
                'Tag', 'ActivityDisplay');
            
            % Modify the text within the status box to show the current
            % activity message
            ActivityDisplay.String = obj.ActivityMessage;
        end
        
        function updateConnectionStatus(obj, ~, ~)
            % Listener callback for a change of the object property
            % IsConnected, which is used to update various GUI controls
            % affected by this property.
            
            % Find the ConnectionDisplay
            ConnectionDisplay = findall(obj.GUIParent, ...
                'Tag', 'ConnectionDisplay');
            
            % Modify the text within the status box to show the current
            % activity message
            ConnectionDisplay.String = obj.convertLogicalToStatus(...
                obj.IsConnected, {'Connected', 'Not connected'});
            
            % Change the background color of the status box.
            ConnectionDisplay.BackgroundColor = ...
                obj.convertLogicalToStatus(...
                obj.IsConnected, {'green', 'red'});
            
            % Update the connection and disconnection pushbuttons.
            ConnectTSButton = findall(obj.GUIParent, ...
                'Tag', 'ConnectTSButton');
            ConnectTSButton.Enable = obj.convertLogicalToStatus(...
                obj.IsConnected, {'off', 'on'});
            DisconnectTSButton = findall(obj.GUIParent, ...
                'Tag', 'DisconnectTSButton');
            DisconnectTSButton.Enable = obj.convertLogicalToStatus(...
                obj.IsConnected, {'on', 'off'});
    
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
    
    methods (Static, Hidden)
        % These methods are hidden because I don't anticipate users
        % wanting/needing these methods, but I also don't want to prevent
        % them from using these if needed.
        
        function [StatusChar] = convertLogicalToStatus(Logical, ...
                CharOptions)
            %convertLogicalToStatus converts a logical to a char message.
            % This method converts a scalar logical to one of the two char
            % arrays in CharOptions, i.e., this converts logical(1) to
            % CharOptions{1} and logical(0) to CharOptions{2}.
            StatusChar = erase([char(Logical*CharOptions{1}), ...
                char(~Logical*CharOptions{2})], ...
                char(0));
        end
        
    end
    
    
end