#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	int32	propertyID;
	double* propertyValue;
	DCAMERR error;
	
	// Grab the inputs from MATLAB and check their types before proceeding.
	if (!mxIsInt32(prhs[0]))
	{
		mexErrMsgTxt("Camera handle must be type INT 32.");
	}
	if (!mxIsInt32(prhs[1]))
	{
		mexErrMsgTxt("Property ID must be type INT 32.");
	}
	handle = (long)mxGetScalar(prhs[0]);
	propertyID = (int32)mxGetScalar(prhs[1]);

	// Prepare the outputs.
	plhs[0] = mxCreateDoubleScalar(123);
	propertyValue = (double*)mxGetData(plhs[0]);

	// Call the dcam function.
	error = dcamprop_getvalue((HDCAM)handle, propertyID, propertyValue);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() failed.\n", error);
	}

	return;
}