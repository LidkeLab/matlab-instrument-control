function varargout = errorcheck(obj,fname,varargin)

% certain errors throw variable error codes but are specific to axis controls, 
% this is logical branch for that
if obj.LastError ~= obj.ErrorCode.MCL_SUCCESS
    displayError(fname,varargin);
end

% Error check function for processing most of the MCL Nano Drive errors
switch obj.LastError
    case obj.ErrorCode.MCL_SUCCESS
        % nest if statements for when we call this, not sure what
        % this needs to be yet
        switch fname
            case 'MCL_GetProductInfo'
                obj.ProductInfo.ADC_resolution=varargin{1}.ADC_resolution;
                obj.ProductInfo.DAC_resolution=varargin{1}.DAC_resolution;
                obj.ProductInfo.Product_id=varargin{1}.Product_id;
                obj.ProductInfo.FirmwareVersion=varargin{1}.FirmwareVersion;
                obj.ProductInfo.FirmwareProfile=varargin{1}.FirmwareProfile;
            case 'MCL_SingleWriteN'
                obj.Position(varargin{2}) = varargin{1};
        end
        
    case obj.ErrorCode.MCL_GENERAL_ERROR
        error('Some Internal Sanity Check Failed');
    case obj.ErrorCode.MCL_DEV_ERROR
        error('A problem occurred when transferring data to the Nano-Drive');
    case obj.ErrorCode.MCL_DEV_NOT_ATTACHED
        error('The Nano-Drive cannot complete the task because it is not attached.');
    case obj.ErrorCode.MCL_USAGE_ERROR
        error('This library function is not supported by this particular Nano-Drive');
    case obj.ErrorCode.MCL_DEV_NOT_READY
        error('The Nano-Drive is currently completing or waiting to complete another task');
    case obj.ErrorCode.MCL_ARGUMENT_ERROR
        error('An argument is out of range or a required pointer is equal to NULL');
    case obj.ErrorCode.MCL_INVALID_AXIS
        varargout{1} = 'Invalid Axis'; % axis returns as invalid
        warning('The Attempted operation on this axis does not exist in the Nano-Drive');
    case obj.ErrorCode.MCL_INVALID_HANDLE
        error('The handle is not valid, or at least not in this instance of the DLL');
    case obj.ErrorCode.MCL_MISC
        switch fname
            case 'MCL_InitHandle'
                error('MCLNanoDrive:NoHandle','Cannot get a handle to the device. Make sure device is on.  If on, try ''MCLNanoDrive.libreset''');            
            case 'MCL_CorrectDriverVersion'
                warning('MCLNanoDriveStage:WrongDLL','DLL in use does not match the current driver version');
        end
    otherwise
        switch fname
            case 'MCL_GetCalibration'
                varargout{1} = obj.LastError; % return correct axis values
                obj.LastError = 0;
        end
        
end
end

% I had to make a static function because sometimes MCL will throw variable error codes for a single command
function displayError(fname,varargin)
switch fname
    case 'MCL_SingleWriteN'
        switch varargin{2}
            case 1
                dimChar = X;
            case 2
                dimChar = Y;
            case 3
                dimChar = Z;
        end
        disp(obj.LastError);
        error('MCLNanoDrive:MoveFailed','Could not move to new %s position',dimChar);
end

end
