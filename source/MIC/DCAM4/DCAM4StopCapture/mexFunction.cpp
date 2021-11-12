#include "stdafx.h"

// [] = DCAM4StopCapture(cameraHandle)
// Stop capturing started by DCAM4StartCapture().
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32	handle;
	DCAMERR error;

	// Grab the inputs from MATLAB.
	handle = (int32)mxGetScalar(prhs[0]);

	// Call the dcam function.
	error = dcamcap_stop((HDCAM)handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_stop() failed.\n", error);
	}

	return;
}