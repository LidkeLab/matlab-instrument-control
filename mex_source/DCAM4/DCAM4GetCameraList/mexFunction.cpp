#include "stdafx.h"

// [nDevices] = DCAM4GetCameraList()
// Prepares a list of the cameras visible to the API and prints the results to 
// the MATLAB Command Window.
void mexFunction(int nlhs, mxArray* plhs[],	int	nrhs, const	mxArray* prhs[]) 
{
	// Initialize the API and determine the number of cameras connected.
	DCAMAPI_INIT apiinit;
	DCAMERR error;
	memset(&apiinit, 0, sizeof(apiinit)); // set all apiinit fields to 0
	apiinit.size = sizeof(apiinit);
	error = dcamapi_init(&apiinit);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamapi_init() failed.\n", error);
	}

	// Loop through the detected cameras and request info.
	if (apiinit.iDeviceCount > 0)
	{
		for (int ii = 0; ii < apiinit.iDeviceCount; ii++)
		{
			// Request device info.
			DCAMDEV_STRING param;
			char CameraName[64];
			char CameraID[64];
			memset(&param, 0, sizeof(param));
			param.size = sizeof(param);
			param.iString = DCAM_IDSTR_MODEL; // model of the camera
			param.text = CameraName;
			param.textbytes = 8;
			error = dcamdev_getstring((HDCAM)ii, &param);
			if (failed(error))
			{
				mexPrintf("Error = 0x%08lX\ndcamdev_getstring() failed.\n", error);
			}

			// Print the device info.
			mexPrintf("Model: %s Index: %d\n", CameraName, ii);
		}
	}

	// Grab some outputs to return to MATLAB.
	mwSize outsize[1];
	int* nDevices = 0;
	outsize[0] = 1;
	plhs[0] = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	nDevices = mxGetInt32s(plhs[0]);
	*nDevices = apiinit.iDeviceCount;

	return;
}