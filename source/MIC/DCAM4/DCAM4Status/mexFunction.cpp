#include "stdafx.h"

// [pStatus] = DCAM4Status(cameraHandle)
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	mwSize  outsize[1];
	int32*  pStatus;
	DCAMERR error;
	
	// Grab the inputs from MATLAB and check their types before proceeding.
	if (!mxIsInt32(prhs[0]))
	{
		mexErrMsgTxt("Camera handle must be type INT 32.");
	}
	handle = (int32)mxGetScalar(prhs[0]);

	// Prepare the outputs.
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	pStatus = (int32*)mxGetData(plhs[0]);

	// Call the dcam function.
	error = dcamcap_status((HDCAM)handle, pStatus);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\dcamcap_status() failed.\n", error);
	}

	return;
}