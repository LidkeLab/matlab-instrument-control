#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	ScanSpeed;
	_DWORD CameraCapability = 0;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	ScanSpeed=(long)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	// ScanMode Inquiry Structure
	DCAM_PARAM_SCANMODE_INQ ScanModeInquiry;

	// ScanMode Set/Get Structure
	DCAM_PARAM_SCANMODE ScanMode;	
	
	// Query Scan Mode feature
	/*memset( &ScanModeInquiry, 0, sizeof(DCAM_PARAM_SCANMODE_INQ));
	ScanModeInquiry.hdr.cbSize = sizeof(DCAM_PARAM_SCANMODE_INQ);
	ScanModeInquiry.hdr.id = DCAM_IDPARAM_SCANMODE_INQ;
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&ScanModeInquiry,sizeof(DCAM_PARAM_SCANMODE_INQ)))
	{
		mexPrintf("\nMaximum scan speed: %ld\n",ScanModeInquiry.speedmax);		
	}*/

	memset( &ScanMode, 0, sizeof(DCAM_PARAM_SCANMODE));
	ScanMode.hdr.cbSize = sizeof(DCAM_PARAM_SCANMODE);
	ScanMode.hdr.id = DCAM_IDPARAM_SCANMODE;
	// set new Scan Mode setting
	ScanMode.speed=ScanSpeed;
	if (dcam_extended(hDCAM,DCAM_IDMSG_SETGETPARAM,&ScanMode,sizeof(DCAM_PARAM_SCANMODE)))
		mexPrintf("\ncamera scan mode setting is %ld.\n",ScanMode.speed);
	else
		mexPrintf("\n\nAn error occurred trying to set the new Scan Mode to the camera.");
		
	return;
}