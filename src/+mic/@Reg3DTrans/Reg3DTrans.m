classdef Reg3DTrans < mic.abstract
    % mic.Reg3DTrans  
    %
    % ## Description
    % This class Register a sample to a stack of transmission images Class that performs 3D registration using transmission images
    % 
    % ## INPUT
    %    CameraObj - camera object -- tested with mic.AndorCamera only
    %    StageObj - stage object -- tested with mic.MCLNanoDrive only
    %    LampObj - lamp object -- tested with mic.IX71Lamp only, will work
    %                             with other lamps that inherit from
    %                             LightSource_Abstract
    %    Calibration file (optional)
    %
    % ## Properties
    %
    % ### Protected Properties
    %
    % #### `InstrumentName`
    % - **Description:** Name of the instrument.
    %   - **Default Value:** `'ShutterELL6'`
    %
    % #### `IsOpen`
    % - **Description:** Indicates whether the shutter is currently open.
    %
    % ### Public Properties
    %
    % #### `Comport`
    % - **Description:** Communication port used for the shutter connection.
    %
    % #### `ShutterAddress`
    % - **Description:** Address of the shutter for communication purposes.
    %
    % #### `RS232`
    % - **Description:** RS232 communication object used to interface with the shutter.
    %
    % #### `openstr`
    % - **Description:** Command string used to open the shutter.
    %
    % #### `closestr`
    % - **Description:** Command string used to close the shutter.
    %
    % #### `StartGUI`
    % - **Description:** Determines whether to use `mic.abstract` to bring up the GUI (no need for a separate GUI function in `mic.ShutterTTL`).
    %   - **Default Value:** `0`
    % 
    % ### Hidden Properties
    % - **`StartGUI`**: Defines GUI start mode (default: `false`).
    % - **`PlotFigureHandle`**: Handle for plotting calibration and alignment results.
    % ## SETTING (IMPORTANT!!)
    %    There are several Properties that are system specific. These need
    %    to be specified after initialization of the class, before using
    %    any of the functionality. See Properties section for explanation
    %    and which ones.
    %
    % ## Constructor
    %
    % ### `Reg3DTrans(CameraObj, StageObj, [CalFileName])`
    % Creates a `Reg3DTrans` object.
    % - **Parameters**:
    %   - `CameraObj`: Camera object for image acquisition.
    %   - `StageObj`: Stage object for movement control.
    %   - `CalFileName` (optional): Path to calibration file containing `PixelSize` and `OrientationMatrix`.
    %
    % ## Public Methods
    %
    % ### Calibration Methods
    % - **`calibrate(PlotFlag)`**: Calibrates the orientation matrix between the camera and stage.
    %   - **Parameters**:
    %     - `PlotFlag` (optional): Boolean indicating whether to plot results.
    %
    % - **`takerefimage()`**: Takes a new reference image for alignment.
    %
    % - **`saverefimage()`**: Saves the reference image to a `.mat` file.
    %
    % ### Alignment Methods
    % - **`align2imageFit()`**: Aligns the current image to the reference image using iterative optimization.
    %
    % - **`findXYShift()`**: Finds the XY shift between the current and reference images.
    %
    % - **`findZPos()`**: Finds the best Z-position for alignment using cross-correlation.
    %
    % ### Z-Stack Collection
    % - **`collect_zstack(ZStackMaxDev, ZStackStep, NMean)`**: Collects a Z-stack of images.
    %   - **Parameters**:
    %     - `ZStackMaxDev`: Maximum deviation for Z-stack (default: `ZStack_MaxDev`).
    %     - `ZStackStep`: Step size for Z-stack (default: `ZStack_Step`).
    %     - `NMean`: Number of images to average per position (default: `NMean`).
    %
    % ### Image Capture Methods
    % - **`capture()`**: Captures a single image.
    % - **`capture_single()`**: Captures a single image with predefined settings.
    %
    % ### Utility Methods
    % - **`showoverlay()`**: Displays an overlay of the aligned image on top of the reference image.
    % - **`savealignment()`**: Saves the current, reference, and overlay images.
    %
    % ### State Export
    % - **`exportState()`**: Exports the current state of the object.
    %
    % ## Static Methods
    %
    % ### `funcTest(camObj, stageObj, lampObj)`
    % Tests the functionality of the `Reg3DTrans` class using the provided camera, stage, and lamp objects.
    %
    % ### Utility Static Methods
    % - **`GaussFit(X, CC, Zpos)`**: Fits a Gaussian model to data.
    % - **`findStackOffset(Stack1, Stack2, Params)`**: Finds the offset between two stacks.
    % - **`findOffsetIter(RefStack, MovingStack, NIterMax, Tolerance, CorrParams, ShiftParams)`**: Iterative offset finding.
    % - **`shiftImage(ImageStack, Shift, Params)`**: Shifts an image stack.
    % - **`frequencyMask(ImSize, FreqCutoff)`**: Creates a frequency mask for filtering.
    %
    % ## Usage Example
    %
    % ```matlab
    % % Create a Reg3DTrans object
    % RegObj = mic.Reg3DTrans(cameraObj, stageObj);
    %
    % % Calibrate the system
    % RegObj.calibrate();
    %
    % % Take a reference image
    % RegObj.takerefimage();
    %
    % % Align the current image to the reference image
    % RegObj.align2imageFit();
    %
    % % Export the current state
    % state = RegObj.exportState();
    % ```
    %
    % ## REQUIREMENT
    %    Matlab 2014b or higher
    %    mic.abstract
    %
    % ## MICROSCOPE SPECIFIC SETTINGS
    % TIRF: LampPower=2; LampWait=2.5; CamShutter=true; ChangeEMgain=true; 
    %  EMgain=2; ChangeExpTime=true; ExposureTime=0.01;   
    
    % ### Citations: Marjolein Meddens,  Lidke Lab 2017
    % ### Updated version:Hanieh Mazloom-Farsibaf, Lidke Lab 2018.
    
    properties
        % Input
        CameraObj           % Camera Object
        StageObj            % Stage Object
%         LampObj             % Lamp Object
        CalibrationFile     % File containing previously calibrated pixel size, or path to save calibration file
        
        % These must be set by user for specific system
%         LampPower=30;       % Lamp power setting to use for transmission image acquistion 
%         LampWait=1;         % Time (s) to wait after turning on lamp before starting imaging
%         CamShutter=true;    % Flag for opening and closing camera shutter (Andor Ixon's) before acquiring a stack
%         ChangeEMgain=false; % Flag for changing EM gain before and after acquiring transmission images
%         EMgain;             % EM gain setting to use for transmission image acquisitions
        ChangeExpTime=true; % Flag for changing exposure time before and after acquiring transmission images
        ExposureTime=0.1;  % Exposure time setting to use for transmission image acquisitions
        
        % Other properties
        PixelSize;          % image pixel size (um)
        CameraTriggerMode = 'internal'; % 'internal', 'external', 'software'
        Stage
        OrientMatrix;       % unitary matrix to show orientation between Camera and Stage([a b;c d])
        AbortNow=0;         % flag for aborting the alignment
        RefImageFile;       % full path to reference image
        Image_Reference     % reference image
        Image_Current       % current image
        ReferenceStack;     % reference stack to compare to in stack corr.
        ReferenceStackFull  % ref. stack before averaging over NMean images
        ZStack              % acquired zstack
        ZStackFull          % acquired zstack before averaging over NMean images
        ZStack_MaxDev=0.5;  % distance from current zposition where to start and end zstack (um)
        ZStack_Step=0.05;   % z step size for zstack acquisition (um)
        ZStack_Pos;         % z positions where a frame should be acquired in zstack (um)
        NMean=1;              % # of images taken (then averaged) at each z position 
        ZStackMaxDevInitialReg = 1; % max. dev. in z for initial reg.
        XYBorderPx = 10; % # of px. to remove from x and y borders.
        StageSettlingTime = 0; % time for stage to settle after moving (s)
        Tol_X=.01;          % max X shift to reach convergence(um)
        Tol_Y=.01;          % max Y shift to reach convergence(um)
        Tol_Z=.05;          % max Z shift to reach convergence(um)
        MaxIter=10;         % max number of iterations for finding back reference position 
        MaxIterReached = 0; % indicate max number of iterations was reached
        MaxXYShift=5;       % max XY distance (um) stage should move, if found shift is larger it will move this distance
        MaxZShift=0.5;      % max Z distance (um) stage should move, if found shift is larger it will move this distance
        ZFitPos;            % found Z positions
        ZFitModel;          % fitted line though auto correlations
        ZMaxAC;             % autocorrelations of zstack
        maxACmodel;
        MinPeakCorr=0.7; % min. corr. allowed to be considered successful
        UseStackCorrelation = 0; % use 3D stack correlation reg. method
        UseGPU = 1; % if UseStackCorrelation, use GPU for findStackOffset
        MaxOffsetScaleIter = 2; % max # of scaling iter. for MaxOffset
        ErrorSignal = zeros(0, 3); % Error Signal [X Y Z] in microns
        ErrorSignalHistory = zeros(0, 3); % Error signal history in microns
        IsInitialRegistration = 0; % boolean: initial reg. or periodic reg.
        OffsetFitSuccess = zeros(0, 3); % bool. array for poly fit success
        OffsetFitSuccessHistory  = zeros(0, 3); 
    end
    
    properties (SetAccess=protected)
        InstrumentName = 'Registration3DTransmission'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    properties (Hidden)
        StartGUI = false;       % Defines GUI start mode.  'true' starts GUI on object creation. 
        PlotFigureHandle;       % Figure handle of calibration/zposition plot
    end
    
    methods
        function obj=Reg3DTrans(CameraObj,StageObj,CalFileName)
            % mic.Reg3DTrans constructor
            % 
            %  INPUT (required)
            %    CameraObj - camera object
            %    StageObj - stage object
            %    LampObj - lamp object
            %  INPUT (optional)
            %    CalFileName - full path to calibration file (.mat) containing
            %                  'PixelSize' and 'OrientationMatrix' variable, 
            %                  if file doesn't exist calibration  will be saved here
            
            % pass in input for autonaming feature mic.abstract
            obj = obj@mic.abstract(~nargout);
            
            % check input
            if nargin <2
                error('mic.Reg3DTrans:InvInput','You must pass in Camera, Stage and Lamp Objects')
            end
            obj.CameraObj = CameraObj;
            obj.StageObj = StageObj;
%             obj.LampObj = LampObj;
            
            if nargin == 3
                obj.CalibrationFile = CalFileName;
                % get pixelsize
                if exist(obj.CalibrationFile,'file')
                    a=load(CalFileName);
                    obj.PixelSize=a.PixelSize;
                    obj.OrientMatrix=a.OrientMatrix;
                    clear a;
                end
            end
        end
                
        function calibrate(obj,PlotFlag)
            % This function is to obtain elements of rotation matrix between
            % Camera (x,y) and Stage(X,Y) OrientMatrix=[A B,C D]
            if ~exist('PlotFlag','var')
                PlotFlag=0;
            end
            
            obj.StageObj.center;
            X=obj.StageObj.Position;
            N=10;
            StepSize=0.1; %micron
            deltaX=((0:N-1)*StepSize)';
            ImSz=obj.CameraObj.ImageSize; %:)
            ImageStack=zeros(ImSz(1),ImSz(2),N);
            % remember start position
            Xstart=X;
            %change EMgain, shutter and exposure time if needed
%             if obj.ChangeEMgain || obj.CamShutter
%                 CamSet = obj.CameraObj.CameraSetting;
%             end
%             if obj.ChangeEMgain
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%             end
%             if obj.CamShutter
%                 CamSet.ManualShutter.Bit=1;
%             end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end

%             if obj.ChangeEMgain || obj.CamShutter
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            % setup camera
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
                        
%             % turn lamp on
%             if isempty(obj.LampObj.Power) || obj.LampObj.Power==0
%                 obj.LampObj.setPower(obj.LampObj.MaxPower/2);
%             end 
%             obj.LampObj.setPower(obj.LampObj.Power);
%             obj.LampObj.on();
%             % open shutter if needed
%             if obj.CamShutter
%                 obj.CameraObj.setShutter(1);
%             end
%             
            % acquire stack for x_direction
            obj.StageObj.setPosition(Xstart);
            for ii=1:N
                X(1)=Xstart(1)+deltaX(ii);
                obj.StageObj.setPosition(X);
                pause(.1);
                ImageStack_X(:,:,ii)=single(obj.CameraObj.start_capture);
            end
            
            % acquire stack for y_direction
            obj.StageObj.setPosition(Xstart);
            X=Xstart;
            deltaY=deltaX;
            for ii=1:N
                X(2)=Xstart(2)+deltaY(ii);
                obj.StageObj.setPosition(X);
                pause(.1);
                ImageStack_Y(:,:,ii)=single(obj.CameraObj.start_capture);
            end
%             % close shutter if needed
%             if obj.CamShutter
%                 obj.CameraObj.setShutter(0);
%             end
            % turn lamp off
%             obj.LampObj.off();
            
%             %change back EMgain, shutter and exposure time if needed
%             if obj.CamShutter
%                 CamSet.ManualShutter.Bit=0;
%             end
%             if obj.ChangeEMgain
%                 CamSet.EMGain.Value = EMGTemp; 
%             end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
%             if obj.ChangeEMgain || obj.CamShutter
%                 obj.CameraObj.setCamProperties(CamSet);
%             end            
           % set stage back to initial position
            obj.StageObj.setPosition(Xstart);
            dipshow(ImageStack_X(10:end-10,10:end-10,:));
            % find shifts for Change in X
            svec_X=zeros(N,2);
            refim=squeeze(ImageStack_X(10:end-10,10:end-10,1));
            for ii=1:N
                alignim_X=squeeze(ImageStack_X(10:end-10,10:end-10,ii));
                svec_X(ii,:)=findshift(alignim_X,refim,'iter');
            end
            
            % set stage back to initial position
            obj.StageObj.setPosition(Xstart);
            dipshow(ImageStack_Y(10:end-10,10:end-10,:));
            % find shifts for Change in Y
            svec_Y=zeros(N,2);
            refim=squeeze(ImageStack_Y(10:end-10,10:end-10,1));
            for ii=1:N
                alignim_Y=squeeze(ImageStack_Y(10:end-10,10:end-10,ii));
                svec_Y(ii,:)=findshift(alignim_Y,refim,'iter');
            end
            % Here is the calculation for OrientCoMatrix
            % There are four coefficient: change Stage in x,y direction and calculate
            % shift for x,y direction in the image

            % fit shifts delta_X, shift in x in image
            PxSz=obj.PixelSize;
            %xy for Image, XY for Stage
            P_xX=polyfit(deltaX,svec_X(:,1),1);
            P_xY=polyfit(deltaY,svec_Y(:,1),1);
            P_yX=polyfit(deltaX,svec_X(:,2),1);
            P_yY=polyfit(deltaY,svec_Y(:,2),1);

            xXfit=P_xX(1)*deltaX+P_xX(2);
            xYfit=P_xY(1)*deltaX+P_xY(2);
            yXfit=P_yX(1)*deltaX+P_yX(2);
            yYfit=P_yY(1)*deltaX+P_yY(2);
            
            a=P_xX(1);
            b=P_xY(1);
            c=P_yX(1);
            d=P_yY(1);
            %orientation camera vs stage: xy=[a b; c d]XY
            OrientMatrix=[a b; c d];
            
            %calculate scalar pixel size
            PixelSize=2/(sqrt(a^2+c^2)+sqrt(b^2+d^2));
            
            if isempty(obj.CalibrationFile)
                warning('mic.Reg3DTrans:CalPxSz:NotSaving','No CalibrationFile specified in obj.CalibrationFile, not saving calibration')
            elseif exist(obj.CalibrationFile,'file')
                warning('mic.Reg3DTrans:CalPxSz:OverwriteFile','Overwriting previous PixelSize and OrientationMatrix calibration file');
                save(obj.CalibrationFile,'PixelSize','OrientMatrix');
            else
                save(obj.CalibrationFile,'PixelSize','OrientMatrix');
            end
            obj.OrientMatrix=OrientMatrix;
            obj.PixelSize=PixelSize; 
            if PlotFlag
                if isempty(obj.PlotFigureHandle)||~ishandle(obj.PlotFigureHandle)
                obj.PlotFigureHandle=figure;
            else
                figure(obj.PlotFigureHandle)
            end
            hold off
%             plot(deltaX,svec_X(:,2),'r.','MarkerSize',14);
            hold on
%             plot(deltaX,xXfit,'k','LineWidth',2);
%             legend('Found Displacement','Fit');
            end
        end
        function takerefimage(obj)
            %takerefimage Takes new reference image

%             if obj.ChangeEMgain
%                 CamSet = obj.CameraObj.CameraSetting;
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
%             % turn lamp on
%             if isempty(obj.LampObj.Power) || obj.LampObj.Power==0
%                 obj.LampObj.setPower(obj.LampObj.MaxPower/2);
%             end 
%             obj.LampObj.setPower(obj.LampObj.Power);
%             obj.LampObj.on;
%             
            obj.Image_Reference=obj.capture;
            dipshow(obj.Image_Reference);
            % turn lamp off
%             obj.LampObj.off;
            
            % change back EMgain and exposure time if needed
%             if obj.ChangeEMgain
%                 CamSet.EMGain.Value = EMGTemp; 
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function saverefimage(obj)
            % saverefimage Saves reference image

            [a,b]=uiputfile('*.mat', 'Save Reference Image as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference; %#ok<NASGU,PROP> 
            save(f,'Image_Reference');
            obj.RefImageFile = f;
            obj.updateGui();
        end

        function saveRefStack(obj)
            % saverefimage Saves reference image

            [a,b]=uiputfile('*.mat', 'Save Reference stack as');
            f=fullfile(b,a);
            ReferenceStack=obj.ReferenceStack; %#ok<NASGU,PROP> 
            save(f,'ReferenceStack');
            obj.RefImageFile = f;
            obj.updateGui();
        end
        
        function takeRefStack(obj)
            % Takes a reference stack from -obj.ZStack_MaxDev to
            % +obj.ZStack_MaxDev in steps of obj.ZStack_Step relative to
            % the current focal plane.  The resulting z-stack will be
            % stored as obj.ReferenceStack.

            % If needed, change the exposure time of the camera.
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
            
            % Collect the full size z-stack (which can be used for initial
            % registration) and store it in obj.ReferenceStack.
            obj.collect_zstack(obj.ZStackMaxDevInitialReg);
            obj.ReferenceStack = obj.ZStack;
            
            % Ensure that the reference image is set to the central
            % image in the reference stack (this corresponds to the
            % focal plane of interest).
            FocalInd = 1 + obj.ZStackMaxDevInitialReg/obj.ZStack_Step;
            obj.Image_Reference = obj.ReferenceStack(:, :, FocalInd);
            
            % Change to exposure time of the camera back to it's original
            % value.
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end        
       
        function c=showoverlay(obj)
            %showoverlay Shows aligned image on top of reference image
            
            % check whether images exist
            if isempty(obj.Image_Reference)
                warning('mic.Reg3DTrans:showoverlay:NoRef','No reference image saved, not making overlay');
                return
            elseif isempty(obj.Image_Current)
                warning('mic.Reg3DTrans:showoverlay:NoCur','No current image saved, not making overlay');
                return
            end
            a=stretch(obj.Image_Reference(10:end-10,10:end-10));
            b=stretch(obj.Image_Current(10:end-10,10:end-10));
            c=joinchannels('RGB',a,b);
            h=dipshow(c);
            diptruesize(h,'tight');
        end
        
        function getcurrentimage(obj)
            % getcurrentimage Takes transmission image with current settings
            
%             if obj.ChangeEMgain
%                 CamSet = obj.CameraObj.CameraSetting;
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
%             % turn lamp on
%             if isempty(obj.LampObj.Power) || obj.LampObj.Power==0
%                 obj.LampObj.setPower(obj.LampObj.MaxPower/2);
%             end 
%             obj.LampObj.setPower(obj.LampObj.Power);
%             obj.LampObj.on;
            obj.Image_Current=obj.capture;
            im=obj.Image_Current;
            dipshow(im);
%             % turn lamp off
%             obj.LampObj.off;
%             
%             % change back EMgain and exposure time if needed
%             if obj.ChangeEMgain
%                 CamSet.EMGain.Value = EMGTemp; 
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        

        function align2imageFit(obj)
            % align2imageFit 

%             if obj.ChangeEMgain
%                 CamSet = obj.CameraObj.CameraSetting;
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
%             %turn lamp on
%             if isempty(obj.LampObj.Power) || obj.LampObj.Power==0
%                 obj.LampObj.setPower(obj.LampObj.MaxPower/2);
%             end 
%             obj.LampObj.setPower(obj.LampObj.Power);
%             obj.LampObj.on;
            
            iter=0;
            WithinTol=0;
            obj.MaxIterReached = 0;
            while (WithinTol==0)&&(iter<obj.MaxIter)
                if obj.AbortNow
                    obj.AbortNow = 0;
                    break
                end
                
                if obj.UseStackCorrelation                    
                    % Collect a z-stack whose size depends on whether we
                    % are performing an initial registration step or a
                    % periodic re-registration step.
                    if obj.IsInitialRegistration
                        % Acquire a large z-stack for the current stage
                        % location.
                        % NOTE: This stores the z-stack in the object
                        %       property obj.ZStack.
                        obj.collect_zstack(obj.ZStackMaxDevInitialReg);
                        
                        % Define the indices of the full size reference
                        % stack (for better code continuity with the else 
                        % statement).
                        ZStackRefInds = 1:size(obj.ZStack, 3);
                    else
                        % Acquire a small z-stack for the current stage
                        % location.
                        % NOTE: This stores the z-stack in the object
                        %       property obj.ZStack.
                        obj.collect_zstack(obj.ZStack_MaxDev);
                        
                        % Define the indices of the full size reference
                        % stack which correspond to this smaller
                        % sub-stack.
                        StackSteps = obj.ZStack_MaxDev / obj.ZStack_Step;
                        FocalInd = 1 + obj.ZStack_MaxDev/obj.ZStack_Step;
                        ZStackRefInds = FocalInd - StackSteps ...
                            :FocalInd + StackSteps;
                    end
                    
                    % Isolate the reference stack and the current stack of
                    % interest, removing the boundaries in x and y to 
                    % ensure only the images of interest are being 
                    % compared. 
                    RefStack = obj.ReferenceStack(...
                        obj.XYBorderPx:end-obj.XYBorderPx, ...
                        obj.XYBorderPx:end-obj.XYBorderPx, ZStackRefInds);
                    CurrentStack = obj.ZStack(...
                        obj.XYBorderPx:end-obj.XYBorderPx, ...
                        obj.XYBorderPx:end-obj.XYBorderPx, :);
                    MaxOffset = ceil(size(RefStack) / 2).';
                    FitOffset = [2; 2; 3];
                    
                    % Determine the pixel and sub-pixel predicted shifts
                    % between the two stacks.  After the first iteration,
                    % we'll attempt the iterative shift finding if it seems
                    % reasonable to do so.
                    CorrParams.UseGPU = obj.UseGPU;
                    CorrParams.PlotFlag = true;
                    CorrParams.MaxOffset = MaxOffset;
                    CorrParams.FitOffset = FitOffset;
                    CorrParams.SuppressWarnings = true;
                    if ((iter>0) && all(SubPixelOffset<=MaxOffset) ...
                            && all(SubPixelOffset<=1))
                        NIterMax = 3;
                        CorrParams.SymmetrizeFit = true;
                        [SubPixelOffset, PixelOffset, CorrData] = ...
                            obj.findOffsetIter(RefStack, CurrentStack, ...
                            NIterMax, [], CorrParams);
                    else
                        CorrParams.SymmetrizeFit = false;
                        [SubPixelOffset, PixelOffset, CorrData] ...
                            = obj.findStackOffset(RefStack, CurrentStack, ...
                            CorrParams);
                    end
                    
                    % Decide which shift to proceed with based on
                    % PixelOffset and SubPixelOffset (SubPixelOffset can be
                    % innacurate), setting a flag array to indicate when
                    % the SubPixelOffset has 'failed'.
                    CameraOffset = SubPixelOffset ...
                        .* (abs(PixelOffset-SubPixelOffset) <= 0.5) ...
                        + PixelOffset ...
                        .* (abs(PixelOffset-SubPixelOffset) > 0.5);
                    obj.OffsetFitSuccess = ...
                        (abs(PixelOffset-SubPixelOffset) <= 0.5).';
                    
                    % Flag low correlation values to indicate a potential
                    % failure.
                    obj.OffsetFitSuccess = obj.OffsetFitSuccess ...
                        & (max(CorrData.XCorr3D(:))>=obj.MinPeakCorr);
                    obj.OffsetFitSuccessHistory = ...
                        [obj.OffsetFitSuccessHistory; ...
                        obj.OffsetFitSuccess];
                    
                    % Modify PixelOffset to correspond to physical piezo
                    % (sample stage) dimensions, taking care of minus sign
                    % differences as needed.
                    % NOTE: The additional minus sign accounts for the
                    %       convention used in findStackOffset() and was
                    %       kept there (instead of distributing) to
                    %       emphasize this convention.
                    % NOTE: The permute in (x,y) is from the traditional
                    %       image processing convention for (x,y).  In
                    %       findStackOffset, (x,y) are defined using the
                    %       convention s.t. the first index (rows)
                    %       corresponds to x, second index (columns)
                    %       corresponds to y.
                    CameraOffset = -[CameraOffset(2); CameraOffset(1); ...
                        -CameraOffset(3)];
                    StageOffset = CameraOffset; % initialize
                    StageOffset(1:2) = ...
                        obj.OrientMatrix \ CameraOffset(1:2); % px -> um
                    StageOffset(3) = CameraOffset(3) * obj.ZStack_Step;
                    
                    % Move the piezos to adjust for the predicted shift.
                    CurrentPos = obj.StageObj.Position;
                    NewPos = CurrentPos - StageOffset.';
                    obj.StageObj.setPosition(NewPos);
                    
                    % Check if the current iteration succeeded within the
                    % set tolerance.
                    StageOffsetTol = [obj.Tol_X; obj.Tol_Y; obj.Tol_Z];
                    WithinTol = all(abs(StageOffset) < StageOffsetTol);
                    
                    % Save the error signal.
                    obj.ErrorSignal = StageOffset.';
                else
                    %find z-position and adjust
                    [Zfit]=obj.findZPos();
                    Pos=obj.StageObj.Position;
                    Zshift=Zfit-Pos(3);
                    Pos(3)=Pos(3) + (sign(real(Zshift))*min(abs(real(Zshift)),obj.MaxZShift));
                    obj.StageObj.setPosition(Pos);

                    %find XY position and adjust
                    [XYshift]=findXYShift(obj);

                    StageShiftXY=inv(obj.OrientMatrix)*XYshift;
                    Pos(1)=Pos(1)+sign(StageShiftXY(1))*min(abs(StageShiftXY(1)),obj.MaxXYShift);
                    Pos(2)=Pos(2)+sign(StageShiftXY(2))*min(abs(StageShiftXY(2)),obj.MaxXYShift);

                    obj.StageObj.setPosition(Pos);
                    
                    %check convergence
                    WithinTol=(abs(XYshift(1))<obj.Tol_X/obj.PixelSize)&...
                    (abs(XYshift(2))<obj.Tol_Y/obj.PixelSize)&(abs(Zshift)<obj.Tol_Z/obj.PixelSize);
                
                    % Save the error signal.
                    obj.ErrorSignal = -[StageShiftXY.', Zshift];
                    
                    % Determine where the fit procedure was succesful
                    obj.OffsetFitSuccess = [1, 1, 1]; % assume success
                    obj.OffsetFitSuccessHistory = ...
                        [obj.OffsetFitSuccessHistory; ...
                        obj.OffsetFitSuccess];
                end
                
                % Append the new ErrorSignal to ErrorSignalHistory.
                obj.ErrorSignalHistory = [obj.ErrorSignalHistory; ...
                    obj.ErrorSignal];
                
                %show overlay
                obj.Image_Current = obj.capture_single();
                im=obj.Image_Reference(...
                    obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx);
                zs=obj.Image_Current(...
                    obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx);
                o=joinchannels('RGB',stretch(im),stretch(zs));
                h=dipshow(1234,o);
                diptruesize(h,'tight');
                drawnow;
                
                % Increment the iteration counter.
                iter=iter+1;
                fprintf('Alignment iteration %i complete \n', iter)
            end
            
            if iter==obj.MaxIter
                obj.MaxIterReached = 1;
                warning('mic.Reg3DTrans:MaxIter','Reached max iterations');
            end

            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function collect_zstack(obj, ZStackMaxDev, ZStackStep, NMean)
            % collect_zstack Collects Zstack 
            
            % Set defaults if not passed as inputs to this method.
            if ~exist('ZStackMaxDev', 'var')
                ZStackMaxDev = obj.ZStack_MaxDev; % microns
            end
            if ~exist('ZStackStep', 'var')
                ZStackStep = obj.ZStack_Step; % microns
            end
            if ~exist('NMean', 'var')
                NMean = obj.NMean; % # of images per z position
            end
            
            % get current position of stage
            XYZ=obj.StageObj.Position;
            X_Current=XYZ(1);
            Y_Current=XYZ(2);
            Z_Current=XYZ(3);

            obj.ZStack_Pos = ...
                (Z_Current-ZStackMaxDev:ZStackStep:Z_Current+ZStackMaxDev);
            N=length(obj.ZStack_Pos);
            ROI = obj.CameraObj.ROI;
            obj.ZStack=zeros(ROI(4)-ROI(3)+1,ROI(2)-ROI(1)+1,N,'uint16');
            
            %change EMgain, shutter and exposure time if needed
%             if obj.ChangeEMgain || obj.CamShutter
%                 CamSet = obj.CameraObj.CameraSetting;
%             end
%             if obj.ChangeEMgain
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%             end
%             if obj.CamShutter
%                 CamSet.ManualShutter.Bit=1;
%             end
            if obj.ChangeExpTime
                if strcmpi(obj.CameraTriggerMode, 'software')
                    % Software triggering will use a sequence, thus we have
                    % to change the sequence acquisition time.
                    ExpTimeTemp = obj.CameraObj.ExpTime_Sequence; 
                    obj.CameraObj.ExpTime_Sequence = obj.ExposureTime;
                else
                    ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                    obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
                end
            end
%             if obj.ChangeEMgain || obj.CamShutter
%                 obj.CameraObj.setCamProperties(CamSet);
%             end

                        
            % Setup the camera based on the TriggerMode. 
            obj.CameraObj.TriggerMode = obj.CameraTriggerMode;
            if strcmpi(obj.CameraTriggerMode, 'software')
                % When using a software trigger, we'll actually setup the
                % camera for a 'sequence' instead of a 'capture'. 
                % NOTE: we'll still use the exposure time as set for a
                %       'capture' since the user will likely not want to
                %       change the exposure time based on the trigger mode. 
                obj.CameraObj.AcquisitionType = 'sequence';
                
                % Change the sequence length property of the camera, saving
                % the old value so that we can undo this change later on.
                PreviousSequenceLength = obj.CameraObj.SequenceLength; 
                obj.CameraObj.SequenceLength = N * NMean; % change back later on
                
                % Setup the acquisition to prepare for the triggered
                % captures. 
                obj.CameraObj.setup_fast_acquisition();
                
                % Call the camera start_sequence() method to initiate the
                % triggered capture process. 
                %obj.CameraObj.start_sequence(); 
            else
                obj.CameraObj.AcquisitionType = 'capture';
                obj.CameraObj.setup_acquisition();
                obj.CameraObj.ReturnType = 'matlab';
            end
                        
            % Collect the z-stack

            for nn=1:N
                % Add a short pause to give misc. system components time to
                % settle. 
                if nn == 1
                    pause(0.5);
                end
                
                % Display the current stack position being collected in the
                % command window.
                NumChar = fprintf(...
                    'Acquiring z-stack image index %i out of %i\n', nn, N);
                
                % Move the stage and allow it to settle (if needed).
                obj.StageObj.setPosition(...
                    [X_Current, Y_Current, obj.ZStack_Pos(nn)]);

                pause(obj.StageSettlingTime);
                    
                 % Capture an image at the current stage location.
                if strcmpi(obj.CameraTriggerMode, 'software')
                    % When TriggerMode is 'software', we're doing a
                    % triggered capture sequence and must fire the trigger
                    % and collect the stack at the end.
                    for ii = 1:NMean
                        obj.CameraObj.fireTrigger();
                        pause(obj.CameraObj.TriggerPause)
                    end
                else
                    % Capture the image as usual.
                    CurrentStack = zeros(size(obj.ZStack), [1, 2, NMean]);
                    for ii = 1:NMean
                        CurrentStack(:, :, ii) = obj.CameraObj.start_capture();
                    end
                    obj.ZStackFull(:, :, nn, :) = single(CurrentStack);
                    obj.ZStack(:, :, nn) = single(median(CurrentStack, 4));
                end

                
                
                %obj.ZStack(:, :, nn)=single(obj.CameraObj.start_capture);
                %pause(0.1)
                % Remove the characters identifying stack index and stack
                % number from command line so that they can be updated.  
                % This is being done to avoid clutter to the command
                % line.
                % NOTE: \b deletes previous character displayed in the
                %       command window.
                for ii = 1:NumChar
                    fprintf('\b');
                end
            end

            
            % If a software trigger was used to perform a fast acquisition,
            % we need to collect the stack now that all of the desired
            % triggers were fired.  Also, we need to 'clean up' our changes
            % made to camera parameters (e.g. the length of a sequence). 
            if strcmpi(obj.CameraTriggerMode, 'software')
                CurrentStack = single(...
                    obj.CameraObj.finishTriggeredCapture(N * NMean));
                obj.ZStackFull = [];
                for ii = 1:N
                    ZIndicesToAverage = (1:NMean) + (ii-1)*NMean;
                    obj.ZStackFull(:, :, ii, :) = ...
                        CurrentStack(:, :, ZIndicesToAverage);
                end
                obj.ZStack = median(obj.ZStackFull, 4);
                obj.CameraObj.SequenceLength = PreviousSequenceLength;
            end
            
            % Ensure that Image_Current is set to the center image of the
            % newly collected z-stack (this corresponds to the current
            % focal plane).
            FocalInd = 1 + obj.ZStack_MaxDev/obj.ZStack_Step;
            obj.Image_Current = obj.ZStack(:, :, FocalInd);
            

%             % close shutter if needed
%             if obj.CamShutter
%                 obj.CameraObj.setShutter(0);
%             end

            %change back EMgain, shutter and exposure time if needed
%             if obj.CamShutter
%                 CamSet.ManualShutter.Bit=0;
%             end
%             if obj.ChangeEMgain
%                 CamSet.EMGain.Value = EMGTemp; 
%             end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
%             if obj.ChangeEMgain || obj.CamShutter
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            
            % Move stage back to original position
            obj.StageObj.setPosition(XYZ);
        end
        
        function [XYshift]=findXYShift(obj)
            % findXYShift Finds XY shift between reference image and newly 
            % acquired current image
            
            % check pixelsize
            if isempty(obj.PixelSize)
                error('mic.Reg3DTrans:noPixelSize', 'no PixelSize given in obj.PixelSize, please calibrate pixelsize first. Run obj.calibratePixelSize')
            end
            if isempty(obj.OrientMatrix)
                error('mic.Reg3DTrans:noOrientMatrix', 'no OrientMatrix given in obj.OrientMatrix, please calibrate OrientMatrix first. Run obj.calibrateOrientation')
            end
            %cut edges
            Ref=dip_image(obj.Image_Reference(...
                    obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx));
            Ref=Ref-mean(Ref);
            Ref=Ref/std(Ref(:));

            %get image at current z-position
            Current=obj.capture_single;
            Current=dip_image(Current(...
                    obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx));
            Current=Current-mean(Current);
            Current=Current/std(Current(:));
                
            %find 2D shift         
            svec=findshift(Current,Ref,'iter');
            XYshift=-svec; % In Pixels
        end
        
        
        function [Zfit]=findZPos(obj)
            % findZPos acquires zstack and finds zposition matching
            %   reference image
            
            %collect z-data stack
            if obj.IsInitialRegistration
                % Collect a larger z-stack if the IsInitialRegistration
                % flag is set.
                obj.collect_zstack(obj.ZStackMaxDevInitialReg);
            else
                obj.collect_zstack(obj.ZStack_MaxDev);
            end          
            
            %whiten data to give zero mean and unit variance
            Ref=obj.Image_Reference(obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx);
            Ref=Ref-mean(Ref(:));
            Ref=Ref/std(Ref(:));
            zs=obj.ZStack;
            zs=zs(obj.XYBorderPx:end-obj.XYBorderPx, ...
                    obj.XYBorderPx:end-obj.XYBorderPx, :);
            N=size(zs,3);
            n=numel(Ref);
            for ii=1:N
                %whiten 
                Current=squeeze(zs(:,:,ii));
                Current=Current-mean(Current(:));
                Current=Current/std(Current(:));
                cc=abs(ifft2(fft2(Current).*conj(fft2(Ref))));
                maxAC(ii)=1/n*max(cc(:));
            end
            [~,zindex]=find(maxAC==max(maxAC));
            
            %fit cross-correlation to find best in focus z-position
            StartFit=max(1,zindex-4);
            EndFit=min(N,zindex+4);
            Zpos_fit=obj.ZStack_Pos(StartFit:EndFit);
            maxAC_fit=maxAC(StartFit:EndFit);
            
            %fit
            [P, S, MU] = polyfit(Zpos_fit,maxAC_fit,3);
            model = polyval(P,Zpos_fit,S,MU);
            zAtMax=(-sqrt(P(2)^2-3*P(1)*P(3))-P(2))/3/P(1)*MU(2)+MU(1);
            
            obj.maxACmodel=polyval(P,zAtMax);
            %plot results
            if isempty(obj.PlotFigureHandle)||~ishandle(obj.PlotFigureHandle)
                obj.PlotFigureHandle=figure;
            else
                figure(obj.PlotFigureHandle);
            end
            hold off
            plot(obj.ZStack_Pos,maxAC,'ro');hold on
            plot(Zpos_fit,model,'b','linewidth',2);
            xlabel('Z position (microns)')
            ylabel('Max of Crosscorrelation')
            
            % update parameters
            obj.ZFitPos=Zpos_fit;
            obj.ZFitModel=model;
            obj.ZMaxAC=maxAC;
            
            %return best z position
            Zfit=zAtMax;
        end
 
        function out=capture(obj)
            % Captures a single image
            %   All camera parameters must have been set prior to running
            %     this method
            %   The lamp must have been turned on prior to running this
            %     method
            obj.CameraObj.AcquisitionType='capture';
            obj.CameraObj.setup_acquisition;
            out=single(obj.CameraObj.start_capture);
        end
        
        function out=capture_single(obj)
            % Sets camera and lamp parameters and captures a single image
            
%             % change EMgain and exposure time if needed
%             if obj.ChangeEMgain
%                 CamSet = obj.CameraObj.CameraSetting;
%                 EMGTemp = CamSet.EMGain.Value;
%                 CamSet.EMGain.Value = obj.EMgain;
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                ExpTimeTemp = obj.CameraObj.ExpTime_Capture; 
                obj.CameraObj.ExpTime_Capture = obj.ExposureTime;
            end
                        
            % turn lamp on
%            obj.turnLampOn();
            % capture image
            out=obj.capture;
            % turn lamp off
 %           obj.turnLampOff();
            
            % change back EMgain and exposure time if needed
%             if obj.ChangeEMgain
%                 CamSet.EMGain.Value = EMGTemp; 
%                 obj.CameraObj.setCamProperties(CamSet);
%             end
            if obj.ChangeExpTime
                obj.CameraObj.ExpTime_Capture = ExpTimeTemp;
            end
        end
        
        function savealignment(obj)
            % savealignment() Saves current, refenrece and overlay images
            
            % check whether images exist
            if isempty(obj.Image_Reference)
                warning('mic.Reg3DTrans:NoRef','No reference image saved, not making overlay');
                return
            elseif isempty(obj.Image_Current)
                warning('mic.Reg3DTrans:NoCur','No current image saved, not making overlay');
                return
            end
            [a,b]=uiputfile('*.mat', 'Save Overlay as');
            f=fullfile(b,a);
            Image_Reference=obj.Image_Reference; %#ok<NASGU,PROP>
            Image_Current=obj.Image_Current; %#ok<NASGU,PROP>
            Image_Overlay=obj.showoverlay(); %#ok<NASGU>
            save(f,'Image_Reference','Image_Current','Image_Overlay');
        end

        function updateGui(obj)
            % updateGui Updates gui with current values/settings
            
            if isempty(obj.GuiFigure) || ~isvalid(obj.GuiFigure)
                return
            end
            for ii = 1 : numel(obj.GuiFigure.Children)
                if strcmp(obj.GuiFigure.Children(ii).Tag,'fileEdit')
                    obj.GuiFigure.Children(ii).String = obj.RefImageFile;
                end
            end
        end
        
        function [Attribute,Data,Children] = exportState(obj)
            % exportState Exports current state of object
            % all relevant object  properties will be returned in State
            % structure
            
            Attribute.CalibrationFile = obj.CalibrationFile;
%             Attribute.LampPower = obj.LampObj.Power;
%             Attribute.LampWait = obj.LampWait;
%             Attribute.CamShutter = obj.CamShutter;
%             Attribute.ChangeEMgain = obj.ChangeEMgain;
%             Attribute.EMgain = obj.EMgain;
            Attribute.ChangeExpTime = obj.ChangeExpTime;
            Attribute.ExposureTime = obj.ExposureTime;
            Attribute.PixelSize = obj.PixelSize;
            Attribute.OrientMatrix = obj.OrientMatrix;
            Attribute.RefImageFile = obj.RefImageFile;
            Attribute.ZStack_MaxDev = obj.ZStack_MaxDev;
            Attribute.ZStack_Step = obj.ZStack_Step;
            Attribute.ZStack_Pos = obj.ZStack_Pos;
            Attribute.Tol_X = obj.Tol_X;
            Attribute.Tol_Y = obj.Tol_Y;
            Attribute.Tol_Z = obj.Tol_Z;
            Attribute.MaxIter = obj.MaxIter;
            Attribute.MaxXYShift = obj.MaxXYShift;
            Attribute.MaxZShift = obj.MaxZShift;
            Attribute.IsInitialRegistration = obj.IsInitialRegistration;
            Attribute.UseStackCorrelation = obj.UseStackCorrelation;
            Attribute.MinPeakCorr = obj.MinPeakCorr;
            
            Data.Image_Reference = obj.Image_Reference;
            Data.Image_Current = obj.Image_Current;
            Data.MaxIterReached = obj.MaxIterReached;
            if ~isempty(obj.ZFitPos)
                Data.ZFitPos = obj.ZFitPos;
            end
            if ~isempty(obj.ZFitModel)
                Data.ZFitModel = obj.ZFitModel;
            end
            if ~isempty(obj.ZMaxAC)
                Data.ZMaxAC = obj.ZMaxAC;
            end
            if ~isempty(obj.ZStack)
                Data.ZStack = obj.ZStack;
            end
            if ~isempty(obj.ReferenceStack)
                Data.ReferenceStack = obj.ReferenceStack;
            end
            if ~isempty(obj.ZStack)
                Data.CurrentStack = obj.ZStack; 
            end
            if ~isempty(obj.ErrorSignal)
                Data.ErrorSignal = obj.ErrorSignal;
            end
            if ~isempty(obj.ErrorSignalHistory)
                Data.ErrorSignalHistory = obj.ErrorSignalHistory;
            end
            if ~isempty(obj.OffsetFitSuccess)
                Data.OffsetFitSuccess = uint8(obj.OffsetFitSuccess);
            end
            if ~isempty(obj.OffsetFitSuccessHistory)
                Data.OffsetFitSuccessHistory = ...
                    uint8(obj.OffsetFitSuccessHistory);
            end
            
            Children=[];
            
        end
        
        function delete(obj)
            %delete Deletes gui figure before deleting object
            delete(obj.GuiFigure);
        end
    end
    
    methods (Static)
        function [fval,model]=GaussFit(X,CC,Zpos)
            u = X(1);    %mean
            s = X(2);    %sigma
            a = X(3);    %magnitude
            o = X(4);    %offset
            model=o + a*normpdf(Zpos,u,s);
            fval=mse(model,CC);
        end
        
        [Shift, IntShift, CorrData, Params] = ...
            findStackOffset(Stack1, Stack2, Params)
        [Shift, IntShift, CorrData, CorrParams, ShiftParams] = ...
            findOffsetIter(RefStack, MovingStack, NIterMax, Tolerance, ...
            CorrParams, ShiftParams)
        [ImageStack, Params] = shiftImage(ImageStack, Shift, Params);
        [FreqMask, FreqSqEllipse, YMesh, XMesh, ZMesh] = ...
            frequencyMask(ImSize, FreqCutoff)
        [Struct] = padStruct(Struct, DefaultStruct)
        [Image] = removeBorder(Image, Border, Direction)
    
        function State = funcTest(camObj,stageObj,lampObj)
            %funcTest Tests all functionality of mic.Reg3DTrans
            % 
            %  INPUT (required)
            %    CameraObj - camera object
            %    StageObj - stage object
            %    LampObj - lamp object
            %
            %  This will only work fully if there is a sample on the
            %  microscope with some contrast in transmission and that
            %  changes with changing z focus

            fprintf('\nTesting mic.Reg3DTrans class...\n')
            % constructing and deleting instances of the class
            RegObj = mic.Reg3DTrans(camObj,stageObj);
            delete(RegObj);
            RegObj = mic.Reg3DTrans(camObj,stageObj);
            fprintf('* Construction and Destruction of object works\n')
            % loading and closing gui
            RegObj.gui;
            close(gcf);
            RegObj.gui;
            fprintf('* Opening and closing of GUI works, please test GUI manually\n');
            % Calibration
            fprintf('* Testing calibration function\n')
            RegObj.calibrate();
            % Get current and reference images
            fprintf('* Testing image acquisition\n')
            RegObj.getcurrentimage();
            RegObj.takerefimage();
            % Perform alignment
            fprintf('* Testing alignment\n')
            RegObj.align2imageFit();
            % export state
            State = RegObj.exportState;
            disp(State);
            fprintf('* Export of current state works, please check workspace for it\n')
            fprintf('Finished testing mic.Reg3DTrans class\n');            
        end
    end
    
end
