classdef TissueImager_Collect < MIC_Abstract

properties

    % Hardware objects
    Tiss;           % MIC_TIRF obj

    % Other things
    SaveDir='C:\';  % Save Directory

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
        obj = obj@MIC_Abstract(~nargout);

        % Initialize hardware objects
        %         try
        obj.Tiss=TissueImager();

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

    function [Attributes,Data,Children] = exportState(obj)
        % exportState Exports current state of all hardware objects
        % and SRcollect settings

        % Children
        [Children.Tiss.Attributes,Children.Tiss.Data,Children.Tiss.Children]=...
            obj.Tiss.exportState();
    end

end
end