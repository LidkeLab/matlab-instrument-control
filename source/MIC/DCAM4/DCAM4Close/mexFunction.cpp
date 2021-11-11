#include "stdafx.h"

// [] = DCAM4Close(cameraHandle)
// Release the handle defined by the int32 'cameraHandle'.
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	DCAMERR error;
	
	// Validate inputs.
	if (!mxIsInt64(prhs[0]))
	{
		mexErrMsgTxt("Camera handle must be type INT 64.");
	}

	// Close the camera.
	handle = (int32)mxGetScalar(prhs[0]);
	error = dcamdev_close((HDCAM)handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcam_devclose() failed.\n", error);
	}

	return;
}