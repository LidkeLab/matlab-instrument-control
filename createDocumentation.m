function createDocumentation(inputFolderPath, outputFolderPath)
    % Validate input folder path
    if ~isfolder(inputFolderPath)
        error('Input path is not a valid folder: %s', inputFolderPath);
    end

    % Get all items in the input directory
    items = dir(inputFolderPath);
    % Filter for directories starting with '@'
    atFolders = items([items.isdir] & startsWith({items.name}, '@'));
    
    % Iterate over each @folder
    for i = 1:length(atFolders)
        folderPath = fullfile(inputFolderPath, atFolders(i).name);
        classFiles = dir(fullfile(folderPath, '*.m'));
        
        % Process each .m file in the @folder
        for j = 1:length(classFiles)
            classFilePath = fullfile(folderPath, classFiles(j).name);
            % Generate output file path
            outputFilePath = fullfile(outputFolderPath, [classFiles(j).name(1:end-2), '.md']);
            
            try
                % Extract comments and write to Markdown
                extractAndWriteComments(classFilePath, outputFilePath);
            catch ME
                warning('Failed to process %s: %s', classFilePath, ME.message);
            end
        end
    end
    
    disp('Completed documentation for all classes.');
end

function extractAndWriteComments(inputFilePath, outputFilePath)
    % Open the MATLAB .m file
    fid = fopen(inputFilePath, 'r');
    if fid == -1
        error('File cannot be opened: %s', inputFilePath);
    end
    
    % Read the entire file into memory
    fileContents = fread(fid, '*char')';
    fclose(fid);
    
    % Regular expression to extract the first significant comment block
    commentPattern = '(\s*%[^\n]*\n)+';
    [startIndex, endIndex] = regexp(fileContents, commentPattern, 'once');
    
    if isempty(startIndex)
        error('No initial comment block found.');
    end
    
    % Extract the comment block
    commentBlock = fileContents(startIndex:endIndex);
    
    % Convert comment block from MATLAB comments to markdown format
    commentLines = strsplit(commentBlock, '\n');
    markdownText = strjoin(cellfun(@(x) strtrim(strrep(x, '%', '')), commentLines, 'UniformOutput', false), '\n');
    
    % Write to Markdown file
    fid = fopen(outputFilePath, 'w');
    if fid == -1
        error('Output file cannot be created: %s', outputFilePath);
    end
    fprintf(fid, '%s', markdownText);
    fclose(fid);
end


% inputFolderPath = 'C:\Users\sajja\Documents\MATLAB\matlab-instrument-control\'
% outputFolderPath = 'C:\Users\sajja\Documents\MATLAB\matlab-instrument-control\Documentation\'