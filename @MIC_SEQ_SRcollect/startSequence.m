function startSequence(obj, RefStruct, LabelID)
%startSequence collects/saves SR data for a cell specified in RefStruct.
%   This method will collect and save a super-resolution dataset for a cell
%   specified in the RefStruct.
%
%   INPUTS:
%       RefStruct: (structure) Structured array containing the information
%                  needed to find/acquire data for a specific cell.
%       LabelID: (integer, scalar) Integer used to specify the current
%                label (for a sequential acquisition) being observed. 

% Setup directories/filenames as needed.
obj.StatusString = 'Preparing directories...';
DirectoryName = fullfile(obj.TopDir, obj.CoverslipName, ...
    sprintf('Cell_%.2i', RefStruct.CellIdx), ...
    sprintf('Label_%.2i', LabelID));
mkdir(DirectoryName);
CurrentTime = clock;
DateString = [num2str(CurrentTime(1)), '-', ...
    num2str(CurrentTime(2)),  '-', num2str(CurrentTime(3)), '-', ...
    num2str(CurrentTime(4)), '-', num2str(CurrentTime(5)), '-', ...
    num2str(round(CurrentTime(6)))];
if obj.IsBleach
    % Indicate that this is a photobleaching sequence if necessary.
    FileName = sprintf('Data_%s_bleaching_%s.h5', ...
        DateString, obj.FilenameTag);
else
    FileName = sprintf('Data_%s_%s.h5', DateString, obj.FilenameTag);
end
FileName = fullfile(DirectoryName, FileName);

% Prepare for .h5 file writing.
% NOTE: For now, obj.SaveFileType must be 'h5'.
switch obj.SaveFileType
    case {'h5', 'h5DataGroups'}
        % For either .h5 file save type, we'll still use the same
        % supergroup of Channel01.
        FileH5 = FileName;
        MIC_H5.createFile(FileH5);
        MIC_H5.createGroup(FileH5, 'Channel01');
        MIC_H5.createGroup(FileH5, 'Channel01/Zposition001');
    otherwise
        error('StartSequence:: unknown file save type')
end

% Attempt to move to the cell of interest.
% NOTE: The stepper channels are in the order [y, x, z], but
%       RefStruct.StepperPos is in the order [x, y, z].
obj.StageStepper.moveToPosition(1, ...
    RefStruct.StepperPos(2) + obj.CoverSlipOffset(2));
obj.StageStepper.moveToPosition(2, ...
    RefStruct.StepperPos(1) + obj.CoverSlipOffset(1));
obj.StageStepper.moveToPosition(3, ...
    RefStruct.StepperPos(3) + obj.CoverSlipOffset(3));
obj.StagePiezo.center(); % center the piezos to ensure full range of motion

% Attempt to align the cell to the reference image in brightfield (if
% requested).
if obj.UseBrightfieldReg
    obj.StatusString = sprintf(['Cell %g, Sequence 1 - ', ...
        'Attempting initial brightfield alignment...'], RefStruct.CellIdx);
    obj.Lamp660.setPower(obj.Lamp660Power);
    pause(obj.LampWait);
    obj.CameraSCMOS.ExpTime_Capture = obj.ExposureTimeCapture;
    obj.CameraSCMOS.AcquisitionType = 'capture';
    obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
    obj.CameraSCMOS.setup_acquisition();
    obj.AlignReg.Image_Reference = double(RefStruct.Image);
    obj.AlignReg.ReferenceStack = double(RefStruct.ReferenceStack);
    obj.AlignReg.AbortNow = 0; % reset the AbortNow flag
    obj.AlignReg.IsInitialRegistration = 1; % indicate first cell find
    obj.AlignReg.ErrorSignalHistory = zeros(0, 3); % reset history
    obj.AlignReg.OffsetFitSuccessHistory = zeros(0, 3);
    try
        obj.AlignReg.align2imageFit();
    catch
        % We don't want to throw an error since there are still other cells
        % to be measured from here on: warn the user, attempt to export
        % data that might be useful, and return control to the calling
        % method.
        warning('Problem with AlignReg.align2imageFit()')
        obj.StatusString = ...
            'Exporting object Data and Children with exportState()...';
        fprintf(...
            'Saving exportables from exportState()....................\n')
        switch obj.SaveFileType
            case {'h5', 'h5DataGroups'}
                % For either .h5 file save type, we'll still use the same
                % supergroup of Channel01/Zposition001.
                SequenceName = 'Channel01/Zposition001';
                MIC_H5.createGroup(FileH5, SequenceName);
                obj.save2hdf5(FileH5, SequenceName);
            otherwise
                error('StartSequence:: unknown SaveFileType')
        end
        obj.StatusString = '';
        fprintf('Saving exportables from exportState() complete \n')
        return
    end
    obj.Lamp660.setPower(0);
end

% Setup Active Stabilization (if desired).
if obj.UseActiveReg
    obj.ActiveReg = MIC_ActiveReg3D_Seq(...
        obj.CameraIR,obj.StagePiezoX,obj.StagePiezoY,obj.StagePiezoZ);
    obj.Lamp850.on;
    obj.Lamp850.setPower(obj.Lamp850Power);
    obj.IRCamera_ExposureTime = obj.CameraIR.ExpTime_Capture;
    obj.ActiveReg.takeRefImageStack(); % takes 21 reference images
    obj.ActiveReg.Period = obj.StabPeriod;
    obj.ActiveReg.start();
end

% Setup the main sCMOS to acquire the sequence.
obj.StatusString = sprintf(['Cell %g, Sequence 1 - ', ...
    'Preparing for acquisition...'], RefStruct.CellIdx);
obj.CameraSCMOS.ExpTime_Sequence = obj.ExposureTimeSequence;
obj.CameraSCMOS.SequenceLength = obj.NumberOfFrames;
obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
obj.CameraSCMOS.TriggerMode = 'internal';
obj.CameraSCMOS.AcquisitionType = 'sequence';
obj.CameraSCMOS.setup_acquisition();

% Prepare the lasers for the sequence based on the appropriate object
% properties.
obj.FlipMount.FilterOut(); % removes ND filter from optical path
obj.Laser647.setPower(obj.LaserPowerSequence647);
obj.Laser405.setPower(obj.LaserPowerSequence405);

% Begin the acquisition, performing a pre-activation step if requested.
if obj.UsePreActivation
    % Update the status string to indicate that the pre-activation is
    % happening.
    obj.StatusString = sprintf(['Cell %g, Sequence 1 - ', ...
        'Pre-activating fluorophores...'], RefStruct.CellIdx);
    
    % Allow the lasers to reach the sample as requested by the set flags.
    if obj.OnDuringSequence405
        obj.Laser405.on();
    end
    if obj.OnDuringSequence647
        % Only open the shutter if requested by the set flag.
        obj.Shutter.open();
    end
    
    % Pause for the prescribed amount of time to allow for
    % pre-activation, first ensuring the user hasn't disabled the
    % pause setting.
    PreviousState = pause('on'); % saves current state for later
    pause(obj.DurationPreActivation);
    
    % Turn off the 405nm laser (if used) and close the shutter to
    % prevent the 647nm laser from reaching the sample.
    obj.Shutter.close();
    obj.Laser405.off();
    
    % Restore the previous pause setting (in case this was important
    % elsewhere/to the user).
    pause(PreviousState);
    
    % Empty the status string to indicate that the pre-activation has
    % completed.
    obj.StatusString = '';
end
fprintf('Collecting data..........................................\n')
for ii = 1:obj.NumberOfSequences
    % If AbortNow flag was set, do not continue.
    if obj.AbortNow
        return
    end
    
    % Use periodic registration after NSeqBeforePeriodicReg
    % sequences have been collected.
    if obj.UseBrightfieldReg && ~mod(ii, obj.NSeqBeforePeriodicReg) ...
            && ~(ii == 1)
        obj.StatusString = sprintf(['Cell %g, Sequence %i - ', ...
            'Attempting periodic registration...'], ...
            RefStruct.CellIdx, ii);
        obj.Lamp660.setPower(obj.Lamp660Power);
        pause(obj.LampWait);
        obj.CameraSCMOS.ExpTime_Capture = obj.ExposureTimeCapture;
        obj.CameraSCMOS.AcquisitionType = 'capture';
        obj.CameraSCMOS.ROI = obj.SCMOS_ROI_Collect;
        obj.CameraSCMOS.setup_acquisition();
        obj.AlignReg.IsInitialRegistration = 0; % indicate periodic reg.
        try
            obj.AlignReg.align2imageFit();
        catch
            % If the alignment fails, don't stop auto collect for
            % other cells.
            warning('Problem with AlignReg.align2imageFit()')
            return
        end
        obj.Lamp660.setPower(0);
    end
    
    % Allow the lasers to reach the sample as requested by the set flags.
    if obj.OnDuringSequence405
        obj.Laser405.on();
    end
    if obj.OnDuringSequence647
        % Only open the shutter if requested by the set flag.
        obj.Shutter.open();
    end
    
    % Collect the sequence.
    obj.StatusString = sprintf(['Cell %g, Sequence %i - ', ...
            'Acquiring data...'], ...
            RefStruct.CellIdx, ii);
    obj.CameraSCMOS.AcquisitionType = 'sequence';
    obj.CameraSCMOS.TriggerMode = 'internal';
    obj.CameraSCMOS.ExpTime_Sequence = obj.ExposureTimeSequence;
    Sequence = obj.CameraSCMOS.start_sequence();
    switch obj.SaveFileType
        case 'h5'
            % Place the current dataset in the same group as all other
            % datasets.
            SequenceName = sprintf('Data%04d', ii);
            MIC_H5.writeAsync_uint16(FileH5, ...
                'Channel01/Zposition001', SequenceName, Sequence);
        case 'h5DataGroups'
            % Create a new group for the current dataset, so each dataset
            % will have its own group in the .h5 file.
            DataName = sprintf('Data%04d', ii);
            SequenceName = sprintf('Channel01/Zposition001/%s', ...
                DataName);
            MIC_H5.createGroup(FileH5, SequenceName);
            
            % Save the exportState() exportables.
            obj.StatusString = sprintf(['Cell %g, Sequence %i - ', ...
                'Exporting object Data and Children...'], ...
                RefStruct.CellIdx, ii);
            fprintf('Saving exportables from exportState().........\n')
            obj.save2hdf5(FileH5, SequenceName);
            fprintf('Exportables from exportState() have been saved\n')
            obj.StatusString = '';
            fprintf('Saving exportables from exportState() complete\n')
            
            % Begin writing the data.
            MIC_H5.writeAsync_uint16(...
                FileH5, SequenceName, DataName, Sequence);
        otherwise
            error('StartSequence:: unknown SaveFileType')
    end
    obj.Shutter.close(); % block 647nm from reaching sample
    obj.Laser405.off(); % ensure the 405nm is turned off
end
obj.StatusString = '';
fprintf('Data collection complete\n')

% Ensure that the lasers are not reaching the sample.
obj.Shutter.close(); % close shutter instead of turning off the laser
obj.FlipMount.FilterIn();
obj.Laser405.setPower(0);
obj.Laser405.off();

% If it was used, end the active stabilization process.
if obj.UseActiveReg
    obj.ActiveReg.stop();
end

% Save the acquisition data.
switch obj.SaveFileType
    case 'h5'
        obj.StatusString = ...
            'Exporting object Data and Children with exportState()...';
        fprintf('Saving exportables from exportState()................ \n')
        SequenceName = 'Channel01/Zposition001';
        MIC_H5.createGroup(FileH5, SequenceName);
        obj.save2hdf5(FileH5, SequenceName);
        fprintf('Saving exportables from exportState() complete \n')
        obj.StatusString = '';
    case 'h5DataGroups'
        % In this case, we don't need to do anything since the export state
        % was already performed previously.
    otherwise
        error('StartSequence:: unknown SaveFileType')
end


end