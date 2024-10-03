classdef MCLNanoDrive < mic.stage3D.abstract
    % mic.stage3D.MCLNanoDrive controls the Mad City Labs 3D Piezo Stage
    %
    %   ## Description
    %   This class controls a 3D Peizo stage from Mad City Labs.  The class
    %   uses 'calllib' to directly call funtions from the madlib.dll. The instument
    %   is attached via USB.
    %   The first time an object of this class is created, the user must
    %   direct the object to the 'madlib.h' header file.  This is usually
    %   located here:  C:\Program Files\Mad City Labs\NanoDrive
    %
    % ## Features
    % - Direct control of Mad City Labs 3D Piezo stages via USB.
    % - Dynamic link library interaction using `madlib.dll` for stage control.
    % - Error handling and reporting integrated within the class structure.
    % - Simple and intuitive GUI for easy operation.
    %
    % ## Requirements
    % - mic.stage3D.abstract.m
    % - mic.abstract.m
    % - MATLAB 2014b or higher
    % - Mad City Labs drivers and `madlib.h` installed on the system.
    %
    % ## Installation Notes
    % During the first initialization of this class on a system, users are prompted to direct the class to the `madlib.h` header file, typically located in `C:\Program Files\Mad City Labs\NanoDrive`.
    %
    % ## Key Methods
    % - **Constructor (`mic.stage3D.MCLNanoDrive()`):** Initializes the connection to the Mad City Labs stage and loads necessary libraries.
    % - **`setPosition([x, y, z])`:** Moves the stage to the specified x, y, z coordinates.
    % - **`getSensorPosition()`:** Retrieves the current sensor position from the stage.
    % - **`center()`:** Centers the stage based on its configured range of motion.
    % - **`delete()`:** Releases the hardware handle and properly shuts down the connection to the stage.
    % - **`gui()`:** Launches a graphical user interface for real-time stage control.
    % - **`exportState()`:** Exports the current state of the stage including settings and position for record-keeping or analysis.
    %
    % ## Usage Example
    % ```matlab
    % % Create an instance of the mic.stage3D.MCLNanoDrive
    % stage = mic.stage3D.MCLNanoDrive();
    %
    % % Move the stage to a specific position
    % stage.setPosition([10, 10, 10]);
    %
    % % Retrieve and display the current sensor position
    % stage.getSensorPosition();
    % disp(stage.SensorPosition);
    %
    % % Center the stage
    % stage.center();
    %
    % % Display the GUI
    % stage.gui();
    % ```
    % ### Citation:Hanieh Mazloom-Farsibaf, Lidke Lab 2018

     properties (SetAccess=protected)
        InstrumentName='MCLNanoDrive'; 
        ErrorCode;  %Fixed structure listing all error codes.  Loaded by set_errorcodes()
        Max_X;      %Max X Position (microns)
        Max_Y;      %Max Y Position (microns)
        Max_Z;      %Max Z Position (microns)
        DLLversion;     % Dll major version
        DLLrevision;    % Dll minor version
        ProductInfo;    % Stage controller model number
        Serial;         % Stage serial number
        DLLPath;        % Path to madlib.h
        LastError;      % Last ErrorCode
    end
    
    properties(Transient, SetAccess = protected)
       Position=[0 0 0];    %Current Position (micron)
       SensorPosition;      %Results of a get Position (micron)
       PositionUnit='um'    %Units of position parameter (micron)
    end
     
    properties(Access=private)
        handle;         % handle to control this specific stage.  Only one Dll instance can control a stage at a time.
    end
    
    properties(Hidden)
       StartGUI=false;
    end
    
    methods
        
        function obj=MCLNanoDrive()
            % Constructor. Takes no arguments and returns the object. 
            obj=obj@mic.stage3D.abstract(~nargout);
            
            obj.set_errorcodes(); % set obj.ErrorCode to static values
            
            [p,~]=fileparts(which('mic.stage3D.MCLNanoDrive'));
            if exist(fullfile(p,'MCLNanoDrive_Properties.mat'),'file')
                a=load(fullfile(p,'MCLNanoDrive_Properties.mat'));
                obj.DLLPath=a.DLLPath;
                clear a;
            else
                obj.getdllpath;
            end
            fprintf('Starting MCL NanoDrive Controller\n')
            if ~libisloaded('Madlib')
                addpath(obj.DLLPath)
                f=fullfile(obj.DLLPath,'Madlib.dll');
                loadlibrary(f,'Madlib.h')
            end
            % Call the MCL Nano Drive handle, 0 is the error so I set it to -9 to flag towards MISC
            obj.handle = obj.callNano('MCL_InitHandle');
            obj.LastError = (~obj.handle)*-9;
            obj.errorcheck('MCL_InitHandle');
            
            % Set the maximum distances for each of the 3-axes
            obj.LastError = obj.callNano('MCL_GetCalibration',1,obj.handle);
            obj.Max_X = obj.errorcheck('MCL_GetCalibration');
            obj.LastError = obj.callNano('MCL_GetCalibration',2,obj.handle);
            obj.Max_Y = obj.errorcheck('MCL_GetCalibration');
            obj.LastError = obj.callNano('MCL_GetCalibration',3,obj.handle);
            obj.Max_Z = obj.errorcheck('MCL_GetCalibration');
            % return the serial number of the device
            obj.Serial = obj.callNano('MCL_GetSerialNumber',obj.handle);
            % condition the product information structure
            prodinfo.axis_bitmap = uint8(0);
            prodinfo.ADC_resolution = int16(0);
            prodinfo.DAC_resolution = int16(0);
            prodinfo.Product_id = int16(0);
            prodinfo.FirmwareVersion = int16(0);
            prodinfo.FirmwareProfile = int16(0);
            prodinfo=libstruct('ProductInformation',prodinfo);
            % get the product information
            obj.LastError = obj.callNano('MCL_GetProductInfo',prodinfo,obj.handle);
            obj.errorcheck('MCL_GetProductInfo',prodinfo);
            % get dynamic load library versions
            [obj.DLLversion, obj.DLLrevision] = obj.callNano('MCL_DLLVersion',0,0);
            % zero is the error for MCL_CorrectDriverVersion, so I set it to -9 to flag it towards MISC
            fail = obj.callNano('MCL_CorrectDriverVersion');
            obj.LastError = (~fail)*-9;
            obj.errorcheck('MCL_CorrectDriverVersion');
            % center the stage
            obj.center;            
        end
        
        function delete(obj)  % destructor
            obj.callNano('MCL_ReleaseHandle',obj.handle);
            fprintf('Stage released\n');
            obj.handle = 0;
        end

        function getdllpath(obj)
            [~,obj.DLLPath]=uigetfile('Select Madlib.h');
            [p,~]=fileparts(which('mic.stage3D.MCLNanoDrive'));
            f=fullfile(p,'MCLNanoDrive_Properties.mat');
            DLLPath=obj.DLLPath;
            save(f,'DLLPath');
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
        
        function center(obj, AxisBool)
            % Center the stage in it's range of travel rounded to the
            % nearest micron, i.e. range = 101, stage goes to 50,50,50
            % If AxisBool is specified, the stage will only be centered
            % alnog the dimensions selected.  For example, if 
            % AxisBool = [1; 0; 1], the stage will be centered along the X 
            % and Z axes, and the Y axis will remain unchanged. 
            
            % Check if the AxisBool was entered, setting a default if not.
            if ~exist('AxisBool', 'var')
                AxisBool = [1; 1; 1];
            end
            
            X = obj.Position; % initialize
            if AxisBool(1)
                X(1) = floor(obj.Max_X/2);
            end
            if AxisBool(2)
                X(2) = floor(obj.Max_Y/2);
            end
            if AxisBool(3)
                X(3) = floor(obj.Max_Z/2);
            end
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
                M=mic.stage3D.MCLNanoDrive()
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
        % test
        
        function libreset()
            if  libisloaded('Madlib')
                unloadlibrary('Madlib')
            end
        end
    end
    
end
