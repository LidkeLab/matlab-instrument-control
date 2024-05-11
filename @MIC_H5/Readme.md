# # MIC_H5 Class: MIC_H5 A collection of static methods for working with HDF5 files
## Description
The `MIC_H5` class is designed for handling HDF5 file operations in MATLAB.
It includes static methods to create files, write data asynchronously, and manage data groups within HDF5 files.
This class leverages MATLAB's capabilities to interact with large datasets efficiently.
## Requirements
- MATLAB 2011a or later
- `h5Write_Async.mex64` for asynchronous writing operations
## Usage Example
The following example demonstrates how to create an HDF5 file, add a group, and write data asynchronously:
```matlab
Define the file and data
File = 'TestFile.h5';
data = uint16(2^16 * rand(256, 512, 10));
Create a new HDF5 file
MIC_H5.createFile(File);
Create a new group within the file
MIC_H5.createGroup(File, 'Data');
Write data asynchronously to the 'Data' group
MIC_H5.writeAsync_uint16(File, 'Data', 'data1', data);
Display the structure of the HDF5 file
h5disp(File);
```
## Key Functions
- **`createFile(File)`:** Creates an empty HDF5 file. If the file already exists, it issues a warning rather than overwriting the existing file.
- **`createGroup(File, Group)`:** Adds a new group to an existing HDF5 file. If the group already exists, the creation process is skipped to avoid duplication.
- **`writeAsync_uint16(File, Group, DataName, Data)`:** Initiates an asynchronous data writing process to a specified group within an HDF5 file. This method allows MATLAB to continue executing other commands while data is being written in the background.
- **`readH5File(FilePath, GroupName)`:** Retrieves data from a specified group within an HDF5 file. This function would be implemented to allow reading of complex datasets stored within the file system.
### CITATION: David James Schodt (LidkeLab, 2018)
# Extracts contents of an h5 file into H5Structure.
This method will extract the Data and Attributes from a group
named GroupName in the .h5 file specified by FilePath.
Examples:
H5Structure = readH5File('C:\file.h5') will extract all
contents of file.h5 and store them in H5Structure.
H5Structure = readH5File('C:\file.h5', 'Laser647') will extract
contents of the group 'Laser647' from file.h5 given only
the group name.
H5Structure = readH5File('C:\file.h5', ...
'/Channel01/Zposition001/Laser647') will extract contents
of the group 'Laser647' from file.h5 given a full group
path.
INPUTS:
FilePath: String containing the path to the .h5 file of interest.
GroupName: (optional) Name of a specific group in the .h5 file to be
extracted.
OUTPUTS:
H5Structure: Structured array containing the information extracted from
the .h5 file at FilePath.
REQUIRES:
MATLAB 2016b or later
CITATION:
Created by:
David James Schodt (LidkeLab, 2018)
Ensure that FilePath points to a valid file.
NOTE: == 2 means a file indeed exists at FilePath
