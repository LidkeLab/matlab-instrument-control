# mic.stage3D.abstract Matlab Instrument Abstact Class for all stages Matlab Instrument Class

## Description
This class defines a set of abstract Properties and methods that must
implemented in inheritting classes for all stages devices.
This also provides a simple and intuitive GUI interface.

## Abstract Protected Properties

### `Position`
Represents the current position.

### `PositionUnit`
Units of the position parameter (e.g., `um`/`mm`).
## Constructor
The constructor in each subclass must begin with the following line
inorder to enable the auto-naming functionality:
obj=obj@mic.stage3D.abstract(~nargout);

## REQUIREMENTS:
mic.abstract.m
MATLAB software version R2016b or later

### CITATION: Hanieh Mazloom-Farsibaf  Lidkelab, 2017.

