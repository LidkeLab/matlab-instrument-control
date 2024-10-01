function guiFig = gui(obj)
%gui Graphical User Interface to MIC_OptotuneLens

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure();
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigure.CloseRequestFcn = @closeFigure;

%Initialize GUI properties
properties2gui();

    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigure);
    end

%%  All figure have these functions but will be different contents

    function gui2properties()
        % Sets the object properties based on the GUI widgets
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties
    end

end

