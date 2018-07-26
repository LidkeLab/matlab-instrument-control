classdef MIC_SyringePump < MIC_Abstract
    % MIC_SyringePump creates MATLAB Instrument class to control Syringe
    % Pump by kdScientific
    %   
   % REQUIRES:
%   Statistics Toolbox
%   USB cable
%
% CITATION:
% Hanieh Mazloom-Farsibaf   Apr 2017 (Keith A. Lidke's lab)
 
    
    %%% Next: add errorcheck, reload and backward/forward
    properties (SetAccess=protected)
        InstrumentName='SyringPump'; % Descriptive Instrument Name
        PumpAddress;
        SerialNumber;
    end
    properties
        StartGUI,                  % =0 OR 1 to pop up gui by defining the class  
    end
    
    properties
        S           % Serial object
        Force;
        Target;
        Mode='Infuse Only'
        Rate;
        Syringe;
        MaxRate=2.7; % micliter per min or 9.20ml/min
        MinRate=0.00886; %micliter/min
        SyringeVolume;
        SyringeList; % all possible types of Syringe
        TypeSyringe='bdp'
        N_typeSyringe=17;
        T_start_syringe=[];
    end
    
    methods
        function obj=MIC_SyringePump()
            %delete all previos ports
            delete(instrfindall)
            
%             %find the name of port
%             [~,res]=system('mode')
%             port_name=res(20:23);
            
            % set a serial variable to connect to deice
            obj.S=serial('COM3','BaudRate', 9600,'Terminator','CR/LF');
            fopen(obj.S);
            
            % define the serial number
            fprintf(obj.S,'version')
            fscanf(obj.S)
            
            % set the addess, it is useful when there are more than one Syringe pump
            % fprintf(obj.S,'addr 00')
            [a b]=fscanf(obj.S)
            obj.PumpAddress=a(16:b)
            [c d]=fscanf(obj.S)
            obj.SerialNumber=c(16:d)
            
            
        end
        
        function delete(obj)
            fclose(obj.S);
            delete(obj.S);
            % how to disconnect the device
        end
        function State=exportState(obj)     %Export All Non-Transient Properties in a Structure
            State.Force=obj.Force;
            State.Target=obj.Target;
            State.Syringe=obj.Syringe;
            State.Target=obj.Target;
        end
        function setForce(obj,fvalue)
            % set the level of force in percent
            % fvalue: valid range is 1 to 100
            if nargin<1
                error('choose an integr to set force')
            end
            if (fvalue <= 1 || fvalue >= 100)
                error('enter a positive integer between 1 to 100')
            end
%             obj.Force=fprintf(obj.S,'force fvalue')
            fprintf(obj.S,'force fvalue')
        end
        
        function setTarget(obj,tvalue)
            fprintf(S,'ctvolume')
            
            if nargin<1
                error('enter a number to set target volume')
            end
            obj.setSyringe
%             if
%                 obj.Force=fprintf(obj.S,'target tvalue')
%             end
%          
        end
            function getTypeSyringe(obj)
%                fprintf(S,'svolume')
%? I may need to clear syringe first
                    fprintf(obj.S,'syrm ?')
              
for ii=1:obj.N_typeSyringe
                    obj.SyringeList(ii)= fscanf(obj.S)
                end
            end
            
            
            function setSyringe(obj)
                % if nargin<1
                %             error('enter from SyringeList to set type volume')
                % end
                
                fprintf(obj.S,'syrm')
                obj.SyringeList= fscanf(obj.S)
                % show all possible volume for a kind of Syringe.
                obj.TypeSyringe;
                % use it as a pop up menu
                fprintf(obj.S,'syrm obj.typesyringe code ?')
                
            end
            function out=getForce(obj)
                fprintf(obj.S, 'force')
                out=fscanf(obj.S)
                obj.Force=out;
            end
            
            function run(obj)
                fprintf(obj.S,'irun')
            end
            
            function stop(obj)
                fprintf(obj.S,'Stop')
                
            end
            
            function out=getTarget(obj)
                fprintf(obj.S,'target')
                out=fscanf(obj.S)
            end
            
            function setRate(obj,rvalue)
                %set the rate, valid range is 2.6553 nl/min to 2.75747 ml/min
                if rvalue
                    fprintf(obj.S,'irate rvalue')
                    
                    % read the rate
                    fprintf(obj.S,'irate')
                    [a b]=fscanf(obj.S)
                    
                    
                    
                end
            end
                
               
                
%                 function errorcheck(obj,errorType) 
% switch errorType
%     case  'Rate'
%         if obj.Rate=[];
%         error('Set the rate first, then press run')
%         end 
%     case
% end 
%                 end 
%                 
                
            end
            
    
         methods (Static=true)
           function unitTest()
               fprintf('Creating Syringe Pump object\n');
               SP=MIC_SyringePump();
               fprintf('Run the pump\n');
               SP.run;
               pause(2);
               fprintf('Stop the pump\n');
               SP.stop;
               
               

           end 
           
end 
        
end