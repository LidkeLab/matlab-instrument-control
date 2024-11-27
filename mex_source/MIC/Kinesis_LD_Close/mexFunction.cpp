#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.LaserDiode.h"

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

	// void __cdecl LD_Close  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Kinesis_LD_Close('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Kinesis_LD_Close('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	LD_StopPolling(input_buf);
	LD_Close(input_buf);
	
	
	mxFree(input_buf);
 }