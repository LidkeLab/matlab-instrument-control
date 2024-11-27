#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.StrainGauge.h"

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
void mexFunction(int nlhs, mxArray *plhs[], int	nrhs, const	mxArray	*prhs[]) {

	// short __cdecl SG_SetZero  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Timeout=Kinesis_SG_SetZero('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Timeout=Kinesis_SG_SetZero('SerialNoString').  Input must be character array.");

	short S = TLI_BuildDeviceList(); //This must be called once before any communication.  
	int N = TLI_GetDeviceListSize();

	if (N == 0)
		mexErrMsgTxt("Can't find any Kinesis Instruments.  Try running Kinesis_TLI_BuildDeviceList()");

	char * input_buf = mxArrayToString(prhs[0]);
	float TimeoutSeconds = 30;

	SG_RequestStatus(input_buf);
	SG_SetZero(input_buf);

	//wait until zeroing finishes
	ULONGLONG T1, T2;
	T1 = GetTickCount64();
	bool Timeout = 1;
	DWORD Status;
	Sleep(200);
	SG_RequestStatus(input_buf);
	Status = SG_GetStatusBits(input_buf);
	SG_RequestStatus(input_buf);
	Status = SG_GetStatusBits(input_buf);

	while (Timeout && (0x00000020 & Status)){
		Sleep(100);
		Status = SG_GetStatusBits(input_buf);
		//mexPrintf("Device Open: %x\n", Status);
		Timeout = double((GetTickCount64() - T1)) < (TimeoutSeconds * 1000); //30s timeout. 
	}

	plhs[0] = mxCreateDoubleScalar(!Timeout);
	mxFree(input_buf);
	return;
}