#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	_DWORD	CameraStatus;
	long	*Status=0;
	mwSize	outsize[1];
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;

	// output status
	outsize[0]=1;
	plhs[0]=mxCreateNumericArray(1,outsize,mxINT32_CLASS,mxREAL);
	Status=(long*)mxGetData(plhs[0]);
	//mexErrMsgTxt("Serial number must be a string.");

	if(dcam_getstatus(hDCAM,&CameraStatus))
	{
		/*switch (CameraStatus){
		case DCAM_STATUS_BUSY:
			mexPrintf("\nCamera status: Busy\n");
			break;
		case DCAM_STATUS_READY:
			mexPrintf("\nCamera status: Ready\n");
			break;
		case DCAM_STATUS_STABLE:
			mexPrintf("\nCamera status: Stable\n");
			break;
		case DCAM_STATUS_UNSTABLE:
			mexPrintf("\nCamera status: Unstable\n");
			break;
		case DCAM_STATUS_ERROR:
			mexPrintf("\nCamera status: Unstable\n");
			break;
		}*/
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_getstatus failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

	Status[0]=(long)CameraStatus;
	return;
}