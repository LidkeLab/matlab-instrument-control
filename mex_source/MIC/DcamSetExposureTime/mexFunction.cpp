#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.

//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	
	long FeatureMin;
	long FeatureMax;
	long FeatureStep=0;
	double lfCurrentExposureTime = 1.0;
	float fNewExposureTimeValue = 1.0f;
	float *CurrentExposureTime=0;
	_DWORD CameraCapability = 0;
	mwSize outsize[1];
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	fNewExposureTimeValue=(float)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;

	// out put current exposure time
	outsize[0]=1;
	plhs[0]=mxCreateNumericArray(1,outsize,mxSINGLE_CLASS,mxREAL);
	CurrentExposureTime=(float*)mxGetData(plhs[0]);
	//mexErrMsgTxt("Serial number must be a string.");

	// Feature Inquiry Structure
	DCAM_PARAM_FEATURE_INQ FeatureInquiry;

	// Feature Set/Get Structure
	DCAM_PARAM_FEATURE FeatureValue;

	if (dcam_getexposuretime(hDCAM,&lfCurrentExposureTime)==FALSE)
		mexPrintf("\n\nAn error occurred trying to get the Exposure Time value from the camera.\n");

	memset( &FeatureInquiry, 0, sizeof(DCAM_PARAM_FEATURE_INQ));
	FeatureInquiry.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE_INQ);
	FeatureInquiry.hdr.id = DCAM_IDPARAM_FEATURE_INQ;

	memset( &FeatureValue, 0, sizeof(DCAM_PARAM_FEATURE));
	FeatureValue.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE);
	FeatureValue.hdr.id = DCAM_IDPARAM_FEATURE;

	FeatureInquiry.featureid = FeatureValue.featureid = DCAM_IDFEATURE_EXPOSURETIME;	// same as DCAM_IDFEATURE_SHUTTER
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureInquiry,sizeof(DCAM_PARAM_FEATURE_INQ)))
	{
		// check if we can set this feature
		if (FeatureInquiry.step)
		{
			// check to see if this feature is relative or absolute with defined units
			if (FeatureInquiry.units[0])
			{
				mexPrintf( "\nExposure Time range is between %f and %f %s\n",(double)FeatureInquiry.min,(double)FeatureInquiry.max,FeatureInquiry.units);
				// it is absolute with defined units
				if ((fNewExposureTimeValue < FeatureInquiry.min) || (fNewExposureTimeValue > FeatureInquiry.max))
				{
					mexPrintf( "\nEnter a valid Exposure Time value between %f and %f %s\n",(double)FeatureInquiry.min,(double)FeatureInquiry.max,FeatureInquiry.units);
					fNewExposureTimeValue = (float)lfCurrentExposureTime;
				}
				// round down to the nearest valid feature value
				fNewExposureTimeValue /= FeatureInquiry.step;
				fNewExposureTimeValue *= FeatureInquiry.step;

					if (dcam_setexposuretime(hDCAM,(double)fNewExposureTimeValue))
					{
						if (dcam_getexposuretime(hDCAM,&lfCurrentExposureTime))
						{
							mexPrintf("\nThe Exposure Time of %f seconds was returned from the camera.\n",lfCurrentExposureTime);
							CurrentExposureTime[0]=(float)lfCurrentExposureTime;
						}
						else
							mexPrintf("\n\nAn error occurred trying to get the Exposure Time value from the camera.\n");
					}
					else
						mexPrintf("\nAn error occurred trying to set the Exposure Time value to the camera.\n");						
			}
			else
			{
				// it is relative only
				long NewShutterValue = (long)fNewExposureTimeValue;
				long FeatureStep = (long)FeatureInquiry.step;
				long FeatureMin = (long)FeatureInquiry.min;
				long FeatureMax = (long)FeatureInquiry.max;
				if((NewShutterValue % FeatureStep) || (NewShutterValue < FeatureMin) || (NewShutterValue > FeatureMax))
					mexPrintf( "\nEnter a valid Shutter value between %ld and %ld in steps of %ld\n",FeatureMin,FeatureMax,FeatureStep);

				FeatureValue.featurevalue = (float)NewShutterValue;
				if (dcam_extended(hDCAM,DCAM_IDMSG_SETGETPARAM,&FeatureValue,sizeof(DCAM_PARAM_FEATURE)))
				{
					mexPrintf("\nA Shutter value of %ld was returned from the camera.\n",(long)FeatureValue.featurevalue);
				    CurrentExposureTime[0]=(float)FeatureValue.featurevalue;
				}
				else
					mexPrintf("\nAn error occurred trying to set/get the Exposure Time value of the camera.\n");
			}
		}
		else
			mexPrintf("\nCan not set exposure time\n");
	}
	else
		mexPrintf("\nCan not query exposure time feature\n");
	return;
}