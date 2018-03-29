classdef MIC_ShutterELL6 < MIC_Abstract % by Gert-Jan based on ShutterTLL (by Farzin)
    
    % MIC_ShutterELL6 Matlab Instrument Control Class for the 2-position
    % slider ELL6, which can be used as a shutter (or filter slider).    
    % This class controls an Elliptec ELL6 shutter, which is USB
    % connected via a rs232-to-USB2.0 board.  The shutter and the board are 
    % delivered as a package, see the Thorlabs catalog, # ELL6K.
    % Make the object by: obj=MIC_ShutterELL6('COM#',Shutter#)where:
    % COM# = the number string of the RS232 com port reserved for the shutter;
    % Shutter# = the address string of the shutter motor, default '0', it
    % can be between 0 and F.
    
    %   REQUIRES:
    %   MIC_Abstract.m
    %   Data Acquisition Toolbox on MATLAB
    %   use MATLAB 2014b and higher 
    
    
    properties(SetAccess=protected)
        
        InstrumentName = 'ShutterELL6';        
        IsOpen;
    end
    
    
    properties
        Comport;
        ShutterAddress;
        RS232=[];
        openstr;
        closestr;
        StartGUI = 0; %uses MIC_Abstract to bring up the GUI (so, no need for a gui function in MIC_ShutterTTL)
%         Position  %either 1 or 0 (to show open or close respectively)
    end
    
    methods
        function obj = MIC_ShutterELL6(Comport,ShutterAddress) % constructor
            obj = obj@MIC_Abstract(~nargout);
            if nargin<2
                error('MIC_ShutterELL6:COMPORT# and Shutter# must be defined')
            end
            
            
            obj.Comport=Comport;
            obj.ShutterAddress=ShutterAddress;
           % obj.close; %closes the shutter as it first starts working

            %Set up the RS232 object
            obj.RS232=serial(['COM',Comport]);
            set(obj.RS232,'BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','none'); 
            fopen(obj.RS232);
            %obj.close;
       
        end
        
        function delete(obj)
            delete(obj.GuiFigure);
            fclose(obj.RS232); % added
            delete(obj.RS232); %added
        end
        
        function close(obj)  %closes the shutter
            obj.closestr=[obj.ShutterAddress,'bw'];
            fprintf(obj.RS232,obj.closestr) % bring the shutter to the closed (backward or home) position
            obj.IsOpen=0;
            % obj.Position=0;

        end
        
        function open(obj) %opens the shutter
            obj.openstr=[obj.ShutterAddress,'fw'];
            fprintf(obj.RS232,obj.openstr) % bring the shutter to the open (forward) position
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
        
        function State=exportState(obj)
            
            State.IsOpen = obj.IsOpen;
            State.InstrumentName = obj.InstrumentName;
        end
        
        
    end
    
    
    
    methods(Static=true)% Static: means it can be used stand alone, without the need to make an object
        % test this class on command line by: MIC_ShutterELL6.unitTest('Comport','ShutterAddress')
        function State=unitTest(Comport,ShutterAddress)
            % Unit test of object functionality
            
            if nargin<2
                error('MIC_ShutterELL6: COMPORT# and Shutter# must be defined')
            end
            
           % release(MIC_ShutterELL6('Comport', 'ShutterAddress'))
            %Create an Object and Test open, close
            fprintf('Creating Object\n')
            % release()
            S=MIC_ShutterELL6(Comport,ShutterAddress);
            S.open;
            fprintf('Shutter Open\n')
            pause(.5);
            S.close;
            fprintf('Shutter Closed\n')
            %Test Destructor
            delete(S);
            clear S;
            %Create an Object and Repeat Test
            fprintf('Creating Object\n')
            S=MIC_ShutterELL6(Comport,ShutterAddress);
            S.open;
            fprintf('Shutter Open\n')
            pause(.5);
            S.close;
            fprintf('Shutter Closed\n')
            %Test export state
            S.exportState;
            %Test Destructor
            delete(S);
            clear S;
            
        end
        
    end
    
end

