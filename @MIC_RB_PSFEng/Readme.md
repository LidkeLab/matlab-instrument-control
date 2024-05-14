# MIC_RB_PSFEng

## Overview
The `MIC_RB_PSFEng` class is designed for super-resolution data collection in PSF (Point Spread Function) engineering on Reflected Beam Microscopes and similar setups. This class interfaces with hardware components like Spatial Light Modulators (SLMs), cameras, lasers, and piezoelectric stages to facilitate the exploration and design of PSFs. It includes methods for PSF construction, pupil position calibration, and other related utilities.

## Requirements
- MATLAB 2016b or later.
- Dependence on several custom classes for hardware interaction:
- `MIC_HamamatsuLCOS`: for SLM operations.
- `MIC_HamamatsuCamera`: for camera controls.
- `MIC_TCubeLaserDiode`: for laser controls.
- `MIC_TCubePiezo`: for piezo stage operations.

## Installation
1. Clone this repository or download the files into your MATLAB working directory.
2. Ensure all dependent classes (`MIC_HamamatsuLCOS`, `MIC_HamamatsuCamera`, `MIC_TCubeLaserDiode`, `MIC_TCubePiezo`) are also included in your MATLAB path.

## Usage Example
Below is an example on how to initialize and use the `MIC_RB_PSFEng` class within MATLAB:
```matlab
Initialize camera, laser, piezo, and SLM objects
camera = MIC_HamamatsuCamera();
laser642 = MIC_TCubeLaserDiode('64844464', 'Power', 71, 181.3, 1);
piezo = MIC_TCubePiezo('81843229', '84842506', 'Z');
slm = MIC_HamamatsuLCOS();

Create an instance of MIC_RB_PSFEng
psfEngine = MIC_RB_PSFEng(camera, laser642, piezo, slm);

Example to calibrate pupil position
psfEngine.calibratePupilPosition();

Example to display the optimal pupil
psfEngine.dispOptimalPupil();
```
### CITATION: Sandeep Pallikuth & Marjolein Meddens, Lidke Lab 2017. Sajjad Khan, Lidkelab, 2021.

