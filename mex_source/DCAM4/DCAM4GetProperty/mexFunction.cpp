#include "stdafx.h"

// [propertyValue] = DCAM4GetProperty(cameraHandle, propertyID)
// Get the value of the property defined by 'propertyID'.  See dcamprop.h for
// hexadecimal propertyIDs (which must be converted to decimal before use
// here).
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	// Grab the inputs from MATLAB and check their types before proceeding.
	unsigned long* mHandle;
	HDCAM handle;
	int32 propertyID;
	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	propertyID = (int32)mxGetScalar(prhs[1]);

	// Prepare the outputs.
	double* propertyValue;
	plhs[0] = mxCreateDoubleScalar(123);
	propertyValue = (double*)mxGetData(plhs[0]);

	// Call the dcam function.
	DCAMERR error;
	error = dcamprop_getvalue(handle, propertyID, propertyValue);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() failed.\n", error);
	}

	return;
}