classdef MIC_RB_PSFEng < MIC_Abstract
    %MIC_RB_PSFEng Explore and design PSFs on the Reflected Beam Microscope
    %   Detailed explanation goes here
    
    properties
    end
    
    properties (SetAccess=protected)
        InstrumentName='PSFEng'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    
    methods
        
        function obj=MIC_RB_PSFEng()
        end
        
        function gui(obj)
        end
        
        function unitTest(obj)
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            %Export all important Attributes, Data and Children
           
            Data=[];
            Attributes=[];
            Children=[];
        end
        
        
    end
    
    methods (Static)
    
        function [HInt,Vint]=scanBlaze(CameraObj)
            H=MIC_HamamatsuLCOS()
            
            
            PSFROI=[]
            
            %Pupil diameter is 2*NA*f, f=180/M for olympus objectives
            NA=1.3;
            F=180/60; %mm
            
            D=2*NA*F/H.PixelPitch*1000;
            R=ceil(D/2);
            
            H.PupilRadius=R;
            ScanStep=10;
            
            %Horizontal scan of blaze at size of pupil
            HScan=(-2*R:ScanStep:H.HorPixels);
            clear HInt;
            for ii=1:length(HScan)
                XStart=max(1,HScan(ii));
                XEnd=min(HScan(ii)+2*R,H.HorPixels);
                H.calcBlazeImage(.1,[1 XStart 1024 XEnd-XStart+1])
                H.calcDisplayImage()
                H.displayImage()
                Data=CameraObj.start_capture();
                HInt(ii)=sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4))));
            end
            
            
            
            %Verticl scan of blaze at size of pupil
            VScan=(-2*R:ScanStep:H.VerPixels);
            clear VInt;
            for ii=1:length(VScan)
                YStart=max(1,VScan(ii));
                YEnd=min(VScan(ii)+2*R,H.VerPixels);
                H.calcBlazeImage(.1,[YStart 1 YEnd-YStart+1 1272])
                H.calcDisplayImage()
                H.displayImage()
                Data=CameraObj.start_capture();
                VInt(ii)=sum(sum(Data(PSFROI(1):PSFROI(2),PSFROI(3):PSFROI(4))));
            end

            figure;plot(HScan,Hint)
            xlabel('Scan Start (pixels)')
            ylabel('ROI Intensity')
            
            figure;plot(VScan,Vint)
            xlabel('Scan Start (pixels)')
            ylabel('ROI Intensity')
            
        end
        
        
        
    end
    
    
    
    
end

