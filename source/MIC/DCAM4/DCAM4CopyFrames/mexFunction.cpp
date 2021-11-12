#include "stdafx.h"

// [Frames] = DCAM4CopyFrames(cameraHandle, nFrames)
// Copy the 'nFrames' of data collected by 'cameraHandle' during a capture.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32		  handle;
	int32		  nFrames;
	mwSize        outsize[1];
	DCAMBUF_FRAME pFrame;
	UINT16*		  images;
	int32		  bytesPerPx;
	DCAMERR       error;

	// Grab the inputs from MATLAB.
	handle = (int32) mxGetScalar(prhs[0]);
	nFrames = (int32) mxGetScalar(prhs[1]);

	// Update a DCAMBUF_FRAME structure with info. about the current data.
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);
	error = dcambuf_lockframe((HDCAM) handle, &pFrame);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed.\n", error);
		return;
	}

	// Copy the image data to our output array.
	outsize[0] = pFrame.width * pFrame.height * nFrames;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);
	images = (UINT16*) mxGetData(plhs[0]);
	bytesPerPx = 2; // uint16 -> 2 bytes
	for (int ff = 0; ff < nFrames; ff++)
	{
		// Update the pointer for the current frame.
		pFrame.iFrame = ff;
		error = dcambuf_lockframe((HDCAM)handle, &pFrame);
		if (failed(error))
		{
			mexPrintf("Error = 0x%08lX\ndcambuf_lockframe() failed for frame %i.\n", error, ff);
		}

		// Copy the image to our output, one row at a time.
		for (int ii = 0; ii < pFrame.height; ii++)
		{
			memcpy(images, pFrame.buf, pFrame.rowbytes);
		}
	}

	return;
}