#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long nCameras = 0;
	long *CameraIndex = 0;
	
	mwSize  outsize[1];	

	if (dcam_init(NULL, &nCameras) && nCameras)
	{		
		char	CameraName[64];
		char	CameraID[64];

		long	ii;
		// out put to Matlab
		outsize[0]=nCameras;
		plhs[0]=mxCreateNumericArray(1,outsize,mxINT32_CLASS,mxREAL);
		CameraIndex=(long*)mxGetData(plhs[0]);

		// detect number of cameras

		for (ii=0;ii<nCameras;ii++)
		{
			CameraIndex[ii]=ii;

			if (dcam_getmodelinfo(ii,DCAM_IDSTR_MODEL,CameraName,sizeof(CameraName)))
			{
				if (dcam_getmodelinfo(ii,DCAM_IDSTR_CAMERAID,CameraID,sizeof(CameraID)))
					mexPrintf ("%ld - %s (%s)\n",ii,CameraName,CameraID);
				else
					mexPrintf ("%ld - %s\n",ii,CameraName);
			}	
		}

	}	
	else
		mexPrintf("Could not initialize DCAM-API. There may be no cameras detected!\n\n");
	return;
}