#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	

	long	CameraIndex;
	char	CameraName[64];
	char	CameraID[64];
	char	VendorName[64];
	char    BusName[64];
	char	CameraVersion[64];
	char	DriverVersion[64];
	char	ModuleVersion[64];
	char	ApiVersion[64];
	long	i;
	HDCAM	hDCAM = NULL;
	long    *Handle= 0;
	mwSize  outsize[1];

	CameraIndex=(long)mxGetScalar(prhs[0]);
	// out put handle to Matlab
	outsize[0]=1;
	plhs[0]=mxCreateNumericArray(1,outsize,mxINT32_CLASS,mxREAL);
	Handle=(long*)mxGetData(plhs[0]);


	// initialize camera
	if (dcam_open( &hDCAM, CameraIndex, NULL) && hDCAM)
	{
		Handle[0]=(long)hDCAM;
		//mexPrintf("%ld",hDCAM);
		mexPrintf("-----Camera information:----\n");
		//mexErrMsgTxt("Serial number must be a string.");
		if (dcam_getstring(hDCAM,DCAM_IDSTR_MODEL,CameraName,sizeof(CameraName)))
		{

			if (dcam_getstring(hDCAM,DCAM_IDSTR_CAMERAID,CameraID,sizeof(CameraID)))
			{
				mexPrintf ("\nModel: %s (%s)",CameraName,CameraID);

			}
			else
				mexPrintf ("\nModel: %s",CameraName);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the Model name of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

		if (dcam_getstring(hDCAM,DCAM_IDSTR_VENDOR,VendorName,sizeof(VendorName)))
		{
			mexPrintf ("\nVendor: %s",VendorName);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the Vendor name of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

		if (dcam_getstring(hDCAM,DCAM_IDSTR_BUS,BusName,sizeof(BusName)))
		{
			mexPrintf ("\nBus: %s",BusName);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the Bus name of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

		if (dcam_getstring(hDCAM,DCAM_IDSTR_CAMERAVERSION,CameraVersion,sizeof(CameraVersion)))
		{
			mexPrintf ("\nCamera Version: %s",CameraVersion);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the camera version.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

		if (dcam_getstring(hDCAM,DCAM_IDSTR_DRIVERVERSION,DriverVersion,sizeof(DriverVersion)))
		{
			mexPrintf ("\nDriver Version: %s",DriverVersion);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the driver version.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));


		if (dcam_getstring(hDCAM,DCAM_IDSTR_MODULEVERSION,ModuleVersion,sizeof(ModuleVersion)))
		{
			mexPrintf ("\nDCAM Module Version: %s",ModuleVersion);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the DCAM module version.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

		if (dcam_getstring(hDCAM,DCAM_IDSTR_DCAMAPIVERSION,ApiVersion,sizeof(ApiVersion)))
		{
			mexPrintf ("\nDCAM-API Version: %s\n",ApiVersion);
		}
		else
			mexPrintf("Error = 0x%08lX\nCould not get the DCAM-API version.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

	}
	else
		mexPrintf("Could not open camera index 0 of DCAM-API.\n\n");

		
	return;
}