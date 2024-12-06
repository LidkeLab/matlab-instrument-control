# mic.camera.IRSyringPump Class

## Description
The `mic.camera.IRSyringPump` class extends the `mic.camera.ThorlabsIR` class to include control over a syringe pump during IR imaging sessions. This class is specifically designed for simultaneous operation of a syringe pump and an IR camera, enabling precise timing of fluid delivery relative to image acquisition. It is tailored for use in single-particle tracking (SPT) microscopy applications within Lidke's Lab.

## Requirements
- MATLAB R2016b or later
- mic.camera.abstract.m
- mic.camera.ThorlabsIR
- mic.camera.SyringePump

## Public Properties

### `SP`
Object for `mic.camera.SyringePump` to control the syringe pump.

### `SPwaitTime`
Wait time for the syringe pump to start after the IR camera starts.

### `tIR_end`
Property to check if all devices (Andor, IRCamera, Syringe Pump) work in the correct time order.

## Key Functions
- **Constructor (`mic.camera.IRSyringPump()`):** Initializes the syringe pump and sets default parameters for the IR camera and pump synchronization.
- **`start_sequence()`:** Begins a sequence acquisition with the IR camera and triggers the syringe pump at a specified frame (`SPwaitTime`). This function handles data acquisition, pump activation, and ensures proper timing and synchronization between devices.

## Usage Example
```matlab
Create an instance of the IRSyringe Pump system
irSyringePump = mic.camera.IRSyringPump();

Set the number of frames to acquire
irSyringePump.SequenceLength = 100;

Set the wait time before starting the syringe pump
irSyringePump.SPwaitTime = 50;

Start the sequence acquisition and pump operation
irSyringePump.start_sequence();

Display the acquired data
figure; imagesc(max(irSyringePump.Data, [], 3)); axis image; colormap gray;
title('Max Intensity Projection of Acquired Sequence');
```
### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.

