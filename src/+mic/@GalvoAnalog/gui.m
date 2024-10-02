function guiFig = gui(obj)
%gui Graphical User Interface to mic,GalvoAnalog

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%Open figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[100 300 500 310]);


end
