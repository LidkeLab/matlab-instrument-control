function findCoverSlipOffset(obj,RefStruct)
    %Registration of first cell to find offset after remounting

    obj.StagePiezoX.center();
    obj.StagePiezoY.center();
    obj.StagePiezoZ.center();
    ROI=RefStruct.Image;
    ROI=ROI(2:end-1,2:end-1);
    ImSize=obj.SCMOS_ROI_Full(2)-obj.SCMOS_ROI_Full(1)+1;
    RE=single(extend(ROI,ImSize,'symmetric',mean(ROI(:))));
    RE=RE-mean(RE(:));
    RE=RE/std(RE(:));

    P0=RefStruct.StepperPos;
    obj.StageStepper.moveToPosition(1,P0(2)) %new %y
    obj.StageStepper.moveToPosition(2,P0(1)) %new %x
    obj.StageStepper.moveToPosition(3,P0(3)) %new %z

    Z=(-obj.OffsetSearchZ:obj.OffsetDZ:obj.OffsetSearchZ)/1000;
    clear CC FullStack
    NP=P0;

    LampRadius=1000;
    [X,Y]=meshgrid(1:ImSize,1:ImSize);
    R=sqrt((X-ImSize/2).^2+(Y-ImSize/2).^2);
    Mask=R>LampRadius;
    for zz=1:length(Z)
        NP(3)=P0(3)+Z(zz);
        obj.StageStepper.moveToPosition(1,NP(2)) %new %y
        obj.StageStepper.moveToPosition(2,NP(1)) %new %x
        obj.StageStepper.moveToPosition(3,NP(3)) %new %z
        pause(1);
        FS=single(obj.captureLamp('Full'));
        FS(Mask)=median(FS(:));

        FS=FS-mean(FS(:));
        FS=FS/std(FS(:));
        FullStack(:,:,zz)=FS;
        CC(:,:,zz)=ifftshift(ifft2(fft2(RE).*conj(fft2(FS))))/numel(RE);

    end
    obj.StageStepper.moveToPosition(1,P0(2)) %new %y
    obj.StageStepper.moveToPosition(2,P0(1)) %new %x
    obj.StageStepper.moveToPosition(3,P0(3)) %new %z

    [v,Zid]=max(max(max(CC,[],1),[],2),[],3);
    [R,C]=find(v==CC(:,:,Zid));

    obj.CoverSlipOffset=[-(1024-R)*obj.SCMOS_PixelSize/1000 (1024-C)*obj.SCMOS_PixelSize/1000 Z(Zid)];

end