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

	// DWORD __cdecl KPC_GetStatusBits  ( char const *  serialNo )
	// Useful bits:
	//   0x00000001 Piezo actuator connected
	//   0x00000010 Piezo channel has been zeroed
	//   0x00000020 Piezo channel is zeroing
	//   0x00000100 Strain gauge feedback connected
	//   0x00000400 Position control mode (1=Closed loop, 0=Open loop)
	//   0x80000000 Channel enabled
	// Requires polling to be active (started by Kinesis_KPC_Open).

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: StatusBits=Kinesis_KPC_GetStatusBits('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: StatusBits=Kinesis_KPC_GetStatusBits('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	DWORD StatusBits = KPC_GetStatusBits(input_buf);
	plhs[0] = mxCreateDoubleScalar((double)StatusBits);

	mxFree(input_buf);
	return;
 }
