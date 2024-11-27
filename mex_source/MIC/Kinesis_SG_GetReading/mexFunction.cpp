#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <mex.h>
#include <conio.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.TCube.StrainGauge.h"

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

	// int __cdecl SG_GetReadingExt  ( char const *  serialNo,  	bool  clipReadng,		bool *  overrange		)


	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Out=Kinesis_SG_GetReading('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Out=Kinesis_SG_GetReading('SerialNoString').  Input must be character array.");

	short S = TLI_BuildDeviceList(); //This must be called once before any communication.  
	int N = TLI_GetDeviceListSize();

	if (N == 0)
		mexErrMsgTxt("Can't find any Kinesis Instruments.  Try running Kinesis_TLI_BuildDeviceList()");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	short Err;
	short Reading;
	bool IsClipped;

	SG_RequestStatus(input_buf);
	Reading = SG_GetReadingExt(input_buf, true, &IsClipped);
	plhs[0] = mxCreateDoubleScalar(Reading);
	mxFree(input_buf);
	return;
}