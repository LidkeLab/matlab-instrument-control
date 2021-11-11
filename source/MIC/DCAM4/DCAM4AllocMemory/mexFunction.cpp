#include "stdafx.h"

// [] = DCAM4AllocMemory(cameraHandle, nFrames)
// Allocate memory for 'cameraHandle' to capture 'nFrames'.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32	handle;
	int32   nFrames;
	DCAMERR error;

	// Grab the inputs from MATLAB and check their types before proceeding.
	handle = (int32)mxGetScalar(prhs[0]);
	nFrames = (int32)mxGetScalar(prhs[1]);

	// Call the dcam function.
	error = dcambuf_alloc((HDCAM)handle, nFrames);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\dcambuf_alloc() failed.\n", error);
	}

	return;
}