#include "stdafx.h"

// [] = DCAM4FireTrigger(cameraHandle, timeout)
// Fire a software trigger to begin capturing an image.
// The input 'timeout' is given in milliseconds and is applied in multiple
// places in this function.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	// Grab the inputs from MATLAB.
	unsigned long* mHandle;
	HDCAM handle;
	int32 timeout;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	timeout = (int32)mxGetScalar(prhs[1]);

	// Attempt to fire the trigger.
	DCAMERR error;
	error = dcamcap_firetrigger(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_firetrigger failed.\n", error);
	}
	
	// Prepare some wait structures.
	DCAMWAIT_OPEN waitopen;
	DCAMWAIT_START waitstart;
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = handle;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_FRAMEREADY;
	waitstart.timeout = timeout;

	// Wait until the frame has been captured before returning.
	error = dcamwait_open(&waitopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_open() failed.\n", error);
		return;
	}
	error = dcamwait_start((HDCAMWAIT)waitopen.hwait, &waitstart);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_start() failed.\n", error);
		return;
	}

	// Close the wait handles.
	error = dcamwait_close((HDCAMWAIT)waitopen.hwait);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_close() failed.\n", error);
	}
	
	return;
}