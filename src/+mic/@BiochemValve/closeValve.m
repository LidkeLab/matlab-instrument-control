function closeValve(obj, ValveNumber)
%Sends a signal to the Arduino to close valve ValveNumber on the BIOCHEM
%flow selection valve. 
%
% INPUTS: 
%   obj: An instance of the mic.BiochemValve class.
%   ValveNumber: The number specifying which valve on the BIOCHEM flow
%                selection valve to close. 
%                NOTE: this may be mapped to the relay block on the relay
%                module for easy verification (by viewing the wiring path).
%
% CITATION: David Schodt, Lidke Lab, 2018


% Map ValveNumber to the appropriate digital I/O pin on the Arduino.
PinNumber = obj.IN1Pin + ValveNumber + 1; % +1 since IN1 and IN2 are power

% Send the HIGH signal to the Arduino digital pin (the valves are wired to
% be active LOW, i.e. to close the valve we'll need to send a HIGH signal).
PinName = sprintf('D%i', PinNumber); 
writeDigitalPin(obj.Arduino, PinName, 1); % send 5V to Arduino pin PinName

% Update valve state property.
obj.ValveState(ValveNumber) = 0; 

end
