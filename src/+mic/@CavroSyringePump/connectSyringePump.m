function connectSyringePump(obj)
%Connects to a Cavro syringe pump and returns messages from the device. 
% INPUTS:
%   obj: An instance of the mic.CavroSyringePump class.
% 
% MATLAB R2017a or later recommended for this method.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Ensure that no COM object exists for the user specified port.
SerialObjectList = instrfindall; 
if ~isempty(SerialObjectList) 
    for ii = 1:numel(SerialObjectList)
        % Loop through all connected instruments known to Matlab.
        if strcmpi(SerialObjectList(ii).Port, obj.SerialPort)
            % If a connection already exists on the user specified Port,
            % close the connection and delete the serial object associated
            % with it. 
            fclose(SerialObjectList(ii));
            delete(SerialObjectList(ii)); 
            
            % Since only one connection can exist per port, we can break
            % the loop early since the one we've found must be unique. 
            break 
        end
    end
end

% Create a serial object for the device and open the connection.
if str2double(obj.MatlabRelease(1:4)) >= 2017
    ConnectedDevices = seriallist; % array of connected serial devices
else
    % This version of Matlab does not have the seriallist function,
    % workaround this problem in the code below.
    ConnectedDevices = '';
end
ValidPortGiven = 0;
tic % begin a timer
while toc < obj.DeviceSearchTimeout
    % Set the ReadableAction property to indicate we are trying to connect.
    obj.ReadableAction = ...
        sprintf('Searching for syringe pump at port %s', ...
        obj.SerialPort);
    
    % Continue looking for a serial device connected at Port until
    % DeviceSearchTimeout has been exceeded. 
    for ii = 1:numel(ConnectedDevices)
        % Loop through serial port devices to see if user specified Port is
        % connected to the computer.
        if strcmpi(obj.SerialPort, ConnectedDevices(ii))
            ValidPortGiven = 1;
        end
    end
    if ValidPortGiven
        % User specified Port was valid so we should attempt to connect to 
        % the device at obj.Port .
        obj.SyringePump = serial(obj.SerialPort); 
        fopen(obj.SyringePump);
        break % exit the while loop, device has been connected
    elseif numel(ConnectedDevices)==0
        warning('MATLAB 2017a recommended for use of this class.')
        obj.SyringePump = serial(obj.SerialPort); 
        fopen(obj.SyringePump);
        break % exit the while loop, a device has been connected
    else
        warning('No serial device was found at %s.', obj.SerialPort)
    end
    pause(5) % wait before trying again to avoid cluttering command window
end

% Throw an error if no device was found within DeviceSearchTimeout and
% refresh obj.StatusByte (unchanged) to pass control to the obj.StatusByte
% setter method.
if ~ValidPortGiven && ~isempty(ConnectedDevices)
    obj.StatusByte = obj.StatusByte; % assign to itself to run setter
    error('No serial device found within DeviceSearchTimeout = %g s \n',...
        obj.DeviceSearchTimeout)
end

% Set several serial communications properties for the device. 
obj.SyringePump.BaudRate = 9600;
obj.SyringePump.DataBits = 8;
obj.SyringePump.FlowControl = 'none';
obj.SyringePump.Terminator = 'CR'; % not sure why, but it works..
obj.SyringePump.Timeout = 1; % default is 10s
obj.SyringePump.Parity = 'none';

% Initialize the Cavro syringe pump.
fprintf(obj.SyringePump, ['/', num2str(obj.DeviceAddress), 'ZR']);

% Do not exit this method until the syringe pump is ready to accept new
% commands (presumably because the syringe pump was connected and
% initialized succesfully). 
QueryNumber = 1; 
while (obj.StatusByte < 96) || (QueryNumber == 1)
    % If obj.StatusByte < 96, the syringe pump is busy and we should query
    % the device (which internally updates obj.StatusByte).  The OR
    % condition ensures that at least one query is performed before
    % exiting this method call. 
    obj.querySyringePump; 
    QueryNumber = QueryNumber + 1; 
end

% Display a message in the command window to indicate a connection was
% made.
fprintf('Syringe pump found at port %s \n', obj.SerialPort)

% Set default properties based on the (assumed) succesful initialization.
obj.StartVelocity = 900;
obj.TopVelocity = 1400;
obj.CutoffVelocity = 900;
obj.VelocitySlope = 14;
obj.PlungerPosition = 0;


end
