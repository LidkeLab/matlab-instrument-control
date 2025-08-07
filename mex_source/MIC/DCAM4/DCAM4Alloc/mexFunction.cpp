#include "stdafx.h"

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
		mexErrMsgTxt("Camera handle must be type INT 32.");
	}
	if (!mxIsInt32(prhs[1]))
	{
		mexErrMsgTxt("Property ID must be type INT 32.");
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
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() failed.\n", error);
	}

	return;
}