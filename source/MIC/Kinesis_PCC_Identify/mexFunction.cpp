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

	// void __cdecl PCC_Identify  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Kinesis_PCC_Identify('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Kinesis_PCC_Identify('SerialNoString').  Input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);
	mexPrintf("Identifying Device: %s\n", input_buf);
	short Err;
	if (TLI_BuildDeviceList() == 0){ //This must be called once before any communication.  
		short n = TLI_GetDeviceListSize();
		mexPrintf("Opening Device: %s\n", input_buf);
		Err = PCC_Open(input_buf);
		
		if (!Err) //If errror opening, send back error code. 
		{
			PCC_Identify(input_buf);
			PCC_Close(input_buf);
		}
	}
	else{
		Err = -1;
	}
	plhs[0] = mxCreateDoubleScalar(Err);
	mxFree(input_buf);
	return;
 }