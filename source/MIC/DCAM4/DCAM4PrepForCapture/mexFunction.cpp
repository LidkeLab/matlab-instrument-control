#include "stdafx.h"

// [] = DCAM4PrepForCapture(cameraHandle, nFrames)
// Prepare the camera 'cameraHandle' to capture 'nFrames'.  The primary purpose
// is to allocate memory for the captured images. 
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	int32   nFrames;
	DCAMERR error;
	
	// Grab the inputs from MATLAB and check their types before proceeding.
	if (!mxIsInt32(prhs[0]))
	{
		mexErrMsgTxt("Camera handle must be type INT 32.");
	}
	if (!mxIsInt32(prhs[1]))
	{
		mexErrMsgTxt("Number of frames must be type INT 32.");
	}
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