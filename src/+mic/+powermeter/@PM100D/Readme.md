# mic.powermeter.PM100D: Matlab Instrument class to control power meter PM100D.

## Description
Controls the [ThorLabs PM100D](https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=3341&pn=PM100D) light power meter.
The class can retrieve the current power and current temperature. 
The wavelength of the light can be set programatically, as can the wavelength (within the sensor limits).
The gui shows a movie of the plot of the
measured power where the shown period can be modified. It also shows
the current power and the maximum measured power. To run this code
you need the power meter to be connected to the machine.

## Constructor
Example: 

```matlab
P = mic.powermeter.PM100D; 
P.gui
P.measurePower
P.setWavelength(900)
```

## Key Functions:
constructor(), exportState(), send(), minMaxWavelength(), getWavelength(), measurePower(), measureTemperature; setWavelength(), shutdown()

## REQUIREMENTS:
* NI_DAQ  (VISA and ICP Interfaces) should be installed.
* MATLAB 2014 or higher.
* MIC_Abstract.m
* MIC_PowerMeter_Abstract.m

### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

