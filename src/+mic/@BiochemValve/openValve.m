function openValve(obj, ValveNumber)
%Sends a signal to the Arduino to open valve ValveNumber on the BIOCHEM
%flow selection valve. 
%
% INPUTS: 
%   obj: An instance of the mic.BiochemValve class.
%   ValveNumber: The number specifying which valve on the BIOCHEM flow
%                selection valve to open. 
%                NOTE: this may be mapped to the relay block on the relay
%                module for easy verification (by viewing the wiring path).
%
% CITATION: David Schodt, Lidke Lab, 2018


% Map ValveNumber to the appropriate digital I/O pin on the Arduino.
PinNumber = obj.IN1Pin + ValveNumber + 1; % +1 since IN1 and IN2 are power

% Send the LOW signal to the Arduino digital pin (the valves are wired to
% be active LOW, i.e. the valve is open when a LOW signal, or 0V, is sent
% the the relay). 
PinName = sprintf('D%i', PinNumber); 
writeDigitalPin(obj.Arduino, PinName, 0); % send 0V to Arduino pin PinName

% Update valve state property.
obj.ValveState(ValveNumber) = 1; 


end
