#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.

void dcam_test_dcamwait(int32 *Signals, HDCAM hdcam, int nTimes );

//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	FrameCount;
	SIZE    ImageSize;
	long	NewestFrameIndex = -1;
	long	TotalFrames = 0;
	void*	pTop=0;
	long	pRowBytes=0;
	unsigned short* OutImage=0;
	DCAM_DATATYPE DataType;
	long BytesPerPixel;
	mwSize	outsize[1];
	int32	Signal=0;
	// input handle from Matlab
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
    // output image


	//mexPrintf("Getting Data Size\n");

	if (dcam_getdatasize(hDCAM,&ImageSize)==FALSE)
		mexPrintf("Error = 0x%08lX\nCould not get the data size of the camera.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	//mexPrintf("\nImage size is %ld by %ld\n",ImageSize.cx,ImageSize.cy);

	//mexPrintf("Getting Data Type\n");
	if (dcam_getdatatype(hDCAM,&DataType))
	{
		switch (DataType) {
		case DCAM_DATATYPE_UINT8:
		case DCAM_DATATYPE_INT8:
			BytesPerPixel = 1;
			break;
		case DCAM_DATATYPE_UINT16:
		case DCAM_DATATYPE_INT16:
			BytesPerPixel = 2;
			break;
		case DCAM_DATATYPE_RGB24:
		case DCAM_DATATYPE_BGR24:
			BytesPerPixel = 3;
			break;
		case DCAM_DATATYPE_RGB48:
		case DCAM_DATATYPE_BGR48:
			BytesPerPixel = 6;
		}
		//mexPrintf("\n%ld Bytes per pixel\n",BytesPerPixel);
	}
	else
		mexPrintf("Error = 0x%08lX\nCould not get the data type of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	
	if (DataType!=DCAM_DATATYPE_UINT16)
		mexErrMsgTxt("\nData type has to be Uint 16\n");

	// create output
	outsize[0]=ImageSize.cx*ImageSize.cy;
	plhs[0]=mxCreateNumericArray(1,outsize,mxUINT16_CLASS,mxREAL);
	OutImage=(unsigned short*)mxGetData(plhs[0]);
	//mexErrMsgTxt("handle must be type INT 32.");

	if (dcam_gettransferinfo(hDCAM, &NewestFrameIndex, &TotalFrames))
	{
		if (NewestFrameIndex > -1)
		{

			if (dcam_lockdata(hDCAM, &pTop, &pRowBytes, NewestFrameIndex) && pTop)
			{
				for (int ii = 0; ii < ImageSize.cy; ii++)
				{
					memcpy(OutImage, pTop, ImageSize.cx*BytesPerPixel);
					pTop = (void*)((char*)pTop + pRowBytes);
					OutImage = (unsigned short*)((char*)OutImage + ImageSize.cx*BytesPerPixel);
				}
				dcam_unlockdata(hDCAM);
			}
			else
				mexPrintf("Error = 0x%08lX\ndcam_lockdata on frame index %ld failed.\n\n", (_DWORD)dcam_getlasterror(hDCAM, NULL, 0), NewestFrameIndex);
		}
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_gettransferinfo failed.\n\n", (_DWORD)dcam_getlasterror(hDCAM, NULL, 0));

	return;
}

