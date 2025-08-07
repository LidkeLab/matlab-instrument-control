#include "stdafx.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.



//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	nCameras = 0;

	long	CameraIndex = 0;
	long	Binning;
	long	i;
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	CurrentBinning;
	_DWORD CameraCapability = 0;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	Binning=(long)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	//if (!mxIsInt32(prhs[1]))
		//mexErrMsgTxt("Binning  must be type INT 32.");

	hDCAM=(HDCAM)Handle;
	//mexErrMsgTxt("Serial number must be a string.");

	/*if (dcam_getcapability(hDCAM,&CameraCapability,DCAM_QUERYCAPABILITY_FUNCTIONS))
	{
		if (!USE_DCAM_API_MEMORY_MANAGEMENT && !(CameraCapability & DCAM_CAPABILITY_USERMEMORY))
			printf ("\n\nUser Memory Management is not supported by this camera's module!\n\n");
		else
		{
			_DWORD BinningCaps;
			CameraCapability &= 0x000000FE;
			BinningCaps = CameraCapability;			
			mexPrintf("\nBinning capability: 0x%08lX\n",BinningCaps);

			mexPrintf("1 x 1 Binning\n");
			if (BinningCaps & DCAM_CAPABILITY_BINNING2)
			{
				mexPrintf ("2 x 2 Binning\n");
				BinningCaps &= ~DCAM_CAPABILITY_BINNING2;
			}

			if (BinningCaps & DCAM_CAPABILITY_BINNING4)
			{
				mexPrintf ("4 x 4 Binning\n");
				BinningCaps &= ~DCAM_CAPABILITY_BINNING4;
			}

			if (BinningCaps & DCAM_CAPABILITY_BINNING8)
			{
				mexPrintf ("8 x 8 Binning\n");
				BinningCaps &= ~DCAM_CAPABILITY_BINNING8;
			}

			if (BinningCaps & DCAM_CAPABILITY_BINNING16)
			{
				mexPrintf ("16 x 16 Binning\n");
				BinningCaps &= ~DCAM_CAPABILITY_BINNING16;
			}

			if (BinningCaps & DCAM_CAPABILITY_BINNING32)
			{
				mexPrintf ("32 x 32 Binning\n");
				BinningCaps &= ~DCAM_CAPABILITY_BINNING32;
			}
		}
	}
*/
	if (dcam_setbinning(hDCAM,Binning))
	{
		dcam_getbinning(hDCAM,&CurrentBinning);
		mexPrintf("\nThe camera's binning mode is %ld\n",CurrentBinning);
	}
	else
		mexPrintf("\nAn error occurred trying to set the camera's binning mode.\n");

	return;
}