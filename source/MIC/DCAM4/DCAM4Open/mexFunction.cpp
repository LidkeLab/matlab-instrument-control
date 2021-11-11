#include "stdafx.h"

// [handle] = DCAM4Open(cameraIndex)
// Open a handle to the camera defined by index 'cameraIndex'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[]) 
{
	int32	     iDevice;
	int32*       handle = 0;
	mwSize       outsize[1];
	DCAMERR      error;
	DCAMDEV_OPEN devopen;

	// Prepare the MATLAB inputs/outputs.
	iDevice = (int32)mxGetScalar(prhs[0]);
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	handle = (long*)mxGetData(plhs[0]);

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
	handle[0] = (int32)devopen.hdcam;

	return;
}