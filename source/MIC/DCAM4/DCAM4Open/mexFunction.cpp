#include "stdafx.h"

// [handle, error] = DCAM4Open(cameraIndex)
// Open a handle to the camera defined by index 'cameraIndex'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[]) 
{
	int32	     iDevice;
	unsigned long*        mHandle = 0;
	mwSize       outsize[1];
	DCAMERR      error;
	int32*		 outError;
	DCAMDEV_OPEN devopen;

	// Prepare the MATLAB inputs/outputs.
	iDevice = (int32)mxGetScalar(prhs[0]);
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT64_CLASS, mxREAL);
	mHandle = (unsigned long*)mxGetData(plhs[0]);
	plhs[1] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	outError = (int32*)mxGetData(plhs[1]);

	// Connect to the camera.
	memset(&devopen, 0, sizeof(devopen));
	devopen.size = sizeof(devopen);
	devopen.index = iDevice;
	error = dcamdev_open(&devopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcam_devopen() failed.\n", error);
	}

	// Grab some outputs to return to MATLAB.
	mHandle[0] = (unsigned long)devopen.hdcam;
	outError[0] = (int32)error;

	return;
}