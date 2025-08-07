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
		mexErrMsgTxt("Proper Usage: Err=Kinesis_BSM_Open('SerialNoString',Channel)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	if (!mxIsClass(prhs[1], "int"))
		mexErrMsgTxt("Second input must be an integer (int32).");

	short S = TLI_BuildDeviceList(); //makes a list of all the devices connected to the SUB ports abd are closed.
	int N = TLI_GetDeviceListSize(); //gets the number of the devices found in the former line.

	if (N == 0) //if there is no device connected then gives this error.
		mexErrMsgTxt("Can't find any Kinesis Instruments.  Try running Kinesis_TLI_BuildDeviceList()");

	char * input_buf = mxArrayToString(prhs[0]); //reading the device serial number as an input.
	int Channel = (int)mxGetScalar(plhs[1]);
	short Err = SBC_Open(input_buf); //opening the device
	plhs[0] = mxCreateDoubleScalar(Err); //output.
	if (!Err){ //If errror opening, send back error code. 
		SBC_Identify(input_buf,Channel);
		SBC_StartPolling(input_buf, Channel, 200);
	}
	mxFree(input_buf);
	return;
 }