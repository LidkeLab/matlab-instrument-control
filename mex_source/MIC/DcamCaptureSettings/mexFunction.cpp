#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	int 	CaptureMode;
	long	FrameCount;
	DCAM_DATATYPE DataType;
	DCAM_DATATYPE newDataType;

	// input handle from Matlab

	Handle=(long)mxGetScalar(prhs[0]);
	CaptureMode=(int)mxGetScalar(prhs[1]);
	FrameCount=(long)mxGetScalar(prhs[2]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");

	hDCAM=(HDCAM)Handle;

	if (dcam_getdatatype(hDCAM,&DataType))
	{
		if (DataType!=DCAM_DATATYPE_UINT16)
		{
			newDataType=DCAM_DATATYPE_UINT16;
			if (dcam_setdatatype(hDCAM,newDataType))
				mexPrintf("\nData type is changed to Uint16\n");
			else
				mexPrintf("Error = 0x%08lX\ndcam_setdatatype failed.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
		}
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_getdatatype failed.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

	DCAM_CAPTUREMODE   Dcam_CaptureMode;
	if (CaptureMode==0)
		Dcam_CaptureMode=DCAM_CAPTUREMODE_SNAP;
	if (CaptureMode==1)
		Dcam_CaptureMode=DCAM_CAPTUREMODE_SEQUENCE;

	if (dcam_precapture(hDCAM, Dcam_CaptureMode))
	{
		//mexPrintf("\ndcam_precapture works\n");
		if (dcam_freeframe(hDCAM))
		{
			if (dcam_allocframe(hDCAM,FrameCount)==FALSE)
				mexPrintf("Error = 0x%08lX\ndcam_allocframe failed.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
		}
		else
			mexPrintf("Error = 0x%08lX\ndcam_freeframe failed.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_precapture failed.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	return;
}