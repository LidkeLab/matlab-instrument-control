classdef MIC_Imaq < MIC_Camera_Abstract

    properties(Access=protected)
        AbortNow;           %stop acquisition flag
        FigurePos;
        FigureHandle;
        ImageHandle;
        ReadyForAcq;        %If not, call setup_acquisition
        TextHandle;
    end
    properties(SetAccess=protected)
        CameraIndex;        %index used when more than one camera
        ImageSize;          %size of current ROI
        LastError;          %last errorcode
        Manufacturer;       %camera manufacturer
        Model;              %camera model
        CameraParameters;   %camera specific parameters
        XPixels;            %number of pixels in first dimention
        YPixels;            %number of pixels in second dimention
    end
    properties
        Binning;            %   [binX binY]
        Data;               %   last acquired data
        ExpTime_Focus;      %   focus mode exposure time
        ExpTime_Capture;    %   capture mode exposure time
        ExpTime_Sequence;   %   sequence mode expsoure time
        ROI;                %   [Xstart Xend Ystart Yend]
        SequenceLength;     %   Kinetic Series length
        SequenceCycleTime;  %   Kinetic Series cycle time (1/frame rate)
    end
    methods
        function obj=MIC_Imaq() 
            % Object constructor
            obj = obj@MIC_Camera_Abstract(~nargout);
        end
        
        function abort(obj)
            % Abort function
            stop(obj.CameraHandle);
            obj.ReadyForAcq=0;
        end
        
        function shutdown(obj)
            % Object shutdown
            delete(obj.CameraHandle);
            clear obj.CameraHandle;
        end
        
        function errorcheck(obj,funcname)
        end

        function initialize(obj)
            % Initialization
            if isempty(obj.CameraIndex)
                obj.getcamera;
            end
            
            fieldp=fields(camset);
            for ii=1:length(fieldp)
                pInfo=propinfo(obj.CameraCap,fieldp{ii});
                switch pInfo.Constraint
                    case 'enum'
                        obj.CameraSetting.(fieldp{ii}).Bit=obj.CameraCap.(fieldp{ii});
                        obj.CameraSetting.(fieldp{ii}).Ind=find(strcmp(pInfo.ConstraintValue,obj.CameraCap.(fieldp{ii})));
                    case 'bounded'
                        obj.CameraSetting.(fieldp{ii}).Value=obj.CameraCap.(fieldp{ii});
                end
            end
            obj.ReturnType='matlab';
            obj.ExpTime_Focus=obj.CameraCap.Exposure;
            obj.ExpTime_Capture=obj.CameraCap.Exposure;
            obj.ExpTime_Sequence=obj.CameraCap.Exposure;
            CCDsize=obj.CameraHandle.VideoResolution;
            obj.XPixels=CCDsize(1);
            obj.YPixels=CCDsize(2);
            obj.ImageSize=CCDsize;
            obj.ROI=[1,obj.XPixels,1,obj.YPixels];
            obj.setCamProperties(obj.CameraSetting);
            GuiCurSel = MIC_IMGSourceCamera.camSet2GuiSel(obj.CameraSetting);
            obj.build_guiDialog(GuiCurSel);
            %obj.gui;
            
        end

    end

end