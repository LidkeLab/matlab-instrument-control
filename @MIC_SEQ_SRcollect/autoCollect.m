function autoCollect(obj, StartCell, RefDir)
%autoCollect initiates collection of SR data using saved reference data.
%   This method will initiate the super-resolution data collection workflow
%   for the MIC_SEQ_SRcollect class, acquiring data for selected cells in
%   the RefDir in an automated fashion.
%   
%   INPUTS: 
%       StartCell: (integer, scalar)(default = 1) Specifies the cell (of a
%                  list of cells in RefDir) for which to start the
%                  acquisition.
%       RefDir: Directory containing the cell reference .mat files.


% Define default parameter values.
if ~exist('RefDir', 'var')
    % No RefDir was provided: ask for user input.
    RefDir = uigetdir(obj.TopDir);
    if RefDir == 0
        % No directory was specified.
        return
    end
end
if ~exist('StartCell', 'var')
    % No StartCell was provided: default to starting at cell 1.
    StartCell = 1;
end

% Construct a list of cell reference files and determine the number of
% cells to be observed.
FileList = dir(fullfile(RefDir, 'Reference_Cell*'));
NumCells = numel(FileList);


% Proceed with the data acquisition, looping through each of the cells
% specified in the FileList.
obj.Shutter.close(); % close shutter before the laser turns on
obj.Laser647.setPower(obj.LaserPowerSequence647);
obj.Laser647.on();
for ii = 1:obj.NAcquisitionCycles
    % Repeat the acquisition NAcquisitionCycles times for each cell.
    for nn = StartCell:NumCells
        % If AbortNow flag was set, do not continue.
        if obj.AbortNow
            return
        end
        
        % Load data from the cell reference .mat file.
        FileName = fullfile(RefDir, FileList(nn).name);
        MatFileObj = matfile(FileName);
        RefStruct = MatFileObj.RefStruct; % extract RefStruct from file
        if obj.UseManualFindCell && (nn==StartCell)
            % Allow the user to manually identify the cell (if requested).
            Success = obj.findCoverSlipOffset_Manual(RefStruct);
            if ~Success
                % The coverslip offset find procedure was not succesful, do 
                % not proceed.
                return
            end
        end
        
        % Begin the acquisition for the current cell.
        obj.startSequence(RefStruct, obj.LabelIdx);
        
        % Update the CoverSlipOffset to account for the observed drift on 
        % the previous cell.
        if nn == StartCell
            % Ensure the error signal in AlignReg is set to its default, 
            % just in case it was changed (e.g. if an acquisition was 
            % previously performed and the class didn't get cleared).
            obj.AlignReg.ErrorSignalHistory = zeros(0, 3);
        else
            obj.CoverSlipOffset = obj.CoverSlipOffset ...
                - sum(obj.AlignReg.ErrorSignalHistory) * 1e-3; % um -> mm
        end
    end
end

% Ensure the lasers are no longer illuminating the sample.
obj.FlipMount.FilterIn(); % move ND filter into beam path
obj.Shutter.close();
obj.Laser647.off();
obj.Laser405.off();

% Publish the results if requested.
if obj.PublishResults
    % Attempt to reset/clear the memory on the default GPU before
    % proceeding with the analysis.
    reset(gpuDevice(1));
    
    % Proceed with the results publishing attempt.
    obj.StatusString = 'Publishing results...';
    SMA_Publish(fullfile(obj.TopDir, obj.CoverslipName), ...
        obj.SCMOSCalFilePath);
    obj.StatusString = '';
end


end