#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long nCameras = 0;

	long	CameraIndex = 0;
	char	CameraName[64];
	char	CameraID[64];
	long	i;
	HDCAM	hDCAM = NULL;
	long   Handle;
	
	
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");
	
	if (dcam_getstring(hDCAM,DCAM_IDSTR_MODEL,CameraName,sizeof(CameraName)))
	{
		
		if (dcam_getstring(hDCAM,DCAM_IDSTR_CAMERAID,CameraID,sizeof(CameraID)))
		{
			mexPrintf ("\nThe camera model being closed is the %s (%s)\n",CameraName,CameraID);

		}
		else
			mexPrintf ("\nThe camera model being closed is the %s\n",CameraName);

	}
	else
		mexPrintf("Error = 0x%08lX\nCould not get the Model name string of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

	dcam_close(hDCAM);

	dcam_uninit(NULL,NULL);

	return;
}