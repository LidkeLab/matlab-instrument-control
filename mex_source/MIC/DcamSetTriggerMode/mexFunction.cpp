#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	TriggerMode;
	long	NewTriggerMode;
	_DWORD CameraCapability = 0;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	NewTriggerMode=(long)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	if (!mxIsInt32(prhs[1]))
		mexErrMsgTxt("trigger mode must be type INT 32.");

	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	/*if (dcam_getcapability(hDCAM,&CameraCapability,DCAM_QUERYCAPABILITY_FUNCTIONS))
	{
		if (!USE_DCAM_API_MEMORY_MANAGEMENT && !(CameraCapability & DCAM_CAPABILITY_USERMEMORY))
			mexPrintf ("\nUser Memory Management is not supported by this camera's module!\n");
		else
		{
			_DWORD TriggerCaps;
			CameraCapability &= 0x00FFFF00;
			TriggerCaps = CameraCapability;	
			mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_EDGE)
			{
				mexPrintf ("TRIGGER_EDGE\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_EDGE;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}

			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_LEVEL)
			{
				mexPrintf ("TRIGGER_LEVEL\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_LEVEL;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_MULTISHOT_SENSITIVE)
			{
				mexPrintf ("TRIGGER_MULTISHOT_SENSITIVE\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_MULTISHOT_SENSITIVE;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_CYCLE_DELAY)
			{
				mexPrintf ("TRIGGER_CYCLE_DELAY\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_CYCLE_DELAY;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_SOFTWARE)
			{
				mexPrintf ("TRIGGER_SOFTWARE\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_SOFTWARE;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_FASTREPETITION)
			{
				mexPrintf ("TRIGGER_FASTREPETITION\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_FASTREPETITION;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_TDI)
			{
				mexPrintf ("TRIGGER_TDI\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_TDI;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_TDIINTERNAL)
			{
				mexPrintf ("TRIGGER_TDIINTERNAL\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_TDIINTERNAL;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_POSI)
			{
				mexPrintf ("TRIGGER_POSI\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_POSI;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_NEGA)
			{
				mexPrintf ("TRIGGER_NEGA\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_NEGA;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_START)
			{
				mexPrintf ("TRIGGER_START\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_START;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
			if (TriggerCaps & DCAM_CAPABILITY_TRIGGER_SYNCREADOUT)
			{
				mexPrintf ("TRIGGER_SYNCREADOUT\n");
				TriggerCaps &= ~DCAM_CAPABILITY_TRIGGER_SYNCREADOUT;
				mexPrintf("\nTrigger capability: 0x%08lX\n",TriggerCaps);
			}
		}
	}*/

	if (dcam_settriggermode(hDCAM,NewTriggerMode))
	{
		if (dcam_gettriggermode(hDCAM,&TriggerMode))
		{
			if(TriggerMode==DCAM_TRIGMODE_INTERNAL) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_INTERNAL\n");
			if(TriggerMode==DCAM_TRIGMODE_EDGE) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_EDGE\n");
			if(TriggerMode==DCAM_TRIGMODE_LEVEL) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_LEVEL\n");
			if(TriggerMode==DCAM_TRIGMODE_MULTISHOT_SENSITIVE) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_MULTISHOT_SENSITIVE\n");
			if(TriggerMode==DCAM_TRIGMODE_CYCLE_DELAY) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_CYCLE_DELAY\n");
			if(TriggerMode==DCAM_TRIGMODE_SOFTWARE) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_SOFTWARE\n");
			if(TriggerMode==DCAM_TRIGMODE_FASTREPETITION) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_FASTREPETITION\n");
			if(TriggerMode==DCAM_TRIGMODE_TDI) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_TDI\n");
			if(TriggerMode==DCAM_TRIGMODE_TDIINTERNAL) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_TDIINTERNAL\n");
			if(TriggerMode==DCAM_TRIGMODE_START) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_START\n");
			if(TriggerMode==DCAM_TRIGMODE_SYNCREADOUT) 
				mexPrintf("\ncurrent trigger mode is TRIGMODE_SYNCREADOUT\n");
		}
		else
			mexPrintf("\nAn error occurred trying to get trigger mode of the camera.\n");
	}
	else
		mexPrintf("\nAn error occurred trying to set trigger mode to the camera.\n");

	return;
}