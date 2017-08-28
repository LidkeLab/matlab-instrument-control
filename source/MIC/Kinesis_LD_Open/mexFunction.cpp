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

	// short __cdecl LD_Open  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_Open('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_LD_Open('SerialNoString').  Input must be character array.");

	short S = TLI_BuildDeviceList(); //This must be called once before any communication.  
	int N = TLI_GetDeviceListSize();

	if (N == 0)
		mexErrMsgTxt("Can't find any Kinesis Instruments.  Try running Kinesis_TLI_BuildDeviceList()");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);
	short Err;
	try{
		Err = LD_Open(input_buf);
	}
	catch (...)
	{
		Err = -1;
		mexPrintf("Exception opening: %s\n", input_buf);
	}
	plhs[0] = mxCreateDoubleScalar(Err);
	if (Err!=0){ //If errror opening, send back error code. 
		LD_Identify(input_buf);
		LD_StartPolling(input_buf, 200);
	}
	mxFree(input_buf);
	return;
 }