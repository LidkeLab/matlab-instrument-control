% Run various tests on the example implementation of the Abstract 
% classes of Matlab-Instrument-Control (MIC).  

% mic.camera.example

fprintf('mic.camera,example.funcTest ...\n');
try
   mic.camera.example.funcTest();
end

% mic.lightsource.example

fprintf('mic.lightsource.example.funcTest ...\n');
try
   mic.lightsource.example.funcTest()
end

% mic.linearstage.example

fprintf('mic.linearstage.example.funcTest ...\n');
try
   mic.linearstage.example.funcTest()
end

% mic.powermeter.example

fprintf('mic.powermeter.example.funcTest ...\n');
try
   mic.powermeter.example.funcTest()
end

% mic.stage3D.example

fprintf('mic.stage3D.example.funcTest ...\n');
try
   mic.stage3D.example.funcTest()
end

%% A modified version
% Run various tests on the example implementation of the Abstract classes of Matlab-Instrument-Control (MIC).  

% Q: integration of CI/CD (Travis/CirceCI are free for open source) to ensure your project's integrtiy is retained across commits?

% Initialize a log file to capture test results
logFile = 'test_log.txt';
fid = fopen(logFile, 'a'); % Open for appending, creating if necessary
fprintf(fid, 'Test Log - %s\n', datestr(now));
fprintf(fid, '=======================\n');

% mic.camera.example
fprintf('mic.camera.example.funcTest ...\n');
fprintf(fid, 'Running mic.camera.example.funcTest ...\n');
try
    mic.camera.example.funcTest();
    fprintf(fid, 'Success: mic.camera.example.funcTest passed.\n');
catch ME
    warning('Error during mic.camera.example.funcTest: %s', ME.message);
    fprintf(fid, 'Error during mic.camera.example.funcTest: %s\n', ME.message);
    fprintf(fid, 'Stack trace:\n%s\n', getReport(ME, 'extended'));
end

% mic.lightsource.example
fprintf('mic.lightsource.example.funcTest ...\n');
fprintf(fid, 'Running mic.lightsource.example.funcTest ...\n');
try
    mic.lightsource.example.funcTest();
    fprintf(fid, 'Success: mic.lightsource.example.funcTest passed.\n');
catch ME
    warning('Error during mic.lightsource.example.funcTest: %s', ME.message);
    fprintf(fid, 'Error during mic.lightsource.example.funcTest: %s\n', ME.message);
    fprintf(fid, 'Stack trace:\n%s\n', getReport(ME, 'extended'));
end

% mic.linearstage.example
fprintf('mic.linearstage.example.funcTest ...\n');
fprintf(fid, 'Running mic.linearstage.example.funcTest ...\n');
try
    mic.linearstage.example.funcTest();
    fprintf(fid, 'Success: mic.linearstage.example.funcTest passed.\n');
catch ME
    warning('Error during mic.linearstage.example.funcTest: %s', ME.message);
    fprintf(fid, 'Error during mic.linearstage.example.funcTest: %s\n', ME.message);
    fprintf(fid, 'Stack trace:\n%s\n', getReport(ME, 'extended'));
end

% mic.powermeter.example
fprintf('mic.powermeter.example.funcTest ...\n');
fprintf(fid, 'Running mic.powermeter.example.funcTest ...\n');
try
    mic.powermeter.example.funcTest();
    fprintf(fid, 'Success: mic.powermeter.example.funcTest passed.\n');
catch ME
    warning('Error during mic.powermeter.example.funcTest: %s', ME.message);
    fprintf(fid, 'Error during mic.powermeter.example.funcTest: %s\n', ME.message);
    fprintf(fid, 'Stack trace:\n%s\n', getReport(ME, 'extended'));
end

% mic.stage3D.example
fprintf('mic.stage3D.example.funcTest ...\n');
fprintf(fid, 'Running mic.stage3D.example.funcTest ...\n');
try
    mic.stage3D.example.funcTest();
    fprintf(fid, 'Success: mic.stage3D.example.funcTest passed.\n');
catch ME
    warning('Error during mic.stage3D.example.funcTest: %s', ME.message);
    fprintf(fid, 'Error during mic.stage3D.example.funcTest: %s\n', ME.message);
    fprintf(fid, 'Stack trace:\n%s\n', getReport(ME, 'extended'));
end

% Close the log file
fprintf(fid, 'Test Log Completed - %s\n\n', datestr(now));
fclose(fid);

% Reply to comment:
% Thank you for your feedback regarding CI/CD integration for our project. We would like to clarify that our 
% preference is to utilize a .yml GitHub Actions workflow for running MATLAB tests of simulated instruments.
% This approach allows us to leverage GitHub's native CI/CD capabilities to automatically execute tests on code 
% commits and pull requests.
% 
% The .yml workflow we have defined includes steps to check out the repository, set up the MATLAB environment, 
% and run tests using a dedicated MATLAB test script. This ensures that our project's integrity is consistently verified across 
% all code changes.
% 
% While we appreciate the suggestion of using platforms like Travis CI or CircleCI, we believe that our current setup 
% with GitHub Actions aligns well with our project goals and provides an efficient and integrated way to manage
% testing and CI/CD processes.
