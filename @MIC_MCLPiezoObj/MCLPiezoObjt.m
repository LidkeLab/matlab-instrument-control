% This script is written to control X-axis movement of MCL Piezo Objective 
function MCLPiezoObjt
% loadlibary(dll name, header file name) : Load a DLL into memory so that MATLAB can call it.
f = fullfile('MadCityLabs','NanoDrive','Madlib.dll');
loadlibrary(f,'Madlib.h')

if (~libisloaded('Madlib'))
	disp('Error: Library did not load correctly');
    return
end
% List the functions available in a DLL
disp('The following functions are availible to be used from Madlib')
libfunctions('Madlib'); % To print with inputs ('Madlib', '-full')

% Call function in C shared library
handle = calllib('Madlib', 'MCL_InitHandle');
% print out information about the piezo objective
prInfo = libstruct('ProductInformation'); % external structure
pprInfo = libpointer('ProductInformation', prInfo); % pointer object to the struct
% use get(prInfo)
err = calllib('Madlib', 'MCL_GetProductInfo', pprInfo, handle);
if (err ~= 0)
    message = sprintf('Error: Piezo Drive did not correctly get product info. Error is %d', err);
    disp(message);
    clear pprInfo 
    clear prInfo
    cleanup(handle, 1);
    return;
else
    disp('MicroDrive product information:');
    disp(pprInfo.value)
    
end

% check info of valid axis 
prInfo = pprInfo.value; % get the info from the pointer back to the structure
axis_bitmap = prInfo.axis_bitmap; % pull out the axis bitmap

if axis_bitmap == 1
    % axis = 1; Not sure to mention axis here?
    disp('Using X axis');
else
    disp('Error: No valid axis is avalible');
    cleanup(handle, 1);
    return;
end

% Get the calibration of x axis by specifying axis = 1 (X)
calibration = calllib('Madlib', 'MCL_GetCalibration', axis, handle);

% try reading and writing to the Piezo Drive.
% This read the current position of the specified axis, here axis=1 (X)
pos = calllib('Madlib', 'MCL_SingleReadN', axis, handle);
if (pos < 0)
    message = sprintf('Error: Piezo Drive did not correctly read position. Error in position is %d', pos);
	disp(message);
    cleanup(handle, 1);
    return;
else 
    percent = (pos/calibration)*100;
	message = sprintf('Current position = %f%% of the total range of motion', percent);
	disp(message);	
end

% get user's input for the new position
percent = input('Move to what percent of range of motion? (0-100%)\n');
pos = (percent*calibration)/100;
err = calllib('Madlib', 'MCL_SingleWriteN', pos, axis, handle);
if (err ~= 0)
    message = sprintf('Error: Piezo Drive did not correctly write position. Error in position is %d', err);
	disp(message);
    cleanup(handle, 1);
    return;    
end

% Pause device before reading again
calllib('Madlib', 'MCL_DeviceAttached', 100, handle); %100 ms pause

% read the new position to make sure Piezo Drive actually moved
pos = calllib('Madlib', 'MCL_SingleReadN', axis, handle);
if (pos < 0)
    message = sprintf('Error: Piezo Drive did not correctly read position. Error in position is %d', pos);
	disp(message);
    cleanup(handle, 1);
    return;
else
	percent = (pos/calibration)*100;
	message = sprintf('New position = %f%% of the total range of motion', percent);
	disp(message);
    disp('Now that we have done with calibration, let''s release handle')
end

function cleanup(handle, errors)
calllib('Madlib', 'MCL_ReleaseHandle', handle);
unloadlibrary('Madlib');
if (errors == 1)
    disp('Exiting');
else
    disp('Program finished without any errors');
end
end 
end % Main function ends here