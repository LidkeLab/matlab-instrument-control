# MIC_AndorCamera class
Usage:
CAM=AndorCamera
CAM.gui
Requires:
Andor MATLAB SDK 2.94.30005 or higher
TODO:
Add quarter CCD left, right ROI selection (for TIRF system).
Fix warning error about not acquiring
Add shutter options so capture can be run with/without shutter
GUI doesn't show programic updates to CameraSettings
Clear of object doesn't warm up to shutdown.
if nargin ~= 2
error('AndorCamera:WrongNumberOfInputs','errorcheck requires the function name and return code');
end
don't display successes unless explicitly stated.
.choose betwee a list of camera models w/ serials
.SETCAMERAPROPERTIES Summary of this function goes here
in: a duplicate CameraSetting structure to be checked and set
this function sets the camera properties on the camera so that what you
select on the gui is committed to the API

