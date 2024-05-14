function extractCommentsToReadme(basePath)
    % Check if the base path exists
    if ~exist(basePath, 'dir')
        error('The specified base directory does not exist.');
    end

    % Get a list of all folders starting with '@'
    d = dir(basePath);
    isDir = [d(:).isdir];  % get logical index of directories
    subDirs = {d(isDir).name};  % get directory names
    targetDirs = subDirs(startsWith(subDirs, '@'));  % filter directories starting with '@'

    % Process each directory
    for i = 1:length(targetDirs)
        folderPath = fullfile(basePath, targetDirs{i});
        fprintf('Processing %s\n', folderPath);
        processFolder(folderPath);
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
    readmePath = fullfile(folderPath, 'README.md');
    fid = fopen(readmePath, 'wt');
    if fid == -1
        error('Cannot create README.md in %s.', folderPath);
    end
    
    fprintf(fid, '# %s\n', comments);  % Write comments with Markdown header
    fclose(fid);
end
