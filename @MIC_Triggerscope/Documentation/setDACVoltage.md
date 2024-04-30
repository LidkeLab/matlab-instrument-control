
setDACVoltage sets the specified DAC to the desired voltage.
This method will set DAC port number 'DACIndex' to the voltage specified
by 'Voltage'.

EXAMPLE USAGE:
If 'TS' is a working instance of the MIC_Triggerscope class (i.e., the
Triggerscope has already been connected successfully), you can use this
method to set DAC port 7 to 1.3 Volts as follows:
TS.setDACVoltage(7, 1.3)

INPUTS:
DACIndex: The DAC port number you wish to change the voltage of.
(integer in range [1, obj.IOChannels])
Voltage: The voltage you wish to set DAC port number DACIndex to.
NOTE: If the voltage you set is outside of the current set
range of DAC port number DACIndex, this method will
issue an error.
(float in range defined by obj.VoltageRangeOptions(...
obj.DACStatus(DACIndex).VoltageRangeIndex, :))

Created by:
David J. Schodt (Lidke Lab, 2020)


Validate the inputs.
