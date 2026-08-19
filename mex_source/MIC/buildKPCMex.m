function buildKPCMex()
% buildKPCMex Compiles the Kinesis_KPC_* mex files for the Thorlabs KPC101.
%
% Compiles all Kinesis_KPC_* wrappers in mex_source/MIC/ against the
% Thorlabs Kinesis C API and places the resulting .mexw64 files in mex64/.
%
% REQUIRES:
%   - A C++ compiler configured in MATLAB (run: mex -setup C++)
%   - Thorlabs Kinesis installed at C:\Program Files\Thorlabs\Kinesis
%
% Run from any directory:
%   run('...\mex_source\MIC\buildKPCMex.m')

SourceDir = fileparts(mfilename('fullpath'));
OutDir = fullfile(fileparts(fileparts(SourceDir)), 'mex64');
KinesisLib = ['C:\Program Files\Thorlabs\Kinesis\', ...
    'Thorlabs.MotionControl.KCube.PiezoStrainGauge.lib'];

if ~isfile(KinesisLib)
    error('buildKPCMex:libNotFound', ...
        'Kinesis import library not found: %s', KinesisLib)
end

MexNames = { ...
    'Kinesis_KPC_Open', ...
    'Kinesis_KPC_Close', ...
    'Kinesis_KPC_SetPosition', ...
    'Kinesis_KPC_GetPosition', ...
    'Kinesis_KPC_SetPositionControlMode', ...
    'Kinesis_KPC_SetZero', ...
    'Kinesis_KPC_GetStatusBits', ...
    'Kinesis_KPC_GetMaximumTravel'};

for ii = 1:numel(MexNames)
    SourceFile = fullfile(SourceDir, MexNames{ii}, 'mexFunction.cpp');
    fprintf('Compiling %s...\n', MexNames{ii})
    mex(SourceFile, KinesisLib, '-outdir', OutDir, '-output', MexNames{ii})
end

fprintf('Done.  Mex files written to %s\n', OutDir)

end
