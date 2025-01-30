# mic.Attenuator Class

## Description
The `mic.Attenuator` class in MATLAB is designed for controlling Liquid Crystal Optical Beam Shutters / Variable Attenuators
optical attenuators (example: Thorlabs LCC1620A, Liquid Crystal Optical Shutter, 420 - 700 nm ) through an
NI DAQ card, providing precise adjustments to the attenuation level. This class integrates
seamlessly with MATLAB's Data Acquisition Toolbox and is part of a broader suite of instrument control classes.
The power meter can be used to callibrate the attenuator.
Note that the attenuator does not block the beam completely. The laser damage threshold for this
attenuator is 1 W/cm2. The current from the LED driver
is regulated by the analog voltage output (0 to 5 V) of a NI DAQ card. The Constructor requires the Device and Channel details.

## Features
- Full control over optical attenuation settings.
- Calibration capabilities using a power meter.
- Integration with NI DAQ for voltage control over the attenuator.
- Suitable for wavelengths from 420-700 nm.
- Protection against laser damage with a threshold of 1 W/cm2.

## Requirements
- MATLAB 2020a or higher.
- Data Acquisition Toolbox.
- MATLAB NI-DAQmx driver installed via the Support Package Installer.
- An NI DAQ device.
- Data Acquisition Toolbox Support Package for National Instruments
NI-DAQmx Devices: This add-on can be installed from link:
https://www.mathworks.com/matlabcentral/fileexchange/45086-data-acquisition-toolbox-support-package-for-national-instruments-ni-daqmx-devices

## Class Properties
- `Transmission`: The current transmission setting (% of maximum).
- `MinTransmission`, `MaxTransmission`: Minimum and maximum transmission settings.
- `PowerBeforeAttenuator`: Power measured before the attenuator, useful for calibration.

### Protected Properties
- **`InstrumentName`**:
- **Description**: Descriptive name of the instrument.
- **Type**: String
- **Default**: `'Attenuator'`
- **`TransmissionUnit`**:
- **Description**: The unit for representing transmission values.
- **Type**: String
- **Default**: `'Percent'`
- **`V_100`**:
- **Description**: Voltage at which the current starts to drop from 100% transmission.
- **Type**: Numeric
- **Default**: `0`
- **`V_0`**:
- **Description**: Voltage to set for completely on (full transmission).
- **Type**: Numeric
- **Default**: `5`
- **`DAQ`**:
- **Description**: National Instruments Data Acquisition (NI DAQ) session object used for controlling the attenuator.
- **Type**: Object
- **Default**: `[]` (empty)

### Public Properties
- **`StartGUI`**:
- **Description**: Flag for starting a graphical user interface (GUI) when an object of this class is created.
- **Type**: Boolean or other indicator type

## Methods
### `mic.Attenuator(NIDevice, AOChannel)`
Constructor for creating an instance of `mic.Attenuator`. Requires NI device and analog output channel specifications.

### `loadCalibration(Name)`
Loads a calibration file specified by `Name`, which adjusts the attenuation curve based on previously gathered data.

### `setTransmission(Transmission_in)`
Sets the desired transmission level, adjusting the voltage output to the attenuator accordingly.

### `calibration(NIDevice, AOChannel, BeforeAttenuator, Name)`
Calibrates the attenuator using a reference power measurement obtained via `findMaxPower` and saves the calibration data under the specified `Name`.

### `shutdown()`
Safely shuts down the attenuator, setting the transmission to zero.

## Usage Example
```matlab
Initialize the attenuator with specific NI DAQ settings
attenuator = mic.Attenuator('Dev1', 'ao1');

Load calibration data
attenuator.loadCalibration('CalibrationFile.mat');

Set transmission to 50%
attenuator.setTransmission(50);

Shutdown the attenuator
attenuator.shutdown();
```
### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

