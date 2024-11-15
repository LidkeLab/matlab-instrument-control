# mic.Triggerscope contains methods to control a Triggerscope.

## Description
This class is designed for the control of a Triggerscope (written for
Triggerscope 3B and 4). All functionality present in the Triggerscope
documentation should be included.

## Public Properties

### `DeviceTimeout`
Triggerscope response timeout in seconds.
**Default:** `1`.

### `SerialPort`
Serial port Triggerscope is connected to.
**Default:** `'COM3'`.

### `SignalStruct`
Structure defining signals on each port.
- See `mic.Triggerscope.triggerArrayGUI()` for formatting or GUI generation of this structure.

### `TriggerMode`
Trigger mode of the Triggerscope.
**Default:** `'Rising'`.
**Note:** This should be set to one of the (hidden property) options `TriggerModeOptions`.

## Dependent Properties (Hidden)

### `SignalArray`
Array of signals to be set on ports when triggered.
**Note:** This property is automatically generated from `SignalStruct`.

## Protected Properties (Set Access, Hidden)

### `GUIParent`
Graphics object parent of the GUI.

### `InstrumentName`
Meaningful name of the instrument.
**Default:** `'Triggerscope'`.

### `TriggerscopeSerialPortDev`
Serial port device for the Triggerscope.

### `ActionPause`
Brief pause made after sending a command in seconds.
**Default:** `0.1`.

### `BaudRate`
Communication rate for Triggerscope.
**Default:** `115200`.

### `DataBits`
Number of bits per serial communication character.
**Default:** `8`.

### `Terminator`
Serial communication command terminator.
**Default:** `'LF'`.

### `CommandList`
List of commands present in the Triggerscope documentation.

### `TriggerModeOptions`
List of trigger modes from the Triggerscope documentation.
**Options:** `'Rising'`, `'Falling'`, `'Change'`.
**Note:** Changing the order of this list may break class functionality.

### `DACResolution`
Resolution of the DAC channels in bits.
**Default:** `16`.

### `IOChannels`
Number of TTL/DAC channels.
**Default:** `16`.

### `VoltageRangeOptions`
List of voltage ranges in Volts as a 5x2 numeric array.
**Default:**  [0, 5; 0, 10; -5, 5; -10, 10; -2.5, 2.5]

## Methods

### Constructor

#### `Triggerscope(SerialPort, DeviceTimeout, AutoConnect)`
Creates an instance of the `Triggerscope` class.
- **Inputs:**
- `SerialPort`: Serial port the Triggerscope is connected to.
- `DeviceTimeout`: Response timeout for the device (optional).
- `AutoConnect`: Boolean indicating whether to automatically connect to the Triggerscope (optional).

### Public Methods

#### `get.SignalArray()`
Retrieves the `SignalArray` dependent property.
- Converts `SignalStruct` into a numeric array representing signals for TTL/DAC ports.

#### `updateActivityDisplay(obj, ~, ~)`
Updates the GUI activity display message when `ActivityMessage` changes.

#### `updateConnectionStatus(obj, ~, ~)`
Updates GUI controls based on changes in the `IsConnected` property.

#### `delete()`
Destructor for the `mic.Triggerscope` class instance.

#### `connectTriggerscope()`
Connects to the Triggerscope (implementation not shown).

#### `disconnectTriggerscope()`
Disconnects the Triggerscope (implementation not shown).

#### `[Response] = executeCommand(obj, Command)`
Executes a command on the Triggerscope (implementation not shown).

#### `[Response] = executeArrayProgram(obj, CommandSequence, FastMode)`
Executes an array program on the Triggerscope (implementation not shown).

#### `[CommandSequence] = generateArrayProgram(obj, NLoops, Arm)`
Generates an array program for the Triggerscope (implementation not shown).

#### `setDefaults()`
Sets default settings for the Triggerscope (implementation not shown).

#### `setDACRange(obj, DACIndex, Range)`
Sets the range for a specified DAC channel (implementation not shown).

#### `setDACVoltage(obj, DACIndex, Voltage)`
Sets the voltage for a specified DAC channel (implementation not shown).

#### `setTTLState(obj, TTLIndex, State)`
Sets the state of a specified TTL channel (implementation not shown).

#### `exportState()`
Exports the current state of the Triggerscope (implementation not shown).

#### `gui(obj, GUIParent)`
Launches the GUI for the Triggerscope (implementation not shown).

#### `triggerArrayGUI(obj, GUIParent)`
Launches a GUI for configuring trigger arrays (implementation not shown).

#### `reset()`
Resets the Triggerscope (implementation not shown).

#### `funcTest()`
Runs a functional test of the Triggerscope (implementation not shown).

### Protected Methods

#### `writeCommand(obj, Command)`
Sends a command to the Triggerscope (implementation not shown).

#### `[Response] = readResponse(obj)`
Reads a response from the Triggerscope (implementation not shown).

### Hidden Methods

#### `[VoltageRangeIndex] = selectVoltageRange(obj, Signal)`
Selects the appropriate voltage range for a given signal (implementation not shown).

### Static Hidden Methods

#### `convertLogicalToStatus(Logical, CharOptions)`
Converts a logical value to a string status.
- **Inputs:**
- `Logical`: Scalar logical value.
- `CharOptions`: Cell array of two strings corresponding to true and false values.

#### `[TriggerModeInt] = convertTriggerStringToInt(TriggerModeString)`
Converts a string trigger mode to an integer index.

#### `[ToggleSignal] = generateToggleSignal(TriggerSignal, SignalPeriod, TriggerModeInt)`
Generates a toggle signal (implementation not shown).

#### `[OutputSignal] = toggleLatch(ToggleSignal, InPhase)`
Toggles a latch signal (implementation not shown).

#### `[BitLevel] = convertVoltageToBitLevel(Voltage, Range, Resolution)`
Converts a voltage to a bit level (implementation not shown).

EXAMPLE USAGE:
TS = mic.Triggerscope('COM3', [], true);
This will create an instance of the class and automatically
attempt to connect to serial port COM3.

## REQUIREMENTS:
Triggerscope 3B, Triggerscope 4 (https://arc.austinblanco.com/)
connected via an accessible serial port
MATLAB 2019b or later (for updated serial communications, e.g.,
serialport())
Windows operating system recommended (Unix based systems might
require changes to, e.g., usage/definition of obj.SerialPort,
or perhaps more serious changes)
TeensyDuino serial communication driver installed
http://www.pjrc.com/teensy/serial_install.exe

### Citation: David J. Schodt (Lidke Lab, 2020)

