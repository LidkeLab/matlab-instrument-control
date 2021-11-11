#include "stdafx.h"

// [] = DCAM4SetProperty(cameraHandle, propertyID, value)
// Set the property defined by 'propertyID' to the double given in 'value'. See
// dcamprop.h for hexadecimal propertyIDs (which must be converted to decimal 
// before use here).
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[])
{
	int32	handle;
	int32	propertyID;
	double  propertyValue;
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
	if (!mxIsDouble(prhs[2]))
	{
		mexErrMsgTxt("property value must be type DOUBLE.");
	}
	handle = (int32)mxGetScalar(prhs[0]);
	propertyID = (int32)mxGetScalar(prhs[1]);
	propertyValue = (double)mxGetScalar(prhs[2]);

	// Call the dcam function.
	error = dcamprop_setvalue((HDCAM)handle, propertyID, propertyValue);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_setvalue() failed.\n", error);
	}

	return;
}