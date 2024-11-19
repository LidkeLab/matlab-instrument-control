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

	if (nrhs != 3)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_SBC_SetJogStepSize('SerialNoString', Channel, Step)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	//if (!mxIsClass(prhs[1], "int"))
	//	mexErrMsgTxt("Second input must be an integer (int32).");

	char* input_buf = mxArrayToString(prhs[0]);
	short Channel = (short)mxGetScalar(prhs[1]);
	double Step = mxGetScalar(prhs[2]) * 819200; //each 819200 microsteps corresponds to 1 mm.
	int StepUnit = (int)Step;

	SBC_SetJogStepSize(input_buf, Channel, StepUnit);
	
	mxFree(input_buf);
	return;

 }