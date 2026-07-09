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

	// short __cdecl KPC_SetPositionControlMode  ( char const *  serialNo,  PZ_ControlModeTypes  mode )
	// mode: 1 = Open Loop, 2 = Closed Loop, 3 = Open Loop Smooth, 4 = Closed Loop Smooth

	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_KPC_SetPositionControlMode('SerialNoString',Mode)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_KPC_SetPositionControlMode('SerialNoString',Mode).  First input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	short Mode = (short)mxGetScalar(prhs[1]);

	short Err = KPC_SetPositionControlMode(input_buf, (PZ_ControlModeTypes)Mode);
	plhs[0] = mxCreateDoubleScalar(Err);

	mxFree(input_buf);
	return;
 }
