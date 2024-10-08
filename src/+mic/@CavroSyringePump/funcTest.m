function funcTest(SerialPort)
%WARNING!!! This funcTest should only be run in two scenarios:
% 1) The syringe has been removed from the syringe pump.
% 2) The In, BP, and Out ports of the syringe pump are fed to/from fluid
%    reservoirs containing test fluid, e.g. the ports are fed to/from
%    reservoirs of water. 
%Perform a unit test for the CavroSyringePump class.  If the unit test
%completes without any errors, the unit test was a success. 
%
% INPUTS: 
%   SerialPort: (optional) String specifying the serial port to which a
%               Cavro syringe pump is connected, e.g. SerialPort = 'COM3'
%               is the default setting.
%
% CITATION: David Schodt, Lidke Lab, 2018


% Create a syringe pump object. 
Pump = mic.CavroSyringePump; 

% Set the SerialPort property to that specified by the user (if given). 
if exist('SerialPort', 'var')
    Pump.SerialPort = SerialPort; 
end

% Test the connectSyringePump() method.
Pump.connectSyringePump();

% Test the querySyringePump() method independently. 
Pump.querySyringePump();

% % Test the readAnswerBlock() method independently. 
% [DataBlock, ASCIIMessage] = readAnswerBlock(obj);

% Test the executeCommand() and waitForReadyStatus() methods.
Pump.executeCommand('IA3000A0OI'); Pump.waitForReadyStatus(); 

% Test the reportCommand() method. 
PlungerPosition = str2double(Pump.reportCommand('?'));
if (PlungerPosition >= 0) && (PlungerPosition <= 3000)
    % Valid plunger position returned.  Do nothing.
else
    % Plunger position returned was not valid, throw an error so that the
    % unit test fails.
    error('Invalid plunger position returned: %g', PlungerPosition)
end
Pump.waitForReadyStatus()

% Bombard the syringe pump with commands to ensure that wait times/status
% checks are working correctly (without those, the syringe pump gets
% overloaded and commands fail to execute/the syringe pump begins to
% respond with invalid messages).
Pump.querySyringePump(); 
Pump.executeCommand('IA3000M500OA0'); Pump.waitForReadyStatus()
Pump.reportCommand('?'); Pump.waitForReadyStatus()
Pump.executeCommand('IM1000OM1000'); Pump.waitForReadyStatus()
Pump.reportCommand('?'); Pump.waitForReadyStatus()
Pump.querySyringePump(); Pump.waitForReadyStatus()
Pump.executeCommand('IM1000OM1000'); Pump.waitForReadyStatus()
Pump.reportCommand('?'); Pump.waitForReadyStatus()
Pump.executeCommand('IA3000OA0'); Pump.waitForReadyStatus()
Pump.executeCommand('I'); Pump.waitForReadyStatus()

% Perform the destructor method to clean up after the funcTest.
Pump.delete()

end
