#include "stdafx.h"

// [] = DCAM4ReleaseMemory(cameraHandle)
// Release memory allocated for 'cameraHandle'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	// Grab the inputs from MATLAB and check their types before proceeding.
	unsigned long* mHandle;
	HDCAM	handle;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];

	// Release the capturing buffer allocated by DCAM4AllocMemory().
	DCAMERR error;
	error = dcambuf_release(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_release() failed.\n", error);
	}

	return;
}