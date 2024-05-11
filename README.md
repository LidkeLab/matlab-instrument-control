# matlab-instrument-control
MATLAB Instrument Control (MIC) is a collection of MATLAB classes for automated data collection on complex, multi-component custom built microscopes.

MIC software package uses object-oriented programming where a class defines the capabilities of each instrument. Each instrument class inherits from a common MIC abstract class and therefore has a basic common interface. Common component types (lasers, camera, etc.) have their own further abstract sub-classes to give common interfaces and to facilitate the development of control classes for specific new instruments. Use of the MATLAB environment allows immediate access to data and image analysis even during data collection.  Proficient MATLAB users can also easily extend or modify any of these control classes. 

## Class Structure of MIC
<p align="center"><img src="ClassStructure.png" width="80%" height="80%"></p>


## Common Features
Each of the instrument components in MIC have export methods, unit tests and graphical user interfaces with a common format.

### Export state method
The current state of the individual instrument can be obtained using the function `exportState`. The output of the `exportState` function is organized as Attributes, Data and Children.  

Example: 
```
[Attributes, Data, Children] = MIC_TIRFLaser488.exportState()
```
`Attributes` is a structure with fields carrying information on the current state of the instrument. In the example, Attribute is a structure with fields `Power`, `IsOn` and `InstrumentName`. 

`Data` contain any data associated with the instrument.

`Children` contain exportState output from children instrument components (if any) called within the parent instrument class. 


### Unit test method
Each instrument component class in MIC comes equiped with static method for unit test. The `unitTest` function cycles through a series of pre-defined tests, uniquely selected for the corresponding instrument component, outputing success status. Common steps in the unit test method are creating object, turning instrument On/Off, change/modify state of the instrument, output exportState and deleting the object.  

**It is important to know the input arguments needed for calling the class on a particular instrument component before calling the unitTest.** This information can be obtained by performing a `doc` function on corresponding MIC class.

Example: 
```
Success=MIC_TCubeLaserDiode.unitTest('64864827','Power',10,100,1)
```

### Graphical user interface
Instument component classes in MIC also come equiped with graphical user interfaces (gui). Classes inheriting from the same instrument abstract class (e.g. `MIC_LightSourceAbstract`) share a common gui, located in the abstract class folder. For all other instrument components the corresponding gui scripts are stored in the local folder.

Example: 
```
MIC_DynamixelServo.gui
```


## Controlling multi-component instruments
Using MIC, control of multi-component instruments can be acheived by 1) scripting or 2) creating functions or classes that make use of individual components.  

Example of microscope control class:
```
MIC_TIRF_SRCollect()
```

## [MIC Classes](doc/MICclasses.md)
