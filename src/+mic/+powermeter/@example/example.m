classdef example < mic.powermeter.abstract
    % ExamplePowerMeter Class for controlling Example Power Meter.
    % This class provides an interface to the example power meter,
    % implementing all necessary methods to operate the device and manage
    % data acquisition and GUI representation.
    
    % REQUIRES:
    % mic.powermeter.abstract.m
    
    % Documentation: For detailed documentation check Readme.md file.
    
    % CITATION: Sajjad Khan, Lidkelab, 2024.
    properties (SetAccess = protected)
        InstrumentName = 'ExamplePowerMeter';
    end
    methods
        function obj = example()
            % Constructor for ExamplePowerMeter
            obj = obj@mic.powermeter.abstract(~nargout);
            
            obj.StartGUI = true;  % Automatically start the GUI
            % Initialize property values
            obj.initializeProperties();
        end
        
        function initializeProperties(obj)
            % Method to initialize or reset properties
            obj.VisaObj = 'NIDAQ';
            obj.Power = 0.1;  % Set initial power to 0.1 mW
            obj.Ask = 'power';  % Set to measure power by default
            obj.Limits = [400, 700];  % Set wavelength limits to a dummy range
            obj.Lambda = 532;  % Set default wavelength to 532 nm
            obj.T = 10;  % Set GUI update period to 10 seconds
            obj.Stop = 0;  % Ensure plotting is off by default
        end
        
        function guiFig=gui(obj)
            % gui selects a data set from the pop-up menu, then
            % click one of the plot-type push buttons. Clicking the button
            % plots the selected data in the axes.
            
            %prevent opening more that one gui for an objext.
            if ishandle(obj.GuiFigure)
                guiFig = obj.GuiFigure;
                figure(obj.GuiFigure);
                return
            end
            %  Create and then hide the GUI as it is being constructed.
            guiFig = figure('Visible','on','Position',[250,120,1010,790]);
            % Construct the components.
            % editable text
            hedit0 = uicontrol('Style','edit','Position',[175,730,200,45],'FontSize',20,'FontWeight','bold');
            % static text
            htext0 = uicontrol('Style','text','String','Current',...
                'Position',[100,720,70,45],'FontSize',12);
            %static text
            htext00 = uicontrol('Style','text','String','mW',...
                'Position',[380,720,30,45],'FontSize',12);
            %editable text
            hedit01 = uicontrol('Style','edit','Position',[510,730,200,45],'FontSize',20,'FontWeight','bold');
            %static text
            htext01 = uicontrol('Style','text','String','Max',...
                'Position',[450,720,50,45],'FontSize',12);
            %editable text
            htext011 = uicontrol('Style','text','String','mW',...
                'Position',[715,720,30,45],'FontSize',12);
            % statics text
            Htext1String=sprintf('%d<lambda(nm)<%d',obj.Limits(1),obj.Limits(2));
            % static text
            htext1 = uicontrol('Style','text','String',Htext1String,...
                'Position',[1100,680,200,30],'FontSize',12);
            %editable text
            hedit1 = uicontrol('Style','edit','Position',[800,649,150,30],'FontSize',12);
            %static text
            htext2  = uicontrol('Style','text','String','nm',...
                'Position',[955,654,25,20],'FontSize',12);
            % push botton
            hStartplot  = uicontrol('Style','pushbutton',...
                'String','Start Plot','Position',[800,570,80,30],...
                'FontSize',12,'Callback',@startPlotbutton_Callback);
            % push button
            hStopplot  = uicontrol('Style','pushbutton',...
                'String','Stop Plot','Position',[890,570,80,30],...
                'FontSize',12,'Callback',@stopPlotbutton_Callback);
            % editable text
            hedit3 = uicontrol('Style','edit','Position',[890,530,80,30],'FontSize',12);
            % static text
            htext3  = uicontrol('Style','text','String','T(S)',...
                'Position',[815,530,50,25],'FontSize',12);
            % push button
            hget  = uicontrol('Style','pushbutton',...
                'String','Get','Position',[473,460,175,30], ...
                'FontSize',12,'Callback',{@getbutton_Callback});
            % editable
            hedit2 = uicontrol('Style','edit','Position',[800,420,140,30],'FontSize',12);
            % static text
            htext4 = uicontrol('Style','text','String','mW','Position',[940,415,40,30],'FontSize',12);
            % popup menu
            hpopup = uicontrol('Style','popupmenu',...
                'String',{'Power(mW)','Temp(C)'},...
                'Position',[815,350,140,30],...
                'FontSize',12,'Callback',@popup_menu_Callback);
            
            %axes
            ha = axes('Units','pixels','Position',[70,60,700,650]);
            xlabel('Time(S)')
            ylabel('Power(log(mW))')
            % set logarithmic scale for the vertical axis.
            set(gca,'yscale','log','ylim',[0.001 1000]);
            %components alignment except axes
            align([hget,htext1],'Center','None');
            %Make the GUI visible.
            guiFig.Visible = 'on';
            
            set([guiFig,hget,hStartplot,htext1],'Units','normalized');
            %getting the current wavelength to be displayed on gui.
            function lambda = getWavelength(obj)
                % Method to retrieve the current wavelength and perform any necessary checks or logging
                lambda = obj.Lambda;  % Assuming Lambda is the property storing the current wavelength
                % You can add any checks or logs here if needed
                fprintf('Current Wavelength: %f nm\n', lambda);
            end
            
            getWavelength(obj);
            fprintf('Current Wavelength: %f nm\n', obj.Lambda);
            %WL = sprintf('%0.5f',str2double(obj.Lambda));
            set(hedit1,'String',obj.Lambda);
            %measuring the current power.
            obj.Ask='power';
            OutPower=measure(obj);
            StrPow = sprintf('%0.5f',OutPower);
            set(hedit2,'String',StrPow);
            %default period is 10 s.
            set(hedit3,'String',10);
            set(hedit0,'String',StrPow);
            
            %popup menu
            function popup_menu_Callback(source,eventdata)
                % when user select to measure either power or temp this function
                % is called and it assign the specified string to thhe property
                % Ask. Moreover, it sets the labels for the figure.
                str = source.String;
                val = source.Value;
                % Set current data to the selected data set.
                switch str{val}
                    case 'Power(W)' % User selects Power.
                        obj.Ask = 'power';
                        ylabel('Power(\mu W)')
                        ylim([0.001 1000])
                        htext00.String='mW';
                        htext011.String='mW';
                        htext4.String='mW';
                    case 'Temp(C)' % User selects Temp.
                        obj.Ask = 'temp';
                        ylabel('Temp')
                        htext00.String = 'C';
                        htext011.String='C';
                        htext4.String='C';
                end
            end
            % specified plot type.
            function getbutton_Callback(source,eventdata)
                % Display get plot of the currently selected data.
                obj.Lambda = str2double(get(hedit1,'String'));
                
                if obj.Lambda > obj.Limits(2)
                    error('Wavelength cannot be larger than 1100 nm.')
                elseif obj.Lambda < obj.Limits(1)
                    error('Wavelength cannot be smaller than 400 nm.')
                end
                
                obj.setWavelength();
                OutPT=obj.measure();
                StrPow = sprintf('%0.5f',OutPT);
                set(hedit2,'String',StrPow);
            end
            
            function startPlotbutton_Callback(source,eventdata)
                % Called when the 'Start plot' button is pushed.
                % Display plot of the currently selected data.
                obj.Stop = 0;
                %obj.Specify = 'Wavelength';
                obj.Lambda = str2double(get(hedit1,'String'));
                
                if obj.Lambda > 1100
                    error('Wavelength cannot be larger than 1100 nm.')
                elseif obj.Lambda < 400
                    error('Wavelength cannot be smaller than 400 nm.')
                end
                %setting the wavelength to the wavelength in the prompt.
                obj.setWavelength();
                %reading the time period from gui.
                obj.T = str2double(get(hedit3,'String'));
                %plot measured temperature or power.
                obj.guiPlot(hedit0,hedit01);
            end
            
            function stopPlotbutton_Callback(source,eventdata)
                %Called when the 'Stop button' is pushed.
                obj.Stop = 1;
            end
            % Assign the GUI a name to appear in the window title.
            obj.GuiFigure = guiFig;
            obj.GuiFigure.Name = obj.InstrumentName;
            % Move the GUI to the center of the screen.
            movegui(guiFig,'center');
            % Make the GUI visible.
            guiFig.Visible = 'on';
        end
        
        function output = measure(obj)
            if ischar(obj.VisaObj) && strcmp(obj.VisaObj, 'Simulated')
                disp('Test Mode: Simulating measurement.');
                output = 0.5;  % Simulated output
            else
                try
                    fprintf(obj.VisaObj, obj.Ask);
                    output = str2double(fscanf(obj.VisaObj));
                catch
                    disp('Error reading from device. Returning simulated data.');
                    output = 0.5;  % Simulated output for development or testing
                end
            end
        end
        
        function [Attributes, Data, Children] = exportState(obj)
            % Export the current state of the power meter
            Attributes.InstrumentName = obj.InstrumentName;
            Attributes.Lambda = obj.Lambda;
            Attributes.Limits = obj.Limits;
            Data.Power = obj.Power;
            Data.T = obj.T;
            Children = [];  % Assuming no children components
        end
        
        function Shutdown(obj)
            % Cleanly shutdown the power meter connection
            if ischar(obj.VisaObj) && strcmp(obj.VisaObj, 'Simulated')
                disp('Test Mode: Simulated power meter shutdown.');
                obj.VisaObj = [];  % Clear the dummy connection object
            elseif isobject(obj.VisaObj) && isvalid(obj.VisaObj)
                fclose(obj.VisaObj);
                delete(obj.VisaObj);
                obj.VisaObj = [];
                disp('Power Meter shutdown completed.');
            else
                disp('No active connection to shutdown.');
            end
        end
        function connect(obj, testMode)
            if nargin < 2
                testMode = false;
            end
            
            if testMode
                disp('Test Mode: Simulated connection to Example power meter.');
                obj.VisaObj = 'Simulated'; % Assign a dummy string to represent a connected state
            else
                try
                    obj.VisaObj = visa('NI', 'USB0::0x1313::0x8078::P0000000::INSTR');
                    fopen(obj.VisaObj);
                    if strcmp(obj.VisaObj.Status, 'open')
                        disp('Connected to PM100D power meter.');
                    else
                        error('Failed to open connection to PM100D power meter.');
                    end
                catch ME
                    error('Failed to connect to Example power meter: %s', ME.message);
                end
            end
        end
        
    end
    
    methods (Static)
        function Success = unitTest(testMode)
            if nargin < 1
                testMode = true;  % Default to test mode
            end
            
            fprintf('Creating instance of ExamplePowerMeter...\n');
            pm = mic.powermeter.example();  % Create instance
            Success = true;
            
            try
                fprintf('Connecting to the Example power meter...\n');
                pm.connect(testMode);
                fprintf('Connection successful.\n');
                
                fprintf('Setting wavelength to 532 nm...\n');
                pm.Lambda = 532;
                if pm.Lambda ~= 532
                    error('Lambda was not set correctly.');
                end
                fprintf('Lambda set correctly.\n');
                
                fprintf('Measuring power...\n');
                pm.Ask = 'power';
                powerReading = pm.measure();
                if isempty(powerReading) || isnan(powerReading)
                    error('Power measurement failed.');
                end
                fprintf('Power measurement successful: %f mW\n', powerReading);
                
                fprintf('Shutting down the power meter...\n');
                pm.Shutdown();
                fprintf('Shutdown successful.\n');
            catch ME
                disp(ME.message);
                Success = false;
            end
            
            delete(pm);
        end
        
    end
end
