#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{

	HDCAM	hDCAM = NULL;
	long	Handle;
	int32	PropertyID;
	double  *PropertyValue;
	DCAMERR error;
	
	// Grab the inputs from MATLAB and check their types before proceeding.
	if (!mxIsInt32(prhs[0]))
	{
		mexErrMsgTxt("camera handle must be type INT 32.");
	}
	if (!mxIsInt32(prhs[1]))
	{
		mexErrMsgTxt("property ID must be type INT 32.");
	}
	Handle = (long)mxGetScalar(prhs[0]);
	PropertyID = (int32)mxGetScalar(prhs[1]);

	// Prepare the outputs.
	plhs[0] = mxCreateDoubleScalar(123);
	PropertyValue = (double*)mxGetData(plhs[0]);

	// Call the dcam function.
	hDCAM = (HDCAM)Handle;
	error = dcamprop_getvalue(hDCAM, PropertyID, PropertyValue);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcam_getpropertyvalue() failed.\n", error);
	}

	return;
}