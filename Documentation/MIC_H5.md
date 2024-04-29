
MIC_H5 A collection of static methods for working with HDF5 files
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
