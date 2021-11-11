#include "stdafx.h"

// nDevices = DCAM4Init()
// Initialize the DCAM-API and determine how many devices are connected.
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {
	mwSize		 outsize[1];
	DCAMERR		 error;
	DCAMAPI_INIT apiinit;
	int*		 nDevice = 0;

	// Initialize the camera(s).
	memset(&apiinit, 0, sizeof(apiinit)); // set all apiinit fields to 0
	apiinit.size = sizeof(apiinit);
	error = dcamapi_init(&apiinit);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamapi_init() failed.\n", error);
	}

	// Grab some outputs to return to MATLAB.
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	nDevice = mxGetInt32s(plhs[0]);
	*nDevice = apiinit.iDeviceCount;

	return;
}