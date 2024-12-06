
#include "stdafx.h"

struct pinfo {
	const char* name;
	const char* type;
	const char* unit;
	double range[3];
	int writable;
	int readable;
};



void dcam_get_propinfo(DCAMPROP_ATTR propattr, pinfo* prop)
{
	int32 count = 0;



	prop[0].writable = (propattr.attribute & DCAMPROP_ATTR_WRITABLE) ? 1 : 0;
	prop[0].readable = (propattr.attribute & DCAMPROP_ATTR_READABLE) ? 1 : 0;

	

	
	// unit
	switch (propattr.iUnit)
	{
	case DCAMPROP_UNIT_SECOND:				prop[0].unit = "SECOND";			break;
	case DCAMPROP_UNIT_CELSIUS:				prop[0].unit = "CELSIUS";			break;
	case DCAMPROP_UNIT_KELVIN:				prop[0].unit = "KELVIN";			break;
	case DCAMPROP_UNIT_METERPERSECOND:		prop[0].unit = "METERPERSECOND";	break;
	case DCAMPROP_UNIT_PERSECOND:			prop[0].unit = "PERSECOND";			break;
	case DCAMPROP_UNIT_DEGREE:				prop[0].unit = "DEGREE";			break;
	case DCAMPROP_UNIT_MICROMETER:			prop[0].unit = "MICROMETER";		break;
	default:								prop[0].unit = "NONE";				break;
	}
	
	
	// mode
	switch (propattr.attribute & DCAMPROP_TYPE_MASK)
	{
	case DCAMPROP_TYPE_MODE:	prop[0].type = "MODE";	break;
	case DCAMPROP_TYPE_LONG:	prop[0].type = "LONG";	break;
	case DCAMPROP_TYPE_REAL:	prop[0].type = "REAL";	break;
	default:					prop[0].type = "NONE";	break;
	}

	// range
	if (propattr.attribute & DCAMPROP_ATTR_HASRANGE)
	{
		prop[0].range[0] = propattr.valuemin;
		prop[0].range[1] = propattr.valuemax;
	}
	else {
		prop[0].range[0] = -1.0;
		prop[0].range[1] = -1.0;
	}
	// step
	if (propattr.attribute & DCAMPROP_ATTR_HASSTEP)
	{
		prop[0].range[2] = propattr.valuestep;
	}
	else {
		prop[0].range[2] = -1.0;
	}
	
	return;

}

#define NUMBER_OF_FIELDS (sizeof(field_names) / sizeof(*field_names))

// [] = DCAM4AllocMemory(cameraHandle, nFrames)
// Allocate memory for 'cameraHandle' to capture 'nFrames'.
void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	/*!
	*  \brief Entry point in the code for Matlab.  Equivalent to main().
	*  \param nlhs number of left hand mxArrays to return
	*  \param plhs array of pointers to the output mxArrays
	*  \param nrhs number of input mxArrays
	*  \param prhs array of pointers to the input mxArrays.
	*/

	// Grab the inputs from MATLAB and check their types before proceeding.
	unsigned long* mHandle;
	HDCAM handle;
	int32 iProp;
	

	mHandle = (unsigned long*)mxGetUint64s(prhs[0]);
	handle = (HDCAM)mHandle[0];
	iProp = (int32)mxGetScalar(prhs[1]);
	
	const char* field_names[] = { "name", "type","unit","range","writable","readable"};
	struct pinfo prop;
	mwSize dims[2] = { 1, 1 };

	DCAMPROP_ATTR	basepropattr;
	memset(&basepropattr, 0, sizeof(basepropattr));
	basepropattr.cbSize = sizeof(basepropattr);
	basepropattr.iProp = iProp;

	// Prepare output
	plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);

	// Call the dcam function.
	DCAMERR error;
	error = dcamprop_getattr(handle, &basepropattr);
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getattr() failed.\n", error);
		return;
	}
	dcam_get_propinfo(basepropattr, &prop);
	// get property name
	char	text[64];
	error = dcamprop_getname(handle, iProp, text, sizeof(text));
	if (failed(error))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getattr() failed.\n", error);
		return;
	}
	prop.name = text;
	//mexPrintf("number of fields: %d.\n", NUMBER_OF_FIELDS);
	//mexPrintf("Name: %s.\n", text);
	//mexPrintf("writable: %d.\n", prop.writable);
	//mexPrintf("readable: %d.\n", prop.readable);
	//mexPrintf("Type: %s.\n", prop.type);
	//mexPrintf("Unit: %s.\n", prop.unit);
	//mexPrintf("Range: %0.2f, %0.2f, %0.2f.\n", prop.range[0],prop.range[1],prop.range[2]);
	// Assign output
	
	mxArray* field_value;
	mxSetFieldByNumber(plhs[0], 0, 0, mxCreateString(prop.name));
	mxSetFieldByNumber(plhs[0], 0, 1, mxCreateString(prop.type));
	mxSetFieldByNumber(plhs[0], 0, 2, mxCreateString(prop.unit));
	
	field_value = mxCreateDoubleMatrix(1, 3, mxREAL);
	double* rangePointer;
	rangePointer = (double*)mxGetDoubles(field_value);
	for (int i = 0; i < 3; i++) {
		rangePointer[i] = prop.range[i];
	}
	mxSetFieldByNumber(plhs[0], 0, 3, field_value);
	
	mwSize outsize[1];
	outsize[0] = 1;
	field_value = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	*mxGetInt32s(field_value)=prop.writable;
	mxSetFieldByNumber(plhs[0], 0, 4, field_value);
	field_value = mxCreateNumericArray(1, outsize, mxINT32_CLASS, mxREAL);
	*mxGetInt32s(field_value) = prop.readable;
	mxSetFieldByNumber(plhs[0], 0, 5, field_value);
	


	return;
}


