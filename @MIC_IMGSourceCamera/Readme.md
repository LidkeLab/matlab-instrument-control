# # MIC_IMGSourceCamera: Matlab instument class for ImagingSource camera.
## Description
It requires dll to be registered in MATLAB.
TISImaq interfaces directly with the IMAQ Toolbox. This allows you to
bring image data directly into MATLAB for analysis, visualization,
and modelling.
The plugin allows the access to all camera properties as they are
known from IC Capture. The plugin works in all Matlab versions
since 2013a. Last tested version is R2016b.
After installing the plugin it must be registered in Matlab manually.
How to do that is shown in a Readme, that can be displayed after
installation.
imaqregister('C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\x64\TISImaq_R2013.dll')
http://www.theimagingsource.com/support/downloads-for-windows/extensions/icmatlabr2013b/
This was done with imaqtool using Tools menu.
## Contructor
Example: obj=MIC_IMGSourceCamera();
## Key Functions:
delete, shutdown, exportState
## REQUIREMENTS:
MIC_Abstract.m
MIC_Camera_Abstract.m
MATLAB software version R2013a or later
CITATION: , Lidkelab, 2017.
