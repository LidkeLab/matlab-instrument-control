# MIC_Attenuator Class

## Description
The `MIC_Attenuator` class in MATLAB is designed for controlling optical attenuators through an
NI DAQ card, providing precise adjustments to the attenuation level. This class integrates
seamlessly with MATLAB's Data Acquisition Toolbox and is part of a broader suite of instrument control classes.
You can also use the power meter to callibrate the attenuator for a new setup and then use it.
Note that the attenuator does not block the beam completely. The laser damage threshold for this
attenuator is 1 W/cm2. The operation wavelength is 420-700 nm. The current from the LED driver
is regulated by the analog voltage output (0 to 5 V) of a NI DAQ card. The Constructor requires the Device and Channel details.

## Features
- Full control over optical attenuation settings.
- Calibration capabilities using a power meter.
- Integration with NI DAQ for voltage control over the attenuator.
- Suitable for wavelengths from 420-700 nm.
- Protection against laser damage with a threshold of 1 W/cm2.

## Requirements
- MATLAB 2014 or higher.
- Data Acquisition Toolbox.
- MATLAB NI-DAQmx driver installed via the Support Package Installer.
- An NI DAQ device.

## Properties
- `Transmission`: The current transmission setting (% of maximum).
- `MinTransmission`, `MaxTransmission`: Minimum and maximum transmission settings.
- `PowerBeforeAttenuator`: Power measured before the attenuator, useful for calibration.

## Methods
### `MIC_Attenuator(NIDevice, AOChannel)`
Constructor for creating an instance of `MIC_Attenuator`. Requires NI device and analog output channel specifications.

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
attenuator = MIC_Attenuator('Dev1', 'ao1');

Load calibration data
attenuator.loadCalibration('CalibrationFile.mat');

Set transmission to 50%
attenuator.setTransmission(50);

Shutdown the attenuator
attenuator.shutdown();
```
### CITATION: Mohamadreza Fazel, Lidkelab, 2017.

