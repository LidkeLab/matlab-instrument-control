 function exposeCellROI(obj)
    %Take ROI lamp image, and allow click on cell, start lamp focus    
    Data=obj.captureLamp('ROI');
    Fig=figure;
    Fig.MenuBar='none';
    imshow(Data,[],'Border','tight');
    Fig.Name='Click To Center and Proceed';
    Fig.NumberTitle='off';
    try
        [X,Y]=ginput(1);%coordinates with respect to top left corner of the 256by256 image
        close(Fig);
    catch
        return
    end

    ImSize=obj.SCMOS_ROI_Collect(2)-obj.SCMOS_ROI_Collect(1)+1;%256by256ROI
    OldPos_X=obj.StageStepper.getPosition(2); %new x
    OldPos_Y=obj.StageStepper.getPosition(1); %new y
    OldPos_Z=obj.StageStepper.getPosition(3); %new z
    OldPos=[OldPos_X,OldPos_Y,OldPos_Z]; %new
    deltaX=(abs(ImSize/2-X)*obj.SCMOS_PixelSize)*1/1000; %mm 
    deltaY=(abs(ImSize/2-Y)*obj.SCMOS_PixelSize)*1/1000; %mm
    if X>ImSize/2 & Y<ImSize/2
        NewPos_X=OldPos_X-deltaX; %mm
        NewPos_Y=OldPos_Y+deltaY; %mm
    elseif X>ImSize/2 & Y>ImSize/2
        NewPos_X=OldPos_X-deltaX; %mm
        NewPos_Y=OldPos_Y-deltaY; %mm
    elseif X<ImSize/2 & Y<ImSize/2
        NewPos_X=OldPos_X+deltaX; %mm
        NewPos_Y=OldPos_Y+deltaY; %mm
    else
        NewPos_X=OldPos_X+deltaX; %mm
        NewPos_Y=OldPos_Y-deltaY; %mm
    end
    NewPos=[NewPos_X,NewPos_Y]; %new

    obj.StageStepper.moveToPosition(1,NewPos(2)); %new y %units are mm
    obj.StageStepper.moveToPosition(2,NewPos(1)); %new x FF
    obj.StageStepper.moveToPosition(3,OldPos(3)); %new z FF 
    %Move to next step
    obj.startROILampFocus();
 end