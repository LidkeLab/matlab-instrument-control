
#include "stdafx.h"
#include <helper.h>
//get information of framebundle
//hdcam:				DCAM handle
//number_of_bundle:	stored the number of bundled frame
//width:				stored width of single frame in the bundled image
//height:				stored height of single frame in the bundled image
//rowbytes:			stored rowbytes of single frame in the bundled image
//totalframebytes:	stored the total data size of bundled images
//framestepbytes:		stored the byte size up to next frame
//result of getting information of framebundle



// [] = DCAM4CopyFrameBundle(cameraHandle)
// 
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	/*!
	*  \brief Entry point in the code for Matlab.  Equivalent to main().
	*  \param nlhs number of left hand mxArrays to return
	*  \param plhs array of pointers to the output mxArrays
	*  \param nrhs number of input mxArrays
	*  \param prhs array of pointers to the input mxArrays.
	*/

	// Grab the inputs from MATLAB and check their types before proceeding.
	unsigned long* mHandle;
	HDCAM handle;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];



	int32 timeout;
	timeout = (int32)mxGetScalar(prhs[1]);



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

	// frame bundle information
	int32 number_of_bundle, width, height, rowbytes, totalframebytes, framestepbytes;
	if (!get_framebundle_information(handle, number_of_bundle, width, height, rowbytes, totalframebytes, framestepbytes))
		return;

	// get number of captured image
	DCAMCAP_TRANSFERINFO transferInfo;
	memset(&transferInfo, 0, sizeof(transferInfo));
	transferInfo.size = sizeof(transferInfo);
	error = dcamcap_transferinfo(handle, &transferInfo);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_transferinfo() failed.\n", error);
		return;
	}

	// prepare user buffer
	DCAMBUF_FRAME	pFrame;
	memset(&pFrame, 0, sizeof(pFrame));
	pFrame.size = sizeof(pFrame);
	pFrame.top = 0;
	pFrame.left = 0;
	pFrame.width = width;
	pFrame.height = height;
	pFrame.rowbytes = rowbytes;

	// Copy the image data to our output array.
	mwSize outsize[1];
	outsize[0] = (long long)width * (long long)height * (long long)number_of_bundle;
	plhs[0] = mxCreateNumericArray(1, outsize, mxUINT16_CLASS, mxREAL);
	unsigned short* buf;
	buf = (unsigned short*)mxGetData(plhs[0]);

	pFrame.iFrame = transferInfo.nNewestFrameIndex;
	pFrame.buf = buf;
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