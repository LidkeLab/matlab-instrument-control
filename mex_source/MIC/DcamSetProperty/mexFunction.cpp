#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray* plhs[], int	nrhs, const	mxArray* prhs[]) {

	HDCAM	hDCAM = NULL;
	long	Handle;
	int32	PropertyID;
	double  PropertyValue;
	bool	test = false;

	// grab the inputs from MATLAB and check their types before proceeding.
	
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("camera handle must be type INT 32.");
	if (!mxIsInt32(prhs[1]))
		mexErrMsgTxt("property ID must be type INT 32.");
	if (!mxIsDouble(prhs[2]))
		mexErrMsgTxt("property value must be type DOUBLE.");
	PropertyID = (int32)mxGetScalar(prhs[1]);
	Handle = (long)mxGetScalar(prhs[0]);
	PropertyValue = (double)mxGetScalar(prhs[2]);

	// call the dcam function.
	hDCAM = (HDCAM)Handle;
	if (dcam_setpropertyvalue(hDCAM, PropertyID, PropertyValue))
	{
		// do nothing unless failure triggers the else condition
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_setpropertyvalue() failed.\n", (_DWORD)dcam_getlasterror(hDCAM, NULL, 0));

	return;
}