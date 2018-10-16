 function autoCollect(obj,StartCell,RefDir)
        %This takes all SR data using saved reference data

        if nargin<3 %Ask for directory with Reference files
            RefDir=uigetdir(obj.TopDir);
        end

        if nargin<2 %Ask for directory with Reference files
            StartCell=1;
        end

        %Find number of cells, filenames, etc
        FileList=dir(fullfile(RefDir,'Reference_Cell*'));
        NumCells=length(FileList);               
        obj.Shutter.close; % close shutter before the Laser turns on
        obj.Laser647.setPower(obj.LaserPowerSequence);
        obj.Laser647.on();

        %Loop over cells

        for nn=StartCell:NumCells 
            % If AbortNow flag was set, do not continue.
            if obj.AbortNow
                return
            end
            
            %Create or load RefImageStruct
            FileName=fullfile(RefDir,FileList(nn).name);
            F=matfile(FileName);
            RefStruct=F.RefStruct;
            if (obj.UseManualFindCell)&&(nn==StartCell)
                S=obj.findCoverSlipOffset_Manual(RefStruct);
                obj.CoverSlipOffset;
                if ~S;return;end
            end

            obj.startSequence(RefStruct,obj.LabelIdx);

            if nn==StartCell %update coverslip offset
                %obj.CoverSlipOffset=obj.StageStepper.Position-RefStruct.StepperPos; %old
                SPx=Kinesis_SBC_GetPosition('70850323',2); %new
                SPy=Kinesis_SBC_GetPosition('70850323',1); %new
                SPz=Kinesis_SBC_GetPosition('70850323',3); %new
                SP=[SPx,SPy,SPz];
                obj.CoverSlipOffset=SP-RefStruct.StepperPos; %new
            end

        end

        obj.FlipMount.FilterIn; %moves in the ND filter toward the beam
        obj.Shutter.close;
        obj.Laser647.off();
        
        % Publish the results if requested.
        if obj.PublishResults
            obj.StatusString = 'Publishing results...';
            PublishSeqSRResults(...
                fullfile(obj.TopDir, obj.CoverslipName), ...
                obj.SCMOSCalFilePath);
            obj.StatusString = '';
        end
 end 