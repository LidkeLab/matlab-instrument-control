# Matlab instrument class to control the TIRF stage with a joystick
## Description
This class controls a microscope stage with a joystick, if said joystick
is turned ON through the GUI. You can change the speed/sensitivity in microns/second
on your joystick with the two edit buttons on the GUI. When turning the
joystick ON, you pass in the Stage object and it will graph where you
are on the stage. When the Joystick is ON, a timer function is used
to check whether you are moving/using the joystick and graphs your position
10 times per second.   This code uses HebiJoystick to control an HID compliant
joystick and uses JSaxes (analog joystick) to move in x and y.  The code uses
buttons(1,1) and buttons(1,3) to move in z ,buttons(1,7) is used to center the stage.
For example we used a USB N64 controller, you use the analog
joystick(JSaxes) to move in x and y.
You use the up and down yellow buttons (buttons(1,1) and buttons(1,3)) to
move in z. Press the blue A button(buttons(1,7)) to center the Stage.
Stg.gui
JS=MIC_Joystick()
JS.StageObj=Stg
JS.gui
## REQUIRES:
MIC_MCLNanoDrive
HebiJoystick: https://www.mathworks.com/matlabcentral/fileexchange/61306-hebirobotics-matlabinput
###Citation: Sajjad Khan, Lidkelab, 2024.
