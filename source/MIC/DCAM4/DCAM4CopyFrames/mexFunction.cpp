#include "stdafx.h"
#include "time.h"

// [Frames] = DCAM4CopyFrames(cameraHandle, nFrames, timeout)
// Copy the 'nFrames' of data collected by 'cameraHandle' during a capture. 
// The input 'timeout' is given in milliseconds and is applied in multiple
// places in this function.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	// Grab the inputs from MATLAB.
	unsigned long* mHandle;
	HDCAM handle;
	int32 nFrames;
	int32 timeout = 1000;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	nFrames = (int32)mxGetScalar(prhs[1]);
	timeout = (int32)mxGetScalar(prhs[2]);

	// Prepare some of the DCAM structures.
	DCAMWAIT_OPEN waitopen;
	DCAMWAIT_START waitstart;
	DCAMBUF_FRAME pFrame;
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = handle;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_CYCLEEND;
	waitstart.timeout = timeout;
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);

	// Create the HDCAMWAIT handle.
	DCAMERR error;
	error = dcamwait_open(&waitopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_open() failed.\n", error);
		return;
	}

	// Wait for the capture to finish and then force stop it.
	error = dcamwait_start((HDCAMWAIT)waitopen.hwait, &waitstart);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_start() failed.\n", error);
		return;
	}
	dcamcap_stop(handle);

	// Prepare the DCAMBUF_FRAME and initialize the output for MATLAB.
	error = dcambuf_lockframe(handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
		return;
	}
	mwSize outsize[1];
	outsize[0] = (long long)pFrame.width * (long long)pFrame.height * nFrames;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);

	// Copy the image data to our output array.
	unsigned short* imagePointer;
	imagePointer = (unsigned short*) mxGetData(plhs[0]);
	for (int ff = 0; ff < nFrames; ff++)
	{
		// Copy the image to our desired output in MATLAB.
		pFrame.iFrame = ff;
		pFrame.buf = imagePointer;
		error = dcambuf_copyframe(handle, &pFrame);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lX\ndcambuf_copyframe() failed on frame %i.\n", error, ff+1);
			return;
		}

		// Update the pointer for our MATLAB output.
		// NOTE: char is one byte, hence the use of char here (we just need a type
		//       that's 1 byte long).
		imagePointer = (unsigned short*)((char*)imagePointer 
			+ (long long)pFrame.rowbytes*(long long)pFrame.height);
	}

	// Release the capturing buffer allocated by DCAM4AllocMemory().
	error = dcambuf_release(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_release() failed.\n", error);
	}

	return;
}