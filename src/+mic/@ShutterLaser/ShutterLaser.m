classdef ShutterLaser < mic.abstract 
    % mic.shutterTTL: Matlab Instrument Control Class for the shutter
    %
    % This class controls on/off of a laser object
    %
    % ## Properties
    %
    % ### Protected Properties
    %
    % #### `InstrumentName`
    % - **Description:** Name of the instrument.
    %   - **Default Value:** `'ShutterLaser'`
    %
    % #### `Laserobj`
    % - **Description:** Object representing the laser associated with the shutter control.
    %
    % #### `IsOpen`
    % - **Description:** Indicates the current state of the shutter (open or closed).
    %
    % ### Public Properties
    %
    % #### `StartGUI`
    % - **Description:** Determines whether to use `mic.abstract` to bring up the GUI.
    %   - **Default Value:** `0`
    %
    % ## Methods
    %
    % ### Public Methods
    %
    % #### `ShutterLaser(laserobj)`
    % - **Description:** Constructor for `ShutterLaser`.
    % - **Usage:** `obj = ShutterLaser(laserobj)`
    %
    % #### `delete(obj)`
    % - **Description:** Deletes the GUI figure when the object is deleted.
    %
    % #### `close(obj)`
    % - **Description:** Closes the shutter by turning off the laser.
    %
    % #### `open(obj)`
    % - **Description:** Opens the shutter by turning on the laser.
    %
    % #### `gui(obj)`
    % - **Description:** Creates a GUI to control the shutter with a toggle button to open or close the shutter.
    %
    % #### `exportState(obj)`
    % - **Description:** Exports the current state of the object.
    % - **Returns:** `Attributes`, `Data`, `Children`.
    %
    % ### Static Methods
    %
    % #### `funcTest(laserobj)`
    % - **Description:** Tests the functionality of the `ShutterLaser` class, including opening, closing, and exporting state.
    % - **Usage:** `State = funcTest(laserobj)`
    %
    % Example: obj=mic.ShutterLaser(laserobj);
    % Functions: close, open, delete, exportState
    %
    % REQUIRES:
    %   mic.abstract.m
    %
    % CITATION: Sheng, Lidkelab, 2024.
    
    properties(SetAccess=protected)
        
        InstrumentName = 'ShutterLaser';
        Laserobj;
        IsOpen;
    end
    
    
    properties
     

        StartGUI = 0; %uses mic.abstract to bring up the GUI (so, no need for a gui function in mic.ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
    end
    
    methods
        function obj = ShutterLaser(laserobj) % constructor
           % daqreset; %reset any former session that might prevent the DAQ card to be available
            % when you are making an object for this class, you should do it this way: obj= ShutterTTL('Dev1','Port0','Line1')
            % of course you need to put the numbers after Dev,Port and Line
            % based on the physical connections of the shutter to your NI-DAQ card
            obj = obj@mic.abstract(~nargout);

            
            obj.Laserobj=laserobj;
            obj.close;
        end
        
        function delete(obj)
            delete(obj.GuiFigure);
        end
        
        function close(obj)  %closes the shutter
            obj.Laserobj.off();
            obj.IsOpen=0;

        end
        
        function open(obj) %opens the shutter
            obj.Laserobj.on();
            obj.IsOpen=1;

        end
        
        %gui
        function gui(obj)
            
            obj.GuiFigure = figure('visible', 'off', 'position', [400,400,250,250]);
            obj.GuiFigure.Visible = 'on';
            set(obj.GuiFigure,'MenuBar','none')
            set(obj.GuiFigure,'NumberTitle','off')
            set(obj.GuiFigure,'Name','ShutterLaser')
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
        % test this class on command line by: mic.ShutterTTL.funcTest('Dev1','Port0','Line1')
        function State=funcTest(laserobj)
            % Unit test of object functionality
            

            
           % release(mic.ShutterTTL('Dev1','Port0','Line1'))
            %Create an Object and Test open, close
            fprintf('Creating Object\n')
            % release()
            S=mic.ShutterLaser(laserobj);
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
            S=mic.ShutterLaser(laserobj);
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

