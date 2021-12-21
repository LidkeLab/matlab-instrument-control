#include "stdafx.h"

// [] = DCAM4Close(cameraHandle)
// Release the handle defined by the int32 'cameraHandle'.
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	unsigned long* mHandle;
	HDCAM	       handle;
	DCAMERR        error;

	// Close the camera.
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	error = dcamdev_close(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcam_devclose() failed.\n", error);
	}

	return;
}