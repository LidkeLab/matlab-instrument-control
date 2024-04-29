
Sends a signal to the Arduino to open valve ValveNumber on the BIOCHEM
flow selection valve.

INPUTS:
obj: An instance of the MIC_BiochemValve class.
ValveNumber: The number specifying which valve on the BIOCHEM flow
selection valve to open.
NOTE: this may be mapped to the relay block on the relay
module for easy verification (by viewing the wiring path).

CITATION: David Schodt, Lidke Lab, 2018


Map ValveNumber to the appropriate digital I/O pin on the Arduino.
