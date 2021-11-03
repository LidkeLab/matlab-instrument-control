#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	HDCAM	hDCAM = NULL;
	long	Handle;
	int32	PropertyID;
	double  *PropertyValue;
	bool	test = false;
	DCAMERR error;
	
	// grab the inputs from MATLAB and check their types before proceeding.
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("camera handle must be type INT 32.");
	if (!mxIsInt32(prhs[1]))
		mexErrMsgTxt("property ID must be type INT 32.");
	Handle = (long)mxGetScalar(prhs[0]);
	PropertyID = (int32)mxGetScalar(prhs[1]);

	// prepare the outputs.
	plhs[0] = mxCreateDoubleScalar(123);
	PropertyValue = (double*)mxGetData(plhs[0]);

	// call the dcam function.
	hDCAM=(HDCAM)Handle;
	if (error = dcamprop_getvalue(hDCAM, PropertyID, PropertyValue))
	{
		mexPrintf("Error = %d\ndcam_getpropertyvalue() failed.\n", error);
	};

	return;
}