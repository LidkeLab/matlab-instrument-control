classdef MIC_MCLMicroDrive < MIC_3DStage_Abstract
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
        InstrumentName char = 'MCLMicroDrive';
        
        % Structure describing error codes (struct)
        % The index of the struct corresponds to the error returned from
        % the instrument as follows: 
        %   ErrorCodes(1) <-> Error code 0
        %   ErrorCodes(2) <-> Error code -1
        %   ErrorCodes(3) <-> Error code -2 
        %   ...
        ErrorCodes struct
        
        % Version number for the MicroDrive.dll file used.
        DLLVersion
        
        % Revision number for the MicroDrive.dll file used.
        DLLRevision
        
        % Serial number for the micro-drive being used.
        SerialNumber
        
        % Directory containing the MicroDrive.dll file to be used.
        DLLPath
        
        % Units used for the stage position. (Default = 'micrometers')
        % NOTE: This should not be changed.  It is merely here as an extra
        %       accounting tool for anybody not familiar with the device
        %       usage.
        PositionUnit char = 'micrometers';
        
        % Integer specifying device handle (Default = 0).
        DeviceHandle(1, 1) {mustBeInteger(DeviceHandle)} = 0;
    end
    
    properties(Transient, SetAccess = protected)
        % Last error to be returned by the instrument. (struct)
        LastError struct
        
        % Current position of the stage (micrometers)
        Position(3, 1) double = NaN(3, 1);
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
            obj = obj@MIC_3DStage_Abstract(~nargout);
            
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
            obj.DeviceHandle = calllib('MCL_InitHandle');
            obj.LastError = obj.ErrorCodes(-9 * (~obj.DeviceHandle));
            
            % Request some device information from the micro-stage.
            obj.SerialNumber = calllib('MCL_GetSerialNumber', ...
                obj.DeviceHandle);
            obj.displayLastError()
            [obj.DLLVersion, obj.DLLRevision] = calllib('MicroDrive', ...
                'MCL_DLLVersion', 0, 0);
            obj.displayLastError()

            % Center the stage.
            obj.center()
        end
        
        function delete(obj)
            %delete is the class destructor.
            calllib('MCL_ReleaseHandle', obj.DeviceHandle);
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
        
        function setPosition(obj,Position)
            x=Position(1);
            y=Position(2);
            z=Position(3);
            % X
            if x < 0 || x > obj.Max_X
                error('MCLNanoDrive:InvalidX','X position must be between 0 and %fµm.', obj.Max_X);
            end
            obj.LastError = obj.callNano('MCL_SingleWriteN',x,1,obj.handle);
            obj.errorcheck('MCL_SingleWriteN',x,1)
            % Y
            if y < 0 || y > obj.Max_Y
                error('MCLNanoDrive:InvalidY','Y position must be between 0 and %fµm.', obj.Max_Y);
            end
            obj.LastError = obj.callNano('MCL_SingleWriteN',y,2,obj.handle);
            obj.errorcheck('MCL_SingleWriteN',y,2);
            % Z
            if z < 0 || z > obj.Max_Z
                error('MCLNanoDrive:InvalidZ','Z position must be between 0 and %fµm.', obj.Max_Z);
            end
            obj.LastError = obj.callNano('MCL_SingleWriteN',z,3,obj.handle);
            obj.errorcheck('MCL_SingleWriteN',z,3);
            %This updates the gui if it exists
            h = findall(0,'tag','MIC_MCLNanoDrive_gui');
            if ~(isempty(h))
                handles=guidata(h);
                X=obj.Position;
                set(handles.edit_XCurrent,'String',num2str(X(1)));
                set(handles.edit_YCurrent,'String',num2str(X(2)));
                set(handles.edit_ZCurrent,'String',num2str(X(3)));
            end
        end
        
        function getSensorPosition(obj)
            % gets the position from the MCL NanoDrive sensor.
            pos = zeros(3,1);
            % X
            obj.LastError = obj.callNano('MCL_SingleReadN',1,obj.handle);
            obj.errorcheck('MCL_SingleReadN')
            pos(1) = obj.LastError;
            % Y
            obj.LastError = obj.callNano('MCL_SingleReadN',2,obj.handle);
            obj.errorcheck('MCL_SingleReadN');
            pos(2) = obj.LastError;
            % Z
            obj.LastError = obj.callNano('MCL_SingleReadN',3,obj.handle);
            obj.errorcheck('MCL_SingleReadN');
            pos(3)= obj.LastError;
            obj.SensorPosition = pos; % update the position
        end
        
        function center(obj)
            % Center the stage in it's range of travel rounded to the
            % nearest micron, i.e. range = 101, stage goes to 50,50,50
            X(1) = floor(obj.Max_X/2);
            X(2) = floor(obj.Max_Y/2);
            X(3) = floor(obj.Max_Z/2);
            obj.setPosition(X);
        end
        
        function varargout = callNano(obj,varargin)
            % wrapper to make calls the MCL library.  There should not be
            % any real reason to call this outside of the class.
            FuncName=varargin{1};
            lname = 'Madlib';
            try
                %make the function call string
                funcall = '';
                if nargout > 0
                    funcall = sprintf('[');
                    for ii=1:nargout
                        if ii==nargout
                            funcall=sprintf([funcall 'varargout{%d}]='],ii);
                        else
                            funcall=sprintf([funcall 'varargout{%d},'],ii);
                        end
                    end
                end
                funcall = sprintf([funcall 'calllib(''%s'',''%s'''],lname,FuncName);
                for ii=2:nargin-1   % - 1 because obj counts
                    funcall=sprintf([funcall ', varargin{%d}'],ii);
                end
                funcall=sprintf([funcall ');']);
                %call the function
                eval(funcall);
                %process errors
            catch ME
                fprintf('MCL Library Call Function Error calling: %s\n',FuncName);
                rethrow(ME);
            end
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Need to populate this
            Attributes.Position=obj.Position;
            Attributes.Max_X = obj.Max_X;
            Attributes.Max_Y = obj.Max_Y;
            Attributes.Max_Z = obj.Max_Z;
            Attributes.DLLversion = obj.DLLversion;     % Dll major version
            Attributes.DLLrevision = obj.DLLrevision;
            Attributes.Serial = obj.Serial;         % stage serial number
            Attributes.DLLPath = obj.DLLPath;
            
            Attributes.ADC_resolution = obj.ProductInfo.ADC_resolution;    % stage controller info
            Attributes.DAC_resolution = obj.ProductInfo.DAC_resolution;    % stage controller info
            Attributes.Product_id = obj.ProductInfo.Product_id;    % stage controller info
            Attributes.FirmwareVersion = obj.ProductInfo.FirmwareVersion;    % stage controller info
            Attributes.FirmwareProfile = obj.ProductInfo.FirmwareProfile;    % stage controller info
            
            
            Data=[];
            Children=[];
        end
        
    end
    
    methods (Static)
        
        function Success=unitTest()
            
            try
                fprintf('Creating Object\n')
                M=MIC_MCLNanoDrive()
                fprintf('Setting Position to 10,10,10\n')
                M.setPosition([10,10,10]);
                pause(.1)
                M.exportState()
                M.getSensorPosition()
                fprintf('Sensor Position:\n')
                M.SensorPosition
                fprintf('Centering Stage\n')
                M.center();
                pause(.1)
                M.getSensorPosition()
                fprintf('Sensor Position:\n')
                M.SensorPosition
                M.gui
                pause(2)
                delete(M)
                Success=1;
            catch
                Success=0;
            end
            
        end
        
        function libreset()
            if  libisloaded('Madlib')
                unloadlibrary('Madlib')
            end
        end
    end
    
end