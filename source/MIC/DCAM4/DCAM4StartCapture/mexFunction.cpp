#include "stdafx.h"

// [] = DCAM4StartCapture(cameraHandle, captureMode)
// Start capturing images on camera 'cameraHandle' with mode 'captureMode'.
// See dcamapi.h for 'mode' options, prefixed by DCAMCAP_START.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	// Grab the inputs from MATLAB.
	unsigned long* mHandle;
	HDCAM handle;
	int32 mode;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	mode = (int32)mxGetScalar(prhs[1]);

	// Call the dcam function.
	DCAMERR error;
	error = dcamcap_start(handle, mode);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_start() failed.\n", error);
	}

	return;
}