classdef DMP40 < mic.abstract
% mic.DMP40 Class Documentation
% 
% ## Description
% The `mic.DMP40` class controls a deformable mirror using MATLAB. This class interfaces with the mirror through .NET assemblies, 
% specifically designed for the Thorlabs DMP40 deformable mirror. It utilizes a digital-to-analog converter (DAC) 
% to set voltages for mirror deformation and can apply different voltages to control tilt, Zernike modes, and other mirror settings.
% 
% ## Requirements
% - MATLAB R2016b or later
% - mic.abstract.m
% - .NET assemblies installed for Thorlabs DMP40 (.dll files for mirror control)
% - .NET environment setup for MATLAB
% 
% ## Installation and Setup
% 1. Install MATLAB R2016b or later.
% 2. Ensure that the required .NET assemblies (`Thorlabs.TLDFMX_64.Interop.dll` and `Thorlabs.TLDFM_64.Interop.dll`) are installed on your system.
% 3. Ensure that the path to the .NET assemblies is correctly set in your MATLAB environment. For example, use `NET.addAssembly` to load the assemblies:
% ```matlab
%    p = 'C:\\Program Files (x86)\\Microsoft.NET\\Primary Interop Assemblies';
%    NET.addAssembly(fullfile(p,'Thorlabs.TLDFMX_64.Interop.dll'));
%    NET.addAssembly(fullfile(p,'Thorlabs.TLDFM_64.Interop.dll'));
% ```
% ## Key Functions
% - **Constructor (`DMP40()`):** Sets up the initial connection to the deformable mirror using specified .NET libraries and verifies device availability.
% - **`setMirrorVoltages(VoltageArray)`:** Applies specific voltages to control the overall shape and curvature of the deformable mirror.
% - **`setTiltVoltages(VoltageArray)`:** Adjusts the tilt of the mirror using voltages for precise alignment or calibration tasks.
% - **`setZernikeModes(ZernikeArray)`:** Utilizes Zernike polynomial coefficients to manipulate the mirror surface for advanced optical wavefront shaping.
% - **`delete()`:** Cleans up the connection to the mirror and releases all system resources.
% - **`gui()`:** Opens a graphical user interface to facilitate interactive adjustments and monitoring of the mirror settings.
% - **`exportState()`:** Captures and returns the current operational state of the deformable mirror, including any settings or adjustments made during operation.
%
% ## Usage Example
% ```matlab
% % Initialize the deformable mirror
% mirror = mic.DMP40();
% 
% % Set mirror voltages for a specific application
% mirror.setMirrorVoltages([1.0, 0.5, 0.3, ...]);
% 
% % Modify the tilt of the mirror using voltages
% mirror.setTiltVoltages([0.1, 0.1]);
% 
% % Apply Zernike modes for advanced mirror shaping
% mirror.setZernikeModes([0.2, 0.4, 0.1, ...]);
% 
% % Clean up and delete the object when done
% delete(mirror);
% ```
% ### CITATION: Ellyse Taylor, Lidke Lab, 2024.

    properties(SetAccess=protected)
        
        InstrumentName = 'DMP40';
        DAQ=[];
        IsOpen;
A PROBLEM!!! property or event may not use the same name as the name of the class (DMP40).
        DMP40   %DMP40 .NET class
    end
    
    
    properties
        
        NIDevice  %DAQ card device number at the USB port of the computer
        DOChannel; %included both port and line information
        StartGUI = 0; %uses mic.abstract to bring up the GUI (so, no need for a gui function in ShutterTTL)
        %         Position  %either 1 or 0 (to show open or close respectively)
        NIString  %shows the combination of Device/Port/Line the shutter is using
    end
    
    methods
        function obj = DMP40() % constructor
            
            obj = obj@mic.abstract(~nargout);
            
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
                warning('mic.DMP40:: No Mirror Found')
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

