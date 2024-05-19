
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
	double value;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	iProp = (int32)mxGetScalar(prhs[1]);
	value = (double)mxGetScalar(prhs[2]);

	char	pv_text[64];
	DCAMPROP_VALUETEXT pvt;
	memset(&pvt, 0, sizeof(pvt));
	pvt.cbSize = sizeof(pvt);
	pvt.iProp = iProp;
	pvt.value = value;
	pvt.text = pv_text;
	pvt.textbytes = sizeof(pv_text);

	
	// Call the dcam function.
	DCAMERR error;
	error = dcamprop_getvaluetext(handle, &pvt);

	plhs[0] = mxCreateString(pvt.text);

	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvaluetext() failed.\n", error);
	}

	return;
}


