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



	if (dcam_getdatasize(hDCAM,&ImageSize)==FALSE)
		mexPrintf("Error = 0x%08lX\nCould not get the data size of the camera.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

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

	dcam_test_dcamwait(&Signal,hDCAM,4);
	//mexPrintf("Signal: %d\n",Signal);
	if(Signal>0)
		dcam_test_dcamwait(&Signal,hDCAM,4);
	if (dcam_gettransferinfo(hDCAM,&NewestFrameIndex,&TotalFrames))
	{
		while (NewestFrameIndex<0)
		{
			dcam_test_dcamwait(&Signal,hDCAM,4);
			if (dcam_gettransferinfo(hDCAM,&NewestFrameIndex,&TotalFrames)==FALSE)
				mexPrintf("Error = 0x%08lX\ndcam_gettransferinfo Failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
		}
		//mexPrintf("Newest Frame index: %d\n",NewestFrameIndex);
		//dcam_test_dcamwait(hDCAM,4);
		if (dcam_lockdata(hDCAM,&pTop,&pRowBytes,NewestFrameIndex) && pTop)
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
	else
		mexPrintf("Error = 0x%08lX\ndcam_gettransferinfo failed.\n\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));

	return;
}

void dcam_test_dcamwait( int32 *Signals, HDCAM hdcam, int nTimes )
{
	int	i;
	int32	timeout = 100;	// 100 msec
	int32	nFRAMESTART = 0;
	int32	nFRAMEEND	= 0;
	int32	nCYCLEEND	= 0;
	int32	nVVALIDBEGIN= 0;
	int32	nUNKNOWNEVENT = 0;
	int32	nTIMEOUT	= 0;
	int32	nERROR		= 0;
	for( i = 0; i < nTimes; i++ )
	{
		char	c;
		_DWORD	dw = 0
					| DCAM_EVENT_FRAMESTART
					| DCAM_EVENT_FRAMEEND
					| DCAM_EVENT_CYCLEEND
					| DCAM_EVENT_VVALIDBEGIN
					;
		/*_DWORD	dw = 0
					| DCAM_EVENT_FRAMESTART
					;*/
		if( dcam_wait( hdcam, &dw, timeout, NULL ) )
		{
			switch( dw )
			{
			case DCAM_EVENT_FRAMESTART:		c = 'S';	nFRAMESTART++;	break;
			case DCAM_EVENT_FRAMEEND:		c = 'F';	nFRAMEEND++;	break;
			case DCAM_EVENT_CYCLEEND:		c = 'C';	nCYCLEEND++;	break;
			case DCAM_EVENT_VVALIDBEGIN:	c = 'V';	nVVALIDBEGIN++;	break;
			default:						c = 'n';	nUNKNOWNEVENT++;break;	// never happen
			}
		}
		else
		{
			int32	err;
			err = dcam_getlasterror( hdcam );
			if( err == DCAMERR_TIMEOUT )
			{
				// event did not happened
				c = '.';
				nTIMEOUT++;
			}
			else
			{
				// unexpected error happened.
				c = 'e';
				nERROR++;
			}
		}

		putchar( c );
	}
	Signals[0]=nCYCLEEND;
	/*mexPrintf( "\n" );
	if(nFRAMESTART != 0)
		mexPrintf( "FRAMESTART:"	"\t%d\n", nFRAMESTART	);
	if(nFRAMEEND != 0) 
		mexPrintf( "FRAMEEND:"		"\t%d\n", nFRAMEEND		);
	if(nCYCLEEND !=0 )
		mexPrintf( "CYCLEEND:"		"\t%d\n", nCYCLEEND		);
	if(nVVALIDBEGIN != 0)
		mexPrintf( "VVALIDBEGIN:"	"\t%d\n", nVVALIDBEGIN	);
	if( nUNKNOWNEVENT != 0 )
		mexPrintf( "UNKNOWNEVENT:"	"\t%d\n", nUNKNOWNEVENT	);
	if(nTIMEOUT !=0)
		mexPrintf( "TIMEOUT:"		"\t%d\n", nTIMEOUT		);
	if( nERROR != 0 )
		mexPrintf( "ERROR: dcam_wait"		"\t%d\n", nERROR		);
	*/	
}