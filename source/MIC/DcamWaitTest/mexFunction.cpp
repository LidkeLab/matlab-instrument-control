#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.

void dcam_test_dcamwait(HDCAM hdcam, int nTimes);

//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	HDCAM	hDCAM = NULL;
	long	Handle;
	SIZE    ImageSize;
	DCAM_DATATYPE DataType;
	long BytesPerPixel;
	// input handle from Matlab
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
    // output image
	if (dcam_getdatasize(hDCAM,&ImageSize)==FALSE)
		mexPrintf("Error = 0x%08lX\nCould not get the data size of the camera.\n",(_DWORD)dcam_getlasterror(hDCAM,NULL,0));
	//mexPrintf("\nImage size is %ld by %ld\n",ImageSize.cx,ImageSize.cy);

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

	dcam_test_dcamwait(hDCAM,100);
		
	return;
}

void dcam_test_dcamwait( HDCAM hdcam, int nTimes )
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
	long	NewestFrameIndex=-1;
	long	TotalFrames = -1;
	for( i = 0; i < nTimes; i++ )
	{
		char	c;
		_DWORD	dw = 0
					| DCAM_EVENT_FRAMESTART
					| DCAM_EVENT_FRAMEEND
					| DCAM_EVENT_CYCLEEND
					| DCAM_EVENT_VVALIDBEGIN
					;
		mexPrintf("dw:%d\n",dw);
		if( dcam_wait( hdcam, &dw, timeout, NULL ) )
		{
			if (dcam_gettransferinfo(hdcam,&NewestFrameIndex,&TotalFrames))
			{
				mexPrintf("Newest Frame index: %d\n",NewestFrameIndex);
				mexPrintf("TotalFrames: %d\n",TotalFrames);
			}
			else
				mexPrintf("Error = 0x%08lX\ndcam_gettransferinfo failed.\n\n",(_DWORD)dcam_getlasterror(hdcam,NULL,0));

			mexPrintf("dw:%d\n",dw);
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

	mexPrintf( "\n" );
	mexPrintf( "FRAMESTART:"	"\t%d\n", nFRAMESTART	);
	mexPrintf( "FRAMEEND:"		"\t%d\n", nFRAMEEND		);
	mexPrintf( "CYCLEEND:"		"\t%d\n", nCYCLEEND		);
	mexPrintf( "VVALIDBEGIN:"	"\t%d\n", nVVALIDBEGIN	);
	if( nUNKNOWNEVENT != 0 )
	mexPrintf( "UNKNOWNEVENT:"	"\t%d\n", nUNKNOWNEVENT	);
	mexPrintf( "TIMEOUT:"		"\t%d\n", nTIMEOUT		);
	if( nERROR != 0 )
	mexPrintf( "ERROR:"		"\t%d\n", nERROR		);
}
