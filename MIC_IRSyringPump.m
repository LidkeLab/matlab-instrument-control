classdef MIC_IRSyringPump < MIC_ThorlabsIR
    % MIC_IRSyringPump Matlab Instrument Class for using Syringe Pump at
    % the same time of taking data with IRCamera
    %
    %This class is only for SPT microscopy in Lidke's Lab 
    % 
    % Example: obj=MIC_IRSyringPump();
    % Function: start_sequence
    %
    % REQUIREMENTS: 
    %   MIC_Abstract.m
    %   MIC_ThorlabsIR
    %   MIC_SyringePump
    %   MATLAB software version R2016b or later
    %
    % CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.
        
    properties
        SP          % an obj for MIC_SyringePump to control Syringe pump
        SPwaitTime  % wait time for Syrineg Pump to start after starting IRCamera
        tIR_end     % to check if all devices work in right time order (Andor,IRCamera,Pump)
    end
    
    methods
        function obj=MIC_IRSyringPump()
            obj.SP=MIC_SyringePump();
        end
        
        function start_sequence(obj)
            %start_sequence for IR Camera and starting Syringe Pump in the
            %middle of taking image by IR Camera
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            %init empty array
            obj.Data=zeros(obj.ROI(2),obj.ROI(4),obj.SequenceLength);
            obj.AbortNow=0;
            for ii=1:obj.SequenceLength
                ii;
                if ii==obj.SPwaitTime
                    obj.SP.run
                end
                s32Wait=uc480.Defines.DeviceParameter.Wait;
                obj.Cam.Acquisition.Freeze(s32Wait);
                out=obj.getlastimage;
                if obj.AbortNow
                    %stop Syringe Pump by closing image
                    obj.SP.stop;
                    obj.AbortNow=0;
                    break
                end
                %save data
                if obj.KeepData
                    obj.Data(:,:,ii)=out;
                end
                
                switch obj.ReturnType
                    case 'dipimage'
                        out=dip_image(out,'uint8');
                    case 'matlab'
                end
                obj.displaylastimage;
            end
            SeqOutput=obj.Data;
        end  
    end
end 

