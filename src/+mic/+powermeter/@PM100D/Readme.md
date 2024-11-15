# mic.powermeter.PM100D: Matlab Instrument class to control power meter PM100D.

## Description
Controls power meter PM100D, gets the current power. It can also gets
the current temperature. The wavelenght of the light can also be
set for power measurement, where the range of the wavelength is
400nm < Lambda < 1100nm. The gui shows a movie of the plot of the
measured power where the shown period can be modified. It also shows
the current power and the maximum measured power. To run this code
you need the power meter to be connected to the machine.

## Constructor
Example: P = mic.powermeter.PM100D; P.gui

## Key Functions:
constructor(), exportState(), send(), minMaxWavelength(), getWavelength(), measure(), setWavelength(), shutdown()

## REQUIREMENTS:
NI_DAQ  (VISA and ICP Interfaces) should be installed.
MATLAB 2014 or higher.
mic.Abstract.m
mic.powermeter.abstract.m

### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

