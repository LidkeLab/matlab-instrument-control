classdef MIC_MCLMicroDrive < MIC_LinearStage_Abstract
    %MIC_MCLMicroDrive controls a Mad City Labs Micro Stage
    % This class controls a Mad City Labs (MCL) micro-positioner stage.
    % This class uses the built-in MATLAB methods for calling C libraries,
    % e.g., calllib(), to call functions in MicroDrive.dll.  The
    % micro-positioner stage controller is to expected to be connected via
    % USB.
    %
    % The first time this class is used on a given computer, the user will
    % be prompted to select the location of MicroDrive.dll.  On a Windows
    % machine, this is typically placed by default in
    % C:\Program Files\Mad City Labs\MicroDrive\MicroDrive.dll  during the
    % installation process (installation files provided by MCL).
    %
    % NOTE: I had to manually modify MicroDrive.h to remove the precompiler
    %       directives related to the '_cplusplus' stuff.  I was getting
    %       errors otherwise that I didn't know what to do about! -DS 2021
    %
    % REQUIRES:
    %   MCL MicroDrive files installed on system.
    
    % Created by:
    %   David J. Schodt (Lidkelab, 2021) based on MIC_MCLNanoDrive class.
    
    
    properties (SetAccess = protected)
        % Generic name of the instrument (char array)
        InstrumentName = 'MCLMicroDrive';
        
        % Structure describing error codes (struct)
        % The index of the struct corresponds to the error returned from
        % the instrument as follows:
        %   ErrorCodes(1) <-> Error code 0
        %   ErrorCodes(2) <-> Error code -1
        %   ErrorCodes(3) <-> Error code -2
        %   ...
        ErrorCodes struct
        
        % Last error to be returned by the instrument. (struct)
        LastError struct
        
        % Version number for the MicroDrive.dll file used.
        DLLVersion
        
        % Revision number for the MicroDrive.dll file used.
        DLLRevision
        
        % Serial number for the micro-drive being used.
        SerialNumber
        
        % Directory containing the MicroDrive.dll file to be used.
        DLLPath
        
        % Current position of the stage (millimeters)
        CurrentPosition = NaN;
        
        % Minimum position of stage (millimeters)
        % NOTE: We don't have the position encoder, so for now I'm making
        %       this NaN (since we can't make use of it).
        MinPosition = NaN;
        
        % Maximum position of stage (millimeters)
        % NOTE: We don't have the position encoder, so for now I'm making
        %       this NaN (since we can't use it).
        MaxPosition = NaN;
        
        % Size of a single step of the stage. (millimeters)
        StepSize(1, 1) double = NaN;
        
        % Min. and max. velocities of stage (mm/s)(2x1 array, [min.; max.])
        VelocityBounds(2, 1) double = NaN(2, 1);
        
        % Axis of the stage (char)('X', 'Y', or 'Z')
        Axis = 'Z';
        
        % Units used for the stage position. (Default = 'millimeters')
        % NOTE: This should not be changed.  It is merely here as an extra
        %       accounting tool for anybody not familiar with the device
        %       usage.
        PositionUnit = 'millimeters';
        
        % Integer specifying device handle (Default = 0).
        DeviceHandle(1, 1) {mustBeInteger(DeviceHandle)} = 0;
    end
    
    properties (Hidden)
        StartGUI = false;
    end
    
    properties
        % Number of axes on the stage to be used. (integer)(Default = 1)
        % The number of axes must be either 1 (z only) or 3 (x, y, z).
        % NOTE: Ideally we should figure this out by requesting info. from
        %       the stage itself, I just haven't figured that out yet!
        NAxes(1, 1) {mustBeMember(NAxes, [1, 3])} = 1;
    end
    
    methods
        function obj = MIC_MCLMicroDrive()
            %MIC_MCLMicroDrive is the class constructor.
            
            % Prepare the class instance.
            obj = obj@MIC_LinearStage_Abstract(~nargout);
            
            % Define the error code structure and set obj.LastError to the
            % default choice (i.e., no error).
            % NOTE: I've just copy-pasted most of this info. straight from
            %       a micro-drive manual.
            obj.ErrorCodes(1).ErrorCode = 0;
            obj.ErrorCodes(1).ErrorName = 'MCL_SUCCESS';
            obj.ErrorCodes(1).ErrorInfo = ...
                'Task has been completed successfully';
            obj.ErrorCodes(2).ErrorCode = -1;
            obj.ErrorCodes(2).ErrorName = 'MCL_GENERAL_ERROR';
            obj.ErrorCodes(2).ErrorInfo = ['These errors generally ', ...
                'occur due to an internal sanity check failing.'];
            obj.ErrorCodes(3).ErrorCode = -2;
            obj.ErrorCodes(3).ErrorName = 'MCL_DEV_ERROR';
            obj.ErrorCodes(3).ErrorInfo = ['A problem occurred ', ...
                'when transferring data to the Micro-Drive.  It is ', ...
                'likely that the Micro-Drive will have to be power ', ...
                'cycled to correct these errors.'];
            obj.ErrorCodes(4).ErrorCode = -3;
            obj.ErrorCodes(4).ErrorName = 'MCL_DEV_NOT_ATTACHED';
            obj.ErrorCodes(4).ErrorInfo = ['The Micro-Drive cannot ', ...
                'complete the task because it is not attached.'];
            obj.ErrorCodes(5).ErrorCode = -4;
            obj.ErrorCodes(5).ErrorName = 'MCL_USAGE_ERROR';
            obj.ErrorCodes(5).ErrorInfo = ['Using a function from ', ...
                'the library which the Micro-Drive does not support ', ...
                'causes these errors.'];
            obj.ErrorCodes(6).ErrorCode = -5;
            obj.ErrorCodes(6).ErrorName = 'MCL_DEV_NOT_READY';
            obj.ErrorCodes(6).ErrorInfo = ['The Micro-Drive is ', ...
                'currently completing or waiting to complete ', ...
                'another task.'];
            obj.ErrorCodes(7).ErrorCode = -6;
            obj.ErrorCodes(7).ErrorName = 'MCL_ARGUMENT_ERROR';
            obj.ErrorCodes(7).ErrorInfo = ['An argument is out of ', ...
                'range or a required pointer is equal to NULL.'];
            obj.ErrorCodes(8).ErrorCode = -7;
            obj.ErrorCodes(8).ErrorName = 'MCL_INVALID_AXIS';
            obj.ErrorCodes(8).ErrorInfo = ['Attempting an operation ', ...
                'on an axis that does not exist in the Micro-Drive.'];
            obj.ErrorCodes(9).ErrorCode = -8;
            obj.ErrorCodes(9).ErrorName = 'MCL_INVALID_HANDLE';
            obj.ErrorCodes(9).ErrorInfo = ['The handle is not ', ...
                'valid.  Or at least is not valid in this instance ', ...
                'of the DLL.'];
            obj.ErrorCodes(10).ErrorCode = -9;
            obj.ErrorCodes(10).ErrorName = 'Undefined error';
            obj.ErrorCodes(10).ErrorInfo = ['This error is not ', ...
                'defined in the MCL Micro-Drive manual and was ', ...
                'likely set manually inside of this class.'];
            obj.LastError = obj.ErrorCodes(1);
            
            % Check for a .mat file specifying the DLL path and ask the
            % user to specify this path if needed.
            ClassPath = fileparts(which('MIC_MCLMicroDrive'));
            PropertiesFile = fullfile(ClassPath, ...
                'MIC_MCLMicroDrive_Properties.mat');
            if exist(PropertiesFile, 'file')
                % Load the existing path information on this computer.
                load(PropertiesFile, 'DLLPath');
                obj.DLLPath = DLLPath;
            else
                % Ask the user to specify the path to the DLL file.
                obj.getDLLPath();
            end
            
            % Load MicroDrive.dll.
            if ~libisloaded('MicroDrive')
                addpath(obj.DLLPath)
                LibraryPath = fullfile(obj.DLLPath, 'MicroDrive.dll');
                loadlibrary(LibraryPath, 'MicroDrive.h')
            end
            
            % Connect to the micro-drive controller.
            % NOTE: A returned handle of 0 means there was an error.  As
            %       was done in MIC_MCLNanoDrive, we'll set a custom error
            %       in obj.LastError to indicate this failure (if needed).
            fprintf('Starting MCL MicroDrive Controller\n')
            obj.DeviceHandle = calllib('MicroDrive', 'MCL_InitHandle');
            obj.LastError = obj.ErrorCodes(10 * (~obj.DeviceHandle));
            
            % Request some device information from the micro-stage.
            [ErrorCode, obj.SerialNumber] = calllib('MicroDrive', ...
                'MCL_GetSerialNumber', obj.DeviceHandle);
            obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
            obj.displayLastError()
            [ErrorCode, obj.DLLVersion, obj.DLLRevision] = ...
                calllib('MicroDrive', 'MCL_DLLVersion', 0, 0);
            obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
            obj.displayLastError()
            [ErrorCode, ~, obj.StepSize, ...
                obj.VelocityBounds(2), obj.VelocityBounds(1)] = ...
                calllib('MicroDrive', 'MCL_MicroDriveInformation', ...
                0, 0, 0, 0, obj.DeviceHandle);
            obj.LastError = obj.ErrorCodes(-ErrorCode + 1);
            obj.displayLastError()
        end
        
        function delete(obj)
            %delete is the class destructor.
            calllib('MicroDrive', 'MCL_ReleaseHandle', obj.DeviceHandle);
            fprintf('Stage released\n');
            obj.DeviceHandle = 0;
        end
        
        function getDLLPath(obj)
            %getDLLPath request user selection of MicroDrive.dll
            [~, obj.DLLPath] = uigetfile('Select MicroDrive.dll');
            if isequal(obj.DLLPath, 0)
                warning('MicroDrive.dll was not selected')
                return
            end
            ClassPath = fileparts(which('MIC_MCLNanoDrive'));
            FilePath = fullfile(ClassPath, ...
                'MIC_MCLNanoDrive_Properties.mat');
            DLLPath = obj.DLLPath;
            save(FilePath, 'DLLPath');
        end
        
        function setPosition(obj, Position)
            % Currently, the MCL microdrive we have doesn't have the
            % position encoder, meaning we can't make use of this!
        end
        
        function getPosition(obj)
            % Currently, the MCL microdrive we have doesn't have the
            % position encoder, meaning we can't make use of this!
        end
        
        function center(obj)
            % Currently, the MCL microdrive we have doesn't have the
            % position encoder, meaning we can't make use of this!
        end
        
        moveSingleStep(obj, Direction)
        moveDistance(obj, Distance, Velocity)
        gui(obj)
        [Attributes, Data, Children] = exportState(obj)
        
    end
    
    
    methods (Static)
        
        function Success = unitTest()
            
        end
        
        function libreset()
            if libisloaded('MicroDrive')
                unloadlibrary('MicroDrive')
            end
        end
    end
    
    
end