#include "stdafx.h"
#include "helper.h"
BOOL get_framebundle_information(HDCAM hdcam, int32& number_of_bundle, int32& width, int32& height, int32& rowbytes, int32& totalframebytes, int32& framestepbytes)
{
	DCAMERR err;
	double v;

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_FRAMEBUNDLE_MODE, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_FRAMEBUNDLE_MODE failed.\n", err);
		return FALSE;
	}

	if (v == DCAMPROP_MODE__OFF)
	{
		mexPrintf("framebundle mode is off\n");
		return FALSE;
	}

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_FRAMEBUNDLE_NUMBER, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_FRAMEBUNDLE_NUMBER failed.\n", err);
		return FALSE;
	}

	number_of_bundle = (int32)v;
	mexPrintf("number of bundle is %d.\n", number_of_bundle);

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_IMAGE_WIDTH, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_IMAGE_WIDTH failed.\n", err);
		return FALSE;
	}

	width = (int32)v;
	mexPrintf("image width is %d.\n", width);

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_IMAGE_HEIGHT, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_IMAGE_HEIGHT failed.\n", err);
		return FALSE;
	}

	height = (int32)v;
	mexPrintf("image height is %d.\n", height);

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_FRAMEBUNDLE_ROWBYTES, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_FRAMEBUNDLE_ROWBYTES failed.\n", err);
		return FALSE;
	}

	rowbytes = (int32)v;
	mexPrintf("rowbytes is %d.\n", rowbytes);

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_IMAGE_FRAMEBYTES, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_IMAGE_FRAMEBYTES failed.\n", err);
		return FALSE;
	}

	totalframebytes = (int32)v;
	mexPrintf("total bytes per bundle is %d.\n", totalframebytes);

	err = dcamprop_getvalue(hdcam, DCAM_IDPROP_FRAMEBUNDLE_FRAMESTEPBYTES, &v);
	if (failed(err))
	{
		mexPrintf("Error = 0x%08lX\ndcamprop_getvalue() DCAM_IDPROP_FRAMEBUNDLE_FRAMESTEPBYTES failed.\n", err);
		return FALSE;
	}

	framestepbytes = (int32)v;
	mexPrintf("total bytes per frame is %d.\n", framestepbytes);

	return TRUE;
}
