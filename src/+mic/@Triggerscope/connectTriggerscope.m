function connectTriggerscope(obj)
%connectTriggerscope connects to a Triggerscope via a serial port.
% This method will attempt to connect to the serial port obj.SerialPort,
% which is assumed to be a Triggerscope connected via USB. 

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Update obj.ActivityMessage.
obj.ActivityMessage = sprintf('Connecting to serial port ''%s''...', ...
    obj.SerialPort);

% Connect to the COM port given in obj.SerialPort
obj.TriggerscopeSerialPortDev = serialport(obj.SerialPort, obj.BaudRate);

% Set some serial communication parameters.
obj.TriggerscopeSerialPortDev.Timeout = obj.DeviceTimeout;
obj.TriggerscopeSerialPortDev.DataBits = obj.DataBits;
configureTerminator(obj.TriggerscopeSerialPortDev, obj.Terminator);

% Flush the input and output buffers (maybe not necessary but always seems
% to be a good idea).
flush(obj.TriggerscopeSerialPortDe;

% Update obj.ActivityMessage and obj.IsConnected (we'll assume the
% connection was successful).
obj.ActivityMessage = '';
obj.IsConnected = true;


end
