# mic.lightsource.TCubeLaserDiode: Matlab Instrument Control Class for the ThorLabs TCube Laser Diode

## Description
This class controls a Laser Diode through us USB connected ThorLabs TCube Laser
Diode Driver TLD001.   Low level commands are via c-API functions
in the ThorLabs Kinsesis API compiled to a set of mex64 functions.
The max current should always be set on the TLD001 independently of
this class specifically for the diode being used and before first use.
The WperA should be measured using a power meter and observing the
photodiode current in Kinesis.

## Notes:
The object should never be cleared with 'clear all'.  Use
'delete' or 'clear'.

## Protected Properties

### `InstrumentName`
Descriptive name of the instrument.
**Default:** `'TCubeLaserDiode'`.

### `Power`
Currently set output power.
**Default:** `0`.

### `PowerUnit`
Unit for measuring power.
**Default:** `'mW'` (could be `mA` or `mW` depending on mode).

### `MinPower`
Minimum power setting.
**Default:** `0`.

### `MaxPower`
Maximum power setting.

### `IsOn`
On or off state of the device (`0` for OFF, `1` for ON).
**Default:** `0`.

### `SerialNo`
TCube serial number.

### `Mode`
Current or power mode.

### `WperA`
Laser diode (LD) power per ampere of photodiode (PD) current.

### `TIARange`
Photodiode current range (in mA).

## Hidden Properties

### `StartGUI`
Indicates whether the GUI should start when creating an instance of the class.
**Default:** `false`.

### `PowerSet`
Indicates if power was changed while the laser is off.
**Default:** `0`.
## constructor
TLD=mic.lightsource.TCubeLaserDiode('64864827','Power',10,100,1)

## Key Functions:
on, off, delete, shutdown, setPower, exportState, funcTest

## REQUIREMENT:
mic.abstract.m
mic.lightsource.abstract.m
Kinesis Control Software Intalled: https://www.thorlabs.com/software_pages/ViewSoftwarePage.cfm?Code=Motion_Control
Pre-compiled Kinesis_LD_*.mex64 files in path (typically in ../../mex64);
Thorlabs.MotionControl.DeviceManager.dll and Thorlabs.MotionControl.TCube.LaserDiode
must be in system path or in same folder as *.mex64 files.

## Serial Numbers:
TIRF 642: 64838719
RB 642: 64844464
RB 405: 64864827
SPT 642:
SEQ 405: 64841724

## Calibrations:
TIRF 642, Feb 28, 2017:  I_LD=150 mA, I_PD=310.7 uA, P_LD=56.7 mW. WperA=182.5
RB 642, March 22, 2017:  I_LD=155.15 mA, I_PD=340.0 uA, P_LD=76.35 mW. WperA=224.6
RB 405, March 22, 2017:  I_LD=69.99 mA, I_PD=981 uA, P_LD=40.15 mW. WperA=40.93

### CITATION: ,LidkeLab, 2017.

