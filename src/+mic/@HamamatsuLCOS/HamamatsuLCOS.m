classdef HamamatsuLCOS < mic.abstract
    % mic.HamamatsuLCOS: Matlab Instrument Control of Hamamatsu LCOS SLM
    %
    % ## Description
    % This class controls a phase SLM connected through a DVI interface.
    % Pupil diameter is 2*NA*f, f=M/180 for olympus objectives
    %
    % ## Class Properties
    %
    % ### Public Properties
    %
    % - **`HorPixels`**
    %   - **Description**: Number of horizontal pixels on the SLM.
    %   - **Type**: Integer
    %   - **Default**: `1272`
    %
    % - **`VerPixels`**
    %   - **Description**: Number of vertical pixels on the SLM.
    %   - **Type**: Integer
    %   - **Default**: `1024`
    %
    % - **`PixelPitch`**
    %   - **Description**: Pixel pitch of the SLM in microns.
    %   - **Type**: Float
    %   - **Default**: `12.5`
    %
    % - **`Lambda`**
    %   - **Description**: Wavelength used for phase modulation, specified in microns.
    %   - **Type**: Float
    %   - **Default**: `0.69`
    %
    % - **`File_Correction`**
    %   - **Description**: File path for a wavelength-dependent phase correction image.
    %   - **Type**: String
    %   - **Default**: `'CAL_LSH0801531_690nm.bmp'`
    %
    % - **`ScaleFactor`**
    %   - **Description**: Scale factor for achieving a 2π phase shift, dependent on wavelength.
    %   - **Type**: Float
    %   - **Default**: `218/256`
    %
    % - **`Image_Correction`**
    %   - **Description**: Phase correction image represented on a scale from 0-255, mapping to a 0-2π phase shift.
    %   - **Type**: Matrix/Image
    %
    % - **`Image_Blaze`**
    %   - **Description**: Blaze image for phase modulation in radians.
    %   - **Type**: Matrix/Image
    %   - **Default**: `0`
    %
    % - **`Image_OptimPSF`**
    %   - **Description**: Phase image used for generating an optimized aberration-free PSF (in radians).
    %   - **Type**: Matrix/Image
    %   - **Default**: `0`
    %
    % - **`Image_Pattern`**
    %   - **Description**: Desired phase pattern to be displayed on the SLM, without correction or blaze effects (in radians).
    %   - **Type**: Matrix/Image
    %   - **Default**: `0`
    %
    % - **`Image_Display`**
    %   - **Description**: Final pattern to be displayed on the SLM, including scale factor correction and phase wrapping.
    %   - **Type**: Matrix/Image
    %
    % - **`Image_ZernikeStack`**
    %   - **Description**: Pre-calculated Zernike polynomial images for phase correction and shaping.
    %   - **Type**: Matrix/Image
    %
    % - **`PupilCenter`**
    %   - **Description**: Coordinates for the center of the pupil in SLM pixels.
    %   - **Type**: Array (x, y)
    %
    % - **`PupilRadius`**
    %   - **Description**: Radius of the pupil in SLM pixels.
    %   - **Type**: Float
    %
    % - **`ZernikeCoefOptimized`**
    %   - **Description**: Zernike coefficients used for creating an optimized PSF.
    %   - **Type**: Array of Floats
    %
    % - **`ZernikeCoef`**
    %   - **Description**: Zernike coefficients used to create a desired phase pattern.
    %   - **Type**: Array of Floats
    %
    % - **`Fig_Pattern`**
    %   - **Description**: Figure object representing the pattern display.
    %   - **Type**: Figure Handle
    %
    % - **`PrimaryDispSize`**
    %   - **Description**: Number of pixels in the primary display, specified as `[Hor, Ver]`.
    %   - **Type**: Array of Integers
    %
    % - **`StartGUI`**
    %   - **Description**: Flag for starting the graphical user interface (GUI).
    %   - **Type**: Boolean
    %   - **Default**: `0`
    %
    % ### Protected Properties
    %
    % - **`InstrumentName`**
    %   - **Description**: Descriptive name of the instrument.
    %   - **Type**: String
    %   - **Default**: `'LCOS'`
    %
    % ## Constructor
    % Example: obj = mic.HamamatsuLCOS();
    %
    % ## Key Functions:
    %            delete, gui, exportState, setupImage, displayImage,
    %            calcZernikeImage, calcOptimPSFImage, calcPrasadImage,
    %            calcZernikeStack, calcDisplayImage, calcBlazeImage,
    %            displayCheckerboard
    %
    % ## REQUIREMENTS:
    %   mic.abstract.m
    %   MATLAB software version R2016b or later
    %   Data Acquisition Toolbox
    %
    % ### CITATION: Marjoleing Meddens, Lidkelab, 2017 & Sajjad Khan, Lidkelab, 2021.
    
    properties
        HorPixels=1272      %SLM Horizontal Pixels
        VerPixels=1024      %SLM Vertical Pixels
        PixelPitch=12.5     %Pixel Pitch (micron)
        Lambda=.69;         %Wavelength (micron)
        File_Correction='CAL_LSH0801531_690nm.bmp'     %Wavelength dependent phase correction file
        ScaleFactor=218/256;    %Input required for 2pi phase (default for 690 nm)
        
        Image_Correction    %Phase correction image (0-255, scales to 0-2pi phase)
        Image_Blaze=0       %A Blaze Image in radians
        Image_OptimPSF=0    %Phase for optimized abberation free PSF (radians)
        Image_Pattern=0     %Desired phase (Image without Correction or Blaze, in radians)
        Image_Display       %Pattern to be diplayed on SLM (scale factor corrected and phase wrapped)
        Image_ZernikeStack  %Pre-calculated Zernike Images
        
        PupilCenter         %Location of pupil center (SLM Pixels)
        PupilRadius         %Pupil Radius (SLM Pixels)
        ZernikeCoefOptimized % Zernike coeficients for optimized PSF
        ZernikeCoef         %Zernike coefficients used to create Pattern
        
        Fig_Pattern         %Pattern Figure Object
        PrimaryDispSize;    %Number of pixels of primary display [Hor Ver]
        
        StartGUI=0;
    end
    
    properties (SetAccess=protected)
        InstrumentName='LCOS'; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    
    
    
    methods
        function obj=HamamatsuLCOS()
            % Object constructor
            obj = obj@mic.abstract(~nargout);
            
            %Load in correction file
            obj.Image_Correction=double(imread(obj.File_Correction));
            
            %Setup SLM Figure window
            obj.setupImage();
            
            %Set default pattern to correction image
            obj.calcDisplayImage();
            
            %Diplay the correction image
            obj.displayImage();
            
        end
        
        function delete(obj)
            % Deletes object
            delete(obj.Fig_Pattern);
        end
        
        function gui()
            % Sets up gui
        end
        
        
        function [Attributes,Data,Children]=exportState(obj)
            %Export all important Attributes, Data and Children
            Attributes.HorPixels=obj.HorPixels;
            Attributes.VerPixels=obj.VerPixels;
            Attributes.PixelPitch = obj.PixelPitch;
            Attributes.Lambda = obj.Lambda;
            Attributes.File_Correction=obj.File_Correction;
            Attributes.ScaleFactor=obj.ScaleFactor;
            Attributes.ZernikeCoef=obj.ZernikeCoef;
            Attributes.PupilCenter=obj.PupilCenter;
            Attributes.PupilRadius=obj.PupilRadius;
            
            Data.Image_Correction=obj.Image_Correction;
            Data.Image_Blaze=obj.Image_Blaze;
            Data.Image_OptimPSF=obj.Image_OptimPSF;
            Data.Image_Pattern=obj.Image_Pattern;
            Data.Image_Display=obj.Image_Display;
  
            Children=[];
        end
        
        function setupImage(obj)
            %Create the figure that will display on the SLM
            ScrSz = get(0,'MonitorPosition');
            %Assume larger display is primary
            if ScrSz(1,3)>ScrSz(2,3)
                PM=1;
                SLM=2;
            else
                PM=2;
                SLM=1;
            end
            
            obj.PrimaryDispSize=ScrSz(PM,3:4);
            delete(obj.Fig_Pattern);
            obj.Fig_Pattern=figure('Position',...
                [obj.PrimaryDispSize(1)+1 ScrSz(SLM,2) ...
                obj.HorPixels obj.VerPixels],...
                'MenuBar','none','ToolBar','none','resize','off','NumberTitle','off');
            colormap(gray(256));
            %Prevent closing after a 'close' or 'close all'
            axis off
            set(gca,'position',[0 0 1 1],'Visible','off');
            obj.Fig_Pattern.HandleVisibility='off'; 
        end
        
        function displayImage(obj)
            % Displays Image_Pattern full screen on DVI output
            
            if ~ishandle(obj.Fig_Pattern)
                obj.setupImage();
            end
            obj.Fig_Pattern.HandleVisibility='on';
            figure(obj.Fig_Pattern);
            image(obj.Image_Display);
            set(gca,'position',[0 0 1 1],'Visible','off');
            obj.Fig_Pattern.HandleVisibility='off';
            drawnow();
        end
        
        function calcZernikeImage(obj)
            %Calculates and displays Pattern based on ZernikeCoef
            
            % use SMA_PSF function to generate sum of zernike images
            NMax = numel(obj.ZernikeCoef); % number of zernike coefficients
            [ZStruct]=SMA_PSF.createZernikeStruct(obj.PupilRadius*2,obj.PupilRadius,NMax);
            [Image]=SMA_PSF.zernikeSum(obj.ZernikeCoef,ZStruct);
            % flip and tranpose image to correct for mirror and camera
            % transposition
            Image = Image(:,end:-1:1)';
            obj.Image_Pattern = zeros(obj.VerPixels,obj.HorPixels);
            obj.Image_Pattern(obj.PupilCenter(1)-obj.PupilRadius:obj.PupilCenter(1)+obj.PupilRadius-1,...
                    obj.PupilCenter(2)-obj.PupilRadius:obj.PupilCenter(2)+obj.PupilRadius-1)=...
                    gather(Image);
            obj.calcDisplayImage();
            obj.displayImage();
        end
        
        function calcOptimPSFImage(obj)
            %Calculates image based on ZernikeCoefOptimized
            
            % use SMA_PSF function to generate sum of zernike images
            NMax = numel(obj.ZernikeCoefOptimized); % number of zernike coefficients
            [ZStruct]=SMA_PSF.createZernikeStruct(obj.PupilRadius*2,obj.PupilRadius,NMax);
            [Image]=SMA_PSF.zernikeSum(obj.ZernikeCoefOptimized,ZStruct);
            % flip and tranpose image to correct for mirror and camera
            % transposition
            Image = Image(:,end:-1:1)';
            obj.Image_OptimPSF = zeros(obj.VerPixels,obj.HorPixels);
            obj.Image_OptimPSF(obj.PupilCenter(1)-obj.PupilRadius:obj.PupilCenter(1)+obj.PupilRadius-1,...
                    obj.PupilCenter(2)-obj.PupilRadius:obj.PupilCenter(2)+obj.PupilRadius-1)=...
                    gather(Image);
        end
        
        function calcPrasadImage(obj,L)
            %
            % INPUT
            %   L:      number of zones
            
            D = obj.PupilRadius*2;
            [XGrid,YGrid]=meshgrid((-D/2:D/2-1),(-D/2:D/2-1));
            R=sqrt(gpuArray(XGrid.^2+YGrid.^2));
            Mask=R<obj.PupilRadius;
            R=R/obj.PupilRadius;
            Pupil_Phase=gpuArray(zeros(D,D,'single'));
            Theta=(gpuArray(atan2(YGrid,XGrid))); %CHECK!
            
            Alpha=1/2;
            for ll=1:L
                M=(R>=((ll-1)/L).^Alpha)&(R<(ll/L).^Alpha);
                Pupil_Phase(M)=mod((2*(ll-1)+1)*Theta(M),2*pi); %make hole
            end
            %Pupil_Phase = (Pupil_Phase/(2*pi))*256;
            obj.Image_Pattern = zeros(obj.VerPixels,obj.HorPixels);
            obj.Image_Pattern(obj.PupilCenter(1)-obj.PupilRadius:obj.PupilCenter(1)+obj.PupilRadius-1,...
                    obj.PupilCenter(2)-obj.PupilRadius:obj.PupilCenter(2)+obj.PupilRadius-1)=...
                    gather(Pupil_Phase);
            obj.calcDisplayImage();
            obj.displayImage();
            
        end
        
        function calcZernikeStack(obj)
            %Calculate a stack of images (still being implemented)
        end
        
        function calcDisplayImage(obj)
            %Pattern images is in radians.
            %Correction image and blaze image is input 0-255
            %Images are all scaled to 0-255, meaning 0-2pi phase and then 
            %summed. The result is wrapped modulo 256 and scaled with the
            %scale factor
            PatternIm255 = (obj.Image_Pattern/(2*pi))*255;
            OptimPSFIm255 = (obj.Image_OptimPSF/(2*pi))*255;
            sumIm = obj.Image_Correction + obj.Image_Blaze +...
                PatternIm255 + OptimPSFIm255;
            sumImWrapped = mod(sumIm,256);
            obj.Image_Display=sumImWrapped*obj.ScaleFactor;
        end
        
        function calcBlazeImage(obj,BlazeAngle,ROI)
            %Calculates Pattern using a blaze angle
            % obj.calcBlazePattern(ROI,BlazeAngle)
            
            %ROI is [YStart XStart YWidth XWidth]
            
            if nargin<3 %make full image blaze
                ROI=[1 1 obj.VerPixels obj.HorPixels];
            end

            %Make empty image
            obj.Image_Blaze=zeros(obj.VerPixels,obj.HorPixels);
            L_SubIm=ROI(4)*obj.PixelPitch;
            Delay=L_SubIm*tan(BlazeAngle);
            Delay_Phase=Delay/obj.Lambda*256;
            
            SubIm=meshgrid(linspace(0,Delay_Phase,ROI(4)),1:ROI(3));
            obj.Image_Blaze(ROI(1):ROI(1)+ROI(3)-1,ROI(2):ROI(2)+ROI(4)-1)...
                =SubIm;
            obj.calcDisplayImage();
            obj.displayImage();
        end
        
        function displayCheckerboard(obj)
            % Displays checkboard image for scattering
            % This can be used for alignment to see beam scatter off SLM
            % It displays a checkerboard image with alternating pixels
            % between 0 and pi phase
            
            % Make checkerboard image
            N = 1; %number of pixels per tile
            P = obj.HorPixels/2;
            Q = obj.VerPixels/2;
            I = checkerboard(N,P,Q);
            Ibin = I>0;
            Ifinal = Ibin*255*obj.ScaleFactor/2;
            if ~ishandle(obj.Fig_Pattern)
                obj.setupImage();
            end
            obj.Fig_Pattern.HandleVisibility='on';
            figure(obj.Fig_Pattern);
            image(Ifinal);
            set(gca,'position',[0 0 1 1],'Visible','off');
            obj.Fig_Pattern.HandleVisibility='off';
            drawnow();
        end
        
    end
    
    methods (Static=true)
        function funcTest()
            % Tests the functionality of the class/instrument
        end        
    end
    
end

