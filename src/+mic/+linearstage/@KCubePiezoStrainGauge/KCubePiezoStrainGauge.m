classdef KCubePiezoStrainGauge < mic.linearstage.abstract
    % mic.linearstage.KCubePiezoStrainGauge Matlab Instrument Control Class
    % for the ThorLabs KPC101 KCube Piezo Strain Gauge controller.
    %
    % ## Description
    %   This class controls a linear piezo stage using the Thorlabs KPC101,
    %   an integrated piezo controller + strain gauge reader in a single
    %   KCube with a single serial number (unlike the KPZ101+KSG101 pair
    %   handled by mic.linearstage.KCubePiezo).  It uses the Thorlabs
    %   Kinesis C-API via pre-compiled mex files (Kinesis_KPC_*).
    %
    %   The device is driven in closed loop: positions are commanded and
    %   read back through the built-in strain gauge feedback, so no manual
    %   Slope/Offset calibration is required.  The C API expresses position
    %   as a percentage of maximum travel (WORD 0-32767 = 0-100%); this
    %   class converts to/from microns using the max travel reported by
    %   the device.
    %
    % ## Protected Properties
    %
    % ### `PositionUnit`
    % Units of the position parameter.
    % **Default:** `'um'`.
    %
    % ### `CurrentPosition`
    % Current position of the device.
    % **Default:** `0`.
    %
    % ### `MinPosition`
    % Lower limit position.
    % **Default:** `0`.
    %
    % ### `MaxPosition`
    % Upper limit position in microns.  Read from the device at
    % construction via Kinesis_KPC_GetMaximumTravel.
    % **Default:** `20`.
    %
    % ### `Axis`
    % Stage axis (options: `X`, `Y`, or `Z`).
    %
    % ### `SerialNoKPC101`
    % Serial number of the KCube Piezo Strain Gauge controller.
    %
    % ### `InstrumentName`
    % Name of the instrument.
    % **Default:** `'KCubePiezoStrainGauge'`.
    %
    % ### `WaitTime`
    % Time to wait before returning after a `setPosition` command (in seconds).
    % **Default:** `0`.
    %
    % ## Key Functions
    % - **Constructor (`mic.linearstage.KCubePiezoStrainGauge(SerialNoKPC101, AxisLabel)`):**
    %   Opens the device, reads the maximum travel, sets closed loop mode,
    %   zeroes the strain gauge (~30 s) and centers the stage.
    % - **`openDevices()`:** Opens the connection with the Kinesis C-API.
    % - **`closeDevices()`:** Stops polling and closes the connection.
    % - **`zeroStrainGauge()`:** Runs the device zeroing routine and waits
    %   for it to finish (required for accurate closed loop positions).
    % - **`setPosition(Position)`:** Moves the stage to a position in microns.
    % - **`getPosition()`:** Reads the current position in microns from the
    %   strain gauge feedback.
    % - **`shutdown()`:** Closes the device.
    % - **`exportState()`:** Exports the current operational state.
    %
    % ## Usage Example
    %   PZ=mic.linearstage.KCubePiezoStrainGauge('113251934','Z')
    %   PZ.gui()
    %   PZ.setPosition(10);
    %
    % ## Kinesis Setup:
    %   Recommended one-time setup in the Kinesis Software GUI before
    %   using this class:
    %   1-set Loop Mode to "Closed Loop" (Control tab: Feedback Loop Settings)
    %   2-set Maximum Travel to match the actuator (e.g. 20 um for NanoMax 300)
    %   3-persist settings to the device (Save to Startup tab)
    %   Kinesis must be disconnected/closed before using this class
    %   (the device allows only one connection).
    %
    % ## REQUIRES:
    %   mic.abstract.m
    %   mic.linearstage.abstract.m
    %   Precompiled set of mex files Kinesis_KPC_*.mexw64
    %   (compile with mex_source/MIC/buildKPCMex.m)
    %   The following dll must be in system path or same directory as mex files:
    %   Thorlabs.MotionControl.KCube.PiezoStrainGauge.dll
    %   Thorlabs.MotionControl.DeviceManager.dll
    %
    % ### Citation: Mahsa Habibi, LidkeLab, 2026.

    properties (SetAccess=protected)
        PositionUnit='um';          % Units of position parameter (eg. um/mm)
        CurrentPosition=0;          % Current position of device
        MinPosition=0;              % Lower limit position
        MaxPosition=20;             % Upper limit position (um), read from device
        Axis;                       % Stage axis (X, Y or Z)
        SerialNoKPC101;             % Serial Number of KCube Piezo Strain Gauge Controller
        InstrumentName='KCubePiezoStrainGauge' % Instrument name.
    end

    properties (SetAccess=protected)
        WaitTime=0;                 %Time to wait before returning after a setPosition (s)
    end

    properties (Hidden)
        StartGUI; % Start gui when creating instance of class
    end

    properties (Constant, Hidden)
        PositionWORDMax=32767;      % C API position range 0-32767 = 0-100% travel
        StatusBitZeroed=16;         % 0x10 Piezo channel has been zeroed
        StatusBitZeroing=32;        % 0x20 Piezo channel is zeroing
        ZeroTimeout=60;             % Max time to wait for zeroing routine (s)
    end

    methods
        function obj=KCubePiezoStrainGauge(SerialNoKPC101,AxisLabel,MaxPosition)
            % Creates a KCubePiezoStrainGauge object and centers the stage.
            % MaxPosition (optional) is the actuator travel in microns;
            % it must match the Maximum Travel configured in Kinesis.
            % Example: PZ=mic.linearstage.KCubePiezoStrainGauge('113251934','Z')
            % Example: PZ=mic.linearstage.KCubePiezoStrainGauge('113251934','Z',20)
            obj=obj@mic.linearstage.abstract(~nargout);

            if nargin<2
                error('mic.linearstage.KCubePiezoStrainGauge::SerialNoKPC101,AxisLabel must be defined')
            end
            if nargin>2
                obj.MaxPosition=MaxPosition;
            end

            obj.SerialNoKPC101=SerialNoKPC101;
            obj.Axis=AxisLabel;
            try
                %Open Device (This may crash)
                obj.openDevices();

                %Set closed loop mode (position commands are ignored in open loop)
                Kinesis_KPC_SetPositionControlMode(obj.SerialNoKPC101,2);

                %Zero the Strain Gauge (takes ~30 s)
                obj.zeroStrainGauge();

                %Best-effort read of the maximum travel from the device
                %(100 nm steps -> um).  KPC101 firmware has been observed
                %to return 0 here even after zeroing, in which case
                %MaxPosition keeps its constructor/default value, which
                %must match the Maximum Travel configured in Kinesis.
                Travel=Kinesis_KPC_GetMaximumTravel(obj.SerialNoKPC101);
                if Travel>0&&abs(Travel*0.1-obj.MaxPosition)>0.01
                    warning(['KCubePiezoStrainGauge:: Device reports max ', ...
                        'travel %g um but MaxPosition is %g um; using the ', ...
                        'device value.'],Travel*0.1,obj.MaxPosition)
                    obj.MaxPosition=Travel*0.1;
                end

            catch ME
                obj.closeDevices();
                warning('Problem constructing KCube Piezo Strain Gauge')
                rethrow(ME)
            end

            %Center
            obj.center();

        end
        function delete(obj)
            % Destructor.
            obj.shutdown();
        end

        function Err=openDevices(obj)
            % Opens communications to the KPC101 with Kinesis C-API via mex

            Kinesis_TLI_BuildDeviceList();
            pause(1);  %Try to prevent crash

            ErrKPC=Kinesis_KPC_Open(obj.SerialNoKPC101);

            % Determine if there were errors opening the device and
            % output an appropriate warning.
            if ErrKPC ~= 0 % ErrKPC == 0 suggests a succesful connection
                ErrorMessage = obj.decodeError(ErrKPC);
                warning(['openDevices::Error opening piezo strain gauge ', ...
                    'controller \nError code %i was returned while ', ...
                    'trying to connect to controller %s: \n', ...
                    ErrorMessage], ErrKPC, obj.SerialNoKPC101)
            end

            % Return a general error boolean in case it's needed elsewhere.
            Err=(ErrKPC==0);

        end

        function closeDevices(obj)
            % Closes communications to the KPC101 with Kinesis C-API via mex
            % This must be done before using Kinesis or creating new
            % objects.
            Kinesis_KPC_Close(obj.SerialNoKPC101)
        end

        function resetDevices(obj)
            % Close and Reopen Devices.
            obj.closeDevices();
            obj.openDevices();
        end

        function zeroStrainGauge(obj)
            % Runs the device zeroing routine and waits for completion.
            % Required after power-up for accurate closed loop positions.
            SN=obj.SerialNoKPC101;

            Kinesis_KPC_SetZero(SN);
            pause(2); %give the zeroing bit time to assert

            %Wait until the zeroing bit clears and the zeroed bit sets
            Elapsed=0;
            while Elapsed<obj.ZeroTimeout
                Bits=Kinesis_KPC_GetStatusBits(SN);
                IsZeroing=bitand(Bits,obj.StatusBitZeroing)>0;
                IsZeroed=bitand(Bits,obj.StatusBitZeroed)>0;
                if ~IsZeroing&&IsZeroed
                    return
                end
                pause(1);
                Elapsed=Elapsed+1;
            end
            warning(['KCubePiezoStrainGauge:zeroStrainGauge:: Zeroing did ', ...
                'not complete within %g s'],obj.ZeroTimeout)
        end

        function setPosition(obj,Position)
            % Sets Piezo Stage Position in microns.
            obj.CurrentPosition=max(obj.MinPosition,Position);
            obj.CurrentPosition=min(obj.MaxPosition,obj.CurrentPosition);

            PositionWORD=uint16(round( ...
                obj.CurrentPosition/obj.MaxPosition*obj.PositionWORDMax));
            Kinesis_KPC_SetPosition(obj.SerialNoKPC101,PositionWORD);
            pause(obj.WaitTime);
            obj.updateGui();

        end

        function Position=getPosition(obj)
            % Returns the current position in microns read from the
            % strain gauge feedback.
            PositionWORD=Kinesis_KPC_GetPosition(obj.SerialNoKPC101);
            Position=PositionWORD/obj.PositionWORDMax*obj.MaxPosition;
        end

        function [Attributes,Data,Children]=exportState(obj)
            % Export the object current state
            Attributes.PositionUnit=obj.PositionUnit;
            Attributes.CurrentPosition=obj.CurrentPosition;
            Attributes.MinPosition=obj.MinPosition;
            Attributes.MaxPosition=obj.MaxPosition;
            Attributes.Axis=obj.Axis;
            Attributes.SerialNoKPC101=obj.SerialNoKPC101;
            Attributes.InstrumentName=obj.InstrumentName;
            Data=[];
            Children=[];
        end

        function shutdown(obj)
            % Set power to zero and turn off.
            obj.closeDevices();
        end

    end
    methods (Static=true)
        function Success=funcTest(SN,AxisLabel)
            % Unit test of object functionality
            % Example: mic.linearstage.KCubePiezoStrainGauge.funcTest('113251934','Z')

            if nargin<2
                error('mic.linearstage.KCubePiezoStrainGauge::SerialNoKPC101,AxisLabel must be defined')
            end

            try
                %Creating an Object and Testing setPosition, getPosition
                fprintf('Creating Object and testing...\n')
                P=mic.linearstage.KCubePiezoStrainGauge(SN,AxisLabel);
                P.gui;
                P.setPosition(P.MaxPosition/8);
                pause(1);
                fprintf('Read back position: %g um\n',P.getPosition());
                P.center();
                pause(1);
                P.setPosition(P.MaxPosition*7/8);
                pause(1);
                fprintf('Read back position: %g um\n',P.getPosition());
                P.exportState()
                delete(P);
                fprintf('Deleteing Object.\n')
                Success=1;
            catch
                warning('mic.linearstage.KCubePiezoStrainGauge:: Failed Unit Test');
                Success=0;
            end

        end

        function [ErrorMessage] = decodeError(Error)
            % Used to decode an integer error code returned by a Kinesis
            % device.  Same codes as mic.linearstage.KCubePiezo.
            [ErrorMessage] = mic.linearstage.KCubePiezo.decodeError(Error);
        end

    end


end
