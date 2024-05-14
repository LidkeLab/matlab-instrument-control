# ExampleInstrument: Example for classes inheriting from
## Description
This class is written to serve as a template for implementing
classes inheriting from MIC_Abstract. This class also serves as a
template for the basic functions such as exportState and unitTest.
## Constructor
Example: obj=MIC_ExampleInstrument()
## Key Functions
`exportState` & `unitTest`
## REQUIREMENTS:
MIC_Abstract.m
MATLAB software version R2016b or later
### CITATION: Farzin Farzam, LidkeLab, 2017.
# gui Graphical User Interface to ExampleInstrument
Must contain gui2properties() and properties2gui() functions
This will be the same for all gui functions
Prevent opening more than one figure for same instrument
