
setTTLState sets the specified TTL to the desired state.
This method will set TTL port number 'TTLIndex' to the state specified by
'State'.

EXAMPLE USAGE:
If 'TS' is a working instance of the MIC_Triggerscope class (i.e., the
Triggerscope has already been connected successfully), you can use this
method to set TTL port 13 HIGH (true, on, hot, ...) with any of
the following commands:
TS.setTTLState(13, 'HIGH')
TS.setTTLState(13, true)
TS.setTTLState(13, 1)
Similarly, you can set TTL port 13 LOW (false, off, cold, ...) with any
of the following commands:
TS.setTTLState(13, 'LOW')
TS.setTTLState(13, false)
TS.setTTLState(13, 0)
You can also toggle the state of TTL port 13 by excluding the second
input:
TS.setTTLState(13)

INPUTS:
TTLIndex: The TTL port number you wish to change the state of.
(integer in range [1, obj.IOChannels])
State: The state you wish to set TTL port number TTLIndex to.
(char array 'LOW', 'HIGH', or any input that can be cast to true
or false)

Created by:
David J. Schodt (Lidke Lab, 2020)


Validate the TTLIndex.
NOTE: I'm doing this first to help with the default setting for 'State'.
