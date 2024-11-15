# mic.HamamatsuLCOS: Matlab Instrument Control of Hamamatsu LCOS SLM

## Description
This class controls a phase SLM connected through a DVI interface.
Pupil diameter is 2*NA*f, f=M/180 for olympus objectives

## Class Properties

### Public Properties

- **`HorPixels`**
- **Description**: Number of horizontal pixels on the SLM.
- **Type**: Integer
- **Default**: `1272`

- **`VerPixels`**
- **Description**: Number of vertical pixels on the SLM.
- **Type**: Integer
- **Default**: `1024`

- **`PixelPitch`**
- **Description**: Pixel pitch of the SLM in microns.
- **Type**: Float
- **Default**: `12.5`

- **`Lambda`**
- **Description**: Wavelength used for phase modulation, specified in microns.
- **Type**: Float
- **Default**: `0.69`

- **`File_Correction`**
- **Description**: File path for a wavelength-dependent phase correction image.
- **Type**: String
- **Default**: `'CAL_LSH0801531_690nm.bmp'`

- **`ScaleFactor`**
- **Description**: Scale factor for achieving a 2π phase shift, dependent on wavelength.
- **Type**: Float
- **Default**: `218/256`

- **`Image_Correction`**
- **Description**: Phase correction image represented on a scale from 0-255, mapping to a 0-2π phase shift.
- **Type**: Matrix/Image

- **`Image_Blaze`**
- **Description**: Blaze image for phase modulation in radians.
- **Type**: Matrix/Image
- **Default**: `0`

- **`Image_OptimPSF`**
- **Description**: Phase image used for generating an optimized aberration-free PSF (in radians).
- **Type**: Matrix/Image
- **Default**: `0`

- **`Image_Pattern`**
- **Description**: Desired phase pattern to be displayed on the SLM, without correction or blaze effects (in radians).
- **Type**: Matrix/Image
- **Default**: `0`

- **`Image_Display`**
- **Description**: Final pattern to be displayed on the SLM, including scale factor correction and phase wrapping.
- **Type**: Matrix/Image

- **`Image_ZernikeStack`**
- **Description**: Pre-calculated Zernike polynomial images for phase correction and shaping.
- **Type**: Matrix/Image

- **`PupilCenter`**
- **Description**: Coordinates for the center of the pupil in SLM pixels.
- **Type**: Array (x, y)

- **`PupilRadius`**
- **Description**: Radius of the pupil in SLM pixels.
- **Type**: Float

- **`ZernikeCoefOptimized`**
- **Description**: Zernike coefficients used for creating an optimized PSF.
- **Type**: Array of Floats

- **`ZernikeCoef`**
- **Description**: Zernike coefficients used to create a desired phase pattern.
- **Type**: Array of Floats

- **`Fig_Pattern`**
- **Description**: Figure object representing the pattern display.
- **Type**: Figure Handle

- **`PrimaryDispSize`**
- **Description**: Number of pixels in the primary display, specified as `[Hor, Ver]`.
- **Type**: Array of Integers

- **`StartGUI`**
- **Description**: Flag for starting the graphical user interface (GUI).
- **Type**: Boolean
- **Default**: `0`

### Protected Properties

- **`InstrumentName`**
- **Description**: Descriptive name of the instrument.
- **Type**: String
- **Default**: `'LCOS'`

## Constructor
Example: obj = mic.HamamatsuLCOS();

## Key Functions:
delete, gui, exportState, setupImage, displayImage,
calcZernikeImage, calcOptimPSFImage, calcPrasadImage,
calcZernikeStack, calcDisplayImage, calcBlazeImage,
displayCheckerboard

## REQUIREMENTS:
mic.abstract.m
MATLAB software version R2016b or later
Data Acquisition Toolbox

### CITATION: Marjoleing Meddens, Lidkelab, 2017 & Sajjad Khan, Lidkelab, 2021.

