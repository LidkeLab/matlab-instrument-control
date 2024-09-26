# MIC_PM100D: Matlab Instrument class to control power meter PM100D.

## Description
Controls the [ThorLabs PM100D](https://www.thorlabs.com/newgrouppage9.cfm?objectgroup_id=3341&pn=PM100D) light power meter.
The class can retrieve the current power and current temperature. 
The wavelenghth of the light can be set programatically, as can the wavelength (within the 400 nm to 1100 nm range).
The gui shows a movie of the plot of the
measured power where the shown period can be modified. It also shows
the current power and the maximum measured power. To run this code
you need the power meter to be connected to the machine.

## Constructor
Example: 

```matlab
P = MIC_PM100D; 
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

