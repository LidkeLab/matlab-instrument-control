#include "stdafx.h"
#include "dcamprop.h"

#define NUMBER_OF_FRAMES						4			// The number of frames to be captured.
#define USE_DCAM_BASIC_EXPOSURETIME_SET			TRUE		// If set to FALSE, this program will use the dcam_extended() function to control exposure time.
#define USE_DCAM_API_MEMORY_MANAGEMENT			TRUE		// If set to FALSE, this program owns the recording memory buffer.

void show_propertyattr(DCAM_PROPERTYATTR attr);
void show_supportvalues(HDCAM hdcam, int32 iProp, double v);
void print_attr(int32& count, const char* name);
//*******************************************************************************************
void mexFunction(int nlhs, mxArray *plhs[],	int	nrhs, const	mxArray	*prhs[]) {

	long	CameraIndex = 0;	
	HDCAM	hDCAM = NULL;
	long	Handle;
	long	ScanSpeed;
	_DWORD CameraCapability = 0;
	// input handle from Matlab
	
	Handle=(long)mxGetScalar(prhs[0]);
	ScanSpeed=(long)mxGetScalar(prhs[1]);
	if (!mxIsInt32(prhs[0]))
		mexErrMsgTxt("handle must be type INT 32.");
	
	hDCAM=(HDCAM)Handle;
	
	int32	iProp = DCAM_IDPROP_INTERNAL_FRAMEINTERVAL; 
	double	CurValue;
	DCAM_PROPERTYATTR attr;
	memset(&attr,0,sizeof(DCAM_PROPERTYATTR));
	attr.cbSize=sizeof(DCAM_PROPERTYATTR);
	attr.iProp=iProp;
	dcam_getpropertyattr(hDCAM,&attr);
	show_propertyattr(attr);
	dcam_getpropertyvalue(hDCAM, iProp, &CurValue);
	mexPrintf("Current frame period:\t%f s\n",CurValue);
	mexPrintf("\n");

	iProp=DCAM_IDPROP_EXPOSURETIME;
	attr.iProp=iProp;
	dcam_getpropertyattr(hDCAM,&attr);
	show_propertyattr(attr);
	dcam_getpropertyvalue(hDCAM, iProp, &CurValue);
	mexPrintf("Current exposure time:\t%f s\n",CurValue);
	mexPrintf("\n");

	iProp=DCAM_IDPROP_SUBARRAYMODE;
	attr.iProp=iProp;
	dcam_getpropertyattr(hDCAM,&attr);
	show_propertyattr(attr);
	dcam_getpropertyvalue(hDCAM, iProp, &CurValue);
	mexPrintf("Current subarray mode:\t%f\n",CurValue);
	show_supportvalues(hDCAM, iProp, attr.valuemin);
	mexPrintf("\n");

	iProp=DCAM_IDPROP_READOUTSPEED;
	attr.iProp=iProp;
	dcam_getpropertyattr(hDCAM,&attr);
	show_propertyattr(attr);
	dcam_getpropertyvalue(hDCAM, iProp, &CurValue);
	mexPrintf("Current read out speed:\t%f\n",CurValue);
	mexPrintf("\n");
	return;
}
				
void show_propertyattr( DCAM_PROPERTYATTR attr )
{
	int32 count = 0;
	//attribute
	mexPrintf( "ATTR:\t" );
	if( attr.attribute & DCAMPROP_ATTR_WRITABLE )				print_attr( count, "WRITABLE" );
	if( attr.attribute & DCAMPROP_ATTR_READABLE )				print_attr( count, "READABLE" );
	if( attr.attribute & DCAMPROP_ATTR_DATASTREAM )				print_attr( count, "DATASTREAM" );
	if( attr.attribute & DCAMPROP_ATTR_ACCESSREADY )			print_attr( count, "ACCESSREADY" );
	if( attr.attribute & DCAMPROP_ATTR_ACCESSBUSY )				print_attr( count, "ACCESSBUSY" );
	if( attr.attribute & DCAMPROP_ATTR_HASVIEW )				print_attr( count, "HASVIEW" );
	if( attr.attribute & DCAMPROP_ATTR_HASCHANNEL )				print_attr( count, "HASCHANNEL" );
	if( attr.attribute & DCAMPROP_ATTR_HASRATIO )				print_attr( count, "HASRATIO" );
	if( attr.attribute & DCAMPROP_ATTR_VOLATILE )				print_attr( count, "VOLATILE" );
	if( attr.attribute & DCAMPROP_ATTR_AUTOROUNDING )			print_attr( count, "AUTOROUNDING" );
	if( attr.attribute & DCAMPROP_ATTR_STEPPING_INCONSISTENT )	print_attr( count, "STEPPING_INCONSISTENT" );
	if( count == 0 )	mexPrintf( "none" );
	mexPrintf( "\n" );

	//mode
	switch( attr.attribute & DCAMPROP_TYPE_MASK )
	{
		case DCAMPROP_TYPE_MODE:	mexPrintf( "TYPE:\tMODE\n" ); break;
		case DCAMPROP_TYPE_LONG:	mexPrintf( "TYPE:\tLONG\n" ); break;
		case DCAMPROP_TYPE_REAL:	mexPrintf( "TYPE:\tREAL\n" ); break;
		default:					mexPrintf( "TYPE:\tNONE\n" ); break;
	}

	//range
	if( attr.attribute & DCAMPROP_ATTR_HASRANGE )
	{
		mexPrintf( "min:\t%f\n", attr.valuemin );
		mexPrintf( "max:\t%f\n", attr.valuemax );
	}
	//step
	if( attr.attribute & DCAMPROP_ATTR_HASSTEP )
	{
		mexPrintf( "step:\t%f\n", attr.valuestep );
	}
	//default
	if( attr.attribute & DCAMPROP_ATTR_HASDEFAULT )
	{
		mexPrintf( "default:\t%f\n", attr.valuedefault );
	}
}

void print_attr( int32& count, const char* name )
{
	if( count == 0 )
		mexPrintf( "%s", name );
	else
		mexPrintf( " | %s", name );

	count++;
}

void show_supportvalues( HDCAM hdcam, int32 iProp, double v )
{
	mexPrintf( "Support:\n" );

	int32 pv_index = 0;

	do
	{
		char	pv_text[64];
		DCAM_PROPERTYVALUETEXT pvt;
		memset( &pvt, 0, sizeof( pvt ) );
		pvt.cbSize		= sizeof( pvt );
		pvt.iProp		= iProp;
		pvt.value		= v;
		pvt.text		= pv_text;
		pvt.textbytes	= sizeof( pv_text );

		pv_index++;
		/* This should succeed. */
		if( dcam_getpropertyvaluetext( hdcam, &pvt ) )
			mexPrintf( "\t%d:\t%s\n", pv_index, pv_text );

	} while( dcam_querypropertyvalue( hdcam, iProp, &v, DCAMPROP_OPTION_NEXT ) );
}