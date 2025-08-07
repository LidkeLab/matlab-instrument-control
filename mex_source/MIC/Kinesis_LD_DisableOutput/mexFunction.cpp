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

	// short __cdecl LD_DisableOutput  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_DisableOutput('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_DisableOutput('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	short Err = LD_DisableOutput(input_buf);
	plhs[0] = mxCreateDoubleScalar(Err);
	
	mxFree(input_buf);
	return;
 }