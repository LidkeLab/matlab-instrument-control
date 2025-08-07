
#include "stdafx.h"

// [] = DCAM4AllocMemory(cameraHandle, nFrames)
// Allocate memory for 'cameraHandle' to capture 'nFrames'.
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	/*!
	*  \brief Entry point in the code for Matlab.  Equivalent to main().
	*  \param nlhs number of left hand mxArrays to return
	*  \param plhs array of pointers to the output mxArrays
	*  \param nrhs number of input mxArrays
	*  \param prhs array of pointers to the input mxArrays.
	*/

	// Grab the inputs from MATLAB and check their types before proceeding.
	unsigned long* mHandle;
	HDCAM handle;
	int32 nFrames;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	nFrames = (int32)mxGetScalar(prhs[1]);

	// Call the dcam function.
	DCAMERR error;
	error = dcambuf_alloc(handle, nFrames);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_alloc() failed.\n", error);
	}

	return;
}


