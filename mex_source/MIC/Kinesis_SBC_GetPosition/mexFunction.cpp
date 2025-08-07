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

	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_GetPosition('SerialNoString',Channel)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	//if (!mxIsClass(prhs[1], "int"))
	//	mexErrMsgTxt("Second input must be an integer (int32).");

	char * input_buf = mxArrayToString(prhs[0]);
	int Channel = (int)mxGetScalar(prhs[1]);
	
	SBC_RequestPosition(input_buf, Channel);
	plhs[0] = mxCreateDoubleScalar((double)SBC_GetPosition(input_buf, Channel) / 819200);//each mm corresponds with 2 pitches which corresponds to 819200 mm.
	//mexPrintf("Position: %d", SBC_GetPosition(input_buf, Channel));
	//mexPrintf("3\n");

	mxFree(input_buf);

 }