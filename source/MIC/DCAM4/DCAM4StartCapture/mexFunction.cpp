#include "stdafx.h"

// [] = DCAM4StartCapture(cameraHandle, captureMode)
// Start capturing images on camera 'cameraHandle' with mode 'captureMode'.
// See dcamapi.h for 'mode' options, prefixed by DCAMCAP_START.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32	handle;
	int32	mode;
	DCAMERR error;

	// Grab the inputs from MATLAB.
	handle = (int32)mxGetScalar(prhs[0]);
	mode = (int32)mxGetScalar(prhs[1]);

	// Call the dcam function.
	error = dcamcap_start((HDCAM)handle, mode);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_start() failed.\n", error);
	}

	return;
}