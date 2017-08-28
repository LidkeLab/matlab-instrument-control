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

	// short __cdecl LD_Open  ( char const *  serialNo ) 

	if (nrhs != 1)
		mexErrMsgTxt("Proper Usage: Err=Kinesis_SG_Open('SerialNoString')");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("Proper Usage: Err=Kinesis_SG_Open('SerialNoString').  Input must be character array.");

	short S = TLI_BuildDeviceList(); //This must be called once before any communication.  
	int N = TLI_GetDeviceListSize();

	if (N==0)
		mexErrMsgTxt("Can't find any Kinesis Instruments.  Try running Kinesis_TLI_BuildDeviceList()");

	char * input_buf = mxArrayToString(prhs[0]);
	//mexPrintf("%s\n", input_buf);

	TLI_DeviceInfo deviceInfo;                    // get device info from device                    
	TLI_GetDeviceInfo(input_buf, &deviceInfo);                    // get strings from device info structure
	char desc[65];                    
	strncpy(desc, deviceInfo.description, 64);                    
	desc[64] = '\0';                    
	char serialNo[9];                    
	strncpy(serialNo, deviceInfo.serialNo, 8);                    
	serialNo[8] = '\0';                    // output                    
	mexPrintf("Found Device %s=%s : %s\r\n", input_buf, serialNo, desc);
	short Err;
	try {  Err= SG_Open(input_buf);}
	catch (...) { mexPrintf("Caught Excpetion %s\n", input_buf); mxFree(input_buf); }

	mexPrintf("Opened %s\n", input_buf);
	plhs[0] = mxCreateDoubleScalar(Err);
	if (!Err){ //If errror opening, send back error code. 
		SG_Identify(input_buf);
		SG_StartPolling(input_buf, 200);
	}
	mxFree(input_buf);
	return;
 }