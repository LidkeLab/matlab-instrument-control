classdef MIC_DynamixelServo < MIC_Abstract
    % MIC_DynamixelServo: Matlab Instrument Class for Dynamixel Servos
    % 
    % ## Description
    %   Dynamixel Servos are used to control the rotation of filter wheels
    %   Setup instruction can be found at Z:\Lab General Info and
    %   Documents\TIRF Microscope\Build Instructions for Filter Wheel
    %   Setup.doc
    %
    %   ## Usage Example:
    %           obj=MIC_DynamixelServo(ServoId,Port,Bps);
    %           ServoId: Id of servo(is written on servo)
    %           Port: COM port to which servo is connected (Optional)
    %           Bps: Baud setting for port (Optional)
    %
    %   ## Key Functions: 
     %             delete, shutdown, checkCommStatus, exportState, ping, 
    %              get.Firmware, get.GaolPosition, set.GoalPosition,
    %              get.Led, set.Led, get.Model, get.Moving,
    %              get.MovingSpeed, set.MovingSpeed, get.PresentPostion,
    %              get.PresentSpeed, get.PresentTemperature,
    %              get.PresentVoltage, get.Rotation, set.Rotation
    %
    %   ## REQUIRES:
    %     Matlab 2014b or higher
    %     MIC_Abstract.m
    %     Roboplus software
    %     Driver library for servo
    %     Driver library for USB2Dynamixel
    %     DynamixelSDK (most likely will be installed during installation of
    %       Roboplus, if not it can be found on the Roboplus webpage)
    %     All files that are not specifically for the Roboplus software should 
    %       be extracted into C:\Program Files(x86)\ROBOTIS\USB2Dynamixel
    %   
    %  ### CITATION: Marjolein Meddens, Lidke Lab, 2017.

    properties(SetAccess=protected)
        InstrumentName = 'DynamixelServo'; % MIC instrument name
    end
    properties(SetAccess = private, GetAccess = public)
        Id;    % Servo Id 0-255 for each port
        Bps;   % Baud setting for port
        Port;  % USB2dynamixel serial port connected to
    end          
    properties(SetObservable = true,Dependent = true) 
        Led; % Turns on or off LED on servo (used for identification purposes), default is off
        GoalPosition; % Position to which servo should go, changing this will move servo
        MovingSpeed; % Speed at which it should move, 1-1023 for most servos, default is fastest
    end    
    properties(Dependent = true)
        Model; %Servo model
        Firmware; %Firmware version
        Moving; %Currently moving
        PresentPosition; %Current position
        PresentSpeed; %Current speed, 0 if not moving
        PresentTemperature; %Current temperature
        PresentVoltage; %Current voltage
        Rotation; % Current position in degrees
    end    
    properties (Hidden = true)
        StartGUI = 0;
        minSpeed = 1;
        maxSpeed = 1023;
    end    
    properties (Constant = true, Hidden = true)
        % These are for using the dynamixel library
        DEFAULT_PORTNUM = 2; % com2 (uses serial port over USB)
        DEFAULT_BAUDNUM = 1; % 1 mbps 
        MODEL_NUMBER = 0; % byte offset
        VERSION_OF_FIRMWARE = 2;
        ID = 3;
        BAUD_RATE = 4;
        RETURN_DELAY_TIME = 5;
        CW_ANGLE_LIMIT = 6;
        CCW_ANGLE_LIMIT = 8;
        HIGH_LIMIT_TEMPERATURE = 11;
        LOW_LIMIT_VOLTAGE = 12;
        HIGH_LIMIT_VOLTAGE = 13;
        MAX_TORQUE = 14;
        STATUS_RETURN_LEVEL = 16;
        ALARM_LED = 17;
        ALARM_SHUTDOWN = 18;
        TORQUE_ENABLE = 24;
        LED = 25;
        CW_COMPLIANCE_MARGIN = 26;
        CCW_COMPLIANCE_MARGIN = 27;
        CW_COMPLIANCE_SLOPE = 28;
        CCW_COMPIANCE_SLOPE = 29;
        GOAL_POSITION = 30;
        MOVING_SPEED = 32;
        TORQUE_LIMIT = 34;
        PRESENT_POSITION = 36;
        PRESENT_SPEED = 38;
        PRESENT_LOAD = 40;
        PRESENT_VOLTAGE = 42;
        PRESENT_TEMPERATURE = 43;
        REGISTERED_INSTRUCTION = 44;
        MOVING = 46;
        LOCK = 47;
        PUNCH = 48;
        BROADCAST_ID = 254; % broadcast device id
        % packet instructions
        INST_PING = 1; 
        INST_READ = 2;
        INST_WRITE	= 3;
        INST_REG_WRITE	= 4;
        INST_ACTION = 5;
        INST_RESET	= 6;
        INST_SYNC_WRITE = 131;
        % error bit values
        ERRBIT_VOLTAGE	= 1; 
        ERRBIT_ANGLE = 2;
        ERRBIT_OVERHEAT = 4;
        ERRBIT_RANGE = 8;
        ERRBIT_CHECKSUM = 16;
        ERRBIT_OVERLOAD = 32;
        ERRBIT_INSTRUCTION = 64;
        % com results
        COMM_TXSUCCESS = 0;
        COMM_RXSUCCESS = 1;
        COMM_TXFAIL = 2;
        COMM_RXFAIL = 3;
        COMM_TXERROR = 4;
        COMM_RXWAITING = 5;
        COMM_RXTIMEOUT = 6;
        COMM_RXCORRUPT = 7;
        MAX_ROTATION=300; % maximum rotation of actuator in degrees
    end
    
    methods
        function obj=MIC_DynamixelServo(Id,Port,Bps)
            % Object constructor
            obj = obj@MIC_Abstract(~nargout);
            if ~exist('Id','var') || Id < 1 || Id > 255
                error('MIC_DynamixelServo:Id','Invalid servo Id');
            end
            obj.Id = Id;          
            if ~exist('Bps','var')
                Bps = MIC_DynamixelServo.DEFAULT_BAUDNUM;
            end
            obj.Bps = Bps;            
            MIC_DynamixelServo.loadlibrary();
            
            %Try to find correct com port if not inputed
            if exist('Port','var')
                obj.Port = Port;
            else  
               obj.Port=obj.findport(Id,Bps);
            end
            if obj.ping() ~= obj.COMM_RXSUCCESS
                error('MIC_DynamixelServo:MissingServo','Could not connect to servo at Id:%d Port:%d Bps:%d',Id,obj.Port,Bps);
            end
            
            % set Led and MovingSpeed to allowed values
            obj.Led = 0;
            obj.MovingSpeed = 1023;
        end
        
        function delete(obj)
            %MIC_DynamixelServo destructor
            obj.shutdown();
        end
        
        function shutdown(obj)
            % unload library
            obj.unloadlibrary();
        end
        
        function checkCommStatus(obj)
            % Checks status of COM port
            CommStatus = int32(obj.callDynamixel('dxl_get_result'));
            if CommStatus == MIC_DynamixelServo.COMM_RXSUCCESS
                MIC_DynamixelServo.printErrorCode();
            else
                MIC_DynamixelServo.printCommStatus(CommStatus);
                return;
            end            
        end
        
        function result = ping(obj)
            % Checks status of connection to servo
            obj.callDynamixel('dxl_ping',obj.Id);
            result = obj.callDynamixel('dxl_get_result');
        end
        
        function value = get.Firmware(obj)
            % Gets firmware data
            value = obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.VERSION_OF_FIRMWARE);
        end
        
        function value = get.GoalPosition(obj)
            % Gets position
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.GOAL_POSITION));
            %fprintf('get goal %d\n', value);
            obj.checkCommStatus();
        end
        
        function set.GoalPosition(obj,value)
            % Sets position
            if value < 0 || value > 1023
                error('MIC_DynamixelServo:PosOutofRange','Position must be between 0 and 1023');
            end
            obj.callDynamixel('dxl_write_word',obj.Id,MIC_DynamixelServo.GOAL_POSITION,value);
            %fprintf('set goal %d\n', value);
            obj.checkCommStatus();
        end
        
        function value = get.Led(obj)
            % Gets LED information
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.LED));
            obj.checkCommStatus();
        end
        
        function set.Led(obj,value)
            % Sets LED value
            if value ~= 0 && value ~= 1
                error('MIC_DynamixelServo:Led', 'Led can only be 0 off or 1 on');
            end
            obj.callDynamixel('dxl_write_word',obj.Id,MIC_DynamixelServo.LED,value);
            obj.checkCommStatus();
        end
        
        function value = get.Model(obj)
            % Gets model number
            value = obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.MODEL_NUMBER);
            obj.checkCommStatus();
        end
        
        function value = get.Moving(obj)
            % Gets moving information
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.MOVING));
            obj.checkCommStatus();
        end
        
        function value = get.MovingSpeed(obj)
            % Gets moving speed
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.MOVING_SPEED));
            obj.checkCommStatus();
        end
        
        function set.MovingSpeed(obj,value)
            % Sets moving speed to value
            if value < obj.minSpeed || value > obj.maxSpeed
                error('MIC_DynamixelServo:speed', 'Moving speed must be between %i and %i',obj.minSpeed, obj.maxSpeed);
            end
            obj.callDynamixel('dxl_write_word',obj.Id,MIC_DynamixelServo.MOVING_SPEED,value);
            obj.checkCommStatus();
        end
        
        function value = get.PresentPosition(obj)
            % Gets current position
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.PRESENT_POSITION));
            obj.checkCommStatus();
        end
        
        function value = get.PresentSpeed(obj)
            % Gets current speed setting
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.PRESENT_SPEED));
            obj.checkCommStatus();
        end
        
        function value = get.PresentTemperature(obj)
            % Gets current temperature information
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.PRESENT_TEMPERATURE));
            obj.checkCommStatus();
        end
        
        function value = get.PresentVoltage(obj)
            % Gets current voltage information
            value = int32(obj.callDynamixel('dxl_read_word',obj.Id,MIC_DynamixelServo.PRESENT_VOLTAGE));
            obj.checkCommStatus();
        end
        
        function value = get.Rotation(obj)
            % Gets current rotation information
            value = double(obj.GoalPosition)/1023.0 * MIC_DynamixelServo.MAX_ROTATION;
        end
        
        function set.Rotation(obj,value)
            % Sets rotation to value
            pos = value/MIC_DynamixelServo.MAX_ROTATION * 1023;
            obj.GoalPosition = round(pos);
        end
        
        function State=exportState(obj)
            % Exports current state of MIC_DynamixelServo
            State.InstrumentName = obj.InstrumentName;
            State.Id = obj.ID;
            State.Bps = obj.Bps;
            State.Firmware = obj.Firmware;
            State.GoalPosition = obj.GoalPosition;
            State.Model = obj.Model;
            State.MovingSpeed = obj.MovingSpeed;
            State.Port = obj.Port;
            State.PresentPosition = obj.PresentPosition;
            State.PresentSpeed = obj.PresentSpeed;
            State.PresentTemperature = obj.PresentTemperature;
            State.PresentVoltage = obj.PresentVoltage;
            State.Rotation = obj.Rotation;
        end
    end
    
    methods(Static)        
        function varargout = callDynamixel(varargin)
            % Calls Dynamixel library functions
            % varargin{1} should be name of library function to call
            % Other varargin arguments should be input to the library
            %  function
            % varargout can contain output arguments for the libary
            %  function
            lname = 'dynamixel';
            FuncName=varargin{1};
            varargout = {};
            MIC_DynamixelServo.loadlibrary();
            %make the function call string
            try
                funcall = '';
                if nargout > 0
                    funcall='[';
                end
                for ii=1:nargout
                    if ii==nargout
                        funcall=[funcall 'varargout{' num2str(ii) '}' ']='];
                    else
                        funcall=[funcall 'varargout{' num2str(ii) '},'];
                    end
                end
                funcall=[funcall 'calllib(''' lname ''','];
                funcall=[funcall '''' FuncName ''''];
                for ii=2:length(varargin)
                    funcall=[funcall ', varargin{' num2str(ii) '}'];
                end
                funcall=[funcall ');'];
                %call the function
                eval(funcall);
                %process errors
            catch ME
                fprintf('MIC_DynamixelServo Library Call Function Error calling: %s\n',FuncName);
                rethrow(ME);
            end
        end        
        
        function Port=findport(Id,Bps)
            % Finds to which COM port servo is connected
            if ~exist('Bps','var')
                Bps = MIC_DynamixelServo.DEFAULT_BAUDNUM;
            end
            Port = 0;
            comports = instrhwinfo('serial');
            N=length(comports.SerialPorts);
            for nn=1:N
                stext=comports.SerialPorts{nn};
                Port = str2double(stext(4));
                try
                MIC_DynamixelServo.initialize(Port,Bps);
                catch
                    %fprintf('Not on Port %d\n',nn)
                    continue
                end
                % confirm servo exists
                if MIC_DynamixelServo.ping_static(Id) ~= MIC_DynamixelServo.COMM_RXSUCCESS
                    %fprintf('Not on Port %d\n',nn)
                else
                    Port=nn;
                    %fprintf('Found on Port %d\n',nn)
                    break;
                end
                
            end
            
            if ~Port
                error('Could not find DynamixelServo Port')
            end
            
        end
        
        function result = ping_static(Id)
            % Checks status of connection to servo
            MIC_DynamixelServo.callDynamixel('dxl_ping',Id);
            result = MIC_DynamixelServo.callDynamixel('dxl_get_result');
        end
        
        function initialize(Port, Bps)
            % Initializes the servo using the library function
            result = calllib('dynamixel', 'dxl_initialize', Port, Bps);
            if result ~= 1
                error('MIC_DynamixelServo:InitFailed','MIC_DynamixelServo lib failed to initialize.');
            end
        end
        
        function loadlibrary(lpath, lname)
            % Loads USB2Dynamixel library
            if ~exist('lpath','var')
                lpath = {'C:\Program Files (x86)\ROBOTIS\USB2Dynamixel\bin',...
                    'C:\Program Files (x86)\ROBOTIS\USB2Dynamixel\import'};
            end
            if ~exist('lname','var')
                lname = 'dynamixel';
            end
            try
                % only load if not loaded
                if ~libisloaded('dynamixel')
                    for p = lpath
                        if exist(p{:},'dir')
                            addpath(p{:});
                        else
                            warning('MIC_DynamixelServo:LibraryPathNotFound', 'Path %s does not exist', p{:});
                        end
                    end
                    %if ~exist([lpath lname '.dll'],'file')
                    %    warning('MIC_DynamixelServo:LibraryNotFound','Could not find %s.dll!', lname);
                    %end
                    [~,~]=loadlibrary([lname '.dll'],'dynamixel.h');
                end
            catch ME
                error('MIC_DynamixelServo:NoDll',['Failed to load ' lname ' cannot talk to servos.']);
            end
        end

        function [] = printErrorCode()
            %Prints communication result
            if int32(calllib('dynamixel','dxl_get_rxpacket_error', MIC_DynamixelServo.ERRBIT_VOLTAGE))==1
                error('Input Voltage Error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_ANGLE))==1
                error('Angle limit error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_OVERHEAT))==1
                error('Overheat error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_RANGE))==1
                error('Out of range error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_CHECKSUM))==1
                error('Checksum error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_OVERLOAD))==1
                error('Overload error!');
            elseif int32(calllib('dynamixel','dxl_get_rxpacket_error',MIC_DynamixelServo.ERRBIT_INSTRUCTION))==1
                error('Instruction code error!');
            end
        end
        
        function [] = printCommStatus( CommStatus )
            % Prints error bit of status packet
            switch(CommStatus)
                case MIC_DynamixelServo.COMM_TXFAIL
                    disp('COMM_TXFAIL : Failed transmit instruction packet!');
                case MIC_DynamixelServo.COMM_TXERROR
                    disp('COMM_TXERROR: Incorrect instruction packet!');
                case MIC_DynamixelServo.COMM_RXFAIL
                    disp('COMM_RXFAIL: Failed get status packet from device!');
                case MIC_DynamixelServo.COMM_RXWAITING
                    disp('COMM_RXWAITING: Now recieving status packet!');
                case MIC_DynamixelServo.COMM_RXTIMEOUT
                    disp('COMM_RXTIMEOUT: There is no status packet!');
                case MIC_DynamixelServo.COMM_RXCORRUPT
                    disp('COMM_RXCORRUPT: Incorrect status packet!');
                otherwise
                    disp('This is unknown error code!');
            end
        end
        
        function unloadlibrary()
            % Unloads Dynamixel library
            calllib('dynamixel','dxl_terminate');
        end
        
        function State=unitTest(Id)
            % Test all functionality of MIC_DynamixelServo class
            % INPUT
            %   Id    Id of servo, is written on servo
            % OUTPUT
            %   State    exported current state of object
            
            fprintf('Testing MIC_DynamixelServo class...\n')
            % constructing and deleting instances of the class
            DSobj = MIC_DynamixelServo(Id);
            delete(DSobj)
            clear DSobj;
            DSobj = MIC_DynamixelServo(Id);
            fprintf('* Construction and Destruction of object works\n')
            % loading and closing gui
            GUIfig = DSobj.gui;
            close(GUIfig);
            DSobj.gui;
            fprintf('* Opening and closing of GUI works, please test GUI manually\n');
            % Turn LED on and off
            fprintf('* LED should be blinking now, showing that it works\n');
            for ii = 1:10
                DSobj.Led = 1;
                pause(0.2);
                DSobj.Led = 0;
                pause(0.2);
            end
            % Change position and moving speed
            % Should move slowly to one side and then fast back
            fprintf('* Do you hear/see the servo move?\n')
            fprintf('  It should move slowly to one side and fast back\n');
            DSobj.MovingSpeed = 100;
            DSobj.GoalPosition = 500;
            pause(5);
            DSobj.MovingSpeed = 1000;
            DSobj.GoalPosition = 0;
            fprintf('  If you saw/heard that, moving and changing the speed works\n');
            % export state
            State = DSobj.exportState;
            disp(State);
            fprintf('* Export of current state works, please check workspace for it\n')
            fprintf('Finished testing MIC_DynamixelServo class\n');
        end
    end
end