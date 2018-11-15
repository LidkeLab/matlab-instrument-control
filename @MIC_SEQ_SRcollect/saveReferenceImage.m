function saveReferenceImage(obj)
    %Take reference image and save

    % Collect a z-stack if needed (probably not a good way to do this, 
    % but it's important to collect the z-stack in the same manner as it 
    % will be collected in the AlignReg class).
    if obj.UseStackCorrelation
        obj.Lamp660.setPower(obj.Lamp660Power);
        pause(obj.LampWait);
        obj.AlignReg.collect_zstack(); 
        RefStruct.ReferenceStack = obj.AlignReg.ZStack;
        obj.Lamp660.setPower(0);
    end
    
    %Collect ROI Image
    obj.Lamp660.setPower(obj.Lamp660Power);
    pause(obj.LampWait);
    obj.CameraSCMOS.ExpTime_Capture=obj.ExposureTimeCapture;
    obj.CameraSCMOS.AcquisitionType = 'capture';
    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Collect;
    obj.CameraSCMOS.setup_acquisition();
    Data=obj.CameraSCMOS.start_capture();
    obj.Lamp660.setPower(0);
    RefStruct.Image=Data;
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
    %Center Piezo and add to stepper
    PPx=obj.StagePiezoX.getPosition; %new
    PPy=obj.StagePiezoY.getPosition; %new
    PPz=obj.StagePiezoZ.getPosition; %new
    PP=[PPx, PPy, PPz];
    obj.StagePiezoX.center(); %new
    obj.StagePiezoY.center(); %new
    obj.StagePiezoZ.center(); %new
    PPCx=obj.StagePiezoX.getPosition; %new
    PPCy=obj.StagePiezoY.getPosition; %new
    PPCz=obj.StagePiezoZ.getPosition; %new
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
end