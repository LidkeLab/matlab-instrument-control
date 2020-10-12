function connectTriggerscope(obj)
%connectTriggerscope connects to a Triggerscope via a serial port.
% This method will attempt to connect to the serial port obj.SerialPort,
% which is assumed to be a Triggerscope connected via USB. 

% Created by:
%   David J. Schodt (Lidke Lab, 2020)


% Connect to the COM port given in obj.SerialPort
obj.Triggerscope = serialport(obj.SerialPort);
fopen(obj.SyringePump);

% Set some serial communication parameters.
obj.Triggerscope.Timeout = obj.DeviceTimeout;
obj.Triggerscope.BaudRate = obj.BaudRate;
obj.Triggerscope.DataBits = obj.DataBits;
configureTerminator(obj.Triggerscope, obj.Terminator);

% Flush the input and output buffers (maybe not necessary but always seems
% to be a good idea).
flush(obj.Triggerscope);


end