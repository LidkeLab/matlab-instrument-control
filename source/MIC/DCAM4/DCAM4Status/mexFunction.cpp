#include "stdafx.h"

// [pStatus] = DCAM4Status(cameraHandle)
// Get the current capture status of the camera. See hex. values prefixed by
// DCAMCAP_STATUS in dcamapi.h.
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	mwSize  outsize[1];
	int32*  pStatus;
	DCAMERR error;

	// Prepare the outputs.
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	pStatus = (int32*)mxGetData(plhs[0]);

	// Call the dcam function.
	handle = (int32)mxGetScalar(prhs[0]);
	error = dcamcap_status((HDCAM)handle, pStatus);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_status() failed.\n", error);
	}

	return;
}