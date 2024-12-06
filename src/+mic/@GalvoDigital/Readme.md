# mic.GalvoDigital: Matlab instrument class to control Galvo Mirror using digital input

## Description
This class controls the galvo mirror (Cambridge Technology) on
the HSM microscope by using digital signals.  This utilizes a
National Instruments (NI) data acquisition (DAQ) device to adjust
the galvo mirror's angle (Range:[-15, 15])for scanning purposes. It
changes the angle of the galvo mirror to scan the sample. The position
of the galvo mirror is determined by a 16-bit digital signal
(Word property). This signal can represent integer values ranging
from 0 to 65535, corresponding to the full range of movement of
the mirror.  The galvo mirror is driven by 16 digital channels
configured on the NI DAQ device. These channels send the digital
word to control the mirror's position.

## Class Properties

### Protected Properties

- **`InstrumentName`**
- **Description**: Descriptive name for the instrument.
- **Type**: String
- **Default**: `'GalvoDigital'`

- **`DAQsessionAngle`**
- **Description**: NI card session used to control the angle of the galvo mirror.
- **Type**: Session Object

- **`DAQsessionEnable`**
- **Description**: NI card session used to enable or disable the movement of the galvo mirror.
- **Type**: Session Object

### Public Properties

- **`Word`**
- **Description**: 16-bit integer value sent to the channels to control the galvo.
- **Type**: Integer
- **Range**: `[0, 65535]`

- **`Range`**
- **Description**: The range of travel for the galvo mirror, specified in degrees from the center.
- **Type**: Float
- **Default**: `15`

- **`Sequence`**
- **Description**: Sequence of 16-bit words used for a full High-Speed Mirror (HSM) scan.
- **Type**: Array of Integers

- **`NIDevice`**
- **Description**: Identity of the NI card being used for control.
- **Type**: String or Device Object

- **`Angle`**
- **Description**: Current angle of the galvo mirror in degrees.
- **Type**: Float
- **Range**: `[-15, 15]`

- **`ClockConnection`**
- **Description**: Variable for managing scan clock connections.
- **Type**: Connection Object or Variable

- **`idxClockConnection`**
- **Description**: Index of the scan clock connection.
- **Type**: Integer

- **`IsEnable`**
- **Description**: Flag indicating if the galvo mirror is enabled for movement.
- **Type**: Boolean
- **Default**: `0`

- **`Voltage`**
- **Description**: Current voltage applied to the galvo system.
- **Type**: Float

- **`StartGUI`**
- **Description**: Option to pop up a GUI upon object creation.
- **Type**: Boolean

### Scanning Parameters

- **`N_Step`**
- **Description**: Number of steps per scan.
- **Type**: Integer

- **`N_Scan`**
- **Description**: Number of scans to perform.
- **Type**: Integer

- **`StepSize`**
- **Description**: Size of each scan step.
- **Type**: Float

- **`Offset`**
- **Description**: Starting position for the scan.
- **Type**: Float

### Constant Properties

- **`RWpin`**
- **Description**: Pin used for the read/write operation in the system.
- **Type**: String
- **Default**: `'line24'`

- **`CSpin`**
- **Description**: Pin used for chip select operations.
- **Type**: String
- **Default**: `'line25'`

- **`LDACpin`**
- **Description**: Pin used for load digital-to-analog conversion.
- **Type**: String
- **Default**: `'line26'`

- **`CLRpin`**
- **Description**: Pin used to clear data.
- **Type**: String
- **Default**: `'line27'`

- **`Wordpin`**
- **Description**: Pin used to send 16-bit words.
- **Type**: String
- **Default**: `'line0:15'`

## Constructor
Example: obj=mic.GalvoDigital('Dev1','Port0/Line0:31');

## Key Funtions:
delete, clearSession, enable, disable, reset, setSequence, angle2word, word2angle, get.Angle, setAngle, exportState, set.Voltage, get.Voltage,G. updateGui

## REQUIREMENTS:
mic.abstract.m
MATLAB software version R2020a or later
Data Acquisition Toolbox
MATLAB NI-DAQmx driver installed via the Support Package Installer
Data Acquisition Toolbox Support Package for National Instruments
NI-DAQmx Devices: This add-on can be installed from link:
https://www.mathworks.com/matlabcentral/fileexchange/45086-data-acquisition-toolbox-support-package-for-national-instruments-ni-daqmx-devices

### CITATION: Hanieh Mazloom-Farsibaf, Lidkelab, 2017.

