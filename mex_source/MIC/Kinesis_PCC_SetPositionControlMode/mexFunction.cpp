#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.Piezo.h"

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

	// void __cdecl PCC_Close  ( char const *  serialNo ) 

	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPositionControlMode('SerialNoString,Mode=1(open),2(closed)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPositionControlMode('SerialNoString,Mode=1(open),2(closed).  First input must be character array.");

	if (!mxIsClass(prhs[1], "uint16"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPositionControlMode('SerialNoString,Mode=1(open),2(closed).  Second Input must be double uint16");

	char* input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	int Mode = (int)mxGetScalar(prhs[1]);
	short Err;
	switch (Mode) {
		//open loop mode
	case 1: Err = PCC_SetPositionControlMode(input_buf, PZ_OpenLoop);
		break;
	case 2: Err = PCC_SetPositionControlMode(input_buf, PZ_CloseLoop);
		break;
	default: Err = -1;
	}

	plhs[0] = mxCreateDoubleScalar(Err);

	mxFree(input_buf);
	return;
 }