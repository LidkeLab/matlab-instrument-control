# matlab-instrument-control
MATLAB Instrument Control (MIC) is a collection of MATLAB classes for automated data collection on complex, multi-component custom built microscopes.

MIC software package uses object-oriented programming where a class defines the capabilities of each instrument. Each instrument class inherits from a common MIC abstract class and therefore has a basic common interface. Common component types (lasers, camera, etc.) have their own further abstract sub-classes to give common interfaces and to facilitate the development of control classes for specific new instruments. Use of the MATLAB environment allows immediate access to data and image analysis even during data collection.  Proficient MATLAB users can also easily extend or modify any of these control classes. 

<!-- ## Class Structure of MIC -->
<!-- <p align="center"><img src="ClassStructure.png" width="80%" height="80%"></p> -->

## Class Structure Overview

 The structure of MIC is designed to ensure scalability and easy integration of new hardware.

### MIC_Abstract
- Defines basic functions and properties common across all classes.
  - `MIC_Abstract`

### MIC_LightSource_Abstract
- MIC_LightSource_Abstract is the base class for all light sources, defining common functions and properties.
  - `MIC_CoherentLaser561`
  - `MIC_CrystaLaser561`
  - `MIC_CrystaLaser405`
  - `MIC_DHOMLaser532`
  - `MIC_MPB_Laser`
  - `MIC_RebelStarLED`
  - `MIC_VortranLaser488`
  - `MIC_TubeLaserDiode`
  - `MIC_TIRFLaser488`
  - `MIC_HSM_Laser488`
  - `MIC_IX71_Lamp01`

### MIC_Camera_Abstract
- MIC_Camera_Abstract Base class for all camera-related classes, defining common functions and properties.
  - `MIC_AndorCamera`
  - `MIC_HamamatsuCamera`
  - `MIC_IMGSourceCamera`
  - `MIC_ThorlabsIR`

### MIC_LinearStage_Abstract
- MIC_LinearStage_Abstract is abstract class for linear stages.
  - `MIC_MCLMicroDrive`
  - `MIC_KCubePiezo`
  - `MIC_TCubePiezo`

### MIC_3DStage_Abstract
- MIC_3DStage_Abstract is abstract class for 3D stages.
  - `MIC_MCLNanoDrive`
  - `MIC_NanoMaxPiezos`
  
### MIC_PowerMeter_Abstract
- MIC_PowerMeter_Abstract creates an interface with the power meter
  - `MIC_PM100D`

This class structure is integral to the functioning and expansion of our imaging capabilities, facilitating easy maintenance and upgrading of the imaging system components.


See [MIC Classes](doc/MICclasses.md) for the complete detailed list.

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

## Installation Notes
Each instrument needs be controlled by its own drivers, which must be installed on the system. In many cases manufacturer's software development kit (SDK) is provided to create custom applications for controlling instrument.With the installation of the drivers, either the header file or dynamic-link library is installed. For example, the `MIC_MCLNanoDrive` class controls the Mad City Labs 3D Piezo stage and requires the `madlib.h` header file. During the first initialization of this class on a system, users are prompted to direct the class to the `madlib.h` header file, typically located in `C:\Program Files\Mad City Labs\NanoDrive`. 

Similarly, the `MIC_MCLMicroDrive` class controls the Mad City Labs Micro Stage and requires the `MicroDrive.dll` dynamic-link library. The first time this class is used on a given computer, the user will be prompted to select the location of `MicroDrive.dll`. On a Windows machine, this is typically placed by default in `C:\Program Files\Mad City Labs\MicroDrive\MicroDrive.dll` during the installation process (installation files provided by MCL).