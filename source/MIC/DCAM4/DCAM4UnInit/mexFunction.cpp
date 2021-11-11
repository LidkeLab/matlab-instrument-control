#include "stdafx.h"

// [] = DCAM4UnInit()
// Un-initialize the DCAM-API and force close any devices in use.
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[]) 
{
	DCAMERR error;

	// Un-initialize all devices.
	error = dcamapi_uninit();
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamapi_uninit() failed.\n", error);
	}

	return;
}