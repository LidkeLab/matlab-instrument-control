#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.Piezo.h"

#ifndef max
//! not defined in the C standard used by visual studio
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
//! not defined in the C standard used by visual studio
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif
#define pi 3.141592f


//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	if (nrhs != 0)
		mexErrMsgTxt("Proper Usage: N=Kinesis_TLI_BuildDeviceList()");

	mexPrintf("Building Device List... \n");
	int N = 0;
	float TimeoutSeconds = 10;

	if (TLI_BuildDeviceList() == 0){ //This must be called once before any communication.  
		N = TLI_GetDeviceListSize();
		mexPrintf("Getting Number of Devices...\n");

		//wait until zeroing finishes
		ULONGLONG T1;
		T1 = GetTickCount64();
		bool Timeout = 1;
		while (Timeout && (N == 0)){

			Sleep(100);
			N = TLI_GetDeviceListSize();
			Timeout = double((GetTickCount64() - T1)) < (TimeoutSeconds * 1000); //30s timeout. 
		}

	}

	plhs[0] = mxCreateDoubleScalar(N);
	return;
 }