function saveReferenceImage(obj)
    %Take reference image and save

    
    % Update the status of the instrument to indicate we are collecting
    % reference data.
    obj.StatusString = 'Collecting reference data for selected cell...';
    
    % Collect a z-stack for use in brightfield registration (if requested).
    if obj.UsePeriodicReg
        obj.Lamp660.setPower(obj.Lamp660Power);
        pause(obj.LampWait);
        obj.AlignReg.ZStack_Step = obj.Reg3DStepSize;
        obj.AlignReg.ZStack_MaxDev = obj.Reg3DMaxDev;
        obj.AlignReg.takeRefStack();
        RefStruct.ReferenceStack = obj.AlignReg.ReferenceStack;
        obj.Lamp660.setPower(0);
        
        % Set the ROI reference image to be the image at the center of the
        % z-stack (the focal plane of interest).
        RefInd = ...
            (obj.AlignReg.ZStack_MaxDev / obj.AlignReg.ZStack_Step) + 1;
        RefStruct.Image =obj.AlignReg.ReferenceStack(:, :, RefInd);
        
        %Collect Full Image
        obj.Lamp660.setPower(obj.Lamp660Power);
        pause(obj.LampWait);
        obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
        obj.CameraSCMOS.AcquisitionType = 'capture';
        obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
        obj.CameraSCMOS.setup_acquisition();
        Data=obj.CameraSCMOS.start_capture();
        obj.Lamp660.setPower(0);
        RefStruct.Image_Full=Data;
    end
    
    % Center Piezo and add to stepper
    PPx=obj.StagePiezo.StagePiezoX.getPosition();
    PPy=obj.StagePiezo.StagePiezoY.getPosition();
    PPz=obj.StagePiezo.StagePiezoZ.getPosition();
    PP=[PPx, PPy, PPz];
    obj.StagePiezo.center();
    PPCx=obj.StagePiezo.StagePiezoX.getPosition();
    PPCy=obj.StagePiezo.StagePiezoY.getPosition();
    PPCz=obj.StagePiezo.StagePiezoZ.getPosition();
    PPC=[PPCx, PPCy, PPCz];
    OS=PP-PPC; %difference between piezo at center and at current
    % position of each cell
    SPx=Kinesis_SBC_GetPosition('70850323',2); %new
    SPy=Kinesis_SBC_GetPosition('70850323',1); %new
    SPz=Kinesis_SBC_GetPosition('70850323',3); %new
    SP=[SPx,SPy,SPz];
    SP(3)=SP(3)+OS(3)/1000;
    RefStruct.StepperPos=SP;
    %This is now just the center position
    RefStruct.PiezoPos=PPC;
    RefStruct.GridIdx=obj.CurrentGridIdx;
    RefStruct.CellIdx=obj.CurrentCellIdx;
    [~,~]=mkdir(obj.TopDir);
    [~,~]=mkdir(fullfile(obj.TopDir,obj.CoverslipName));
    FN = sprintf('Reference_Cell_%2.2d.mat',obj.CurrentCellIdx);
    FileName=fullfile(obj.TopDir,obj.CoverslipName,FN);
    F=matfile(FileName);
    F.Properties.Writable = true; % so we don't get the error "F.Properties.Writable is False."
    F.RefStruct=RefStruct;
    %Update cell count
    obj.CurrentCellIdx=obj.CurrentCellIdx+1;
    
    % Clear the status of the instrument to indicate the reference has
    % been saved.
    obj.StatusString = '';
end