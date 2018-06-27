function openValve(obj, ValveNumber)
%Sends a signal to the Arduino to open valve ValveNumber on the BIOCHEM
%flow selection valve. 
%
% INPUTS: 
%   obj: An instance of the MIC_BiochemValve class.
%   ValveNumber: The number specifying which valve on the BIOCHEM flow
%                selection valve to open. 
%                NOTE: this may be mapped to the relay block on the relay
%                module for easy verification (by viewing the wiring path).
%
% CITATION: David Schodt, Lidke Lab, 2018


% Map ValveNumber to the appropriate digital I/O pin on the Arduino.
PinNumber = obj.IN1Pin + ValveNumber - 1; % -1 since relay modules are 1-8

% Send the LOW signal to the Arduino digital pin (the valves are wired to
% be active LOW, i.e. the valve is open when a LOW signal, or 0V, is sent
% the the relay). 
PinName = sprintf('D%i', PinNumber); 
writeDigitalPin(obj.Arduino, PinName, 0); % send 0V to Arduino pin PinName


end