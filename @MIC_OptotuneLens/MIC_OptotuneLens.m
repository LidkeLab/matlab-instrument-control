classdef MIC_OptotuneLens < MIC_Abstract
% MIC_OptotuneLens
% 
% ## Overview
% The `MIC_OptotuneLens` MATLAB class facilitates control over an Optotune Electrical Lens via serial communication. The class interfaces with the lens using an embedded Atmel ATmega32U4 microcontroller, allowing for precise adjustments of focal power and monitoring of the lens temperature.
% 
% ## Features
% - **Focal Power Control**: Set and adjust the focal power of the Optotune lens within a defined range.
% - **Temperature Monitoring**: Fetch the current operating temperature of the lens.
% - **Drift Compensation**: Enable drift compensation to maintain focal stability.
% - **Firmware Interaction**: Retrieve and interact with the lens firmware, accommodating different firmware versions for command compatibility.
% 
% ## Prerequisites
% - MATLAB 2016b or later.
% - Instrument Control Toolbox for MATLAB for serial port communication.
% - Optotune lens driver and firmware installed and properly configured.
% 
% ## Installation
% 1. Ensure MATLAB and the required toolboxes are installed.
% 2. Connect the Optotune lens to your computer via a USB port and install any necessary drivers.
% 3. Clone this repository or download the class file directly into your MATLAB working directory.
% 
% ## Usage
% 
% ### Example
% ```matlab
% % Creating an instance of the MIC_OptotuneLens class
% lens = MIC_OptotuneLens('COM3');  % Replace 'COM3' with the actual COM port
% 
% % Setting Focal Power
% desiredPower = 2;  % in diopters
% lens.setFocalPower(desiredPower);
% 
% % Reading Temperature
% temperature = lens.getTemperature();
% disp(['Current Lens Temperature: ', num2str(temperature), ' °C']);
% 
% % Enabling Drift Compensation
% lens.enableDriftCompensation();
% 
% % Cleanup
% delete(lens);
% ```   
% Citation: Marjolein Meddens, Lidke Lab 2017
    properties (SetAccess=protected)
        InstrumentName = 'OptotuneLens' %Descriptive instrument name
        MinFocalPower   % Maximum focal power (dpt) of lens
        MaxFocalPower   % Minimum focal power (dpt) of lens
        FocalPower      % Current focal power
        SPO             % Serial port object
    end
    
    properties (Hidden)
        StartGUI = false(); % Flag for starting gui during constructor
        Data2Temp = 0.0625; % Conversion factor for reading temperature from device
        Firmware            % Firmware type
    end
    
    methods
        function obj = MIC_OptotuneLens(ComPort)
            % MIC_OptotuneLens
            % Example:
            %   ETL = MIC_OptotuneLens('COM3')
            
            % enable autonaming feature of MIC_Abstract
            obj = obj@MIC_Abstract(~nargout);
            
            % intialize communication
            obj.SPO = serial(ComPort);
            fopen(obj.SPO);
            
            % run handshake (#0101) to reset device and test communication
            fprintf(obj.SPO,'Start');
            Answer = fscanf(obj.SPO);
            % read error output to empty buffer (not sure why error command
            % is send but doesn't seem to be a problem so ignored for now)
            fread(obj.SPO,6);
            % check answer
            if ~strfind(Answer,'Ready')
                error('MIC_OptotuneLens:HardwareCommErr','Error in communication with Optotune Lens');
            end
            
            % get the firmware type
            obj.getFirmware();
            % switch device to focal power mode
            obj.setFPmode();
        end
        
        function Temperature = getTemperature(obj)
            % getTemperature get current lens temperature
            
            % compose request temperature message (#0501)
            Prefix1 = sprintf('%x','T');
            Prefix2 = sprintf('%x','C');
            Channel = sprintf('%x','A');
            Message_NoCRC = {Prefix1,Prefix2,Channel};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,9);
            % decode answer
            TempInt = Answer(4)*256 + Answer(5);
            Temperature = TempInt*obj.Data2Temp;
        end
        
        function setFocalPower(obj,Value)
            % setFocalPower Sets focal power of tunable lens
            % Input outside Min Max focal power range will be set to either
            % min or max
            
            % check input
            Value = max(min(Value,obj.MaxFocalPower),obj.MinFocalPower);
            % compose Set Focal Power message (#0310)
            Prefix1 = sprintf('%x','P');
            Prefix2 = sprintf('%x','r');
            Prefix3 = sprintf('%x','D');
            Prefix4 = sprintf('%x','A');
            Dummy = '00';
            % Encode focal power value
            switch obj.Firmware
                case 'A'
                    FPval = (Value-5)*200;
                case {'B','C','E','F'}
                    FPval = Value*200;
            end
            [FPBit1,FPBit2] = obj.dec2SingedInt(FPval);
            % compose message
            Message_NoCRC = {Prefix1,Prefix2,Prefix3,Prefix4,...
                FPBit1,FPBit2,Dummy,Dummy};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % update object
            obj.FocalPower = Value;
        end
        
        function enableDriftCompensation(obj)
            % enableDriftCompensation enables drift compensation
            % 
            
            % check input
            Value = max(min(Value,obj.MaxFocalPower),obj.MinFocalPower);
            % compose Set Focal Power message (#1102)
            Prefix1 = sprintf('%x','O');
            Prefix2 = sprintf('%x','r');
            Prefix3 = sprintf('%x','D');
            Dummy = '00';
            % Encode focal power value

            [FPBit1,FPBit2] = obj.dec2SingedInt(FPval);
            % compose message
            Message_NoCRC = {Prefix1,Prefix2,Prefix3,Dummy,Dummy,Dummy,...
                Dummy,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy,Dummy,...
                Dummy,Dummy,Dummy,Dummy,Dummy,Dummy};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,24);
            % decode answer
            G1 = obj.signedInt2Dec(Answer(3:4))/256;
            G2 = obj.signedInt2Dec(Answer(5:6))/256;
            G3 = obj.signedInt2Dec(Answer(7:8))/256;
            G4 = obj.signedInt2Dec(Answer(9:10))/256;
            T1up = obj.signedInt2Dec(Answer(11:12))/256;
            T1down = obj.signedInt2Dec(Answer(13:14))/256;
            T2 = obj.signedInt2Dec(Answer(15:16))/256;
            T3 = obj.signedInt2Dec(Answer(17:18))/256;
            T4 = obj.signedInt2Dec(Answer(19:20))/256;
        end
        
        function [Attributes,Data,Children]=exportState(obj)
            % Exports current state of MIC_OptotuneLens object
            Attributes.InstrumentName = obj.InstrumentName;
            Attributes.MinFocalPower = obj.MinFocalPower;
            Attributes.MaxFocalPower = obj.MaxFocalPower;
            Attributes.FocalPower = obj.FocalPower;
            Attributes.Data2Temp = obj.Data2Temp;
            Attributes.Firmware = obj.Firmware;
            Data = [];
            Children = [];
        end
        
        function delete(obj)
            % Close gui
            if ~isempty(obj.GuiFigure) && isvalid(obj.GuiFigure)
                close(obj.GuiFigure)
            end
            % close serial port
            fclose(obj.SPO);
        end
    end
    
    methods (Hidden = true)
        
        function FirmwareType = getFirmware(obj)
            %getFirmware retrieves Firmware type from device
            % can be A, B, C, E or F
            % decoding of answers received from device depends on firmware
            % type
            
            % compose request firmware message (#0103)
            Prefix = sprintf('%x','H');
            Message_NoCRC = {Prefix};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,6);
            % decode answer
            FirmwareType = char(Answer(2));
            obj.Firmware = FirmwareType;
        end
        
        function setFPmode(obj)
            %setFPmode sets Lens to focal power mode
            % Before focal power mode can be set it is required to set the
            % temperature limits as these determine the focal power range
            % of the device
            
            % Set min and max temperature range
            % This needs to be set in order to be able to switch to focal
            % power controlled mode. The range should be set such that it
            % encorporates any reasonably occuring temperature in the lab,
            % say 15-30 Celcius. Increasing the range will decrease the
            % allowable focal power range
            MinTemp = 15; % min temp 15C
            MaxTemp = 30; % max temp 30C
            % compose set temperature limits message (#0309)
            Prefix1 = sprintf('%x','P');
            Prefix2 = sprintf('%x','w');
            Prefix3 = sprintf('%x','T');
            Prefix4 = sprintf('%x','A');
            MinTempVal = 16*MinTemp; % Encoded temp is 16*Temp in Celcius
            MaxTempVal = 16*MaxTemp; % Encoded temp is 16*Temp in Celcius
            [MinTempBit1,MinTempBit2] = obj.dec2SingedInt(MinTempVal);
            [MaxTempBit1,MaxTempBit2] = obj.dec2SingedInt(MaxTempVal);
            Message_NoCRC = {Prefix1,Prefix2,Prefix3,Prefix4,...
                MaxTempBit1,MaxTempBit2,MinTempBit1,MinTempBit2};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,11);
            % handle status byte
            Status = Answer(3);
            obj.displayError(Status);
            % decode answer
            MaxFPval = obj.signedInt2Dec(Answer(4:5));
            MinFPval = obj.signedInt2Dec(Answer(6:7));
            switch obj.Firmware
                case 'A'
                    obj.MinFocalPower = (MinFPval/200)-5;
                    obj.MaxFocalPower = (MaxFPval/200)-5;
                case {'B','C','E','F'}
                    obj.MinFocalPower = MinFPval/200;
                    obj.MaxFocalPower = MaxFPval/200;
            end
            
            % set lens to focal power controlled mode
            % compose Change to Focal Power Controlled Mode message (#0308)
            Prefix1 = sprintf('%x','M');
            Prefix2 = sprintf('%x','w');
            Prefix3 = sprintf('%x','C');
            Prefix4 = sprintf('%x','A');
            Message_NoCRC = {Prefix1,Prefix2,Prefix3,Prefix4};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,12);
            % handle status byte
            Status = Answer(4);
            obj.displayError(Status);
            % decode answer
            MaxFPval = obj.signedInt2Dec(Answer(5:6));
            MinFPval = obj.signedInt2Dec(Answer(7:8));
            switch obj.Firmware
                case 'A'
                    obj.MinFocalPower = (MinFPval/200)-5;
                    obj.MaxFocalPower = (MaxFPval/200)-5;
                case {'B','C','E','F'}
                    obj.MinFocalPower = MinFPval/200;
                    obj.MaxFocalPower = MaxFPval/200;
            end
            
            % get current focal power
            % compose Get Focal Power message (#0310)
            Prefix1 = sprintf('%x','P');
            Prefix2 = sprintf('%x','r');
            Prefix3 = sprintf('%x','D');
            Prefix4 = sprintf('%x','A');
            Dummy = '00';
            Message_NoCRC = {Prefix1,Prefix2,Prefix3,Prefix4,Dummy,Dummy,Dummy,Dummy};
            Message = obj.addCRC(Message_NoCRC);
            Message = hex2dec(Message);
            % send message
            fwrite(obj.SPO,Message);
            % retrieve answer
            Answer = fread(obj.SPO,8);
            % decode answer
            FPval = obj.signedInt2Dec(Answer(3:4));
            switch obj.Firmware
                case 'A'
                    obj.FocalPower = (FPval/200)-5;
                case {'B','C','E','F'}
                    obj.FocalPower = FPval/200;
            end
        end
        
    end
    
    methods(Static, Hidden = true)
        
        function Dec = signedInt2Dec(Int)
            %singedInt2Dec converts singed 16 bit integer to decimal value
            % This is used to convert the tunable lens response
            %
            % INPUT
            %   Int:    16 bit signed integer value represented as two's
            %           complement, given as two 8 bit decimal values
            %           retrieved from tunable lens
            % OUTPUT
            %   Dec:    Decimal value converted from input
            
            IntCombined = Int(1)*256 + Int(2);
            BinVal = dec2bin(IntCombined,16);
            SignVal = str2double(BinVal(1)) * -2^15;
            CountVal = bin2dec(['0', BinVal(2:16)]);
            Dec = SignVal+CountVal;
            
        end
        
        function [HighByte,LowByte] = dec2SingedInt(Dec)
            %dec2SingedInt converts decimal value to singed 16 bit integer
            % This is used for messages to the tunable lens
            %
            % INPUT
            %   Dec:    Decimal value (between -32768 and 32767)
            % OUTPUT
            %   Int:    16 bit signed integer value represented as two's
            %           complement, given as two hex string bytes
            
            Val = int16(Dec);
            if Val<0
                SignBit = '1';
                ValueBits = dec2bin( ((2^15 * (Val<0)) - Val), 15);
            else
                SignBit = '0';
                ValueBits = dec2bin(Val, 15);
            end
            HighByte = dec2hex(bin2dec([SignBit,ValueBits(1:7)]));
            LowByte = dec2hex(bin2dec(ValueBits(8:15)));
            
        end
        
        function displayError(Status)
            %displayError decodes and displays status message from status
            %byte
            % It doesn't display anything if there are no errors
            
            if ~Status
                return
            end
            StatusBin = dec2bin(Status(1),8);
            if StatusBin(1)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Temperature out of range specified by user')
            end
            if StatusBin(2)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Focal power out of guaranteed range (defined by user set temperature range) ')
            end
            if StatusBin(3)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Temperature is outside product specifications')
            end
            if StatusBin(4)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Focal power inversion (defined by user set temperature range)')
            end
            if StatusBin(5)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Cannot reach lens focal power (Focal Power Controlled)/position (Position Controlled)')
            end
            if StatusBin(6)
                warning('MIC_OptotuneLens:StatusByte',...
                    'No temperature limits received (for controlled mode)')
            end
            if StatusBin(7)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Bit 1 equal 1: No or faulty EEPROM')
            end
            if StatusBin(8)
                warning('MIC_OptotuneLens:StatusByte',...
                    'Not all hardware available')
            end
            if numel(Status)>1
                StatusBin = dec2bin(Status(2),8);
                if StatusBin(1)
                    warning('MIC_OptotuneLens:StatusByte',...
                        'The connected lens is not compatible with the firmware on the lensdriver.')
                end
            end
        end
        
        function MessageWithCRC = addCRC(Message)
            % MessageWithCRC Adds CRC checksum bits to message
            % A cyclic redundancy check (CRC) is an error-detecting code
            % commonly used in digital networks and storage devices to
            % detect accidental changes to raw data. Blocks of data
            % entering these systems get a short check value attached,
            % based on the remainder of a polynomial division of their contents.
            %
            % Checking for a communication error is done by calculating the
            % CRC checksum over the whole command data array which includes
            % two CRC bytes at the end that were added from the sender. CRC
            % checksum calculation over the whole array results in a CRC
            % checksum equal to zero if no data corruption is present.
            %
            % This implementation is 16-bit CRC Checksum (CRC-16-IBM)
            % Reverse polynomial: 0xA001
            % Initial value: 0
            % Calculation is implemented as described in "Optotune Lens
            % Driver 4 manual.pdf" (adapted from c++ code)
            %
            % INPUT:
            %   Message: cell array of 8 bit hex strings
            %
            % OUTPUT:
            %   MessageWithCRC: Message with 2 CRC bytes appended at the end
            %
            % EXAMPLE:
            %   Message = {'54','41'};
            %   MessageWithCRC = addCRC(message);
            %
            % Marjolein Meddens, Lidke Lab 2017
            
            % polynomial
            poly = uint16(hex2dec('A001'));
            % initial value
            CRC = uint16(0);
            
            % calculate checksum
            for ii = 1 : numel(Message)
                data = hex2dec(Message{ii});
                CRC = bitxor(CRC,data,'uint16');
                for bb = 1 : 8
                    if bitand(CRC,1,'uint16')
                        CRC = bitshift(CRC,-1,'uint16');
                        CRC = bitxor(CRC,poly,'uint16');
                    else
                        CRC = bitshift(CRC,-1,'uint16');
                    end
                end
            end
            
            % append to data
            CRChex = dec2hex(CRC,4);
            MessageWithCRC = [Message, CRChex(1:2), CRChex(3:4)];
        end
    end
    
methods (Static)
    function unitTest()
        fprintf('Starting unit test for MIC_OptotuneLens class.\n');
        
        % Example COM port, change this as needed
        ComPort = 'COM3'; 
        
        % Create an instance of the OptotuneLens class
        try
            optoLens = MIC_OptotuneLens(ComPort);
            fprintf('Successfully created MIC_OptotuneLens object on %s.\n', ComPort);
        catch
            error('Failed to create MIC_OptotuneLens object.');
        end
        
        % Test setting a specific focal power
        try
            testPower = 5; % example focal power to set, adjust as needed within valid range
            optoLens.setFocalPower(testPower);
            fprintf('Successfully set focal power to %g dpt.\n', testPower);
        catch
            error('Failed to set focal power.');
        end
        
        % Test getting temperature
        try
            temperature = optoLens.getTemperature();
            fprintf('Current lens temperature: %g degrees Celsius.\n', temperature);
        catch
            error('Failed to get lens temperature.');
        end
        
        % Test exporting the current state
        try
            [Attributes, Data, Children] = optoLens.exportState();
            fprintf('State Export:\n');
            disp(Attributes);
        catch
            error('Failed to export the current state.');
        end
        
        % Clean up by deleting the instance
        try
            delete(optoLens);
            fprintf('MIC_OptotuneLens object deleted successfully.\n');
        catch
            error('Failed to delete MIC_OptotuneLens object.');
        end
        
        fprintf('Unit test for MIC_OptotuneLens completed successfully.\n');
    end
end

end