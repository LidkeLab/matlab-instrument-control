classdef MIC_APTPiezo < MIC_Abstract
    
    % Class to control the Thorlabs APT piezo stage on sequential microscope
    %
    %
    %
    % REQUIREMENTS:
    % MATLAB 2014 or higher
    % MIC_Abstract class.
    % Access to the mexfunctions for this device. (private folder).
    
    properties
        OneStepPoint=0.0405;% points to move 100 nm
        ControlMode=2;%1:open loop, 2:close loop
        VoltSrc=2;%0:software only(SW), 1:External signal, 2: potentiometer
        HubAnalogInput=3;%1:hub_analoguein_a, 2:hub_analoguein_b, 3:extsig_SMA
        DisplayMode=1;%1:position, 2:voltage, 3:force
        StepSize=0.1;
        CurrentPosition;
    end
    properties (SetAccess = protected)
        InstrumentName='APTPiezo' % Descriptive Instrument Name
    end
    properties (SetAccess = private, GetAccess = public)
         SerialNumberPZ;
         SerialNumberSG;
         MaxZPoint=10;         
         Dev=65535;
         HandlePZ;
         HandleSG;
         PiezoStatus;
         MaxTravel;
    end
    
    properties
        StartGUI    % to pop up gui by creating an object for this class
    end

    methods

        function obj=MIC_APTPiezo(SerialPZ,SerialSG)
            % constructor
            [handlepz]=APTDeviceOpen(SerialPZ);
            [handlesg]=APTDeviceOpen(SerialSG);
            obj.SerialNumberPZ=SerialPZ;
            obj.HandlePZ=handlepz;
            obj.SerialNumberSG=SerialSG;
            obj.HandleSG=handlesg;
            obj.setup;            
        end
        
        function delete(obj)
            % destructor
            APTDeviceClose(obj.HandlePZ);
            APTDeviceClose(obj.HandleSG);
        end
        
        function setup(obj)
            % Initialization
            APTPiezoSetup(obj.HandlePZ,uint8(obj.ControlMode),uint8(obj.VoltSrc),uint8(obj.HubAnalogInput));
            [maxtravel]=APTSGSetup(obj.HandleSG,uint8(obj.DisplayMode));
            obj.MaxTravel=maxtravel/10;%in micron
        end
        
        function setPosition(obj,zPos)
            % moving stage to a set position
            zPosPoint=zPos*obj.OneStepPoint*10;% convert micron to points;
            zPercent=uint16(round(zPosPoint/obj.MaxZPoint*obj.Dev));
            APTPiezoMove(obj.HandlePZ,zPercent);
            obj.CurrentPosition=zPos;
        end
        
        function setPositionAndWaitTillReached(obj,zPos)
            % moving stage to a set position and pause till reached
            zPosPoint=zPos*obj.OneStepPoint*10;% convert micron to points;
            zPercent=uint16(round(zPosPoint/obj.MaxZPoint*obj.Dev));
            APTPiezoMove(obj.HandlePZ,zPercent);
            % don't return until new position is reached
%             [~,PZpos]=APTPiezoStatusUpdate(obj.HandlePZ);
%             while abs(single(zPercent)-single(PZpos))>200
%                 [~,PZpos]=APTPiezoStatusUpdate(obj.HandlePZ);
%             end
            % update parameter
            obj.CurrentPosition=zPos;
        end
        
        function getStatus(obj)
            % get the current status
            [PZstatus,~]=APTPiezoStatusUpdate(obj.HandlePZ);
            switch dec2hex(PZstatus)
                case 'A0300000'
                    obj.PiezoStatus='open loop mode';
                    fprintf('PIEZO STATUS: open loop mode.\n');
                case 'A0300400'
                    obj.PiezoStatus='close loop mode';
                    fprintf('PIEZO STATUS: close loop mode.\n');
                otherwise
                    obj.PiezoStatus=dec2hex(PZstatus);
                    fprintf('PIEZO STATUS: %s\n',dec2hex(PZstatus));
            end
        end
        
        function setZero(obj)
            % set current position to zero
            [PZstatus,~]=APTPiezoStatusUpdate(obj.HandlePZ);
            % set open loop control
            if ~strcmp(dec2hex(PZstatus),'A0300000')
                obj.ControlMode=1;
                APTPiezoSetup(obj.HandlePZ,uint8(obj.ControlMode),uint8(obj.VoltSrc),uint8(obj.HubAnalogInput));
            end
            APTSGSetZero(obj.HandleSG);
            fprintf('Piezo is in open loop control!\n');
        end
        
        function center(obj)
            % center stage
            zPos=double(obj.MaxTravel)/2+2;
            obj.setPosition(zPos)
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes=[];
            
            % no Data is saved in this class
            Data=[];
            Children=[];
        end
    end
    methods (Static)
        function Success=unitTest(SerialPZ,SerialSG)
            if nargin<2
                error('MIC_APTPiezo::needs SerialPZ,SerialSG input')
            end
            
            try
                fprintf('Creating Object\n')
                APT=MIC_APTPiezo(SerialPZ,SerialSG) 
                fprintf('Centering the stage\n')
                APT.center();
                pause(.1)
                fprintf('Displaying current status\n')
                APT.getStatus()
                pause(.1)
                APT.exportState();
                APT.gui;
                pause(2)
                APT.delete;
                Success=1;
            catch
                Success=0;
            end
            
        end
    end
end