
Queries an initialized Cavro syringe pump and returns the received message
INPUTS:
obj: An instance of the MIC_CavroSyringePump class.

CITATION: David Schodt, Lidke Lab, 2018


Query the syringe pump and read the response, repeating until a valid
query response is received (a valid Answer Block in response to a query
has exactly 6 bytes, i.e. no Data Block is returned for a query request)
or the timeout has been exceeded.
