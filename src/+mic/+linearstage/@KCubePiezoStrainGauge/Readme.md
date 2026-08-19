# mic.linearstage.KCubePiezoStrainGauge Matlab Instrument Control Class
for the ThorLabs KPC101 KCube Piezo Strain Gauge controller.

## Description
This class controls a linear piezo stage using the Thorlabs KPC101,
an integrated piezo controller + strain gauge reader in a single
KCube with a single serial number (unlike the KPZ101+KSG101 pair
handled by mic.linearstage.KCubePiezo).  It uses the Thorlabs
Kinesis C-API via pre-compiled mex files (Kinesis_KPC_*).

The device is driven in closed loop: positions are commanded and
read back through the built-in strain gauge feedback, so no manual
Slope/Offset calibration is required.  The C API expresses position
as a percentage of maximum travel (WORD 0-32767 = 0-100%); this
class converts to/from microns using the max travel reported by
the device.

## Protected Properties

### `PositionUnit`
Units of the position parameter.
**Default:** `'um'`.

### `CurrentPosition`
Current position of the device.
**Default:** `0`.

### `MinPosition`
Lower limit position.
**Default:** `0`.

### `MaxPosition`
Upper limit position in microns.  Read from the device at
construction via Kinesis_KPC_GetMaximumTravel.
**Default:** `20`.

### `Axis`
Stage axis (options: `X`, `Y`, or `Z`).

### `SerialNoKPC101`
Serial number of the KCube Piezo Strain Gauge controller.

### `InstrumentName`
Name of the instrument.
**Default:** `'KCubePiezoStrainGauge'`.

### `WaitTime`
Time to wait before returning after a `setPosition` command (in seconds).
**Default:** `0`.

## Key Functions
- **Constructor (`mic.linearstage.KCubePiezoStrainGauge(SerialNoKPC101, AxisLabel)`):**
Opens the device, reads the maximum travel, sets closed loop mode,
zeroes the strain gauge (~30 s) and centers the stage.
- **`openDevices()`:** Opens the connection with the Kinesis C-API.
- **`closeDevices()`:** Stops polling and closes the connection.
- **`zeroStrainGauge()`:** Runs the device zeroing routine and waits
for it to finish (required for accurate closed loop positions).
- **`setPosition(Position)`:** Moves the stage to a position in microns.
- **`getPosition()`:** Reads the current position in microns from the
strain gauge feedback.
- **`shutdown()`:** Closes the device.
- **`exportState()`:** Exports the current operational state.

## Usage Example
PZ=mic.linearstage.KCubePiezoStrainGauge('113251934','Z')
PZ.gui()
PZ.setPosition(10);

## Kinesis Setup:
Recommended one-time setup in the Kinesis Software GUI before
using this class:
1-set Loop Mode to "Closed Loop" (Control tab: Feedback Loop Settings)
2-set Maximum Travel to match the actuator (e.g. 20 um for NanoMax 300)
3-persist settings to the device (Save to Startup tab)
Kinesis must be disconnected/closed before using this class
(the device allows only one connection).

## REQUIRES:
mic.abstract.m
mic.linearstage.abstract.m
Precompiled set of mex files Kinesis_KPC_*.mexw64
(compile with mex_source/MIC/buildKPCMex.m)
The following dll must be in system path or same directory as mex files:
Thorlabs.MotionControl.KCube.PiezoStrainGauge.dll
Thorlabs.MotionControl.DeviceManager.dll

### Citation: Mahsa Habibi, LidkeLab, 2026.

