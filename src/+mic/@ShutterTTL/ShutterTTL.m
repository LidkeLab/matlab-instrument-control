classdef ShutterTTL < mic.abstract 
    % mic.ShutterTTL: Matlab Instrument Control Class for the shutter
    %
    % ## Description
    % This class controls a Thorlabs SH05 shutter via a Thorlabs KSC101 
    % solenoid controller. KSC101 controller is triggerd in  
    % (put the controller in trigger mode) via a TTL signal passing 
    % from the computer to the controller through a NI-DAQ card. 
    % TTL signal lets the shutter to be set open or close.
    % so shutter is regulated by the Digital voltage output of the NI-DAQ card.
    % Make the object by: obj=mic.ShutterTTL('Dev#','Port#/Line#')where:
    % Dev# = Device number assigned to DAQ card by computer USB port of the
    % Port# = Port number in use on the DAQ card by your shutter connection
    % Line# = Line number in use on the DAQ card by the Port.
    %
    % ## Constructor
    % Example: obj=mic.ShutterTTL('Dev1','Port0','Line1');
    %
    % Key Functions: 
    % close, open, delete, exportState 
    %
    % ## REQUIRES:
    %   mic.abstract.m
    %   Data Acquisition Toolbox on MATLAB
    %   MATLAB NI-DAQmx driver in MATLAB installed via the Support Package Installer
    %   type "SupportPackageInstaller" on command line to install the 
    %   support package for NI-DAQmx use MATLAB 2014b and higher 
    %   
    % ### CITATION: Farzin Farzam, Lidkelab, 2017.
    
    
    properties(SetAccess=protected)
        
        InstrumentName = 'ShutterTTL';
        DAQ=[];
        IsOpen;
    end
    
    
    properties
     
        NIDevice  %DAQ card device number at the USB port of the computer
        DOChannel; %included both port and line information 
        StartGUI = 0; %uses mic.Abstract to bring up the GUI (so, no need for a gui function in mic.ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
        NIString  %shows the combination of Device/Port/Line the shutter is using
    end
    
    methods
        function obj = ShutterTTL(NIDevice,DOChannel) % constructor
           % daqreset; %reset any former session that might prevent the DAQ card to be available
            % when you are making an object for this class, you should do it this way: obj= ShutterTTL('Dev1','Port0','Line1')
            % of course you need to put the numbers after Dev,Port and Line
            % based on the physical connections of the shutter to your NI-DAQ card
            obj = obj@mic.abstract(~nargout);
            if nargin<2
                error('mic,ShutterTTL:NIDevice, Port and Line must be defined')
            end
            
            obj.NIDevice=NIDevice;
            obj.DOChannel=DOChannel;
            obj.NIString=sprintf('%s/%s/%s',obj.NIDevice,obj.DOChannel);
           % obj.close; %closes the shutter as it first starts working
            
            %Set up the NI Daq Object
            obj.DAQ = daq.createSession('ni');
            addDigitalChannel(obj.DAQ,NIDevice,DOChannel,'OutputOnly');  % addDigitalChannel(s,deviceID,channelID,measurementType)
            obj.close;
        end
        
        function delete(obj)
            delete(obj.GuiFigure);
            delete(obj.DAQ);
        end
        
        function close(obj)  %closes the shutter
           % obj.NIDevice=NIDevice;
            %release(obj)
           % obj.DAQ = daq.createSession('ni');
           % addDigitalChannel(obj.DAQ,NIDevice,DOChannel,'OutputOnly');
            outputSingleScan(obj.DAQ,0)
            obj.IsOpen=0;
            % obj.Position=0;

        end
        
        function open(obj) %opens the shutter
            outputSingleScan(obj.DAQ,1)
            obj.IsOpen=1;
            % obj.Position=1;

        end
        
        %gui
        function gui(obj)
            
            obj.GuiFigure = figure('visible', 'off', 'position', [400,400,250,250]);
            obj.GuiFigure.Visible = 'on';
            set(obj.GuiFigure,'MenuBar','none')
            set(obj.GuiFigure,'NumberTitle','off')
            set(obj.GuiFigure,'Name','ShutterTTL')
            h=uicontrol('Style','togglebutton',...
                'String','Shutter Closed','Position',[90 105,80,70],...
                'BackgroundColor',[0  0  0],'Callback',@ToggleLight);
            h.ForegroundColor=[1 1 1]
            
            function ToggleLight(src,event)
                handlevalue=get(h,'Value');
                if handlevalue==1
                    set(h,'String','Shutter Open')
                    set(h,'BackgroundColor',[1 1 1])
                    set(h,'ForegroundColor',[0 0 0])
                    obj.open;
                else
                    set(h,'String','Shutter Closed')
                    set(h,'BackgroundColor',[0  0  0])
                    set(h,'ForegroundColor',[1 1 1])
                    obj.close;
                end
               % display('Button pressed');
            end
            
            
            %Save Propeties upon close
            obj.GuiFigure.CloseRequestFcn = @closeFigure;
            
            function closeFigure(~,~)
                delete(obj.GuiFigure);
            end
            
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            Attributes.IsOpen = obj.IsOpen;
            Attributes.InstrumentName = obj.InstrumentName;
            Data = [];
            Childern = [];
        end
        
        
    end
    
    
    
    methods(Static=true)% Static: means it can be used stand alone, without the need to make an object
        % test this class on command line by: mic.ShutterTTL.unitTest('Dev1','Port0','Line1')
        function State=unitTest(NIDevice,DOChannel)
            % Unit test of object functionality
            
            if nargin<2
                error('mic.ShutterTTL:NIDevice, Port and Line must be defined')
            end
            
           % release(mic.ShutterTTL('Dev1','Port0','Line1'))
            %Create an Object and Test open, close
            fprintf('Creating Object\n')
            % release()
            S=mic.ShutterTTL(NIDevice,DOChannel);
            S.open;
            fprintf('Shutter Open\n')
            pause(.5);
            S.close;
            fprintf('Shutter Off\n')
            %Test Destructor
            delete(S);
            clear S;
            %Create an Object and Repeat Test
            fprintf('Creating Object\n')
            S=mic.ShutterTTL(NIDevice,DOChannel);
            S.open;
            fprintf('Shutter Open\n')
            pause(.5);
            S.close;
            fprintf('Shutter Off\n')
            %Test export state
            A=S.exportState;
            disp(A);
            %Test Destructor
            daqreset;
            delete(S);
            clear S;
            
        end
        
    end
    
end

