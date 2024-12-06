#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.KCube.Piezo.h"

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

	// short __cdecl PCC_SetPosition  ( char const *  serialNo,  WORD  position )


	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPosition('SerialNoString,Current)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPosition('SerialNoString,Current').  First input must be character array.");

	if (!mxIsClass(prhs[1], "uint32"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_PCC_SetPosition('SerialNoString,Current').  Second Input must be uint32");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	UINT32 *Current = (UINT32*)mxGetData(prhs[1]);

	//PCC_Enable(input_buf);
	short Err = PCC_SetPosition(input_buf, Current[0]);
	plhs[0] = mxCreateDoubleScalar(Err);

	mxFree(input_buf);
	return;
 }