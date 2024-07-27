#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include "hdf5.h"
#include <process.h>

#ifndef max
//! not defined in the C standard used by visual studio
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
//! not defined in the C standard used by visual studio
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif
#define pi 3.141592f


char filename[MAX_PATH];
char DATASET[MAX_PATH];
char group[MAX_PATH];

int NDims;
int Size[5] = {1,1,1,1,1};
unsigned short * dataMATLAB;
double IsSaving = 0;
int CompressionLevel = 5;
int IsCopied = 0;    

void Save(void *p){

	//mexPrintf("Entering Save...\n");

	unsigned short * data;
	int elemsize = 2;
	int Nelem = 1; 
	hsize_t dims[5] = {0,0,0,0,0};
	hsize_t chunk_dims[5] = {0,0,0,0,0};
	
	hid_t           file, space, dset, dcpl,gid;    /* Handles */
	herr_t          status;
	
	for (int n = 0; n < NDims; n++)
		Nelem = Nelem*Size[n];


	//mexPrintf("NDims %d Nelem %d\n",NDims, Nelem);

	//This does the fliplr() operation needed to convert column major (MATLAB) to row-major (HDF5)
	for (int n = 0; n < NDims; n++)
		dims[n] = (const hsize_t)Size[NDims-n-1];


	//This is make chunks in the size of images
	chunk_dims[0] = 1; //chunk size in largest dimension
	for (int n = 1; n < NDims; n++)
		chunk_dims[n] = (const hsize_t)Size[NDims - n - 1];

	//copy data to local heap
	data = (unsigned short *)calloc(Nelem, sizeof(unsigned short));
	memcpy(data, dataMATLAB, Nelem*sizeof(unsigned short));
	IsCopied = 1;

	/*
	* Create a new file using the default properties.
	*/
	//mexPrintf("filename %s\n", filename);

	file = H5Fopen(filename, H5F_ACC_RDWR, H5P_DEFAULT);
	//mexPrintf("file %d\n", file);
	/*
	* Open group if nessesary using the default properties.
	*/
	//mexPrintf("group %s\n", group);
	gid = H5Gopen(file, group, H5P_DEFAULT);
	//mexPrintf("gid %d\n", gid);
	
	
	/*
	* Create dataspace.  Setting maximum size to NULL sets the maximum
	* size to be the current size.
	*/
	space = H5Screate_simple(NDims, dims, NULL);


	/*
	* Create the dataset creation property list, add the gzip
	* compression filter and set the chunk size.
	*/
	dcpl = H5Pcreate(H5P_DATASET_CREATE); 
	
	status =  H5Pset_chunk(dcpl, NDims, chunk_dims);

	status = H5Pset_deflate(dcpl, CompressionLevel);
	//mexPrintf("Deflate Status: %d\n", status);
	
	
	/*
	* Create the dataset.
	*/
	//mexPrintf("DATASET %s\n", DATASET);
	dset = H5Dcreate(gid, DATASET, H5T_NATIVE_USHORT, space, H5P_DEFAULT, dcpl,
		H5P_DEFAULT);
	//mexPrintf("dset %d\n", dset);
	/*
	* Write the data to the dataset.
	*/
	status = H5Dwrite(dset, H5T_NATIVE_USHORT, H5S_ALL, H5S_ALL, H5P_DEFAULT, (const void *)data);
	//mexPrintf("Write Status: %d\n", status);
	/*
	* Close and release resources.
	*/
	status = H5Pclose(dcpl);
	status = H5Gclose(gid);
	status = H5Dclose(dset);
	status = H5Sclose(space);
	status = H5Fclose(file);

	free(data);
	IsSaving = 0;
	return;
}



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {
/*!
 *  \brief Entry point in the code for Matlab.  Equivalent to main().
 *  \param nlhs number of left hand mxArrays to return
 *  \param plhs array of pointers to the output mxArrays
 *  \param nrhs number of input mxArrays
 *  \param prhs array of pointers to the input mxArrays.
 */
	

	//check for required inputs, correct types, and dimensions
	//1D vectors still return 2D

	if ((nrhs == 0) || (IsSaving)) {
		plhs[0] = mxCreateDoubleScalar(IsSaving);
		return;
	}

	if (nrhs < 4)
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel)");

	//validate input values(this section better not be blank!)

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel).  First input must be character array.");

	if (!mxIsClass(prhs[1], "char"))
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel).  Second input must be character array.");

	if (!mxIsClass(prhs[2], "char"))
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel).  Third input must be character array.");

	if (!mxIsClass(prhs[3], "uint16"))
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel).  Fourth input must be uint16.");

	if ((nrhs == 5)) if (!mxIsScalar(prhs[4]))
		mexErrMsgTxt("Proper Usage: [Err]=H5Write_Async(File,Group,DatSetName,Data,CompressionLevel).  Fifth input must be a scalar 0-9.");

	//declare all vars

	

	
	int  i;        
	htri_t          avail;
	herr_t          status;
	unsigned int filter_info;

	NDims = mxGetNumberOfDimensions(prhs[3]);
	const size_t *Dims = mxGetDimensions(prhs[3]);

	if (NDims>5)
		mexErrMsgTxt("Data must be 5D or less.");

	//retrieve all inputs
	
	/* Get Filename: Second input argument. */
	filename[0] = '\0';
	if (mxGetString(prhs[0], filename, MAX_PATH)) {
		if (filename[0] == '\0')
			mexErrMsgTxt("FILENAME should be a character array.");
		else
			mexErrMsgTxt("The given filename is too long.");
	}

	IsSaving = 1;

	mxGetString(prhs[2], DATASET, MAX_PATH);
	mxGetString(prhs[1], group, MAX_PATH);

	dataMATLAB = (unsigned short *)mxGetData(prhs[3]);

	if ((nrhs ==5))
		CompressionLevel = (int)mxGetScalar(prhs[4]);
	
	for (i = 0; i < NDims; i++) Size[i] = Dims[i];

	//do stuff
	

	//Check for gzip

	avail = H5Zfilter_avail(H5Z_FILTER_DEFLATE);
	if (!avail) {
		mexPrintf("gzip filter not available.\n");
		
	}

	status = H5Zget_filter_info(H5Z_FILTER_DEFLATE, &filter_info);
	if (!(filter_info & H5Z_FILTER_CONFIG_ENCODE_ENABLED) ||
		!(filter_info & H5Z_FILTER_CONFIG_DECODE_ENABLED)) {
		mexPrintf("gzip filter not available for encoding and decoding.\n");
	}

	mexPrintf("Starting Save...\n", status);

	IsCopied = 0;
	//Save(NULL); //run single threaded. 
	_beginthread(Save, 0, NULL); //use this line for new thread


	
	while (!IsCopied){
		//mexPrintf("IsCopied %d\n", IsCopied);

		Sleep(10);
	}


	plhs[0] = mxCreateDoubleScalar(0);


	
	

	return;   
 }