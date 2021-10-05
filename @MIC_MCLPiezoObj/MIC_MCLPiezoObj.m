classdef MIC_MCLPiezoObj < MIC_LinearStage_Abstract
    % MIC_MCLPiezoObj controls the Mad City Labs Piezo objective
    %   
    % The class uses 'calllib' to directly call funtions from the 
    % madlib.dll. The instument is attached via USB.  
    %
    % The first time an object of this class is created, the user must
    % direct the object to the 'madlib.h' header file.  This is usually
    % located here:  C:\Program Files\Mad City Labs\NanoDrive
    %
    %   REQUIRES:
    %       MATLAB 2019b or higher
    %       MCL Drivers installed on system.  
    
    % Update:Sajjad Khan, Lidke Lab 2021
    %       MCL Drivers installed on system.
    
    properties (SetAccess=protected)
        InstrumentName='MCLPiezoObj';
        ErrorCode;  %Fixed structure listing all error codes.  Loaded by set_errorcodes()
        Max_X;      %Max X Position (microns)
        DLLversion;     % Dll major version
        DLLrevision;    % Dll minor version
        ProductInfo;    % Stage controller model number
        Serial;         % Stage serial number
        DLLPath;        % Path to madlib.h
        LastError;      % Last ErrorCode
        PositionUnit='um';     % Units of position parameter (eg. um/mm)
        CurrentPosition;       % Current position of device (set position)
        MinPosition=0;         % Lower limit position 
        MaxPosition=200;       % Upper limit position
        Axis='X';              % Stage axis (X, Y or Z)
    end
    
    properties(Access=private)
        handle;         % handle to control this specific piezo.  Only one .Dll instance can control it at a time.
    end
    
    properties (Abstract,Hidden)
        StartGUI;       %Defines GUI start mode.  'true' starts GUI on object creation. 
    end
    
    methods
        function obj=MIC_MCLPiezoObj()
            % Constructor takes no arguments and returns the object.
            obj = obj@MIC_LinearStage_Abstract(~nargout);
            obj.set_errorcodes(); % set obj.ErrorCode to static values
            
            [p,~]=fileparts(which('MIC_MCLNanoDrive'));
            if exist(fullfile(p,'MIC_MCLProperties.mat'),'file')
                a=load(fullfile(p,'MIC_MCLProperties.mat'));
                obj.DLLPath=a.DLLPath;
                clear a;
            else
                obj.getdllpath();
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
            obj.center();     
        end
        
        function getdllpath(obj)
            [~,obj.DLLPath]=uigetfile('Select Madlib.h');
            [p,~]=fileparts(which('MIC_MCLNanoDrive'));
            f=fullfile(p,'MIC_MCLProperties.mat');
            DLLPath=obj.DLLPath;
            save(f,'DLLPath');
        end
        
        function delete(obj)  % destructor
            obj.callNano('MCL_ReleaseHandle',obj.handle);
            fprintf('Handles Relaeased\n');
            obj.handle = 0;
        end
        
        function setPosition(obj,Position) % Move stage to position
           %callNano .....
            x=Position;
            % X
            if x < 0 || x > obj.Max_X
                error('MCLNanoDrive:InvalidX','X position must be between 0 and %fµm.', obj.Max_X);
            end
            obj.LastError = obj.callNano('MCL_SingleWriteN',x,1,obj.handle);
            obj.errorcheck('MCL_SingleWriteN',x,1)       
            
            obj.CurrentPosition=Position;
            obj.updateGui()
           
        end
            
        function Pos = getPosition(obj)
        % getPosition Query device for sensor position    
            Pos=obj.CurrentPosition;  
        end
        
        function Pos=getSensorPosition(obj) 
            % gets the position from the MCL NanoDrive sensor.
            obj.LastError = obj.callNano('MCL_SingleReadN',1,obj.handle);
            obj.errorcheck('MCL_SingleReadN')
            Pos = obj.LastError;
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
        
        function libreset()
            if  libisloaded('Madlib')
                unloadlibrary('Madlib')
            end
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            Attributes.Position=obj.Position;
            Attributes.Max_X = obj.Max_X;
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
    
    methods (Abstract)
        unitTest()
    end
end