#include <windows.h>
#pragma comment(lib, "kernel32.lib")

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mex.h>
#include "C:\Program Files\Thorlabs\Kinesis\Thorlabs.MotionControl.Benchtop.StepperMotor.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	if (nrhs != 3)
		mexErrMsgTxt("Proper Usage: err = Kinesis_SBC_SetHomingVelocity('SerialNo', Channel, Velocity)");

	if (!mxIsClass(prhs[0], "char"))
		mexErrMsgTxt("First input must be character array.");

	char * input_buf = mxArrayToString(prhs[0]);
	short Channel = (short)mxGetScalar(prhs[1]);
	unsigned int velocity = (unsigned int)mxGetScalar(prhs[2]);

	short err = SBC_SetHomingVelocity(input_buf, Channel, velocity);
	plhs[0] = mxCreateDoubleScalar((double)err);

	mxFree(input_buf);
}
