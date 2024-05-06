from dcam import *
import numpy as np
import re

def dcam_show_device_list():
    """
    Show device list
    """
    n = Dcamapi.get_devicecount()
    for i in range(0, n):
        dcam = Dcam(i)
        output = '#{}: '.format(i)

        model = dcam.dev_getstring(DCAM_IDSTR.MODEL)
        if model is False:
            output = output + 'No DCAM_IDSTR.MODEL'
        else:
            output = output + 'MODEL={}'.format(model)

        cameraid = dcam.dev_getstring(DCAM_IDSTR.CAMERAID)
        if cameraid is False:
            output = output + ', No DCAM_IDSTR.CAMERAID'
        else:
            output = output + ', CAMERAID={}'.format(cameraid)

        print(output)

def dcam_get_status(cam):
    id = cam.cap_status()
    status = DCAMCAP_STATUS(id)

    return status.name

def dcam_get_allframes(cam,nframe):
    out = []
    for k in range(nframe):
        img = cam.buf_getframedata(k)
        out.append(img)
    out = np.stack(out)
    return out

def dcam_get_pinfo(cam,idprop):
    attr = cam.prop_getattr(idprop)
    propname = cam.prop_getname(idprop)
 
    writable = attr.is_writable()
    readable = attr.is_readable()
    valrange = np.array([attr.valuemin, attr.valuemax,attr.valuestep])
    unit = DCAMPROP_UNIT(attr.iUnit).name
    valtype = []
    valtype.append(attr.attribute & DCAM_PROP.TYPE.NONE)
    valtype.append(attr.attribute & DCAM_PROP.TYPE.MODE)
    valtype.append(attr.attribute & DCAM_PROP.TYPE.LONG)
    valtype.append(attr.attribute & DCAM_PROP.TYPE.REAL)
    valtype.append(attr.attribute & DCAM_PROP.TYPE.MASK)

    if (valtype[1]==1) & (valtype[2]==0):
        proptype = 'MODE'
    elif (valtype[1]==0) & (valtype[2]==2):
        proptype = 'LONG'
    elif valtype[3]==3:
        proptype = 'REAL'
    else:
        proptype = 'UNKNOWN'

    if (proptype == 'MODE') or (proptype=='LONG'):
        valrange = np.int32(valrange)

        
    pinfo = dict(Name=propname,
                 Type=proptype,
                 Range=valrange,
                unit = unit,
                writable = writable,
                readable = readable)

    return pinfo






