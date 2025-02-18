# mic.lightsource.CoherentLaser561 Class

## Description
The `mic.lightsource.CoherentLaser561` class is a MATLAB Instrument Class for controlling the Coherent Sapphire Laser 561 via a USB connection. It integrates with additional classes like `NDFilterWheel` and `Shutter` to manage laser power output continuously from 0 to 100 mW, despite the laser controller's minimum power setting of 10 mW.

## Requirements
- MATLAB 2016b or later
- mic.abstract
- mic.lightsource.abstract
- mic.NDFilterWheel
- mic.DynamixelServo
- mic.ShutterTTL

## Installation
Ensure that all required classes (`mic.abstract`, `mic.lightsource,abstract`, `mic.NDFilterWheel`, `mic.DynamixelServo`, `mic.ShutterTTL`) are in your MATLAB path. The laser connects via a specified COM port (e.g., 'COM3').

## Protected Properties

### `InstrumentName`
Descriptive name of the instrument.
**Default:** `'CoherentLaser561'`.

### `Serial`
Serial number of the COM port.

### `FilterWheel`
Object for `mic.NDFilterWheel` to change filters.

### `Shutter`
Object for `mic.ShutterTTL` to control the shutter.

## Protected Properties (Public Get Access)

### `Power`
Currently set output power.

### `PowerUnit`
Unit of power measurement.
**Default:** `'mW'`.

### `MinPower`
Minimum power setting.
**Default:** `10 * 0.0125` (0.0125 is the least transmission factor for the filter wheel).

### `MaxPower`
Maximum power setting.
**Default:** `100`.

### `IsOn`
On or off state of the laser (`0` for OFF, `1` for ON).
**Default:** `0`.

### `LaserStatus`
Status of the laser with the following states:
- `1` = Startup
- `2` = Warmup
- `3` = Standby
- `4` = Laser On
- `5` = Laser Ready
- `6` = Error

### `Busy`
Indicates if the laser is busy (`0` for not busy).
**Default:** `0`.

## Public Properties

### `StartGUI`
Controls whether the GUI is started.

## Key Functions
- **Constructor (`mic.lightsource.oherentLaser561(SerialPort)`):** Initializes the laser on a specified COM port, sets up the filter wheel and shutter, and establishes serial communication.
- **`on()`:** Activates the laser, opening the shutter and setting the laser state to on.
- **`off()`:** Deactivates the laser, closing the shutter and turning the laser off.
- **`setPower(Power_in)`:** Adjusts the laser's output power. This method selects the appropriate filter based on the desired power setting and modifies the laser's power output accordingly.
- **`getCurrentPower()`:** Fetches and displays the current power setting from the laser.
- **`GetStatus()`:** Queries the laser for its current operational status, updating internal status Properties.
- **`delete()`:** Safely terminates the connection to the laser, ensuring all resources are properly released.
- **`exportState()`:** Exports a snapshot of the laser's current settings, including power and operational state.

## Usage Example
```matlab
Create an instance of the Coherent Laser 561 on COM3
CL561 = mic.lightsource.oherentLaser561('COM3');
Set power to 50 mW
CL561.setPower(50);
Turn on the laser
CL561.on();
Turn off the laser
CL561.off();
Delete the object when done
delete(CL561);
```
### CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.

