 function startSequence(obj,RefStruct,LabelID)
    %Collects and saves an SR data Set

    %Setup file saving
    if ~obj.IsBleach
        [~,~]=mkdir(obj.TopDir);
        [~,~]=mkdir(fullfile(obj.TopDir,obj.CoverslipName));
        DN=fullfile(obj.TopDir,obj.CoverslipName,sprintf('Cell_%2.2d',RefStruct.CellIdx),sprintf('Label_%2.2d',LabelID));
        [~,~]=mkdir(DN);
        TimeNow=clock;
        DateString=[num2str(TimeNow(1)) '-' num2str(TimeNow(2))  '-' num2str(TimeNow(3)) '-' num2str(TimeNow(4)) '-' num2str(TimeNow(5)) '-' num2str(round(TimeNow(6)))];
        FN=sprintf('Data_%s.h5',DateString);
        FileName=fullfile(DN,FN);
    end

    % FF test for save h.file
    switch obj.SaveFileType
        case 'mat'
        case 'h5'
            FileH5=FileName; %FF
            MIC_H5.createFile(FileH5);
            MIC_H5.createGroup(FileH5,'Channel01');
            MIC_H5.createGroup(FileH5,'Channel01/Zposition001');
        otherwise
            error('StartSequence:: unknown file save type')
    end

    %Move to Cell
    obj.StageStepper.moveToPosition(1,RefStruct.StepperPos(2)+obj.CoverSlipOffset(2)); %new %y
    obj.StageStepper.moveToPosition(2,RefStruct.StepperPos(1)+obj.CoverSlipOffset(1)); %new %x
    obj.StageStepper.moveToPosition(3,RefStruct.StepperPos(3)+obj.CoverSlipOffset(3)); %new %z
    obj.StagePiezoX.center(); %new 
    obj.StagePiezoY.center(); %new
    obj.StagePiezoZ.center(); %new 
    %Align
    obj.Lamp660.setPower(obj.Lamp660Power+2);
    pause(obj.LampWait);
    obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture; %need to update when changing edit box
    obj.CameraSCMOS.AcquisitionType = 'capture';
    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
    obj.CameraSCMOS.setup_acquisition();
    obj.AlignReg.Image_Reference=RefStruct.Image;
    try %So that if alignment fails, we don't stop auto collect for other cells
        obj.AlignReg.align2imageFit(RefStruct); %FF
    catch 
        warning('Problem with AlignReg.align2imageFit()')
        return
    end

    obj.Lamp660.setPower(0);

    % Setup Active Stabilization (if desired).
    if obj.UseActiveReg
        obj.ActiveReg = MIC_ActiveReg3D_Seq(...
            obj.CameraIR,obj.StagePiezoX,obj.StagePiezoY,obj.StagePiezoZ); 
        obj.Lamp850.on; 
        obj.Lamp850.setPower(obj.Lamp850Power);
        obj.IRCamera_ExposureTime=obj.CameraIR.ExpTime_Capture;
        obj.ActiveReg.takeRefImageStack(); %takes 21 reference images
        obj.ActiveReg.Period=obj.StabPeriod;
        obj.ActiveReg.start();
    end

    %Setup sCMOS for Sequence
    obj.CameraSCMOS.ExpTime_Sequence=obj.ExposureTimeSequence;
    obj.CameraSCMOS.SequenceLength=obj.NumberOfFrames;
    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
    obj.CameraSCMOS.AcquisitionType = 'sequence';
    obj.CameraSCMOS.setup_acquisition();

    %Start Laser
    obj.FlipMount.FilterOut; % moves away the ND filter from the beam
    if obj.Use405
        obj.Laser405.setPower(obj.LaserPower405Activate);
    end
    if obj.IsBleach
        obj.Laser405.setPower(obj.LaserPower405Bleach);
    end

    %Collect Data
    if obj.IsBleach
        for nn=1:obj.NumberOfPhotoBleachingIterations
            obj.Shutter.open; % opens shutter before the Laser turns on
            Data=obj.CameraSCMOS.start_sequence();
            S=sprintf('F.Data%2.2d=Data;',nn);
            eval(S);
            obj.Shutter.close; % closes shutter before the Laser turns on
        end

    else
        fprintf('Collecting data...................................... \n')
        for nn=1:obj.NumberOfSequences
            % Use periodic registration between each sequence (if desired).
            if obj.UsePeriodicReg && nn~=1
                % No need to re-align on the first iteration, we just did
                % that above!
                obj.Lamp660.setPower(obj.Lamp660Power+2);
                pause(obj.LampWait);
                obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture; 
                obj.CameraSCMOS.AcquisitionType = 'capture';
                obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
                obj.CameraSCMOS.setup_acquisition();
                obj.AlignReg.Image_Reference=RefStruct.Image;
                obj.AlignReg.MaxIter = 10; % reduce from 20 for speed
                try
                    obj.AlignReg.align2imageFit(RefStruct); %FF
                catch 
                    % If the alignment fails, don't stop auto collect for 
                    % other cells.
                    warning('Problem with AlignReg.align2imageFit()')
                    return
                end
                obj.Lamp660.setPower(0);
            end
            
            obj.Shutter.open; % opens shutter before the Laser turns on

            %Collect 
            sequence=obj.CameraSCMOS.start_sequence();
            if ~obj.IsBleach %Append Data
                obj.Shutter.close;
                switch obj.SaveFileType
                    case 'mat'
                        fn=fullfile(obj.SaveDir,[obj.BaseFileName '#' num2str(nn,'%04d') s]);
                        Params=exportState(obj); %#ok<NASGU>
                        save(fn,'sequence','Params');
                    case 'h5' %This will become default
                        S=sprintf('Data%04d',nn);
                        MIC_H5.writeAsync_uint16(FileH5,'Channel01/Zposition001',S,sequence);
                    otherwise
                        error('StartSequence:: unknown SaveFileType')
                end
                %obj.Shutter.open;
            end
            obj.Shutter.close; % closes shutter before the Laser turns on
            
        end
        fprintf('Data collection complete \n')
        %End Laser
        obj.Shutter.close; % closes the shutter instead of turning off the Laser
        obj.FlipMount.FilterIn; %new
        obj.Laser405.setPower(0);

        %End Active Stabilization:
        if obj.UseActiveReg
            obj.ActiveReg.stop();
        end

        %Save Everything
        if ~obj.IsBleach %Append Data
            fprintf('Saving exportables from exportState()............ \n')
            switch obj.SaveFileType
                case 'mat'
                    %Nothing to do
                case 'h5'
                    S='Channel01/Zposition001';
                    MIC_H5.createGroup(FileH5,S);
                    obj.save2hdf5(FileH5,S);
                otherwise
                    error('StartSequence:: unknown SaveFileType')
            end
            fprintf('Saving exportables from exportState() complete \n')
        end

        % Delete obj.ActiveReg (if active stabilization was used).
        if obj.UseActiveReg
            delete(obj.ActiveReg);
        end
    end
 end