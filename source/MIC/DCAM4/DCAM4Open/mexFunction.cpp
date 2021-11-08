#include "stdafx.h"

void mexFunction(int nlhs, mxArray * plhs[], int	nrhs, const	mxArray * prhs[]) {
	int	CameraIndex;
	long*   Handle = 0;
	mwSize  outsize[1];
	DCAMERR error;
	DCAMDEV_OPEN	hDCAM;

	// Prepare the MATLAB inputs/outputs.
	CameraIndex = (int)mxGetScalar(prhs[0]);
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	Handle = (long*)mxGetData(plhs[0]);

	// Connect to the camera.
	hDCAM.index = CameraIndex;
	error = dcamdev_open(&hDCAM);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcam_devopen() failed.\n", error);
	}

	// Grab some outputs to return to MATLAB.
	Handle[0] = (long)hDCAM.hdcam;

	return;
}