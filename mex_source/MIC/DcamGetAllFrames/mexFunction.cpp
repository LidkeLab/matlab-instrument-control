#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



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
	// input handle from Matlab
	Handle=(long)mxGetScalar(prhs[0]);
	FrameCount=(long)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");

	hDCAM=(HDCAM)Handle;
    // output image
	if (dcam_getdatasize(hDCAM,&ImageSize)==FALSE)
		mexPrintf("Error = 0x%08lX\nCould not get the data size of the camera.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	mexPrintf("\nImage size is %ld by %ld\n",ImageSize.cx,ImageSize.cy);

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
		//mexPrintf("\n %ld Bytes per pixel\n",BytesPerPixel);
	}
	else
		mexPrintf("Error = 0x%08lX\nCould not get the data type of the camera.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	
	if (DataType!=DCAM_DATATYPE_UINT16)
		mexErrMsgTxt("\nData type has to be Uint 16\n");
	// creat output
	outsize[0]=ImageSize.cx*ImageSize.cy*FrameCount;
	plhs[0]=mxCreateNumericArray(1,outsize,mxUINT16_CLASS,mxREAL);
	OutImage=(unsigned short*)mxGetData(plhs[0]);
	//mexErrMsgTxt("handle must be type INT 32.");

	
	mexPrintf("Starting to wait for capture end\n");
	_DWORD	Event=DCAM_EVENT_CAPTUREEND;
	//if(dcam_wait(hDCAM,&Event,DCAM_WAIT_INFINITE,NULL))
	if (dcam_wait(hDCAM, &Event, 10000, NULL))
	{
		if (dcam_gettransferinfo(hDCAM,&NewestFrameIndex,&TotalFrames))
			mexPrintf("\nrecorded total frame numbers is %ld\n",TotalFrames);
		for (long kk=0;kk<FrameCount;kk++)
		{
			if (dcam_lockdata(hDCAM,&pTop,&pRowBytes,kk) && pTop)
			{
				//mexPrintf("\n %ld Bytes in each row\n",pRowBytes);
				for (int ii=0;ii < ImageSize.cy;ii++)
				{
					memcpy(OutImage,pTop,ImageSize.cx*BytesPerPixel);
					pTop=(void*)((char*)pTop+pRowBytes);
					OutImage=(unsigned short*)((char*)OutImage+ImageSize.cx*BytesPerPixel);
				}
				dcam_unlockdata(hDCAM);
			}
			else
				mexPrintf("Error = 0x%08lX\ndcam_lockdata on frame index %ld failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0),NewestFrameIndex);
		}
	}
	else
		mexPrintf("Error = 0x%08lX\ndcam_wait on frame index %ld failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0),NewestFrameIndex);

	return;
}