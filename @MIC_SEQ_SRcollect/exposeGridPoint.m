function exposeGridPoint(obj)
    %Move to a grid point, take full cam lamp image, give figure to
    %click on cell.

    obj.StagePiezoX.center();
    obj.StagePiezoY.center();
    obj.StagePiezoZ.center();
    ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
    OldPos_X=obj.StageStepper.getPosition(2); %new
    OldPos_Y=obj.StageStepper.getPosition(1); %new
    OldPos_Z=obj.StageStepper.getPosition(3); %new
    %Move to Grid Point
    Grid_mm=obj.CurrentGridIdx*ImSize*obj.SCMOS_PixelSize/1000+obj.GridCorner;
    obj.StageStepper.moveToPosition(1,Grid_mm(2)); %new y %units are mm
    obj.StageStepper.moveToPosition(2,Grid_mm(1)); %new x
    obj.StageStepper.moveToPosition(3,OldPos_Z); %new z

    pause(4)

    Data=obj.captureLamp('Full');
    Fig=figure;
    Fig.MenuBar='none';
    imshow(Data,[],'Border','tight');
    Fig.Name='Click To Center and Proceed';
    Fig.NumberTitle='off';
    try
        [X,Y]=ginput(1)% [X,Y] goes from 1 to 2048 for each of the 
        % ROIs of each of 100 buttons on the GUI. 
        % NOTE ON ROTATION: this [X,Y] are coordinates calculated on a rotated
        % and mirror imaged of the live SCMOS 
        close(Fig);
    catch
        return
    end

    OldPos_X=obj.StageStepper.getPosition(2); %new x
    OldPos_Y=obj.StageStepper.getPosition(1); %new y
    OldPos_Z=obj.StageStepper.getPosition(3); %new z
    OldPos=[OldPos_X,OldPos_Y,OldPos_Z]; %new
    %find new position with respect to Motor's (0,0):
    deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm 
    deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
    if X>1024 & Y<1024
        NewPos_X=OldPos_X-deltaX; %mm
        NewPos_Y=OldPos_Y-deltaY; %mm
    elseif X>1024 & Y>1024
        NewPos_X=OldPos_X-deltaX; %mm
        NewPos_Y=OldPos_Y+deltaY; %mm
    elseif X<1024 & Y<1024
        NewPos_X=OldPos_X+deltaX; %mm
        NewPos_Y=OldPos_Y-deltaY; %mm
    else
        NewPos_X=OldPos_X+deltaX; %mm
        NewPos_Y=OldPos_Y+deltaY; %mm
    end

    NewPos=[NewPos_X,NewPos_Y]; %new
    obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
    obj.StageStepper.moveToPosition(2,NewPos(1)); %new x
    obj.StageStepper.moveToPosition(3,OldPos(3)); %new z
    pause(1)
    %Move to next step
    obj.exposeCellROI();
end