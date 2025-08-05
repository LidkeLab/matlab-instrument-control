function set_errorcodes(obj)
    % set the ErrorCode static codes as a structure
        obj.ErrorCode.MCL_SUCCESS=0;
        obj.ErrorCode.MCL_GENERAL_ERROR=-1;
        obj.ErrorCode.MCL_DEV_ERROR=-2;
        obj.ErrorCode.MCL_DEV_NOT_ATTACHED=-3;
        obj.ErrorCode.MCL_USAGE_ERROR=-4;
        obj.ErrorCode.MCL_DEV_NOT_READY=-5;
        obj.ErrorCode.MCL_ARGUMENT_ERROR=-6;
        obj.ErrorCode.MCL_INVALID_AXIS=-7;
        obj.ErrorCode.MCL_INVALID_HANDLE=-8;
        obj.ErrorCode.MCL_MISC = -9;
end
