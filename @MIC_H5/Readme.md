# MIC_H5 A collection of static methods for working with HDF5 files
See individual methods for details.
doc MIC_H5
EXAMPLE:  create a new file, and new group and write data
File='TestFile.h5';
data=uint16(2^16*rand(256,512,10));
MIC_H5.createFile(File)
MIC_H5.createGroup(File,'Data')
MIC_H5.writeAsync_uint16(File,'Data','data1',data)
h5disp(File)
REQUIRES:
h5Write_Async.mex64
MATLAB 2011a or newer
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
