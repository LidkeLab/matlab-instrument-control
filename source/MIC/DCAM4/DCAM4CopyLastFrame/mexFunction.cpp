#include "stdafx.h"

// [Frames] = DCAM4CopyLastFrame(cameraHandle)
// Copy the most recently transfered frame of data.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	long long	         handle;
	mwSize               outsize[1];
	DCAMBUF_FRAME        pFrame;
	DCAMERR              error;
	DCAMWAIT_OPEN	     waitopen;
	DCAMWAIT_START       waitstart;
	DCAMCAP_TRANSFERINFO transferInfo;

	// Grab the inputs from MATLAB.
	handle = (long long)mxGetScalar(prhs[0]);

	// Prepare some of the DCAM structures.
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = (HDCAM)handle;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_FRAMEREADY;
	waitstart.timeout = 1000;
	memset(&transferInfo, 0, sizeof(transferInfo));
	transferInfo.size = sizeof(transferInfo);

	// Create the HDCAMWAIT handle.
	error = dcamwait_open(&waitopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_open() failed.\n", error);
		return;
	}

	// Determine the frame index of the most recently transfered image.
	error = dcamcap_transferinfo((HDCAM)handle, &transferInfo);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_transferinfo() failed.\n", error);
		return;
	}

	// Prepare the DCAMBUF_FRAME and initialize the output for MATLAB.
	pFrame.iFrame = transferInfo.nNewestFrameIndex;
	error = dcambuf_lockframe((HDCAM)handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
		return;
	}
	outsize[0] = (long long)pFrame.width * (long long)pFrame.height;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);

	// Copy the image data to our output array.
	pFrame.buf = (unsigned short*)mxGetData(plhs[0]);
	error = dcambuf_copyframe((HDCAM)handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_copyframe() failed.\n", error);
		return;
	}

	return;
}