# _H5 Class: H5 A collection of static methods for working with HDF5 files

## Description
The `H5` class is designed for handling HDF5 file operations in MATLAB.
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
mic.H5.createFile(File);

Create a new group within the file
mic.H5.createGroup(File, 'Data');

Write data asynchronously to the 'Data' group
mic.H5.writeAsync_uint16(File, 'Data', 'data1', data);

Display the structure of the HDF5 file
h5disp(File);
```
## Key Functions
- **`createFile(File)`:** Creates an empty HDF5 file. If the file already exists, it issues a warning rather than overwriting the existing file.
- **`createGroup(File, Group)`:** Adds a new group to an existing HDF5 file. If the group already exists, the creation process is skipped to avoid duplication.
- **`writeAsync_uint16(File, Group, DataName, Data)`:** Initiates an asynchronous data writing process to a specified group within an HDF5 file. This method allows MATLAB to continue executing other commands while data is being written in the background.
- **`readH5File(FilePath, GroupName)`:** Retrieves data from a specified group within an HDF5 file. This function would be implemented to allow reading of complex datasets stored within the file system.
### CITATION: David James Schodt (LidkeLab, 2018)

