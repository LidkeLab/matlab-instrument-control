classdef MIC_Triggerscope < MIC_Abstract
    %MIC_Triggerscope contains methods to control a Triggerscope.
    % This class is designed for the control of a Triggerscope (written for
    % Triggerscope 3B and 4). All functionality present in the Triggerscope
    % documentation should be included (see documents in
    % Z:\Manuals\AdvancedResearch).
    %
    % EXAMPLE USAGE:
    %   TS = MIC_Triggerscope('COM3', [], true); 
    %       This will create an instance of the class and automatically
    %       attempt to connect to serial port COM3.
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
    
    properties (SetAccess = protected, Hidden)
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
        
        % Resolution of the DAC channels. (bits)(integer)(Default = 16)
        DACResolution = 16;
        
        % Number of TTL/DAC channels. (integer)(Default = 16)
        IOChannels = 16;
                
        % List of voltage ranges. (Volts)(5x2 numeric array)
        % NOTE: These must be kept in the same order specified in the
        %       Triggerscope documentation so that the command to set these
        %       works correctly.
        VoltageRangeOptions = [0, 5; 0, 10; -5, 5; -10, 10; -2.5, 2.5];
        
        % Char arrays describing voltage ranges. (cell array of char array)
        VoltageRangeChar =  {'0-5V'; '0-10V'; ...
            '+/-5V'; '+/-10V'; '+/-2.5V'};
        
        % Status of each TTL channel (struct)
        TTLStatus struct = struct([]);
        
        % Status of each DAC channel (struct)
        DACStatus struct = struct([]);
    end
    
    properties (SetObservable, SetAccess = protected, Hidden)
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
        function obj = MIC_Triggerscope(SerialPort, DeviceTimeout, ...
                AutoConnect)
            %MIC_Triggerscope is the class constructor.
            % Setting the optional input 'AutoConnect' to 1 (or true) will
            % lead the this constructor attempting to make a connection to
            % the specified SerialPort.
            
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
            if (~exist('AutoConnect', 'var') || isempty(AutoConnect))
                AutoConnect = false;
            end
            
            % Populate the TTLStatus and DACStatus structs.
            % NOTE: TTLStatus(nn)/DACStatus(nn) will provide information
            %       about the nn-th TTL/DAC channel, respectively.
            for ii = 1:obj.IOChannels
                % TTLStatus(ii).Value specifies whether the TTL is driven
                % HIGH (true) or LOW (false).
                obj.TTLStatus(ii).Value = false; 
                
                % DACStatus(ii).Value gives the current voltage this line
                % is being driven at.
                obj.DACStatus(ii).Value = 0; 
                
                % DACStatus(ii).VoltageRangeIndex is the row index of
                % obj.VoltageRangeOptions that defines the voltage range
                % currently set to the ii-th DAC.
                obj.DACStatus(ii).VoltageRangeIndex = 1;
            end
            
            % Attempt to connect to the Triggerscope, if requested.
            if AutoConnect
                obj.connectTriggerscope();
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
            
            % Update the toggle connection pushbutton.
            ToggleConnectionButton = findall(obj.GUIParent, ...
                'Tag', 'ToggleConnectionButton');
            ToggleConnectionButton.String = obj.convertLogicalToStatus(...
                obj.IsConnected, ...
                {'Disconnect Triggerscope', 'Connect Triggerscope'});
            ToggleConnectionButton.BackgroundColor = ...
                obj.convertLogicalToStatus(...
                obj.IsConnected, {'green', 'red'});
    
        end
        
        function delete(obj)
            % This is the destructor for the MIC_Triggerscope class.
            
            % For now, just delete the class instance.
            delete(obj);
            
        end
        
        connectTriggerscope(obj)
        disconnectTriggerscope(obj)
        [Response] = executeCommand(obj, Command);
        setDACRange(obj, DACIndex, Range)
        setDACVoltage(obj, DACIndex, Voltage)
        setTTLState(obj, TTLIndex, State)
        exportState(obj)
        gui(obj, GUIParent)
        triggerArrayGUI(obj, GUIParent)
        reset(obj)
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
        
        [BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution)
        
    end
    
    
end