classdef MIC_GalvoDigital < MIC_Abstract
    % MIC_GalvoDigital: Matlab instrument class to control Galvo Mirror using digital input
    % ## Description
    %  This class controls the galvo mirror (Cambridge Technology)on the  
    %  HSM microscope.It changes the angle of galvo mirror to scan the  
    %  sample. Input voltage [-10,10] to change the angle in [-15,15], 
    %  is sent by 16 channels on NI card. There are 4 more
    %  channels to make the galvo enable to move.
    % ## Constructor
    %  Example: obj=MIC_GalvoDigital('Dev1','Port0/Line0:31');
    %  ## Key Funtions: delete, clearSession, enable, disable, reset, setSequence, angle2word, word2angle, get.Angle, setAngle, exportState, set.Voltage, get.Voltage,G. updateGui
    %
    %  ## REQUIREMENTS:
    %  MIC_Abstract.m
    %  MATLAB software version R2016b or later
    %  Data Acquisition Toolbox
    %  MATLAB NI-DAQmx driver installed via the Support Package Installer
    %
    % CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.
    
    properties(SetAccess=protected)
        InstrumentName='GalvoDigital' % Descriptive Instrument Name
        DAQsessionAngle        % NI card session to change the angle
        DAQsessionEnable       % NI card session to make the galvo to move the angle
    end
    
    properties
        Word;       % an integer number to send to 16 channels [0,65535]
        Range=15;   % Range of travel in degrees from center
        Sequence;   % The Sequence if 16bit Words for an entire HSM scan
        NIDevice;   % NI card identity
        Angle;      % angle of galvo mirror [-15,15]
        ClockConnection;    % Scan Clock connection variable
        idxClockConnection; %index of Scan Clock connection
        IsEnable=0; % if the galvo is able to move or not(This is set by four channels)
        Voltage; % current Voltage
    end
    properties
        StartGUI    % to pop up gui by creating an object for this class
    end
    
    % Scanning Parameters
    properties
        N_Step;     % Number of Steps per scan
        N_Scan;     % Number of Scans
        StepSize;   % Step size for each scan
        Offset;     % Starting position 
    end
    
    properties (Constant = true)
        % to remember which channels for what
        RWpin = 'line24';
        CSpin = 'line25';
        LDACpin = 'line26';
        CLRpin = 'line27';
        Wordpin = 'line0:15';
    end
    
    methods
        function obj=MIC_GalvoDigital(NIDevice,DOChannel)
            % Object constructor
            obj=obj@MIC_Abstract(~nargout);
            if nargin<2
                error('NIDevice and DOChannel must be defined')
            end
            % Set up the NI Daq Object
            obj.DAQsessionAngle = daq.createSession('ni');
            obj.DAQsessionEnable= daq.createSession('ni');
                       
            % 16 channels to change the angles
            obj.DAQsessionAngle.addDigitalChannel(NIDevice,'Port0/Line0:15','OutputOnly');
            % 4 channels to make the galvo mirror be enabled to move
            obj.DAQsessionEnable.addDigitalChannel(NIDevice,'Port0/Line24:27','OutputOnly');
            
            obj.NIDevice=NIDevice;
            obj.Word = 2^16/2;

            % Turn off all channels 
            outputSingleScan(obj.DAQsessionEnable,[0 0 0 0]);
            outputSingleScan(obj.DAQsessionAngle,zeros(1,16));
        end
        
        function delete(obj)
            % Object deconstructor
            obj.clearSession;
            clear obj.DAQsessionAngle obj.DAQsessionEnable obj.ClockConnection
        end
        
        function clearSession(obj)
            % Clear all channels to stop running obj.DAQsessionAngle 
            % otherwise you can't send another signal to these channels
            stop(obj.DAQsessionAngle)
            
            % to remove previous clock connections
            if ~isempty(obj.ClockConnection)
                obj.DAQsessionAngle.removeConnection(obj.idxClockConnection);
                obj.ClockConnection=[];
            end
            
            % set zeros to all channels to turn off LED lamps on the chip
            outputSingleScan(obj.DAQsessionAngle,ones(1,16));
            outputSingleScan(obj.DAQsessionEnable,[1 1 1 1]);
            obj.Sequence=[];
        end
        
        function reset(obj)
            % Completely reset the DAQ device.  Use only in emergencies!
            daqreset(obj.DAQsession);
            daqreset(obj.DAQsessionEnable);
        end
        
        function enable(obj)
        % set CLRpin = 1 to be able to move the Galvo
            outputSingleScan(obj.DAQsessionEnable,[0 0 0 1]);
            obj.IsEnable=1;
        end
        
        function disable(obj)
        % set CLRpin = 0 to be able not to move the Galvo
            outputSingleScan(obj.DAQsessionEnable,[0 0 0 0]);
            obj.IsEnable=0;
        end
        
        function setSequence(obj)
            % Create and send 16 words in a sequence for the 16 channels to
            % move the galvo mirror
            % Usage: setSequence(StepSize, NumberOfStepsPerScan, NumberOfScans, Offset)
            % StepSize - the size of each step in degrees
            % NumberOfStepsPerScan - number of steps that occurs in each scan
            % NumberOfScans - number of scans across the sample for the acquisition
            % Offset - offset to first position in degrees
            
            % Check to have all required input
            if isempty(obj.N_Step) || isempty(obj.StepSize) ||isempty(obj.N_Scan) ||isempty(obj.Offset)
             % make a default values for scanning parameters 
                obj.StepSize=0
                obj.N_Step=0;
                obj.N_Scan=0;
                obj.Offset=0; 
            end
            
            StepSize=obj.StepSize;
            NumberOfStepsPerScan=obj.N_Step;
            NumberOfScans=obj.N_Scan;
            Offset=obj.Offset;
            
            
            AngleSteps = (Offset:StepSize:Offset+StepSize*(NumberOfStepsPerScan-1)) + obj.Range;
            TTLWordRounded = floor((2^16-1)* AngleSteps/(2*obj.Range));
            
            % Calculations:
            %             StepSizeVolts = StepSize*(2/3);                                            % Volts (the 2/3 comes from the scanning mirror behavior where -10 to +10 volts gives 30 degrees of movement.
            %             %StepSizeVolts = 1;
            %             StartingPositionVolts = Offset*2/3;                              % Volts. Allowed values are from -10 to +10 volts.
            %             EndingPositionVolts = StartingPositionVolts + StepSizeVolts*NumberOfStepsPerScan;
            %             VoltsDesiredEachScan = StartingPositionVolts:StepSizeVolts:EndingPositionVolts;
            %
            %             % Convert the VoltsDesired into a 16-bit binaries where 0000000000000000 = -10 V and 1111111111111111 = +10 V:
            %             TTLWord = (2^16 - 1)*(10 + VoltsDesiredEachScan)/20;                       % This step finds which of the 65,536 binary values should go to each voltage and provides the decimal number for it starting at 0 and going to 65,535.
            %             TTLWordRounded = round(TTLWord);                                           % Need to round each number to pick out one of the 65,536 values to then convert that into binary, so we need an integer here.
            TTLWordRoundedSize = size(TTLWordRounded,2);                               % This should be the NumberOfSteps + 1 (we need a number for each actual position including the start and end).
            TTLWordBinary = zeros(TTLWordRoundedSize,16);                              % Pre-allocate one single scan's worth of 16-bit binary arrays.
            for ii = 1:TTLWordRoundedSize                                              % Each iteration of this loop finds a binary array for the given integer number and populates the step positions for one scan.
                %binVec = dec2bin(data, nBits)-'0' to create a double
                %instead of char {output of dex2bin is char}
                TTLWordBinary(ii,:) = dec2bin(TTLWordRounded(ii), 16) - '0';           % Convert each TTLWord integer into a binary array. Each row represents a converted integer. The -'0' takes each character in a string and converts it into a double.
            end
            obj.Offset = Offset;
            
            % clear all channels before creating a new sequence of words
            obj.clearSession();
            
            %TTLWordBinary based on number of scan (only repeated in row)
            obj.Sequence = repmat(TTLWordBinary,[NumberOfScans 1]);
            
            %DOArray
            % I have to have array with 32 elements to connect to obj.DAQ
            % 16 elements come from Sequence and Angle and 16 elements
            % control the NIDAQ card. create zero matrix for the 2nd
            % 16-elements.
           
            %start sending a Sequence to 16 channels to move Galvo Mirror
            %             if obj.DAQsessionAngle.ScansQueued~=0
            %             end
            % %                %Adding an external clock to your session may not trigger a scan unless you
            % % %set the session's rate to match the expected external clock frequency.
            % % obj.DAQsessionAngle=Frequency_External   % Frequency of ExternalDevice
            
            % Create 16bit Words
            queueOutputData(obj.DAQsessionAngle,obj.Sequence);
            % define a clock connection to start moving Galvo Mirror
            [C idxC]=addClockConnection(obj.DAQsessionAngle,'External','Dev1\PFI0','ScanClock');
            obj.ClockConnection=C;
            obj.idxClockConnection=idxC;
            % send the list of 16bit Words to the backgorund of MATLAB
            startBackground(obj.DAQsessionAngle);
            % update gui from 
            obj.updateGui();
        end
        
        function Word = angle2word(obj,Angle)
            % Define a Word for TTL channel to specific Angle
            if nargin<2
                error('enter a valid value for Angle as an input')
            end
            if Angle < -obj.Range || Angle > obj.Range
                msg=sprintf('Angle must be in thid Range: [%g, %g] ',-obj.Range,obj.Range);
                error(msg);
            end
            
            
            TTLWord = (2^16 - 1)*(Angle+15)/(2*obj.Range);    % This step finds which of the 65,536 binary values should go to each voltage and provides the decimal number for it starting at 0 and going to 65,535.
            
            Word = round(TTLWord);        % Need to round each number to pick out one of the 65,536 values to then convert that into binary, so we need an integer here.
            obj.Angle=Angle;
            obj.Word=Word;
            obj.updateGui();
            
        end
        
        function Angle = word2angle(obj,value)
            % Create the 16bit Words based on angle
            if size(value,1) ~= 1
                error('Galvo:WordOutOfRange', 'Word must be integer between 0 and 65535 or a 1x16 array');
            end
            if size(value,2) == 16
                tmp = 0;
                for ii = 1:size(value,2)
                    tmp = tmp + logical(value(ii))*2^(size(value,2)-ii);
                end
                value = tmp;
            end
            if value < 0 || value > 65535
                error('Galvo:WordOutOfRange','Word must be between 0 and 65535');
            end
            Angle = value/65535*(2*obj.Range)  - 15;
        end
        
        function value = get.Angle(obj)
            % show the angle of Galvo Mirror based on an input 16bit Word
            value = obj.word2angle(obj.Word);
        end
       
        function obj = setAngle(obj) %#ok<MCHV2>
            % set the angle by sending a 16bit Words to NI card
            if isempty(obj.Word)
                error('The Angle is not specified')
            end
            
            %obj.clearSession;
            flip(dec2bin(obj.Word, 16) - '0')
            obj.Sequence=flip(dec2bin(obj.Word, 16) - '0');
            obj.enable;
            outputSingleScan(obj.DAQsessionAngle,obj.Sequence);
            obj.updateGui();
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes=[];
            Data=[];
            Children=[];
        end
        
        function obj = set.Voltage(obj,value)
            % Sets voltage to value
           if value < -10 || value > 10
               error('Galvo:VoltageOutOfRange', 'Voltage must be between -10 and 10 volts.');
           end
           obj.Word = floor((value + 10)/20*65535);
        end
        
        function value = get.Voltage(obj)
            % Gets current voltage
           value = (obj.Word/65535*20)-10; 
        end
        
        function updateGui(obj)
            % update gui with current parameters
            % check whether gui is open
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            % find edit box and togglebutton for update gui from obj
            % (when it is changed in Command Windoew)
            for ii = 1 : numel(obj.GuiFigure.Children)
                if strcmp(obj.GuiFigure.Children(ii).Tag,'EditAngle')
                    obj.GuiFigure.Children(ii).String = num2str(obj.Angle);
                    % to update info from gui to obj for Scanning Parameters
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'EditNSteps')
                    obj.GuiFigure.Children(ii).String = num2str(obj.N_Step);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'EditNScans')
                    obj.GuiFigure.Children(ii).String = num2str(obj.N_Scan);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'EditStepsize')
                    obj.GuiFigure.Children(ii).String = num2str(obj.StepSize);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'EditOffset')
                    obj.GuiFigure.Children(ii).String = num2str(obj.Offset);
                elseif strcmp(obj.GuiFigure.Children(ii).Tag,'positionToggle')
                    obj.GuiFigure.Children(ii).Value = obj.IsEnable;
                    if obj.IsEnable
                        obj.GuiFigure.Children(ii).String = 'Enable';
                        obj.GuiFigure.Children(ii).BackgroundColor = 'green';
                    else
                        obj.GuiFigure.Children(ii).String = 'Disable';
                        obj.GuiFigure.Children(ii).BackgroundColor = [0.8  0.8  0.8];
                    end
                end
            end
        end
    end
    
    methods (Static=true)
        function unitTest(obj)
            % Testing the functionality of the class/instrument
            fprintf('Creating Object\n')
            G=MIC_GalvoDigital('Dev1','Port0/Line0:31');
            fprintf('Exporting current sate\n')
            Expt=G.exportState;
            disp(Expt);
            fprintf('Deleting Object\n')
            G.delete;
        end
    end
    methods(Static)
        
        function versn()
            global VERSION %#ok<NUSED>
            r = '$Rev: 312 $';
            d = '$Date: 2011-10-21 22:12:32 -0600 (Fri, 21 Oct 2011) $';
            a = '$Author: jbyars $';
            h = '$HeadURL: https://rayleigh.phys.unm.edu/svn/MATLAB/Instrumentation/Galvo.m $';
            eval(['VERSION.' mfilename('class') '.Rev=''' r(7:end-2) ''';']);
            eval(['VERSION.' mfilename('class') '.Date=''' d(8:end-2) ''';']);
            eval(['VERSION.' mfilename('class') '.Author=''' a(10:end-2) ''';']);
            eval(['VERSION.' mfilename('class') '.HeadURL=''' h(11:end-2) ''';']);
        end
    end
end

