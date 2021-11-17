#include "stdafx.h"

// [Frames] = DCAM4CopyFrames(cameraHandle, nFrames)
// Copy the 'nFrames' of data collected by 'cameraHandle' during a capture.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32		    handle;
	int32		    nFrames;
	mwSize          outsize[1];
	DCAMBUF_FRAME   pFrame;
	unsigned short* imagePointer;
	int32		    bytesPerPx;
	DCAMERR         error;
	DCAMWAIT_OPEN	waitopen;
	DCAMWAIT_START  waitstart;

	// Grab the inputs from MATLAB.
	handle = (int32) mxGetScalar(prhs[0]);
	nFrames = (int32) mxGetScalar(prhs[1]);

	// Prepare some of the DCAM structures.
	memset(&waitopen, 0, sizeof(waitopen));
	waitopen.size = sizeof(waitopen);
	waitopen.hdcam = (HDCAM)handle;
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

	// Wait for the capture to finish and then force stop it (the call to
	// dcamcap_stop() is made in the access_image.cpp example provided with the
	// SDK, so I've included it here even though it seems unnecessary).
	error = dcamwait_start((HDCAMWAIT)waitopen.hwait, &waitstart);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamwait_start() failed.\n", error);
		return;
	}
	dcamcap_stop((HDCAM)handle);

	// Prepare the DCAMBUF_FRAME and initialize the output for MATLAB.
	error = dcambuf_lockframe((HDCAM)handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
		return;
	}
	outsize[0] = pFrame.width * pFrame.height * nFrames;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);

	// Copy the image data to our output array.
	imagePointer = (unsigned short*) mxGetData(plhs[0]);
	for (int ff = 0; ff < nFrames; ff++)
	{
		// Update the pointer for the current frame.
		pFrame.iFrame = ff;
		error = dcambuf_lockframe((HDCAM)handle, &pFrame);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
			return;
		}

		// Copy the image to our output, one row at a time.
		for (int ii = 0; ii < pFrame.height; ii++)
		{
			// Copy the ii-th row of data.
			memcpy(imagePointer, pFrame.buf, pFrame.rowbytes);

			// Update our destination pointer for the next row.
			imagePointer = (unsigned short*)((char*)imagePointer + pFrame.rowbytes);
		}
	}

	// Release the capturing buffer allocated by DCAM4AllocMemory().
	error = dcambuf_release((HDCAM)handle, 1);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_release() failed.\n", error);
	}

	return;
}