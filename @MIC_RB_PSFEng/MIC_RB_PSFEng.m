classdef MIC_RB_PSFEng < MIC_Abstract
% MIC_RB_PSFEng
% 
% ## Overview
% The `MIC_RB_PSFEng` class is designed for super-resolution data collection in PSF (Point Spread Function) engineering on Reflected Beam Microscopes and similar setups. This class interfaces with hardware components like Spatial Light Modulators (SLMs), cameras, lasers, and piezoelectric stages to facilitate the exploration and design of PSFs. It includes methods for PSF construction, pupil position calibration, and other related utilities.
% 
% ## Requirements
% - MATLAB 2016b or later.
% - Dependence on several custom classes for hardware interaction:
%   - `MIC_HamamatsuLCOS`: for SLM operations.
%   - `MIC_HamamatsuCamera`: for camera controls.
%   - `MIC_TCubeLaserDiode`: for laser controls.
%   - `MIC_TCubePiezo`: for piezo stage operations.
% 
% ## Installation
% 1. Clone this repository or download the files into your MATLAB working directory.
% 2. Ensure all dependent classes (`MIC_HamamatsuLCOS`, `MIC_HamamatsuCamera`, `MIC_TCubeLaserDiode`, `MIC_TCubePiezo`) are also included in your MATLAB path.
% 
% ## Usage Example
% Below is an example on how to initialize and use the `MIC_RB_PSFEng` class within MATLAB:
% ```matlab
% % Initialize camera, laser, piezo, and SLM objects
% camera = MIC_HamamatsuCamera();
% laser642 = MIC_TCubeLaserDiode('64844464', 'Power', 71, 181.3, 1);
% piezo = MIC_TCubePiezo('81843229', '84842506', 'Z');
% slm = MIC_HamamatsuLCOS();
% 
% % Create an instance of MIC_RB_PSFEng
% psfEngine = MIC_RB_PSFEng(camera, laser642, piezo, slm);
% 
% % Example to calibrate pupil position
% psfEngine.calibratePupilPosition();
% 
% % Example to display the optimal pupil
% psfEngine.dispOptimalPupil();
% ```   
% ### CITATION: Sandeep Pallikuth & Marjolein Meddens, Lidke Lab 2017. Sajjad Khan, Lidkelab, 2021.
    properties
        % Instruments
        SLM                 % SLM object (MIC_HamamatsuLCOS)
        Camera              % Camera object (MIC_HamamatsuCamera)
        Laser642            % Laser object (MIC_TCubeLaserDiode)
        Piezo               % Piezo object (MIC_TCubePiezo)
        % Microscope
        NA=1.3;             % NA of objective
        RefrIdx=1.406;      % Refractive index of immersion medium
        Fobjective=180/60;  % Focal lenght of objective (mm)
        SLMangle = 7.4;     % Angle of SLM with respect to the X-axis of 
                                % the incoming beam (degrees)
        PixelSize = 0.151;  % um
        % PSF
        ZCoefOptimized      % Optimized zernike coefficient for no abberations
        
        % calibrated defocus coefficient
        DefocusCoeff2Micron=-0.2882; % um defocus for a defocus coefficient of 1
        % calibrated TL shift
        FP2Shift = 26; % TL shift in waist position (um/dpt)
    end
    
    properties (SetAccess=protected)
        InstrumentName='RB PSF engineering'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    properties (Hidden)
        StartGUI=false;       %Defines GUI start mode.  'true' starts GUI on object creation. 
    end
    
    methods
        
        function obj=MIC_RB_PSFEng(Camera,Laser642,Piezo,SLM)
            %MIC_RB_PSFEng constructor
            % INPUTS:
            %   All inputs are optional. If variable is empty or doesn't
            %   exist it will create the object
            %   Camera:     MIC_HamamatsuCamera object
            %   Laser642:   MIC_TCubeLaserDiode object
            %   Piezo:      MIC_TCubePiezo object
            %   SLM:        MIC_HamamatsuLCOS object
            
            % for naming variables
            obj = obj@MIC_Abstract(~nargout);
            
            % add or create instrument objects
            if ~exist('Camera','var') || isempty(Camera)
                obj.Camera = MIC_HamamatsuCamera();
            else
                obj.Camera = Camera;
            end
            if ~exist('Laser642','var') || isempty(Laser642)
                obj.Laser642 = MIC_TCubeLaserDiode('64844464','Power',71,181.3,1);
            else
                obj.Laser642 = Laser642;
            end
            if ~exist('Piezo','var') || isempty(Piezo)
                obj.Piezo = MIC_TCubePiezo('81843229','84842506','Z');
            else
                obj.Piezo = Piezo;
            end
            if ~exist('SLM','var') || isempty(SLM)
                obj.SLM = MIC_HamamatsuLCOS();
            else
                obj.SLM = SLM;
            end 
            
            % set some properties
            obj.ZCoefOptimized = zeros(15,1);
            % Get calibrated pixel size
            [p,~]=fileparts(which('MIC_RB_SRcollect'));
            pix = load(fullfile(p,'RB_PixelSize.mat'));
            obj.PixelSize = pix.PixelSizeX;

        end
               
        function unitTest(obj)
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            %Export all important Attributes, Data and Children
           
            Data=[];
            Attributes=[];
            Children=[];
        end
        
        function dispOptimalPupil(obj)
            obj.SLM.ZernikeCoef = obj.ZCoefOptimized;
            obj.SLM.calcZernikeImage();
        end
        
        function calibratePupilPosition(obj)
            % calibratePupilPosition calibrates the position and size of
            % pupil on the SLM
            % It scans a blaze across the SLM in the horizontal and 
            % vertical directions.
            %
            % USER INPUT DURING PROCEDURE
            % The method starts with running focus, during which the user
            % should adjust the focus and field of view to have a bright
            % bead in focus. The user should then close the focus window
            % and click on the bead in the figure window that appears.
            % After that the code will run automatically and update the
            % fields of the SLM object with the results
            %
            % Marjolein Meddens 2017, Lidke Lab
            
            % perform blaze scan
            [HInt,HScan,VInt,VScan] = obj.scanBlaze();
            % fit results
            % initial guess of parameters
            R=ceil(obj.NA*obj.Fobjective/obj.SLM.PixelPitch*1000);
            X0hor = [max(HInt)-min(HInt),min(HInt),obj.SLM.HorPixels/2, R];
            X0ver = [max(VInt)-min(HInt),min(VInt),obj.SLM.VerPixels/2, R];
            % run fminsearch
            funHor = @(x)obj.blazeScanObjFcn(x,HInt,HScan);
            Xhor = fminsearch(funHor,X0hor);
            funVer = @(x)obj.blazeScanObjFcn(x,VInt,VScan);
            Xver = fminsearch(funVer,X0ver);
            
            % calculate fit curve results
            HIntFit = zeros(size(HInt));
            VIntFit = zeros(size(VInt));
            for ii = 1:numel(HIntFit)
                HIntFit(ii) = obj.blazeScanIntensity(HScan(ii),Xhor(1),Xhor(2),Xhor(3),Xhor(4));
            end
            for ii = 1:numel(VIntFit)
                VIntFit(ii) = obj.blazeScanIntensity(VScan(ii),Xver(1),Xver(2),Xver(3),Xver(4));
            end
            % plot results
            figure;
            plot(HScan,HInt,'or')
            hold on
            plot(HScan,HIntFit,'-g','LineWidth',2)
            plot(VScan,VInt,'ob')
            plot(VScan,VIntFit,'-m','LineWidth',2)
            legend({'Horizontal scan data','Horizontal scan fit','Vertical scan data','Vertical scan fit'});
            
            % update SLM properties
            obj.SLM.PupilCenter = round([Xver(3),Xhor(3)]);
            obj.SLM.PupilRadius = round(max(Xhor(4),Xver(4))); %assume round pupil for now
            % reset blaze image
            obj.SLM.Image_Blaze = 0;
            obj.SLM.calcDisplayImage();
            obj.SLM.displayImage();
        end
        
        function delete(obj)
            if ~isempty(obj.GuiFigure) && ishandle(obj.GuiFigure)
                close(obj.GuiFigure)
            end
        end
    end
    
    methods (Static)
        [f] = blazeScanObjFcn(X,I,BlazeWidth);
        [I] = blazeScanIntensity(BlazeWidth,Ibead,Ibg,PupilPos,Rpupil);
        [MaxPos,Ifit] = fitCoefScan(CoefVals,I);
    end
    
    
    
    
end

