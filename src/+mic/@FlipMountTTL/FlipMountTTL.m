classdef FlipMountTTL < mic.abstract 
    % mic.FlipMountTTL: Matlab Instrument Control Class for the flipmount
    %
    % ## Description
    % This class controls a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M
    % controller.  Controller is triggered in via a TTL signal passing from the
    % computer to the controller through a NI-DAQ card. TTL signal lets the
    % flipmount to be set in up or down positions, so flipmount is regulated by
    % the Digital voltage output of the NI-DAQ card.
    %
    % ## Usage Example
    % Make the object by: obj = mic.FlipMountTTL('Dev#', 'Port#/Line#') where:
    % Dev#  = Device number assigned to DAQ card by computer USB port of the
    % Port# = Port number in use on the DAQ card by your flipmount connection
    % Line# = Line number in use on the DAQ card by the Port
    %
    % ## Constructor
    % Example: obj = mic.FlipMountTTL('Dev1', 'Port0/Line1');
    %
    % ## Key Functions: FilterIn, FilterOut, gui, exportState
    %
    % ## REQUIREMENTS:
    %   mic.abstract.m
    %   Data Acquisition Toolbox on MATLAB
    %   MATLAB NI-DAQmx driver in MATLAB installed via the Support Package
    %      Installer
    %   type "SupportPackageInstaller" on command line to install the support
    %      package for NI-DAQmx
    %
    % ### CITATION: Farzin Farzam, Lidkelab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName = 'FlipMountTTL';
        DAQ=[];
        IsOpen;
    end    
    
    properties
        NIDevice  %DAQ card device number at the USB port of the computer
        DOChannel; %included both port and line information 
        StartGUI = 0; %uses mic.abstract to bring up the GUI (so, no need for a gui function in mic.ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
        NIString  %shows the combination of Device/Port/Line the shutter is using
    end
    
    methods
        function obj = FlipMountTTL(NIDevice,DOChannel) % constructor
            % when you are making an object for this class, 
            % you should do it this way: obj= mic.FlipMountTTL('Dev1','Port0/Line1')
            % of course you need to put the numbers after Dev,Port and Line
            % based on the physical connections of the shutter to your NI-DAQ card
            obj = obj@mic.abstract(~nargout);
            if nargin<2
                error('mic.FlipMountTTL:NIDevice, Port and Line must be defined')
            end
            
            obj.NIDevice=NIDevice;
            obj.DOChannel=DOChannel;
            obj.NIString=sprintf('%s/%s/%s',obj.NIDevice,obj.DOChannel);
            %Set up the NI Daq Object
            obj.DAQ = daq.createSession('ni');
            addDigitalChannel(obj.DAQ,NIDevice,DOChannel,'OutputOnly');  % addDigitalChannel(s,deviceID,channelID,measurementType)
            obj.FilterIn;
        end
        
        function FilterIn(obj)  %puts in the filter
           % obj.NIDevice=NIDevice;
            %release(obj)
           % obj.DAQ = daq.createSession('ni');
           % addDigitalChannel(obj.DAQ,NIDevice,DOChannel,'OutputOnly');
            outputSingleScan(obj.DAQ,1)
            obj.IsOpen=0;
            % obj.Position=0;

        end
        
        function FilterOut(obj) %puts out the filter
            outputSingleScan(obj.DAQ,0)
            obj.IsOpen=1;
            % obj.Position=1;

        end
             
       
        function gui(obj)
            
            obj.GuiFigure = figure('visible', 'off', 'position', [400,400,250,250]);
            obj.GuiFigure.Visible = 'on';
            set(obj.GuiFigure,'MenuBar','none')
            set(obj.GuiFigure,'Name','FlipMountTTL')
            h=uicontrol('Style','togglebutton',...
                'Position',[90 105,80,70],...
                'Callback',@Toggle);

           % guitoproperties()
           if obj.IsOpen==0
               set(h,'String','Filter In')
               set(h,'BackgroundColor',[0 1 0])
               set(h,'ForegroundColor',[1 0 0])
               set(h,'Value',0)
           else
               set(h,'String','Filter Out')
               set(h,'BackgroundColor',[1 0 0])
               set(h,'ForegroundColor',[0 1 0])
               set(h,'Value',1)
           end    
                
            function Toggle(src,event)
                handlevalue=get(h,'Value')
                if handlevalue==1
                    set(h,'String','Filter Out')
                    set(h,'BackgroundColor',[1 0 0])
                    set(h,'ForegroundColor',[0 1 0])
                    obj.FilterOut;
                else
                    set(h,'String','Filter In')
                    set(h,'BackgroundColor',[0 1 0])
                    set(h,'ForegroundColor',[1 0 0])
                    obj.FilterIn;
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
            % Exports current state of the instrument
            Attributes.IsOpen = obj.IsOpen;
            Attributes.InstrumentName = obj.InstrumentName;
            Data=[];
            Children=[];
        end

        
    end
    
    methods(Static=true)% 
        % test this class on command line by: mic.FlipMountTTL.funcTest('Dev1','Port0/Line1')
        function State=funcTest(NIDevice,DOChannel)
            % Unit test of object functionality
            
            if nargin<2
                error('mic.FlipMountTTL:NIDevice, Port and Line must be defined')
            end
            
            fprintf('Creating Object\n')
            S=mic.FlipMountTTL(NIDevice,DOChannel);

%                   h=uicontrol('Style','togglebutton',...
%                  'String','Filter In','Position',[90 105,80,70],...
%                  'BackgroundColor',[0  1  0],'Callback',@Toggle);
%              handlevalue=get(h,'Value');
             fprintf('IsOpen == %d\n', S.IsOpen);
             pause(1)
             S.FilterOut;
             fprintf('IsOpen == %d\n', S.IsOpen);
             pause(1)
             S.FilterIn;
             fprintf('IsOpen == %d\n', S.IsOpen);
%             %Test Destructor
%             delete(S);
%             clear S;

%             %Test export state
             S.exportState;
%             %Test Destructor
%             
             delete(S);
            clear S;
        end
    end

end
