function setupMIC()
%Run this function in startup.m to setup required paths for
% matlab-instrument-control (MIC).
% If the MIC folder is located in userpath, then use the following: 
% 
% MATLAB 2017a and later:
%   run(fullfile(userpath, 'matlab-instrument-control', 'setupMIC'))
% MATLAB 2016b and earlier:
%   run(fullfile(userpath(1:end-1), 'matlab-instrument-control', 'setupMIC'))

MICPath = fileparts(which('setupMIC'));

addpath(fullfile(MICPath, 'src'))
addpath(fullfile(MICPath, 'mex64'))
addpath(fullfile(MICPath, 'mex64', 'dcam4'))

end
