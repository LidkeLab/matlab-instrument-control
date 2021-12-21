#include "stdafx.h"

// [] = DCAM4AllocMemory(cameraHandle, nFrames)
// Allocate memory for 'cameraHandle' to capture 'nFrames'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	unsigned long* mHandle;
	HDCAM	handle;
	int32   nFrames;
	DCAMERR error;

	// Grab the inputs from MATLAB and check their types before proceeding.
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	nFrames = (int32)mxGetScalar(prhs[1]);

	// Call the dcam function.
	error = dcambuf_alloc(handle, nFrames);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_alloc() failed.\n", error);
	}

	return;
}