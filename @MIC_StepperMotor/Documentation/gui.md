
MIC_StepperMotor.gui: This gui is written for the Benchtop stepper motor.

gui has three lines of uicontrols to control X, Y and Z axes (from top to
the bottom). The Home button moves the stage to the origin. The jog
buttons at each side of the slider makes the stage to jog with the size
given in the jog-box. User can use the slider in three different ways.
1) They can simply drag the slider. 2) They can click at the buttons at
the ends of the slider. 3) They can right click on the slider and then use
the mouse wheel to move the stage. The user has two options for the mouse
wheel steps, it can be determined using the toggle button at the bottom of
the gui. The position box shows the current position of the stage and the
Jog box shows the jog step size.

Functions: properties2gui, homeX, jogXBackward, clickSliderX, wheelX,
jogXForward, posX, jogX, homeY, jogYBackward, sliderY,
clickSliderY, wheelY, jogYForward, posY, jogY, homeZ,
jogZBackward, sliderZ, clickSliderZ, wheelZ, jogZForward, posZ,
jogZ, toggSliderStep

REQUIREMENTS:
MATLAB 2014 or higher
Kinesis software from thorlabs
MIC_Abstract class.
Access to the mexfunctions for this device. (kinesis_SBC_function).

CITATION: Mohamadreza Fazel, Lidkelab, 2017.

prevent opening more than one gui for an objext.
