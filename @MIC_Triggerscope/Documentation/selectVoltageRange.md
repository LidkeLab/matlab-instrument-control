
selectVoltageRange determines the best voltage range for the given Signal
This method will look at the voltage range of an analog signal 'Signal'
and determine the smallest voltage range encompassing that signal range.
The range options are selected from the options given in
obj.VoltageRangeOptions.

INPUTS:
Signal: An array whose elements represent voltages to be set on a DAC
port of the Triggerscope.
(numeric array, Nx1 or 1xN)(Units = volts)

OUTPUTS:
VoltageRangeIndex: Index of obj.VoltageRangeOptions (or of
obj.VoltageRangeChar) specifying the voltage range
selected for the input 'Signal'.
(scalar integer)

Created by:
David J. Schodt (Lidke Lab, 2020)


Determine the min. and max. voltages present in 'Signal'.
