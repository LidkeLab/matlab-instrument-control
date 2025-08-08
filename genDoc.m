basePath = '.';
createDocumentation(basePath)
%% A modified version
function createDocumentation(basePath)
    % Check if the base path exists
    if ~exist(basePath, 'dir')
        error('The specified base directory does not exist.');
    end

    % Call recursive function to process directories
    processDirectoriesRecursively(basePath);
end

function processDirectoriesRecursively(currentPath)
    % Get a list of all folders in the current path
    d = dir(currentPath);
    isDir = [d(:).isdir];  % get logical index of directories
    subDirs = {d(isDir).name};  % get directory names

    % Filter out '.' and '..'
    validDirs = subDirs(~ismember(subDirs, {'.', '..'}));

    % Process each valid directory
    for i = 1:length(validDirs)
        folderName = validDirs{i};
        folderPath = fullfile(currentPath, folderName);
        
        % If directory starts with '@', process it
        if startsWith(folderName, '@')
            fprintf('Processing %s\n', folderPath);
            processFolder(folderPath);
        end
        
        % Recursively call this function on all subdirectories
        processDirectoriesRecursively(folderPath);
    end
end

function processFolder(folderPath)
    % Get all MATLAB files in the directory
    files = dir(fullfile(folderPath, '*.m'));
    for i = 1:length(files)
        filePath = fullfile(folderPath, files(i).name);
        comments = extractComments(filePath);
        if ~isempty(comments)
            writeReadme(folderPath, comments);
            break;  % Assume only one class definition per folder
        end
    end
end

function comments = extractComments(filePath)
    fid = fopen(filePath, 'rt');
    if fid == -1
        error('Cannot open file %s.', filePath);
    end

    try
        % Read file line by line
        tline = fgetl(fid);
        insideCommentBlock = false;
        comments = '';
        while ischar(tline)
            if contains(tline, 'classdef')
                insideCommentBlock = true;  % Start capturing comments after classdef
            elseif contains(tline, 'properties')
                if insideCommentBlock
                    break;  % Stop if properties block is reached
                end
            elseif insideCommentBlock && startsWith(strtrim(tline), '%')
                % Clean and format the comment line
                cleanLine = strtrim(tline(2:end));  % Remove leading '%' and white spaces
                if startsWith(cleanLine, '%')
                    cleanLine = strtrim(cleanLine(2:end));  % Remove additional '%' for Markdown headers
                end
                comments = [comments, cleanLine, newline];
            end
            tline = fgetl(fid);
        end
    catch
        fclose(fid);
        rethrow(lasterror);
    end
    fclose(fid);
end

function writeReadme(folderPath, comments)
    readmePath = fullfile(folderPath, 'Readme.md');
    fid = fopen(readmePath, 'wt');
    if fid == -1
        error('Cannot create Readme.md in %s.', folderPath);
    end
    
    fprintf(fid, '# %s\n', comments);  % Write comments with Markdown header
    fclose(fid);
end
% basePath = 'C:\Users\sajja\Documents\MATLAB\matlab-instrument-control\'
% basePath = 'C:\Users\sajja\Documents\MATLAB\matlab-instrument-control\src\+mic\'