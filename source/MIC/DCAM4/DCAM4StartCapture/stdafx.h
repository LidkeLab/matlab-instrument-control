// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifndef _WIN32_WINNT		// Allow use of features specific to Windows XP or later.                   
#define _WIN32_WINNT 0x0501	// Change this to the appropriate value to target other versions of Windows.
#endif						

#if _MSC_VER >= 1300
#define	_CRT_SECURE_NO_DEPRECATE
#endif

#ifdef LINUX
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#else
#include <windows.h>
#include <stdio.h>
#include <tchar.h>
#endif

#include <memory.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <mex.h>
//#define	DCAMAPI_VER	4000
#include "dcamapi4.h"
#include "dcamprop.h"

#if _MSC_VER < 1400
#define	sprintf_s			sprintf
#define	scanf_s				scanf
#define	_secure_buf(buf)	buf
#else
#define	_secure_buf(buf)	buf,sizeof(buf)
#endif // _MSC_VER

inline BOOL fopen( FILE*& fp, const char* filename, const char* mode )
{
#if _MSC_VER < 1400
	fp = fopen( filename, mode );
	return fp != NULL;
#else
	fopen_s( &fp, filename, mode );
	return fp != NULL;
#endif // _MSC_VER

}

// TODO: reference additional headers your program requires here
#ifndef max
//! not defined in the C standard used by visual studio
#define max(a,b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
//! not defined in the C standard used by visual studio
#define min(a,b) (((a) < (b)) ? (a) : (b))
#endif
#define pi 3.141592f
