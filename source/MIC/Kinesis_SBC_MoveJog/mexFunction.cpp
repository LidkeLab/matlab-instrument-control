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
		mexErrMsgTxt("Proper Usage: Kinesis_LD_Close('SerialNoString',Channel,Direction)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");


	char * input_buf = mxArrayToString(prhs[0]);
	int Channel = (int)mxGetScalar(prhs[1]);
    double Direction = mxGetScalar(prhs[2]);

	if (Direction != 1 && Direction !=-1 )
		mexErrMsgTxt("The third input must either be 1 (Forward) or -1 (Backward).");

	if (Direction == 1)
	{
		SBC_MoveJog(input_buf, Channel, (MOT_TravelDirection)1);
	}
	if (Direction == -1)
	{
		SBC_MoveJog(input_buf, Channel, (MOT_TravelDirection)2);
	}

	mxFree(input_buf);
	return;
 }
