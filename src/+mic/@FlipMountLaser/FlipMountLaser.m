classdef FlipMountLaser < mic.abstract %by FF
    % mic.FlipMountTTL: Matlab Instrument Control Class for the flipmount
    %
    % This class controls a Thorlabs LMR1/M flipmount via a Thorlabs MFF101/M
    % controller.  Controller is triggered in via a TTL signal passing from the
    % computer to the controller through a NI-DAQ card. TTL signal lets the
    % flipmount to be set in up or down positions, so flipmount is regulated by
    % the Digital voltage output of the NI-DAQ card.
    %
    % ## Class Properties
    %
    % ### Protected Properties
    %
    % - **`InstrumentName`**
    %   - **Description**: Descriptive name for the instrument.
    %   - **Type**: String
    %   - **Default**: `'FlipMountLaser'`
    %
    % - **`Laserobj`**
    %   - **Description**: Object representing the laser that is integrated with the flip mount system.
    %   - **Type**: Laser Object (type unspecified)
    %
    % - **`LaserPower`**
    %   - **Description**: Power of the laser controlled through the flip mount system.
    %   - **Type**: Numeric (Power level)
    %
    % - **`IsOpen`**
    %   - **Description**: Indicates whether the flip mount is currently open. The default value indicates that the mount starts open.
    %   - **Type**: Boolean
    %   - **Default**: `1` (open)
    %
    % ### Public Properties
    %
    % - **`Low`**
    %   - **Description**: Represents the lower threshold or minimum operational setting (e.g., for laser power).
    %   - **Type**: Numeric
    %   - **Default**: `0.1`
    %
    % - **`StartGUI`**
    %   - **Description**: Determines if the graphical user interface (GUI) will be launched upon object creation using the `mic.Abstract` interface.
    %   - **Type**: Boolean
    %   - **Default**: `0` (disabled)
    %
    % Make the object by: obj = mic.FlipMountTTL('Dev#', 'Port#/Line#') where:
    % Dev#  = Device number assigned to DAQ card by computer USB port of the
    % Port# = Port number in use on the DAQ card by your flipmount connection
    % Line# = Line number in use on the DAQ card by the Port
    %
    % Example: obj = mic.FlipMountTTL('Dev1', 'Port0/Line1');
    % Functions: FilterIn, FilterOut, gui, exportState
    %
    % REQUIREMENTS:
    %   mic.abstract.m
    %   Data Acquisition Toolbox on MATLAB
    %   MATLAB NI-DAQmx driver in MATLAB installed via the Support Package
    %      Installer
    %   type "SupportPackageInstaller" on command line to install the support
    %      package for NI-DAQmx
    %
    % CITATION: Farzin Farzam, Lidkelab, 2017.
    
    properties (SetAccess=protected)
        InstrumentName = 'FlipMountLaser';
        Laserobj;
        LaserPower;
        IsOpen=1;
    end    
    
    properties
        Low = 0.1; % 
        StartGUI = 0; %uses mic.Abstract to bring up the GUI (so, no need for a gui function in ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
    end
    
    methods
        function obj = FlipMountLaser(laserobj) % constructor
            % when you are making an object for this class, 
            % you should do it this way: obj= mic.FlipMountTTL('Dev1','Port0/Line1')
            % of course you need to put the numbers after Dev,Port and Line
            % based on the physical connections of the shutter to your NI-DAQ card
            obj = obj@mic.abstract(~nargout);

            
            obj.Laserobj = laserobj;
            obj.LaserPower = laserobj.Power;
            obj.FilterIn;
        end
        
        function FilterIn(obj)  %puts in the filter
           % obj.NIDevice=NIDevice;
            %release(obj)
           % obj.DAQ = daq.createSession('ni');
           % addDigitalChannel(obj.DAQ,NIDevice,DOChannel,'OutputOnly');
           if obj.IsOpen == 1
            obj.LaserPower = obj.Laserobj.Power;
           end
            obj.Laserobj.setPower(obj.LaserPower*obj.Low)
            obj.IsOpen=0;

        end
        
        function FilterOut(obj) %puts out the filter
            obj.Laserobj.setPower(obj.LaserPower)
            obj.IsOpen=1;

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
        % test this class on command line by: mic_FlipMountTTL.funcTest('Dev1','Port0/Line1')
        function State=funcTest(laserobj)
            % Unit test of object functionality
            

            
            fprintf('Creating Object\n')
            S=mic.FlipMountLaser(laserobj);

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
