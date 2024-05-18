classdef MIC_ShutterLaser < MIC_Abstract 
    % MIC_ShutterTTL: Matlab Instrument Control Class for the shutter
    %
    % This class controls on/off of a laser object
    %
    % Example: obj=MIC_ShutterLaser(laserobj);
    % Functions: close, open, delete, exportState 
    %
    % REQUIRES:
    %   MIC_Abstract.m
    %
    % CITATION: Sheng, Lidkelab, 2024.
    
    
    properties(SetAccess=protected)
        
        InstrumentName = 'ShutterLaser';
        Laserobj;
        IsOpen;
    end
    
    
    properties
     

        StartGUI = 0; %uses MIC_Abstract to bring up the GUI (so, no need for a gui function in MIC_ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
    end
    
    methods
        function obj = MIC_ShutterLaser(laserobj) % constructor
           % daqreset; %reset any former session that might prevent the DAQ card to be available
            % when you are making an object for this class, you should do it this way: obj= ShutterTTL('Dev1','Port0','Line1')
            % of course you need to put the numbers after Dev,Port and Line
            % based on the physical connections of the shutter to your NI-DAQ card
            obj = obj@MIC_Abstract(~nargout);

            
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
        % test this class on command line by: MIC_ShutterTTL.unitTest('Dev1','Port0','Line1')
        function State=unitTest(laserobj)
            % Unit test of object functionality
            

            
           % release(MIC_ShutterTTL('Dev1','Port0','Line1'))
            %Create an Object and Test open, close
            fprintf('Creating Object\n')
            % release()
            S=MIC_ShutterLaser(laserobj);
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
            S=MIC_ShutterLaser(laserobj);
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

