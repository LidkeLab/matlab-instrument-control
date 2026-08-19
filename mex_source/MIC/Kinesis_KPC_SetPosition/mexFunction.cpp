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

	// short __cdecl KPC_SetPosition  ( char const *  serialNo,  WORD  position )
	// position is a percentage of maximum travel, range 0 to 32767 (0 to 100%).
	// The command is ignored if not in closed loop mode.

	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_KPC_SetPosition('SerialNoString',Position)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_KPC_SetPosition('SerialNoString',Position).  First input must be character array.");

	if (!mxIsClass(prhs[1], "uint16"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_KPC_SetPosition('SerialNoString',Position).  Second input must be uint16 (0-32767).");

	char * input_buf = mxArrayToString(prhs[0]);

	unsigned short *Position = (unsigned short*)mxGetData(prhs[1]);

	short Err = KPC_SetPosition(input_buf, Position[0]);
	plhs[0] = mxCreateDoubleScalar(Err);

	mxFree(input_buf);
	return;
 }
