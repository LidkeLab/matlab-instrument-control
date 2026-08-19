% testNanoMax300Piezos
%
% Hardware test script for a Thorlabs NanoMax 300 stage with a mixed set
% of piezo controllers / strain gauge readers:
%
%   X: TPZ001 ('81843229')  + TSG001 ('84842506')  -> mic.linearstage.TCubePiezo
%   Y: KPZ101 ('29501303')  + KSG101 ('59000140')  -> mic.linearstage.KCubePiezo
%   Z: KPC101 ('113251934') (integrated controller + strain gauge)
%                                                  -> mic.linearstage.KCubePiezoStrainGauge
%
% Run this script section by section (Ctrl+Enter) with the stage
% connected.  The Kinesis GUI must be CLOSED before running (each device
% allows only one connection).
%
% Construction of each axis includes zeroing/calibrating its strain
% gauge, so expect ~30 s per axis before the object returns.
%
% REQUIRES:
%   mic.linearstage.TCubePiezo, mic.linearstage.KCubePiezo,
%   mic.linearstage.KCubePiezoStrainGauge and their Kinesis mex files
%   (Kinesis_PCC_*, Kinesis_SG_*, Kinesis_KCube_PCC_*, Kinesis_KCube_SG_*,
%   Kinesis_KPC_*) on the MATLAB path along with the Thorlabs runtime DLLs.

%% Setup: serial numbers and test parameters
SerialNoTPZ001 = '81843229';   % X piezo controller (TCube)
SerialNoTSG001 = '84842506';   % X strain gauge reader (TCube)
SerialNoKPZ101 = '29501303';   % Y piezo controller (KCube)
SerialNoKSG101 = '59000140';   % Y strain gauge reader (KCube)
SerialNoKPC101 = '113251934';  % Z piezo + strain gauge (single KCube)

Tolerance = 0.25;              % max |commanded - measured| allowed (um)
SettleTime = 2;                % wait after each move before reading (s)
TestPositions = [2, 5, 10, 15, 18];  % test points within 0-20 um travel

%% Connect X axis: TPZ001 + TSG001 (T-Cube pair)
fprintf('Connecting X axis (TPZ001 %s + TSG001 %s)...\n', ...
    SerialNoTPZ001, SerialNoTSG001);
PX = mic.linearstage.TCubePiezo(SerialNoTPZ001, SerialNoTSG001, 'X');
fprintf('X axis connected. MaxPosition = %g um\n', PX.MaxPosition);

%% Connect Y axis: KPZ101 + KSG101 (K-Cube pair)
fprintf('Connecting Y axis (KPZ101 %s + KSG101 %s)...\n', ...
    SerialNoKPZ101, SerialNoKSG101);
PY = mic.linearstage.KCubePiezo(SerialNoKPZ101, SerialNoKSG101, 'Y');
fprintf('Y axis connected. MaxPosition = %g um\n', PY.MaxPosition);

%% Connect Z axis: KPC101 (integrated K-Cube piezo + strain gauge)
% The constructor sets closed loop mode, zeroes the strain gauge (~30 s)
% and centers the stage.
fprintf('Connecting Z axis (KPC101 %s)...\n', SerialNoKPC101);
PZ = mic.linearstage.KCubePiezoStrainGauge(SerialNoKPC101, 'Z');
fprintf('Z axis connected. MaxPosition = %g um\n', PZ.MaxPosition);

%% Per-axis position sweep with strain gauge readback
% Command each test position and compare against the strain gauge
% reading.  The T/K-Cube pair classes' getPosition() returns the
% commanded position, so read their strain gauges directly through the
% Kinesis mex interface; the KPC101 getPosition() already returns the
% strain gauge feedback.
%
% Strain gauge readings for the cube pairs come back as a 15-bit value
% over the full travel: 0-(2^15-1) -> 0-20 um.
SGToUm = 20 / 2^15;
readX = @() SGToUm * double(Kinesis_SG_GetReading(SerialNoTSG001));
readY = @() SGToUm * double(Kinesis_KCube_SG_GetReading(SerialNoKSG101));
readZ = @() PZ.getPosition();

Axes = {'X', PX, readX; 'Y', PY, readY; 'Z', PZ, readZ};
NFail = 0;
for aa = 1:size(Axes, 1)
    [AxisName, P, readSG] = Axes{aa, :};
    fprintf('\n--- %s axis sweep ---\n', AxisName);
    for Pos = TestPositions
        P.setPosition(Pos);
        pause(SettleTime);
        Measured = readSG();
        ErrUm = Measured - Pos;
        if abs(ErrUm) <= Tolerance
            Result = 'PASS';
        else
            Result = 'FAIL';
            NFail = NFail + 1;
        end
        fprintf('%s: commanded %5.2f um, measured %6.3f um, error %+6.3f um  [%s]\n', ...
            AxisName, Pos, Measured, ErrUm, Result);
    end
    P.center();
    pause(SettleTime);
    fprintf('%s: centered, strain gauge reads %6.3f um (expect ~%g)\n', ...
        AxisName, readSG(), P.MaxPosition/2);
end

%% Repeatability: return to the same position several times
% Move away, come back to the target and record the strain gauge
% reading; the spread shows closed loop repeatability per axis.
Target = 10;
NRepeats = 5;
fprintf('\n--- Repeatability at %g um (%d repeats) ---\n', Target, NRepeats);
for aa = 1:size(Axes, 1)
    [AxisName, P, readSG] = Axes{aa, :};
    Readings = zeros(1, NRepeats);
    for rr = 1:NRepeats
        P.setPosition(2);
        pause(SettleTime);
        P.setPosition(Target);
        pause(SettleTime);
        Readings(rr) = readSG();
    end
    fprintf('%s: mean %6.3f um, std %6.4f um, peak-to-peak %6.4f um\n', ...
        AxisName, mean(Readings), std(Readings), ...
        max(Readings) - min(Readings));
    P.center();
end

%% Small step response (Z axis, KPC101)
% Step the Z piezo in 0.1 um increments around center and read back the
% strain gauge after each step, to confirm the KPC101 resolves small
% closed loop moves.
fprintf('\n--- Z axis small steps (0.1 um) ---\n');
StartPos = 10;
PZ.setPosition(StartPos);
pause(SettleTime);
for Step = 1:5
    Pos = StartPos + 0.1*Step;
    PZ.setPosition(Pos);
    pause(1);
    fprintf('Z: commanded %6.2f um, measured %6.3f um\n', ...
        Pos, PZ.getPosition());
end
PZ.center();

%% Combined 3D move
% Move all three axes together as they would be used on the microscope.
fprintf('\n--- Combined 3D moves ---\n');
Positions3D = [5 5 5; 15 15 15; 10 10 10];
for pp = 1:size(Positions3D, 1)
    PX.setPosition(Positions3D(pp, 1));
    PY.setPosition(Positions3D(pp, 2));
    PZ.setPosition(Positions3D(pp, 3));
    pause(SettleTime);
    fprintf('Commanded [%g %g %g], measured [%6.3f %6.3f %6.3f] um\n', ...
        Positions3D(pp, :), readX(), readY(), readZ());
end

%% Export state
fprintf('\n--- Exported states ---\n');
StateX = PX.exportState()
StateY = PY.exportState()
StateZ = PZ.exportState()

%% Summary and cleanup
% Deleting the objects closes the Kinesis connections; this must be done
% before opening the Kinesis GUI or constructing new objects.
if NFail == 0
    fprintf('\nAll sweep points passed within %g um tolerance.\n', Tolerance);
else
    fprintf('\n%d sweep point(s) FAILED the %g um tolerance.\n', ...
        NFail, Tolerance);
end
PX.center(); PY.center(); PZ.center();
pause(1);
delete(PX);
delete(PY);
delete(PZ);
clear PX PY PZ
fprintf('All devices closed.\n');
