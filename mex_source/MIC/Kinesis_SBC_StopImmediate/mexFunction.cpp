#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotor.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	if (nrhs != 2)
		mexErrMsgTxt("Proper Usage: err = Kinesis_SBC_StopImmediate('SerialNo', Channel)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);
	short Channel = (short)mxGetScalar(prhs[1]);

	short err = SBC_StopImmediate(input_buf, Channel);
	plhs[0] = mxCreateDoubleScalar((double)err);

	mxFree(input_buf);
}
