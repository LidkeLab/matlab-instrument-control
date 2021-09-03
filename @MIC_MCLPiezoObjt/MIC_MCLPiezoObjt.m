classdef MIC_MCLPiezoObjt < MIC_LinearStage_Abstract
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
        Serial;         % piezo serial number
        PosRead;        % reading the position of an X-axis
    end
    
    properties(Access=private)
        handle;         % handle to control this specific piezo.  Only one .Dll instance can control it at a time.
    end
    
    methods
        function obj=MIC_MCLPiezoObjt()
            % Constructor takes no arguments and returns the object.
            obj = obj@MIC_LinearStage_Abstract(~nargout);
            if f = fullfile('MadCityLabs','NanoDrive','Madlib.dll')
                loadlibrary(f,'Madlib.h')
            end
            fprintf('Starting MCL Piezo Controller\n')
            % Call the MCL Nano Drive handle
            obj.handle = obj.callNano('MCL_InitHandle');
            obj.Serial = obj.callNano('MCL_GetSerialNumber',obj.handle);
        end
        

        function delete(obj)  % destructor
            obj.callNano('MCL_ReleaseHandle',obj.handle);
            fprintf('Handles Relaeased\n');
            obj.handle = 0;
        end
        
        function getCurrentPosition(obj)            
            obj.PosRead = obj.callNano('MCL_SingleReadN',1,obj.handle);
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
            Attributes.Serial = obj.Serial;
            Attributes.PosRead = obj.PosRead;
            
            Data=[];
           Children=[];
        end
        
    end

end