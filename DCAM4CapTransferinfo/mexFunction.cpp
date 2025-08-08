
#include "stdafx.h"

// [] = DCAM4AllocMemory(cameraHandle, nFrames)
// Allocate memory for 'cameraHandle' to capture 'nFrames'.
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
	DCAMERR error;

	// Prepare the outputs.
	mwSize outsize[1];
	int* FrameIndex = 0;
	int* FrameCount = 0;
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	plhs[1] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	FrameIndex = mxGetInt32s(plhs[0]);
	FrameCount = mxGetInt32s(plhs[1]);


	DCAMCAP_TRANSFERINFO transferInfo;
	memset(&transferInfo, 0, sizeof(transferInfo));
	transferInfo.size = sizeof(transferInfo);
	error = dcamcap_transferinfo(handle, &transferInfo);

	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamcap_transferinfo() failed.\n", error);
		return;
	}
	*FrameIndex = transferInfo.nNewestFrameIndex;
	*FrameCount = transferInfo.nFrameCount;



	return;
}


