
MIC_MCLMicroDrive controls a Mad City Labs Micro Stage
This class controls a Mad City Labs (MCL) micro-positioner stage.
This class uses the built-in MATLAB methods for calling C libraries,
e.g., calllib(), to call functions in MicroDrive.dll.  The
micro-positioner stage controller is to expected to be connected via
USB.

The first time this class is used on a given computer, the user will
be prompted to select the location of MicroDrive.dll.  On a Windows
machine, this is typically placed by default in
C:\Program Files\Mad City Labs\MicroDrive\MicroDrive.dll  during the
installation process (installation files provided by MCL).

NOTE: I had to manually modify MicroDrive.h to remove the precompiler
directives related to the '_cplusplus' stuff.  I was getting
errors otherwise that I didn't know what to do about! -DS 2021

REQUIRES:
MCL MicroDrive files installed on system.

Created by:
David J. Schodt (Lidkelab, 2021) based on MIC_MCLNanoDrive class.
