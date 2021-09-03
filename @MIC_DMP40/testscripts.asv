

%% .NET

% CS Example:
%C:\Program Files (x86)\IVI Foundation\VISA\WinNT\TLDFM\Examples\DotNet

%Function Libraries:
web('file:///C:/Program%20Files%20(x86)/IVI%20Foundation/VISA/WinNT/TLDFMX/Manual/TLDFMX.html')
web('file:///C:/Program%20Files%20(x86)/IVI%20Foundation/VISA/WinNT/TLDFM/Manual/TLDFM.html')

%Dot NET XML:
web('file:///C:\Program Files\IVI Foundation\VISA\VisaCom64\Primary Interop Assemblies\Thorlabs.TLDFM_64.Interop.xml')
web('file:///C:\Program Files\IVI Foundation\VISA\VisaCom64\Primary Interop Assemblies\Thorlabs.TLDFMX_64.Interop.xml')

% Add the .NET assembly as shown below
% Find function you want to use from function library.  
% Look up .NET function signature in .NET xml file. 
% Inputs qualified by 'out' should be removed from the matlab call. 
% The first output is the function return value (Typically ViStatus)
% Other output inputs qualified by 'out' are returned as LHS arguments
% Other RHS arguments are treated as pointers (see get_device_info below)


%Example:
% TLDFM_get_device_count
% c-code function signature (not used):
% ViStatus TLDFM_get_device_count (ViSession instrumentHandle, ViPUInt32 deviceCount);
% .NET:
% "M:Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count(System.UInt32@)"

%The actual .NET call:
% [Status,N]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count()

% Check .NET support (Should return true)
tf = NET.isNETSupported

%Change directly to the dlls (We will find workaround)
cd('C:\Program Files\IVI Foundation\VISA\Win64\Bin')

% path to .NET assemblies
p='C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies'

% Add the assemblies to matlab using full path. Full path is important
DMX=NET.addAssembly(fullfile(p,'Thorlabs.TLDFMX_64.Interop.dll'))
DM=NET.addAssembly(fullfile(p,'Thorlabs.TLDFM_64.Interop.dll'))

%These should show a few things. Ignore actual resutls for now. 
DM.Classes
DM.Enums
DMX.Classes
DMX.Enums

% Call an assembly method
% "M:Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count(System.UInt32@)"
% Note that the '@' seems to indicate an output treated as a pointer.
% These are not used in the function call (double check for other calls)
[Status,N]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count()

% Get device info
deviceindex=0;
manufacturer=System.Text.StringBuilder;
instrumentName=System.Text.StringBuilder;
serialNumber=System.Text.StringBuilder;
resourceName=System.Text.StringBuilder;


% .NET:
% "M:Thorlabs.TLDFM_64.Interop.TLDFM.get_device_information(System.UInt32,
%   System.Text.StringBuilder,System.Text.StringBuilder,System.Text.StringBuilder,
%   System.Boolean@,System.Text.StringBuilder)"
% NOTE: System.Boolean@ moved to LHS

[Status,deviceAvailable]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_information(...
    deviceindex,manufacturer,instrumentName,serialNumber,resourceName)

deviceAvailable
manufacturer.ToString
instrumentName.ToString
serialNumber.ToString
resourceName.ToString

% Create DM Object
% "M:Thorlabs.TLDFM_64.Interop.TLDFM.#ctor(System.String,System.Boolean,System.Boolean)"
% NOTE: '#ctor' means 'constructor' and is removed from call

DMP40=Thorlabs.TLDFM_64.Interop.TLDFM(resourceName.ToString,true,true)

[Status,Cnt]=DMP40.get_segment_count()
[Status,Cnt]=DMP40.get_tilt_count()

%get tilt voltage:

% "M:Thorlabs.TLDFM_64.Interop.TLDFM.get_tilt_voltage(System.UInt32,System.Double@)"
MirrorIdx=0
[Status,TiltVoltage]=DMP40.get_tilt_voltage(MirrorIdx)
SetTiltVoltage=.1
[Status]=DMP40.set_tilt_voltage(MirrorIdx,SetTiltVoltage)
[Status,TiltVoltage]=DMP40.get_tilt_voltage(MirrorIdx)

% Close communication to DM
% If you don't do this before clearing your variables, 
%   you can loose connection pending MATLAB restart. 
DMP40.Dispose




