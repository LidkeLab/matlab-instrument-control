

%% .NET

%Note:  inputs qualified by 'out' should be removed from the matlab call. 

tf = NET.isNETSupported
cd('C:\Program Files\IVI Foundation\VISA\Win64\Bin')

p='C:\Program Files (x86)\Microsoft.NET\Primary Interop Assemblies'
DMX=NET.addAssembly(fullfile(p,'Thorlabs.TLDFMX_64.Interop.dll'))
DM=NET.addAssembly(fullfile(p,'Thorlabs.TLDFM_64.Interop.dll'))

DM.Classes
DM.Enums
DMX.Classes
DMX.Enums

[Err,N]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_count()

deviceindex=0;
manufacturer=System.Text.StringBuilder;
instrumentName=System.Text.StringBuilder;
serialNumber=System.Text.StringBuilder;
resourceName=System.Text.StringBuilder;

[Err,deviceAvailable]=Thorlabs.TLDFM_64.Interop.TLDFM.get_device_information(...
    deviceindex,manufacturer,instrumentName,serialNumber,resourceName)

deviceAvailable
manufacturer.ToString
instrumentName.ToString
serialNumber.ToString
resourceName.ToString

Obj=Thorlabs.TLDFM_64.Interop.TLDFM(resourceName.ToString,true,true)

[Err,Cnt]=Obj.get_segment_count()
[Err,Cnt]=Obj.get_tilt_count()

Obj.Dispose




