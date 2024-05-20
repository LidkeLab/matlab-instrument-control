
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
	int32 iProp;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	iProp = (int32)mxGetScalar(prhs[1]); // property IDs

	// Call the dcam function.
	DCAMERR error;

	error = dcamprop_getnextid(handle, &iProp, DCAMPROP_OPTION_SUPPORT);

	// Prepare the outputs.
	mwSize outsize[1];
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	*mxGetInt32s(plhs[0]) = iProp;
	

	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getnextid() failed.\n", error);
		*mxGetInt32s(plhs[0]) = 0;
	}

	return;
}


