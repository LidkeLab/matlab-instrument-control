#include "stdafx.h"
#include "time.h"

// [Frames] = DCAM4CopyFrames(cameraHandle, nFrames)
// Copy the 'nFrames' of data collected by 'cameraHandle' during a capture.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	unsigned long*  mHandle;
	HDCAM		    handle;
	long		    nFrames;
	long			timeout;
	mwSize          outsize[1];
	DCAMBUF_FRAME   pFrame;
	unsigned short* imagePointer;
	DCAMERR         error;
	DCAMWAIT_OPEN	waitopen;
	DCAMWAIT_START  waitstart;
	int32			status = 1;

	// Grab the inputs from MATLAB.
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	nFrames = (long)mxGetScalar(prhs[1]);

	// Prepare some of the DCAM structures.
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = handle;
	memset(&waitstart, 0, sizeof(waitstart));
	waitstart.size = sizeof(waitstart);
	waitstart.eventmask = DCAMWAIT_CAPEVENT_FRAMEREADY;
	waitstart.timeout = 1000;
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);

	// Create the HDCAMWAIT handle.
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
	
	// Query the camera until it's no longer busy before attempting 
	// to transfer the data.
	error = dcamcap_status(handle, &status);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lx\ndcamcap_status() failed.\n", error);
		return;
	}
	while (status != 2) // status 2 is ready
	{
		error = dcamcap_status(handle, &status);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lx\ndcamcap_status() failed.\n", error);
			return;
		}
	}

	// Prepare the DCAMBUF_FRAME and initialize the output for MATLAB.
	dcamcap_stop(handle);
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
		
		/*
		// Update the pointer for the current frame.
		pFrame.iFrame = ff;
		error = dcambuf_lockframe((HDCAM)handle, &pFrame);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed on frame %i.\n", error, ff+1);
			return;
		}

		// Copy the image to our output, one row at a time.	
		for (int ii = 0; ii < pFrame.height; ii++)
		{
			// Copy the ii-th row of data.
			memcpy(imagePointer, pFrame.buf, pFrame.rowbytes);

			// Update our destination pointer for the next row.
			// NOTE: A char is only 1 byte, so we're converting to char so that
			//		 our arithmetic is in units of bytes!
			imagePointer = (unsigned short*)((char*)imagePointer + pFrame.rowbytes);
		}
		*/
	}

	// Release the capturing buffer allocated by DCAM4AllocMemory().
	error = dcambuf_release(handle);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_release() failed.\n", error);
	}

	return;
}