#include "stdafx.h"
#include "time.h"

// [Frames] = DCAM4CopyFrames(cameraHandle, nFrames, timeout)
// Copy the 'nFrames' of data collected by 'cameraHandle' during a capture. 
// The input 'timeout' is given in milliseconds and is applied in multiple
// places in this function.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	unsigned long*  mHandle;
	HDCAM		    handle;
	int32		    nFrames;
	int32			timeout = 1000;
	mwSize          outsize[1];
	DCAMBUF_FRAME   pFrame;
	unsigned short* imagePointer;
	DCAMERR         error;
	char            outError;
	DCAMWAIT_OPEN	waitopen;
	DCAMWAIT_START  waitstart;
	int32			status = 1;

	// Grab the inputs from MATLAB.
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	nFrames = (int32)mxGetScalar(prhs[1]);
	timeout = (int32)mxGetScalar(prhs[2]);

	// Prepare some of the DCAM structures.
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = handle;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_FRAMEREADY;
	waitstart.timeout = timeout;
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);

	// Create the HDCAMWAIT handle.
	error = dcamwait_open(&waitopen);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_open() failed.\n", error);
		return;
	}

	// Query the camera until it's no longer busy before attempting 
    // to transfer the data.
	error = dcamcap_status(handle, &status);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lx\ndcamcap_status() failed.\n", error);
		return;
	}
	double startTime = clock();
	while (status != 2) // status 2 is ready
	{
		// Check the timeout condition.
		if ((clock() - startTime) > (timeout * 1e-3 * CLOCKS_PER_SEC))
		{
			mexPrintf("DCAM4CopyFrames: timeout of %i ms reached!\n", timeout);
			return;
		}

		// Check the status.
		error = dcamcap_status(handle, &status);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lx\ndcamcap_status() failed.\n", error);
			return;
		}
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
	outsize[0] = (long long)pFrame.width * (long long)pFrame.height * nFrames;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);
	
	// Copy the image data to our output array.
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