#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotor.h"

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

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Kinesis_LD_Close('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);

	SBC_StopPolling(input_buf, 1);
	SBC_StopPolling(input_buf, 2);
	SBC_StopPolling(input_buf, 3);
	SBC_Close(input_buf);

	mxFree(input_buf);
	return;
 }