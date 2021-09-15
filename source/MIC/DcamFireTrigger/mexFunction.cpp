#include "stdafx.h"

#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.

void dcamcon_show_dcamerr(HDCAM hdcam, const char* apiname, const char* fmt = NULL, ...);


// show DCAM error code
void dcamcon_show_dcamerr(HDCAM hdcam, const char* apiname, const char* fmt, ...)
{
	char	buf[256];
	memset(buf, 0, sizeof(buf));

	// get error information
	int32	err = dcam_getlasterror(hdcam, buf, sizeof(buf));
	printf("failure: %s returns 0x%08X\n", apiname, err);
	if (buf[0])	printf("%s\n", buf);

	if (fmt != NULL)
	{
		va_list	arg;
		va_start(arg, fmt);
		vprintf(fmt, arg);
		va_end(arg);
	}
}


//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	HDCAM	hDCAM = NULL;
	long	Handle;
	
	// input handle from Matlab
	Handle=(long)mxGetScalar(prhs[0]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;

	// fire trigger.
	//printf("dcam_firetrigger()\n");
	if (!dcam_firetrigger(hDCAM))
	{
		dcamcon_show_dcamerr(hDCAM, "dcam_firetrigger()");
		return;
	}


	// wait frame coming.
	int32	timeout = 10000;
	_DWORD	dw = DCAM_EVENT_FRAMEEND;
	//printf("dcam_wait( FRAMEEND, 10s )\n");
	if (!dcam_wait(hDCAM, &dw, timeout, NULL))
	{
		dcamcon_show_dcamerr(hDCAM, "dcam_wait()");
		return;
	}

		

	
}