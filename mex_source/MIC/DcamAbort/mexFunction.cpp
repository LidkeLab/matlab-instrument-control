#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	if(dcam_idle(hDCAM))
		dcam_freeframe(hDCAM);
	else
		mexPrintf("Error = 0x%08lX\ndcam_idle failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));


	return;
}