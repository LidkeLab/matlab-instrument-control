function Success=findCoverSlipOffset_Manual(obj,RefStruct)
    %Allow user to focus and indentify cell
    if nargin<2
        ref=uigetfile('E:\');
        myDir=obj.TopDir;
        myCoverslip=obj.CoverslipName;
        load(fullfile(myDir,myCoverslip,ref))
    end

    F_Ref=figure;
    imshow(RefStruct.Image,[],'Border','tight');
    F_Ref.Name='Ref Image';
    obj.StagePiezoX.center();
    obj.StagePiezoY.center();
    obj.StagePiezoZ.center();
%             obj.gui_Stage();

    P0=RefStruct.StepperPos; %[P0x, P0y, P0z] where P0y=obj.StageStepper.getPosition(1)
    obj.StageStepper.moveToPosition(1,P0(2)) %y
    obj.StageStepper.moveToPosition(2,P0(1)) %x
    obj.StageStepper.moveToPosition(3,P0(3)) %z

    obj.CameraSCMOS.ExpTime_Focus=obj.ExposureTimeLampFocus;
    obj.CameraSCMOS.ROI=obj.SCMOS_ROI_Full;
    obj.CameraSCMOS.AcquisitionType = 'focus';
    obj.CameraSCMOS.setup_acquisition();
    obj.Lamp660.setPower(obj.Lamp660Power);
    obj.CameraSCMOS.start_focus();
    obj.Lamp660.setPower(0);

    Data=obj.captureLamp('Full');
    Fig=figure;
    Fig.MenuBar='none';
    imshow(Data,[],'Border','tight');
    Fig.Name='Click To Center and Proceed';
    Fig.NumberTitle='off';
    try
        [X,Y]=ginput(1);
        close(Fig);
    catch
        Success=0;
        return
    end

    ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
%             DiffFromCenter_Pixels=ImSize/2-[X,Y];
%             DiffFromCenter_Microns=DiffFromCenter_Pixels*obj.SCMOS_PixelSize;
    FocusPosY=obj.StageStepper.getPosition(1); %y
    FocusPosX=obj.StageStepper.getPosition(2); %x
    FocusPosZ=obj.StageStepper.getPosition(3); %z
    FocusPos=[FocusPosX,FocusPosY,FocusPosZ];
    deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm
    deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
    if X>1024 & Y<1024
        NewPos_X=FocusPosX-deltaX; %mm
        NewPos_Y=FocusPosY-deltaY; %mm
    elseif X>1024 & Y>1024
        NewPos_X=FocusPosX-deltaX; %mm
        NewPos_Y=FocusPosY+deltaY; %mm
    elseif X<1024 & Y<1024
        NewPos_X=FocusPosX+deltaX; %mm
        NewPos_Y=FocusPosY-deltaY; %mm
    else
        NewPos_X=FocusPosX+deltaX; %mm
        NewPos_Y=FocusPosY+deltaY; %mm
    end
    NewPos=[NewPos_X,NewPos_Y,FocusPosZ]; %new
     obj.CoverSlipOffset=NewPos-P0;
    %Move to position and show cell
                obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
                obj.StageStepper.moveToPosition(2,NewPos(1)); %new x
                obj.StageStepper.moveToPosition(3,FocusPosZ); %new z

    pause(1);
    Data=captureLamp(obj,'ROI');

    FF=figure;
    imshow(Data,[],'Border','tight');

    proceedstr=questdlg('Does the Cell Match the Reference Image','Warning',...
        'Yes','No','No');
    if strcmp('Yes',proceedstr)
        Success=1;
    else
        Success=0;
    end
    close(FF)
    try
        close(F_Ref)
    catch
    end
end