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

	// WORD __cdecl KPC_GetMaximumTravel  ( char const *  serialNo )
	// Returns the maximum travel of the strain gauge in steps of 100 nm.
	// e.g. 200 = 20 um.

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Travel=Kinesis_KPC_GetMaximumTravel('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Travel=Kinesis_KPC_GetMaximumTravel('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	KPC_RequestMaximumTravel(input_buf);
	Sleep(300); //allow the async request to complete before reading back
	WORD Travel = KPC_GetMaximumTravel(input_buf);
	plhs[0] = mxCreateDoubleScalar((double)Travel);

	mxFree(input_buf);
	return;
 }
