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

	_DWORD CameraCapability = 0;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	// Feature Inquiry Structure
	DCAM_PARAM_FEATURE_INQ FeatureInquiry;

	// Feature Set/Get Structure
	DCAM_PARAM_FEATURE FeatureValue;

	//  Query Gain/Contrast feature
	memset( &FeatureInquiry, 0, sizeof(DCAM_PARAM_FEATURE_INQ));
	FeatureInquiry.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE_INQ);
	FeatureInquiry.hdr.id = DCAM_IDPARAM_FEATURE_INQ;

	memset( &FeatureValue, 0, sizeof(DCAM_PARAM_FEATURE));
	FeatureValue.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE);
	FeatureValue.hdr.id = DCAM_IDPARAM_FEATURE;
	FeatureInquiry.featureid = FeatureValue.featureid = DCAM_IDFEATURE_GAIN;	// same as DCAM_IDFEATURE_CONTRAST
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureInquiry,sizeof(DCAM_PARAM_FEATURE_INQ)))
	{
		float   fNewGainValue=-65536.0;
		// get the current Gain/Contrast feature value
		if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureValue,sizeof(DCAM_PARAM_FEATURE)))
		{
			if (FeatureInquiry.units[0])
			{
				mexPrintf("\nThe current Gain/Contrast value is %f %s.\n",FeatureValue.featurevalue,FeatureInquiry.units);
				mexPrintf("\nGain/Contrast value range is between %lf %s and %lf %s\n",(double)FeatureInquiry.min,FeatureInquiry.units,(double)FeatureInquiry.max,FeatureInquiry.units);
			}
			else
			{
				FeatureMin = (long)FeatureInquiry.min;
				FeatureMax = (long)FeatureInquiry.max;
				if (FeatureInquiry.step)
					FeatureStep = (long)FeatureInquiry.step;
				mexPrintf("\nThe current Gain/Contrast value is %ld.\n",(long)FeatureValue.featurevalue);
				mexPrintf("\nGain/Contrast value range between %ld and %ld in steps of %ld\n",FeatureMin,FeatureMax,FeatureStep);
			}
		}
		else
			mexPrintf("\nAn error occurred trying to get the Gain/Contrast value of the camera.\n");
	}
	else
		mexPrintf("\nCan not query gain/contrast feature\n");


	// Query Offset feature

	memset( &FeatureInquiry, 0, sizeof(DCAM_PARAM_FEATURE_INQ));
	FeatureInquiry.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE_INQ);
	FeatureInquiry.hdr.id = DCAM_IDPARAM_FEATURE_INQ;

	memset( &FeatureValue, 0, sizeof(DCAM_PARAM_FEATURE));
	FeatureValue.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE);
	FeatureValue.hdr.id = DCAM_IDPARAM_FEATURE;

	FeatureInquiry.featureid = FeatureValue.featureid = DCAM_IDFEATURE_OFFSET;
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureInquiry,sizeof(DCAM_PARAM_FEATURE_INQ)))
	{
		float fNewOffsetValue = -65536.0;
		// get the current Offset feature value
		if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureValue,sizeof(DCAM_PARAM_FEATURE)))
		{
			if (FeatureInquiry.units[0])
				printf("\nThe current Offset value is %f %s\n.",FeatureValue.featurevalue,FeatureInquiry.units);
			else
				printf("\nThe current Offset value is %ld.\n",(long)FeatureValue.featurevalue);
		}
		else
			printf("\nAn error occurred trying to get the Offset value of the camera.\n");
	}
	else
		mexPrintf("\nCan not query offset feature\n");

	// Query Temperature feature
	memset( &FeatureInquiry, 0, sizeof(DCAM_PARAM_FEATURE_INQ));
	FeatureInquiry.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE_INQ);
	FeatureInquiry.hdr.id = DCAM_IDPARAM_FEATURE_INQ;

	memset( &FeatureValue, 0, sizeof(DCAM_PARAM_FEATURE));
	FeatureValue.hdr.cbSize = sizeof(DCAM_PARAM_FEATURE);
	FeatureValue.hdr.id = DCAM_IDPARAM_FEATURE;

	FeatureInquiry.featureid = FeatureValue.featureid = DCAM_IDFEATURE_TEMPERATURE;
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureInquiry,sizeof(DCAM_PARAM_FEATURE_INQ)))
	{
		float fNewTemperatureValue = -65536.0;
		// get the current Temperature feature value
		if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&FeatureValue,sizeof(DCAM_PARAM_FEATURE)))
		{
			if (FeatureInquiry.units[0])
				mexPrintf("\nThe current Temperature value is %6.1f%s.\n",FeatureValue.featurevalue,FeatureInquiry.units);
			else
				mexPrintf("\nThe current Temperature value is %ld.\n",(long)FeatureValue.featurevalue);
		}
		else
			mexPrintf("\nAn error occurred trying to get the Temperature value of the camera.\n");
	}
	else
		mexPrintf("\nCan not query temperature feature\n");
	return;
}