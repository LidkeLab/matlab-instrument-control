#include "stdafx.h"

// [propertyValue] = DCAM4GetProperty(cameraHandle, propertyID)
// Get the value of the property defined by 'propertyID'.  See dcamprop.h for
// hexadecimal propertyIDs (which must be converted to decimal before use
// here).
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	int32	handle;
	int32	propertyID;
	double* propertyValue;
	DCAMERR error;
	
	// Grab the inputs from MATLAB and check their types before proceeding.
	handle = (int32)mxGetScalar(prhs[0]);
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