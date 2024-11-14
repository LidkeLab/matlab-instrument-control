classdef Triggerscope < mic.abstract
    % mic.Triggerscope contains methods to control a Triggerscope.
    %
    % ## Description
    % This class is designed for the control of a Triggerscope (written for
    % Triggerscope 3B and 4). All functionality present in the Triggerscope
    % documentation should be included.
    %
    % ## Public Properties
    %
    % ### `DeviceTimeout`
    % Triggerscope response timeout in seconds.
    % **Default:** `1`.
    %
    % ### `SerialPort`
    % Serial port Triggerscope is connected to.
    % **Default:** `'COM3'`.
    %
    % ### `SignalStruct`
    % Structure defining signals on each port.
    % - See `mic.Triggerscope.triggerArrayGUI()` for formatting or GUI generation of this structure.
    %
    % ### `TriggerMode`
    % Trigger mode of the Triggerscope.
    % **Default:** `'Rising'`.
    % **Note:** This should be set to one of the (hidden property) options `TriggerModeOptions`.
    %
    % ## Dependent Properties (Hidden)
    %
    % ### `SignalArray`
    % Array of signals to be set on ports when triggered.
    % **Note:** This property is automatically generated from `SignalStruct`.
    %
    % ## Protected Properties (Set Access, Hidden)
    %
    % ### `GUIParent`
    % Graphics object parent of the GUI.
    %
    % ### `InstrumentName`
    % Meaningful name of the instrument.
    % **Default:** `'Triggerscope'`.
    %
    % ### `TriggerscopeSerialPortDev`
    % Serial port device for the Triggerscope.
    %
    % ### `ActionPause`
    % Brief pause made after sending a command in seconds.
    % **Default:** `0.1`.
    %
    % ### `BaudRate`
    % Communication rate for Triggerscope.
    % **Default:** `115200`.
    %
    % ### `DataBits`
    % Number of bits per serial communication character.
    % **Default:** `8`.
    %
    % ### `Terminator`
    % Serial communication command terminator.
    % **Default:** `'LF'`.
    %
    % ### `CommandList`
    % List of commands present in the Triggerscope documentation.
    %
    % ### `TriggerModeOptions`
    % List of trigger modes from the Triggerscope documentation.
    % **Options:** `'Rising'`, `'Falling'`, `'Change'`.
    % **Note:** Changing the order of this list may break class functionality.
    %
    % ### `DACResolution`
    % Resolution of the DAC channels in bits.
    % **Default:** `16`.
    %
    % ### `IOChannels`
    % Number of TTL/DAC channels.
    % **Default:** `16`.
    %
    % ### `VoltageRangeOptions`
    % List of voltage ranges in Volts as a 5x2 numeric array.
    % **Default:**  [0, 5; 0, 10; -5, 5; -10, 10; -2.5, 2.5]
    %
    % ## Methods
    %
    % ### Constructor
    %
    % #### `Triggerscope(SerialPort, DeviceTimeout, AutoConnect)`
    % Creates an instance of the `Triggerscope` class.
    % - **Inputs:**
    %   - `SerialPort`: Serial port the Triggerscope is connected to.
    %   - `DeviceTimeout`: Response timeout for the device (optional).
    %   - `AutoConnect`: Boolean indicating whether to automatically connect to the Triggerscope (optional).
    %
    % ### Public Methods
    %
    % #### `get.SignalArray()`
    % Retrieves the `SignalArray` dependent property.
    % - Converts `SignalStruct` into a numeric array representing signals for TTL/DAC ports.
    %
    % #### `updateActivityDisplay(obj, ~, ~)`
    % Updates the GUI activity display message when `ActivityMessage` changes.
    %
    % #### `updateConnectionStatus(obj, ~, ~)`
    % Updates GUI controls based on changes in the `IsConnected` property.
    %
    % #### `delete()`
    % Destructor for the `mic.Triggerscope` class instance.
    %
    % #### `connectTriggerscope()`
    % Connects to the Triggerscope (implementation not shown).
    %
    % #### `disconnectTriggerscope()`
    % Disconnects the Triggerscope (implementation not shown).
    %
    % #### `[Response] = executeCommand(obj, Command)`
    % Executes a command on the Triggerscope (implementation not shown).
    %
    % #### `[Response] = executeArrayProgram(obj, CommandSequence, FastMode)`
    % Executes an array program on the Triggerscope (implementation not shown).
    %
    % #### `[CommandSequence] = generateArrayProgram(obj, NLoops, Arm)`
    % Generates an array program for the Triggerscope (implementation not shown).
    %
    % #### `setDefaults()`
    % Sets default settings for the Triggerscope (implementation not shown).
    %
    % #### `setDACRange(obj, DACIndex, Range)`
    % Sets the range for a specified DAC channel (implementation not shown).
    %
    % #### `setDACVoltage(obj, DACIndex, Voltage)`
    % Sets the voltage for a specified DAC channel (implementation not shown).
    %
    % #### `setTTLState(obj, TTLIndex, State)`
    % Sets the state of a specified TTL channel (implementation not shown).
    %
    % #### `exportState()`
    % Exports the current state of the Triggerscope (implementation not shown).
    %
    % #### `gui(obj, GUIParent)`
    % Launches the GUI for the Triggerscope (implementation not shown).
    %
    % #### `triggerArrayGUI(obj, GUIParent)`
    % Launches a GUI for configuring trigger arrays (implementation not shown).
    %
    % #### `reset()`
    % Resets the Triggerscope (implementation not shown).
    %
    % #### `funcTest()`
    % Runs a functional test of the Triggerscope (implementation not shown).
    %
    % ### Protected Methods
    %
    % #### `writeCommand(obj, Command)`
    % Sends a command to the Triggerscope (implementation not shown).
    %
    % #### `[Response] = readResponse(obj)`
    % Reads a response from the Triggerscope (implementation not shown).
    %
    % ### Hidden Methods
    %
    % #### `[VoltageRangeIndex] = selectVoltageRange(obj, Signal)`
    % Selects the appropriate voltage range for a given signal (implementation not shown).
    %
    % ### Static Hidden Methods
    %
    % #### `convertLogicalToStatus(Logical, CharOptions)`
    % Converts a logical value to a string status.
    % - **Inputs:**
    %   - `Logical`: Scalar logical value.
    %   - `CharOptions`: Cell array of two strings corresponding to true and false values.
    %
    % #### `[TriggerModeInt] = convertTriggerStringToInt(TriggerModeString)`
    % Converts a string trigger mode to an integer index.
    %
    % #### `[ToggleSignal] = generateToggleSignal(TriggerSignal, SignalPeriod, TriggerModeInt)`
    % Generates a toggle signal (implementation not shown).
    %
    % #### `[OutputSignal] = toggleLatch(ToggleSignal, InPhase)`
    % Toggles a latch signal (implementation not shown).
    %
    % #### `[BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution)`
    % Converts a voltage to a bit level (implementation not shown).
    %
    % EXAMPLE USAGE:
    %   TS = mic.Triggerscope('COM3', [], true);
    %   This will create an instance of the class and automatically
    %   attempt to connect to serial port COM3.
    %
    % ## REQUIREMENTS:
    %   Triggerscope 3B, Triggerscope 4 (https://arc.austinblanco.com/)
    %       connected via an accessible serial port
    %   MATLAB 2019b or later (for updated serial communications, e.g.,
    %       serialport())
    %   Windows operating system recommended (Unix based systems might
    %       require changes to, e.g., usage/definition of obj.SerialPort,
    %       or perhaps more serious changes)
    %   TeensyDuino serial communication driver installed
    %       http://www.pjrc.com/teensy/serial_install.exe
    %
    % ### Citation: David J. Schodt (Lidke Lab, 2020)
    properties
        % Triggerscope response timeout. (seconds)(Default = 10)
        DeviceTimeout = 1;
        
        % Serial port Triggerscope is connected to (char)(Default = 'COM3')
        SerialPort = 'COM3';
        
        % Structure defining signals on each port (struct)
        % (see mic.Triggerscope.triggerArrayGUI() for formatting, or to
        % generate this structure in a GUI)
        SignalStruct struct = struct([]);
        
        % Trigger mode of the Triggerscope (char array)(Default = 'Rising')
        % NOTE: This should be set to one of the (hidden property) options
        %       obj.TriggerModeOptions.
        TriggerMode = 'Rising';
    end
    
    properties (Dependent, Hidden)
        % Array of signals be set on ports when triggered (float array)
        % NOTE: If the user wants to define signals manually, they should
        %       edit the SignalStruct property (whose entries are converted
        %       and placed here automatically).
        SignalArray
    end
    
    properties (SetAccess = protected, Hidden)
        % Graphics object parent of the GUI.
        GUIParent
        
        % Meaningful name of instrument. (char)(Default = 'Triggerscope')
        InstrumentName = 'Triggerscope';
        
        % Serial port device for the Triggerscope.
        TriggerscopeSerialPortDev
        
        % Brief pause made after sending a command. (seconds)
        ActionPause = 0.1;
        
        % Communication rate for Triggerscope. (integer)(Default = 115200)
        BaudRate = 115200;
        
        % Number of bits per serial comm. character. (integer)(Default = 8)
        DataBits = 8;
        
        % Serial communication command terminator. (char)(Default = 'LF')
        Terminator = 'LF';
        
        % List of commands present in the Triggerscope documentation.
        CommandList = {'*', 'DAC', 'FOCUS', 'TTL', 'RANGE', 'CAM', ...
            'STAT?', 'TEST?', 'CLEARTABLE', 'PROG', 'STEP', 'ARM', ...
            'ARRAY', 'CLEAR_ALL', 'RANGE', 'RESET', 'SAVESETTINGS', ...
            'PROG_FOCUS', 'PROG_TTL', 'PROG_DAC', 'PROG_DEL', ...
            'PROG_WAVE', 'TIMECYCLES', 'TRIGMODE'};
        
        % List of trigger modes from the Triggerscope documentation.
        % For now, I'm excluding 'Low' and 'High' because those seem to
        % no longer be in use for the Triggerscopes that we have.
        % Changing the order of this list will break some functionality
        % throughout the class!
        TriggerModeOptions = {'Rising', 'Falling', 'Change'};
        
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
        function obj = Triggerscope(SerialPort, DeviceTimeout, ...
                AutoConnect)
            %mic.Triggerscope is the class constructor.
            % Setting the optional input 'AutoConnect' to 1 (or true) will
            % lead the this constructor attempting to make a connection to
            % the specified SerialPort.
            
            % If needed, automatically assign a name to the instance of
            % this class (i.e. if user forgets to do this).
            obj = obj@mic.abstract(~nargout);
            
            % Add property listeners to observable properties.
            addlistener(obj, 'ActivityMessage', ...
                'PostSet', @obj.updateActivityDisplay);
            addlistener(obj, 'IsConnected', ...
                'PostSet', @obj.updateConnectionStatus);
            
            % Set inputs to class properties if needed.
            ReadyToConnect = false;
            if (exist('SerialPort', 'var') && ~isempty(SerialPort))
                obj.SerialPort = SerialPort;
                ReadyToConnect = true;
            end
            if (exist('DeviceTimeout', 'var') && ~isempty(DeviceTimeout))
                obj.DeviceTimeout = DeviceTimeout;
            end
            if (~exist('AutoConnect', 'var') || isempty(AutoConnect))
                AutoConnect = true;
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
            if (AutoConnect && ReadyToConnect)
                obj.connectTriggerscope();
                obj.setDefaults();
            end
        end
        
        function [SignalArray] = get.SignalArray(obj)
            % This is a get method for the dependent property SignalArray.
            % This method will convert the class property SignalStruct into
            % a simpler SignalArray, which is organized in a specific way
            % to be "lighter weight" than the SignalStruct.
            %
            % OUTPUTS:
            %   SignalArray: A numeric array containing the signals
            %                specified in obj.SignalStruct. This array is
            %                formatted to be 2*obj.IOChannels rows by max.
            %                signal length columns, with each row
            %                corresponding to a TTL/DAC port (1-16 are TTL
            %                ports 1-16, 17-32 are DAC ports 1-16). Ports
            %                not specified in obj.SignalStruct are set to
            %                zero arrays. Signals will be padded with zeros
            %                to match the max. signal length if needed.
            
            % If the SignalStruct is empty, we can just output an empty
            % array and stop here.
            if (isempty(obj.SignalStruct) ...
                    || (numel(fieldnames(obj.SignalStruct))==0))
                % I'm making this an empty array with correct number of
                % rows for the sake of consistency (probably not
                % necessary).
                SignalArray = zeros(2*obj.IOChannels, 0);
                return
            end
            
            % Reorganize obj.SignalStruct to ensure the trigger is the
            % first signal.
            IsTrigger = strcmpi({obj.SignalStruct.Identifier}, 'trigger');
            obj.SignalStruct = [obj.SignalStruct(IsTrigger); ...
                obj.SignalStruct(~IsTrigger)];
            
            % Determine how many trigger events there were.
            TriggerModeInt = ...
                obj.convertTriggerStringToInt(obj.TriggerMode);
            TriggerEvents = obj.generateToggleSignal(...
                obj.SignalStruct(1).Signal, 2, TriggerModeInt);
            NTriggerEvents = sum(TriggerEvents);
            
            % Initialize the SignalArray.
            SignalArray = zeros(2*obj.IOChannels, NTriggerEvents);
            
            % Populate the SignalArray.
            NPointsTrigger = obj.SignalStruct(1).NPoints;
            for ii = 2:numel(obj.SignalStruct)
                % Force the input signal to be the correct size before
                % proceeding.
                TruncatedSignal = obj.SignalStruct(ii).Signal(...
                    1:min(NPointsTrigger, obj.SignalStruct(ii).NPoints));
                CurrentSignal = [TruncatedSignal, ...
                    zeros(1, NPointsTrigger-obj.SignalStruct(ii).NPoints)];
                if contains(obj.SignalStruct(ii).Identifier, 'TTL')
                    SignalArray(str2double(...
                        obj.SignalStruct(ii).Identifier(4:5)), ...
                        1:NTriggerEvents) = CurrentSignal(TriggerEvents);
                elseif contains(obj.SignalStruct(ii).Identifier, 'DAC')
                    SignalArray(str2double(...
                        obj.SignalStruct(ii).Identifier(4:5)) + 16, ...
                        1:NTriggerEvents) = CurrentSignal(TriggerEvents);
                else
                    warning(...
                        ['Unknown signal identifier found in ', ...
                        'obj.SignalStruct: ''%s'' not recognized'], ...
                        obj.SignalStruct(ii).Identifier)
                end
            end
            
        end
        
        function updateActivityDisplay(obj, ~, ~)
            % Listener callback for a change of the object property
            % ActivityMessage, which is used to update the GUI activity
            % display message.
            
            % Find the ActivityDisplay
            ActivityDisplay = findall(obj.GUIParent, ...
                'Tag', 'ActivityDisplay');
            if isempty(ActivityDisplay)
                return
            end
            
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
            if isempty(ConnectionDisplay)
                return
            end
            
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
            % This is the destructor for the mic.Triggerscope class.
            
            % For now, just delete the class instance.
            delete(obj);
            
        end
        
        connectTriggerscope(obj)
        disconnectTriggerscope(obj)
        [Response] = executeCommand(obj, Command);
        [Response] = executeArrayProgram(obj, CommandSequence, FastMode);
        [CommandSequence] = generateArrayProgram(obj, NLoops, Arm);
        setDefaults(obj)
        setDACRange(obj, DACIndex, Range)
        setDACVoltage(obj, DACIndex, Voltage)
        setTTLState(obj, TTLIndex, State)
        exportState(obj)
        gui(obj, GUIParent)
        triggerArrayGUI(obj, GUIParent)
        reset(obj)
        funcTest(obj)
        
    end
    
    methods (Access = protected)
        % These methods are protected because it is not anticipated that a
        % user would want to access these. Any methods in this section
        % should either have public calling methods that make them more
        % user-friendly while providing the same functionality, or should
        % not provide user facing functionality.
        
        writeCommand(obj, Command);
        [Response] = readResponse(obj);
        
    end
    
    methods (Hidden)
        % These methods are hidden because I don't anticipate users
        % wanting/needing these methods, but I also don't want to prevent
        % them from using these if needed.
        
        [VoltageRangeIndex] = selectVoltageRange(obj, Signal);
        
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
        
        function [TriggerModeInt] = ...
                convertTriggerStringToInt(TriggerModeString)
            %convertTriggerStringToInt converts a string id into an int.
            % This method converts the string/char array version of the
            % trigger mode (e.g., the char array 'Rising') into the
            % corresponding integer index of the (hidden) property
            % obj.TriggerModeOptions.
            TriggerModeInt = 1*strcmpi(TriggerModeString, 'Rising') ...
                + 2*strcmpi(TriggerModeString, 'Falling') ...
                + 3*strcmpi(TriggerModeString, 'Change');
        end
        
        [ToggleSignal] = generateToggleSignal(TriggerSignal, ...
            SignalPeriod, TriggerModeInt);
        [OutputSignal] = toggleLatch(ToggleSignal, InPhase);
        [BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution);
        
    end
    
    
end
