#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	HorizOff;
	long	HorizWidth;
	long	VertOff;
	long	VertHeight;
	
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	HorizOff=(long)mxGetScalar(prhs[1]);
	HorizWidth=(long)mxGetScalar(prhs[2]);
	VertOff=(long)mxGetScalar(prhs[3]);
	VertHeight=(long)mxGetScalar(prhs[4]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	// SubArray Inquiry Structure
	DCAM_PARAM_SUBARRAY_INQ SubArrayInquiry;

	// SubArray Set/Get Structure
	DCAM_PARAM_SUBARRAY SubArrayValue;

	long SubArrayHorizMax,SubArrayVertMax;
	long NewHorizOffsetValue = -1;
	long NewHorizWidthValue = -1;
	long NewVertOffsetValue = -1;
	long NewVertHeightValue = -1;

	// Query SubArray feature
	memset( &SubArrayInquiry, 0, sizeof(DCAM_PARAM_SUBARRAY_INQ));
	SubArrayInquiry.hdr.cbSize = sizeof(DCAM_PARAM_SUBARRAY_INQ);
	SubArrayInquiry.hdr.id = DCAM_IDPARAM_SUBARRAY_INQ;
	if (dcam_extended(hDCAM,DCAM_IDMSG_GETPARAM,&SubArrayInquiry,sizeof(DCAM_PARAM_SUBARRAY_INQ)))
	{
		//mexPrintf("\nSubArray Horizontal Offset value is between 0 and %ld in steps of %ld.\n",SubArrayInquiry.hmax - SubArrayInquiry.hunit,SubArrayInquiry.hposunit);
		//mexPrintf("\nSubArray Vertical Offset value between 0 and %ld in steps of %ld.\n",SubArrayInquiry.vmax -  SubArrayInquiry.vunit,SubArrayInquiry.vposunit);

		if (SubArrayInquiry.hunit == SubArrayInquiry.hmax)
		{
			NewHorizOffsetValue = 0;
			NewHorizWidthValue = SubArrayInquiry.hmax;
			mexPrintf("\nHorizontal subarray is not supported.\n");
		}	
		if (SubArrayInquiry.vunit == SubArrayInquiry.vmax)
		{
			NewVertOffsetValue = 0;
			NewVertHeightValue = SubArrayInquiry.vmax;
			mexPrintf("\nVertical subarray is not supported.\n");
		}

	}
	// check valid sub array value
	NewHorizOffsetValue=HorizOff;
	if((NewHorizOffsetValue % SubArrayInquiry.hposunit) || (NewHorizOffsetValue < 0) || (NewHorizOffsetValue > (SubArrayInquiry.hmax - SubArrayInquiry.hunit)))
	{
		mexPrintf("\nEnter a valid SubArray Horizontal Offset value between 0 and %ld in steps of %ld.\n",SubArrayInquiry.hmax - SubArrayInquiry.hunit,SubArrayInquiry.hposunit);
		mexErrMsgTxt("\nInvalid value!\n");
	}
	
	SubArrayHorizMax = ((SubArrayInquiry.hmax - NewHorizOffsetValue) / SubArrayInquiry.hunit) * SubArrayInquiry.hunit;
	NewHorizWidthValue=HorizWidth;
	if (SubArrayHorizMax <= SubArrayInquiry.hunit)
		NewHorizWidthValue = SubArrayInquiry.hunit;
	else if ((NewHorizWidthValue % SubArrayInquiry.hunit) || (NewHorizWidthValue < SubArrayInquiry.hunit) || (NewHorizWidthValue > SubArrayHorizMax))
	{
		mexPrintf( "\nEnter a valid SubArray Horizontal Width value between %ld and %ld in steps of %ld.\n",SubArrayInquiry.hunit,SubArrayHorizMax,SubArrayInquiry.hunit);
		mexErrMsgTxt("\nInvalid value!\n");
	}

	NewVertOffsetValue=VertOff;
	if((NewVertOffsetValue % SubArrayInquiry.vposunit) || (NewVertOffsetValue < 0) || (NewVertOffsetValue > (SubArrayInquiry.vmax -  SubArrayInquiry.vunit)))
	{
		mexPrintf( "\nEnter a valid SubArray Vertical Offset value between 0 and %ld in steps of %ld.\n",SubArrayInquiry.vmax -  SubArrayInquiry.vunit,SubArrayInquiry.vposunit);
		mexErrMsgTxt("\nInvalid value!\n");
	}

	SubArrayVertMax = ((SubArrayInquiry.vmax - NewVertOffsetValue) / SubArrayInquiry.vunit) * SubArrayInquiry.vunit;
	NewVertHeightValue=VertHeight;
	if (SubArrayVertMax <= SubArrayInquiry.vunit)
		NewVertHeightValue = SubArrayInquiry.vunit;
	else if  ((NewVertHeightValue % SubArrayInquiry.vunit) || (NewVertHeightValue < SubArrayInquiry.vunit) || (NewVertHeightValue > SubArrayVertMax))
	{
		mexPrintf( "\nEnter a valid SubArray Vertical Height value between %ld and %ld in steps of %ld.\n",SubArrayInquiry.vunit,SubArrayVertMax,SubArrayInquiry.vunit);
	}

	// set new SubArray settings
	if ((SubArrayInquiry.hunit != SubArrayInquiry.hmax) || (SubArrayInquiry.vunit != SubArrayInquiry.vmax))
	{
		memset( &SubArrayValue, 0, sizeof(DCAM_PARAM_SUBARRAY));
		SubArrayValue.hdr.cbSize = sizeof(DCAM_PARAM_SUBARRAY);
		SubArrayValue.hdr.id = DCAM_IDPARAM_SUBARRAY;

		SubArrayValue.hpos = NewHorizOffsetValue;
		SubArrayValue.hsize = NewHorizWidthValue;
		SubArrayValue.vpos = NewVertOffsetValue;
		SubArrayValue.vsize = NewVertHeightValue;
		if (dcam_extended(hDCAM,DCAM_IDMSG_SETGETPARAM,&SubArrayValue,sizeof(DCAM_PARAM_SUBARRAY)))
			mexPrintf("\nThe image SubArray region settings are\nSubArray Horizontal Offset = %ld\nSubArray Horizontal Width = %ld\nSubArray Vertical Offset = %ld\nSubArray Vertical Height = %ld\n",SubArrayValue.hpos,SubArrayValue.hsize,SubArrayValue.vpos,SubArrayValue.vsize);
		else
			printf("\nAn error occurred trying to set the new SubArray region to the camera.\n");
	}

	

		
	return;
}