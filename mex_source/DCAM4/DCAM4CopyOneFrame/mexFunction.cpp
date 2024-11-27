
#include "stdafx.h"

// [Frames] = DCAM4CopyOneFrame(cameraHandle, timeout)
// Copy the most recently transfered frame of data.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	// Grab the inputs from MATLAB.
	unsigned long* mHandle;
	HDCAM handle;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];

	// Prepare some of the DCAM structures.
	int32 iFrame;
	int32 timeout;
	iFrame = (int32)mxGetScalar(prhs[1]);
	timeout = (int32)mxGetScalar(prhs[2]);
	

	// open wait handle.
	DCAMERR error;
	DCAMWAIT_OPEN waitopen;
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = handle;
	error = dcamwait_open(&waitopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_open() failed.\n", error);
		return;
	}

	// wait image
	HDCAMWAIT hwait = waitopen.hwait;
	DCAMWAIT_START waitstart;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_FRAMEREADY;
	waitstart.timeout = timeout;
	error = dcamwait_start(hwait, &waitstart);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_start() failed.\n", error);
		return;
	}

	// Determine the frame index of the most recently transfered image.
	DCAMCAP_TRANSFERINFO transferInfo;
	memset(&transferInfo, 0, sizeof(transferInfo));
	transferInfo.size = sizeof(transferInfo);
	error = dcamcap_transferinfo(handle, &transferInfo);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_transferinfo() failed.\n", error);
		return;
	}

	// Prepare the DCAMBUF_FRAME and initialize the output for MATLAB.
	if (iFrame > transferInfo.nNewestFrameIndex) 
	{
		mwSize outsize[1];
		outsize[0] = 1;
		plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
		*mxGetInt32s(plhs[0]) = 0;
		return;
	}
	DCAMBUF_FRAME pFrame;
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);
	pFrame.iFrame = iFrame;
	error = dcambuf_lockframe(handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
		return;
	}

	mwSize outsize[1];
	outsize[0] = (long long)pFrame.width * (long long)pFrame.height;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);

	// Copy the image data to our output array.
	pFrame.buf = (unsigned short*)mxGetData(plhs[0]);
	error = dcambuf_copyframe(handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_copyframe() failed.\n", error);
		return;
	}

	// close wait handle
	dcamwait_close(hwait);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_close() failed.\n", error);
	}

	return;
}