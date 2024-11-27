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
		mexErrMsgTxt("Proper Usage: Kinesis_LD_Close('SerialNoString',Channel)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");


	char * input_buf = mxArrayToString(prhs[0]);
	short Channel = (short)mxGetScalar(prhs[1]);

	
	short Err = SBC_Home(input_buf, Channel);
	mxFree(input_buf);
	plhs[0] = mxCreateDoubleScalar(Err); //output.

	//SBC_RequestPosition(input_buf, Channel);
	//Sleep(100);    
	//int Pos2 = SBC_GetPosition(input_buf, Channel);
	//mexPrintf("Position: %d\n",Pos2);


 }