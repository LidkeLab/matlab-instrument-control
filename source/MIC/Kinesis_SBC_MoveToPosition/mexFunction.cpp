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
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_GetPosition('SerialNoString', Channel, Position)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	//if (!mxIsClass(prhs[1], "int"))
	//	mexErrMsgTxt("The second input must be an integer (int32).");

	//if (!mxIsClass(prhs[2], "int"))
	//	mexErrMsgTxt("The third input must be an integer (int32).");
	char * input_buf = mxArrayToString(prhs[0]);
	short Channel = (short)mxGetScalar(prhs[1]);
	double Pos = mxGetScalar(prhs[2])*819200; //each 819200 microsteps corresponds to 1 mm.
	int Position = (int)Pos;

	if (Position > 4 * 819200)
		mexErrMsgTxt("The stage cannot go further than 4 mm.");

	if (Position < -4 * 819200)
		mexErrMsgTxt("The stage cannot go further than -4 mm.");

	SBC_MoveToPosition(input_buf, Channel, Position);
	mxFree(input_buf);
	return;
 }