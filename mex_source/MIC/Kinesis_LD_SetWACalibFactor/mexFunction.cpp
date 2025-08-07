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

	// short __cdecl LD_SetWACalibFactor  ( char const *  serialNo, float  calibFactor)



	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_Identify('SerialNoString',CalibFactor)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_Identify('SerialNoString,CalibFactor').  First input must be character array.");

	if (!mxIsClass(prhs[1], "single"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_Identify('SerialNoString,CalibFactor').  Second Input must be float");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	float WperA = (float)mxGetScalar(prhs[1]);

	short Err = LD_SetLaserSetPoint(input_buf, WperA);
	plhs[0] = mxCreateDoubleScalar(Err);
	
	mxFree(input_buf);
	return;
 }