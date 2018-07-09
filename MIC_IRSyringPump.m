classdef MIC_IRSyringPump < MIC_ThorlabsIR
    %MIC_IRSyringPump creates an object to start Syringe Pump in the middle 
    %of sequence for IRcamera from Thorlabs company. 
    %
    %   REQUIREMENTS
    %   MIC_ThorlabsIR
    %   MIC_SyringePump
    %
    % CITATION:
    % Hanieh Mazloom-Farsibaf   Aug 2017 (Keith A. Lidke's lab)
        
    properties
        SP          % an obj for MIC_SyringePump to control Syringe pump
        SPwaitTime  % wait time for Syrineg Pump to start after starting IRCamera
    tIR_end
    end
    
    methods
        function obj=MIC_IRSyringPump()
            obj.SP=MIC_SyringePump();
        end
        
        function start_sequence(obj)
            obj.AcquisitionType='sequence';
            obj.setup_acquisition;
            if isempty(obj.ROI)
                obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            end
            obj.Data=zeros(obj.ROI(2)-obj.ROI(1)+1,obj.ROI(4)-obj.ROI(3)+1,obj.SequenceLength);
            obj.AbortNow=0;
            %init empty array
            for ii=1:obj.SequenceLength
                ii
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

