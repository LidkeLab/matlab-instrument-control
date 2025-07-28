classdef TissueImager_Collect < mic.abstract

properties

    % Hardware objects
    Tiss;           % MIC_TIRF obj

    % Other things
    SaveDir='C:\';  % Save Directory
    BaseFileName = 'Sample1'; % Base file name
    SaveFileType = 'mat';     % Either 'h5' or 'mat'

end

properties (SetAccess = protected)
    InstrumentName = 'TissueImager_Collect'; % Descriptive name of "instrument"
end

properties (Hidden)
    StartGUI=false;       %Defines GUI start mode.  Set to false to prevent gui opening before hardware is initialized.
end

methods
    function obj=TissueImager_Collect()
        %  constructor
        %   Constructs object and initializes all hardware

        % Enable autonaming feature of MIC_Abstract
        obj = obj@mic.abstract(~nargout);

        % Initialize hardware objects
        %         try
        obj.Tiss=mic.TissueImager();

        %Set save directory
        user_name = java.lang.System.getProperty('user.name');
        timenow=clock;
        obj.SaveDir=sprintf('Y:\\%s%s%02.2g-%02.2g-%02.2g\\',user_name,filesep,timenow(1)-2000,timenow(2),timenow(3));

        % Start gui (not using StartGUI property because GUI shouldn't
        % be started before hardware initialization)
        obj.gui();

    end

    function delete(obj)
        %delete all objects
        delete(obj.GuiFigure);
        close all force;
        clear;
    end


    function saveData(obj, Stack)
        % Set fixed save directory
        saveDir = 'C:\Users\unmla\Documents\TissueImager\Data';

        % Create folder if it doesn't exist
        if ~isfolder(saveDir)
            mkdir(saveDir);
        end

        % Construct the full filename
        filename = fullfile(obj.SaveDir, [obj.BaseFileName '.' obj.SaveFileType]);

        % Save based on the selected file type
        switch lower(obj.SaveFileType)
            case 'mat'
                save(filename, 'Stack', '-v7.3');
            case 'h5'
                h5create(filename, '/Stack', size(Stack), 'Datatype', class(Stack));
                h5write(filename, '/Stack', Stack);
            otherwise
                warning('Unsupported file type: %s', obj.SaveFileType);
                return;
        end

        fprintf('Data saved to: %s\n', filename);
    end

    function focusThorcam(obj, isOnDuringFocus, focusPower)
        %setup LEDs and turn them on when focus button is clicked
        if ~isOnDuringFocus
            disp('LED not enabled for focus (checkbox off)');
            return;
        end

        try
            obj.LED.setPower(focusPower);  % set power
            obj.LED.on();                  % turn on
            disp(['LED turned on at ' num2str(focusPower) '%']);
        catch ME
            warning('Could not turn on LED: %s', ME.message);
        end
    end



    function [Attributes,Data,Children] = exportState(obj)
        % exportState Exports current state of all hardware objects
        % and SRcollect settings

        % Children
        [Children.Tiss.Attributes,Children.Tiss.Data,Children.Tiss.Children]=...
            obj.Tiss.exportState();
    end

end

methods (Static)
    function Success = funcTest()
        try
            obj = mic.TissueImager_Collect();
            disp('TissueImager_Collect initialized successfully.');
            delete(obj);
            Success = true;
        catch ME
            warning('funcTest failed: %s', ME.message);
            Success = false;
        end
    end
end


end