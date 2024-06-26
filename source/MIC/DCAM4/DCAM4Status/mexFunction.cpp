#include "stdafx.h"

// [pStatus] = DCAM4Status(cameraHandle)
// Get the current capture status of the camera. See hex. values prefixed by
// DCAMCAP_STATUS in dcamapi.h.
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	// Prepare the outputs.
	mwSize outsize[1];
	int32* pStatus;
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	pStatus = (int32*)mxGetData(plhs[0]);

	// Call the dcam function.
	DCAMERR error;
	unsigned long* mHandle;
	HDCAM handle;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	error = dcamcap_status((HDCAM)handle, pStatus);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_status() failed.\n", error);
	}

	return;
}