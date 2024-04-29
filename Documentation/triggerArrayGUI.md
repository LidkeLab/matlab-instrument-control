
createTriggeringArray opens a GUI that can create a triggering array.
This method will open a GUI which allows the user to define a
'TriggeringArray', i.e., an array defining a simple DAC/TTL program based
on a trigger signal.

NOTE: The primary intention of this method is to generate the class
SignalStruct (which also defines the dependent property
SignalArray), which is a structure with the following fields (to
define this manually outside of this GUI, you only need to set
'Identifier' and 'Signal'):
NPoints: Number of points in the signal.
InPhase: 1 if the signal starts HIGH, 0 otherwise.
Period: Period of the signal with respect to the trigger, e.g., a
period of 4 means that the signal toggles every other
trigger event.
Range: Range of voltages present in the signal [min., max.].
IsLogical: 1 if the signal is logical (e.g., TTL or trigger)
0 if the signal is analog (e.g., DAC)
Handle: Line handle for the signal in this GUI.
Identifier: char array defining which signal this is (the trigger
is 'trigger', TTL's will be 'TTL' suffixed with port
number of field width 2, e.g., 'TTL07', DAC's will be
'DAC' suffixed with port number of field width 2, e.g.,
'DAC03').
Alias: Recognizable char array defining what this signal is meant
to control, e.g., 'laser 405', 'attenuator', ...
Signal: Numeric array containing the signal, e.g., a DAC signal
might be something like [0, 5, 0, 2.5, 0, 5]


INPUTS:
GUIParent: The 'Parent' of this GUI, e.g., a figure handle.
(Default = figure(...))

Created by:
David J. Schodt (Lidke Lab, 2020)


Create a figure handle for the GUI if needed.
