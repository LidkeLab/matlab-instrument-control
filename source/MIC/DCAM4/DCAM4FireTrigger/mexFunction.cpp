#include "stdafx.h"

// [] = DCAM4FireTrigger(cameraHandle)
// Fire a software trigger to begin capturing an image.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	unsigned long* mHandle;
	HDCAM	handle;
	DCAMERR error;

	// Grab the inputs from MATLAB.
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];

	// Call the dcam function.
	error = dcamcap_firetrigger(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_firetrigger failed.\n", error);
	}

	return;
}