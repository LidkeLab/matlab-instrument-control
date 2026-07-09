#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.PiezoStrainGauge.h"

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

	// bool __cdecl KPC_SetZero  ( char const *  serialNo )
	// Initiates the strain gauge zeroing routine.  This routine takes ~30 s
	// to complete; poll Kinesis_KPC_GetStatusBits to detect completion
	// (bit 0x20 = zeroing, bit 0x10 = zeroed).

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Success=Kinesis_KPC_SetZero('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Success=Kinesis_KPC_SetZero('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	bool Success = KPC_SetZero(input_buf);
	plhs[0] = mxCreateDoubleScalar((double)Success);

	mxFree(input_buf);
	return;
 }
