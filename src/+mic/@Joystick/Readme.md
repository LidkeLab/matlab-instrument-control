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
JS=mic.Joystick()
JS.StageObj=Stg
JS.gui

## REQUIRES:
mic.stage3D.MCLNanoDrive
HebiJoystick: https://www.mathworks.com/matlabcentral/fileexchange/61306-hebirobotics-matlabinput
## Class Properties

### Public Properties
- **`JS_activate`**:
- **Description**: Used to control when the joystick is activated.
- **Type**: Numeric (0 or 1)
- **Default**: `0` (Joystick is off)

- **`FigGUI`**:
- **Description**: Figure handle for the graphical user interface (GUI) associated with the joystick control.
- **Type**: Figure Handle or Object

- **`InstrumentName`**:
- **Description**: The name of the instrument being controlled via the joystick.
- **Type**: String
- **Default**: `'Joystick'`

- **`StageObj`**:
- **Description**: Represents the stage object being controlled by the joystick. This object is passed into the `Joystick` class for control.
- **Type**: Object

- **`TimerObj`**:
- **Description**: Timer object used to periodically check the stage's position and detect changes in position or movement.
- **Type**: Timer Object

- **`JSObj`**:
- **Description**: Object representing the joystick, used to interface with the HebiJoystick code for joystick control.
- **Type**: Object

- **`MoveScale`**:
- **Description**: Array defining the speed or scale of movement for each dimension controlled by the joystick.
- **Type**: Array (1x2)
- **Default**: `[1, 0.05]`
- **Usage**: Controls movement speed in each axis.

- **`AxesOrientation`**:
- **Description**: Array indicating whether each dimension of the joystick movement is inverted.
- **Type**: Array (1x3)
- **Default**: `[1, -1, 1]`
- **Usage**: Defines the orientation of movement (e.g., normal or inverted) for each axis.

###Citation: Sajjad Khan, Lidkelab, 2024.

