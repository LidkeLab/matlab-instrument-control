
setDACRange sets the specified DAC port to the desired voltage range.
This method will set DAC port number 'DACIndex' to the voltage range
specified by 'VoltageRange'.

INPUTS:
DACIndex: The DAC port number you wish to change the voltage of.
(integer in range [1, obj.IOChannels])
VoltageRange: The desired voltage range to be set for DAC port
DACIndex.
(1x2 numeric array which is one of the rows of
obj.VoltageRangeOptions, or scalar defining the index
of the row in obj.VoltageRangeOptions)(Default = [0, 5])

Created by:
David J. Schodt (Lidke Lab, 2020)


Set defaults if needed.
