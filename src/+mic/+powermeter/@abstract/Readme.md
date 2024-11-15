# mic.powermeter.abstract

## Description
`mic.powermeter.abstract` is a MATLAB class derived from `mic.abstract` to interface with the power meter (specifically the PM100D model). It enables the measurement of optical power and temperature, and displays this data in real-time through a graphical user interface (GUI).

## Features
- **Real-Time Data Acquisition**: Measures and plots power or temperature data in real time.
- **Flexible Measurement Options**: Users can query the instrument for either 'power' or 'temperature'.
- **Adjustable Display Parameters**: Users can set the period of time displayed on the plot and adjust measurement wavelength.

## Prerequisites
- MATLAB 2014 or higher.
- National Instruments NI-DAQ drivers installed.
- VISA (Virtual Instrument Software Architecture) software installed.

## Installation
1. Ensure that MATLAB and the required toolboxes are installed on your system.
2. Install the National Instruments NI-DAQ driver compatible with your device.
3. Ensure that VISA software is installed for proper communication with the device.
4. Clone this repository or download the `mic.powermeter.abstract.m` file into your MATLAB working directory.

## Properties

### `VisaObj`
Visa Object (Virtual Instrument Standard Architecture = VISA).

### `Power`
Current power.

### `Ask`
The query sent to the instrument. Possible values are `'power'` or `'temp'`.

### `Limits`
Minimum and maximum values of wavelength.

### `Lambda`
Wavelength.

### `T`
Period of time shown on the figure in the GUI.

### `Stop`
Controls plotting behavior. Value `0` stops the plot, while `1` starts the plot (default: `0`).

## Abstract Properties

### `StartGUI`
Represents a property for starting the GUI.
## Usage Example
```matlab
pm = mic.powermeter.abstract('AutoNameHere');
Start the GUI plot. `edit1` and `edit2` are handles to GUI components where the results are displayed.
pm.guiPlot(edit1, edit2);

To export the current state of the power meter:
state = pm.exportState();

Properly shutting down the device:
pm.Shutdown();
```
### Citation: Sajjad Khan, Lidkelab, 2024.

