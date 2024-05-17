classdef MIC_DMP40 < MIC_Abstract
    % MIC_DMP40: Matlab Instrument Control Class for the Deformable Mirror

     % CITATION: Ellyse Taylor, Lidke Lab, 2021
    
    
    properties(SetAccess=protected)
        
        InstrumentName = 'DMP40';
        DAQ=[];
        IsOpen;
        DMP40   %DMP40 .NET class
    end
    
    
    properties
        
        NIDevice  %DAQ card device number at the USB port of the computer
        DOChannel; %included both port and line information
        StartGUI = 0; %uses MIC_Abstract to bring up the GUI (so, no need for a gui function in MIC_ShutterTTL)
        %         Position  %either 1 or 0 (to show open or close respectively)
        NIString  %shows the combination of Device/Port/Line the shutter is using
    end
    
    methods
        function obj = MIC_DMP40() % constructor
            
            obj = obj@MIC_Abstract(~nargout);
            
            %setup and make connection to DM
           
            %Change directly to the dlls (We will find workaround)
            cd('C:\Program Files\IVI Foundation\VISA\Win64\Bin')
            % path to .NET assemblies
            p='C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies'
            
            % Add the assemblies to matlab using full path. Full path is important
            DMX=NET.addAssembly(fullfile(p,'Thorlabs.TLDFMX_64.Interop.dll'))
            DM=NET.addAssembly(fullfile(p,'Thorlabs.TLDFM_64.Interop.dll'))
            
           
            %Check if device is present
            [Status,N]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count()
            if N<1
                warning('MIC_DMP40:: No Mirror Found')
            end
            
            % Get device info
            deviceindex=0;
            manufacturer=System.Text.StringBuilder;
            instrumentName=System.Text.StringBuilder;
            serialNumber=System.Text.StringBuilder;
            resourceName=System.Text.StringBuilder; %need this
            
            [Status,deviceAvailable]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_information(...
                deviceindex,manufacturer,instrumentName,serialNumber,resourceName)

            % Create DM Object
            obj.DMP40=Thorlabs.TLDFM_64.Interop.TLDFM(resourceName.ToString,true,true)

        end
        
        function delete(obj)
            obj.DMP40.Dispose %close com to mirror
            delete(obj.GuiFigure);
        end
        
        function setMirrorVoltages(VoltageArray)
            
            
        end
        
        function setTiltVoltages(VoltageArray)
            
            
        end
        
        function setZernikeModes(ZernikeArray)
            
            
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
            Children = [];
        end
        
        
    end
    
    
    
    methods(Static=true)% Static: means it can be used stand alone, without the need to make an object
        % test this class on command line by: MIC_ShutterTTL.unitTest('Dev1','Port0','Line1')
        function State=unitTest(NIDevice,DOChannel)
            % Unit test of object functionality
            
            if nargin<2
                error('MIC_ShutterTTL:NIDevice, Port and Line must be defined')
            end
            
            % release(MIC_ShutterTTL('Dev1','Port0','Line1'))
            %Create an Object and Test open, close
            fprintf('Creating Object\n')
            % release()
            S=MIC_ShutterTTL(NIDevice,DOChannel);
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
            S=MIC_ShutterTTL(NIDevice,DOChannel);
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

