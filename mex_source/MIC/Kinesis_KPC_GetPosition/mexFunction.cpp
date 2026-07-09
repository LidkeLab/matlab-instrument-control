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

	// WORD __cdecl KPC_GetPosition  ( char const *  serialNo )
	// Returns position as a percentage of maximum travel, range 0 to 32767 (0 to 100%).
	// The result is undefined if not in closed loop mode.
	// Requires polling to be active (started by Kinesis_KPC_Open).

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Position=Kinesis_KPC_GetPosition('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Position=Kinesis_KPC_GetPosition('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	WORD Position = KPC_GetPosition(input_buf);
	plhs[0] = mxCreateDoubleScalar((double)Position);

	mxFree(input_buf);
	return;
 }
