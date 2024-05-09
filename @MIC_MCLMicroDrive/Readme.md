# MIC_MCLMicroDrive controls a Mad City Labs Micro Stage
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
# connectStage attempts to connect to the stage.
This method will use the MCL libraries to attempt to connect to an MCL
micro-drive stage attached to the calling computer.
Created by:
David J. Schodt (Lidke lab, 2021)
Attempt to make the connection.
# displayLastError displays the last error message received from the stage
This method will take the struct in obj.LastError and display it in a
more user friendly way in the Command Window.  If the "error" code
returned was 0 (success), no message will be displayed (for the sake of
avoiding CommandWindow clutter).
Created by:
David J. Schodt (Lidke lab, 2021)
Attempt to display the error.
# gui is the GUI method for the MIC_MCLMicroDrive class.
This GUI has several elements which can be used to control a (single
axis) Mad City Labs micro-drive stage.
INPUTS:
GUIParent: The 'Parent' of this GUI, e.g., a figure handle.
(Default = figure(...))
Created by:
David J. Schodt (Lidke lab, 2021)
Create a figure handle for the GUI if needed.
# moveDistance moves the specified distance with the given velocity.
This method will move an amount specified by 'Distance' at the speed
defined in obj.Velocity
INPUTS:
Distance: Distance the stage will be moved (millimeters)
Created by:
David J. Schodt (Lidke lab, 2021)
Set defaults if needed.
# moveSingleStep moves a single step in the specified direction.
This method will take the smallest possible step size of the connected
MCL micro-drive stage in the direction specified by 'Direction'.
INPUTS:
Direction: Direction in which the stage will take a single step.
(integer, 1 or -1)
Created by:
David J. Schodt (Lidke lab, 2021)
Ensure 'Direction' makes sense.
