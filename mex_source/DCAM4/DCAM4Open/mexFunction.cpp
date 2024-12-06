#include "stdafx.h"

// [handle] = DCAM4Open(cameraIndex)
// Open a handle to the camera defined by index 'cameraIndex'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[]) 
{
	// Prepare the MATLAB inputs/outputs.
	int32 iDevice;
	mwSize outsize[1];
	unsigned long* mHandle = 0;
	iDevice = (int32)mxGetScalar(prhs[0]);
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT64_CLASS, mxREAL);
	mHandle = (unsigned long*)mxGetData(plhs[0]);

	// Connect to the camera.
	DCAMDEV_OPEN devopen;
	DCAMERR error;
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

	return;
}