function gui(obj)
%gui Graphical User Interface to mic,Reg3DTrans
%   Description

%   Marjolein Meddens, Lidke Lab 2017
%   Hanieh Mazloom-Farsibaf, Lidke Lab 2018


%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigure)
    figure(obj.GuiFigure);
    return
end

xsz=500;
ysz=210;
xst=100;
yst=100;
bszx=100;
bszy=30;

%Open figure
guiFig = figure('Resize','off','Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'Reg3DTrans.gui','HandleVisibility','off');

% Create a property based on GuiFigure
obj.GuiFigure = guiFig;
obj.GuiFigure.Name = [obj.InstrumentName];
obj.GuiFigure.NumberTitle = 'off';

%Prevent closing after a 'close' or 'close all'
obj.GuiFigure.HandleVisibility='off';

%%
handles.button_findimage = uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', ...
    'Find Ref. Image','Position', [10 ysz-bszy-10 bszx bszy],'Callback', ...
    @gui_getimagefile);

handles.edit_imagefile = uicontrol('Parent',guiFig, 'Style', 'edit', 'String', ...
    'Image File','Position', [20 + bszx  ysz-bszy-10 xsz-bszx-20 bszy],...
    'Tag','fileEdit');

handles.button_takezstack = uicontrol('Parent',guiFig, 'Style', 'pushbutton', 'String', ...
    'Show Ref. Image','Position',[10 ysz-2*(bszy+10) bszx bszy],'Callback', ...
    @gui_showrefimage);

handles.button_align = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Align', 'Position', [10 ysz-3*(bszy+10) bszx bszy], 'Callback', @gui_align);

handles.button_getcurrentimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Take Current Image', 'Position', [20+2*bszx ysz-4*(bszy+10) bszx bszy], 'Callback', @gui_getcurrentimage);

handles.button_abort = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Abort alignment', 'Position', [20+2*bszx ysz-5*(bszy+10) bszx bszy], 'Callback', @gui_abort);

handles.button_showoverlay = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Show Overlay', 'Position', [10 ysz-4*(bszy+10) bszx bszy], 'Callback', @gui_showoverlay);

handles.button_calibrate = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Calibrate', 'Position', [10 ysz-5*(bszy+10) bszx bszy], 'Callback', @gui_calibrate);

handles.button_takerefimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Take Ref. Image', 'Position', [xsz-10-bszx ysz-3*(bszy+10) bszx bszy], 'Callback', @gui_takerefimage);

handles.button_saverefimage = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Save Ref. Image', 'Position', [xsz-10-bszx ysz-4*(bszy+10) bszx bszy], 'Callback', @gui_saverefimage);

handles.button_save = uicontrol('Parent',guiFig,'Style', 'pushbutton', 'String', ...
    'Save Overlay', 'Position', [xsz-10-bszx ysz-5*(bszy+10) bszx bszy], 'Callback', @gui_save);


%%
    function gui_getimagefile(~,~)
        [a,b]=uigetfile();
        obj.RefImageFile = fullfile(b,a);
        if ishandle(obj.GuiFigure)
            set(handles.edit_imagefile,'String',obj.RefImageFile);
        end
        tmp=load(obj.RefImageFile,'Image_Reference');
        obj.Image_Reference=tmp.Image_Reference;
    end

    function gui_showrefimage(~,~)
        im=permute(obj.Image_Reference,[2 1]);
        dipshow(im)
    end

    function gui_align(~,~)
        warning('Set the camera and turn on the lamp before aligning two images')
        obj.align2imageFit();
        warning('Set back the camera and turn off the lamp after aligning two images')
 end

    function gui_showoverlay(~,~)
        obj.showoverlay();
    end

    function gui_getcurrentimage(~,~)
        warning('Set the camera and turn on the lamp before taking any images')
        obj.getcurrentimage();
        warning('Set back the camera and turn off the lamp after taking any images')
    end

    function gui_abort(~,~)
        obj.AbortNow = 1;
    end

    function gui_calibrate(~,~)
        warning('Set the camera and turn on the lamp before calibration')
        obj.calibrate();
        warning('Set back the camera and turn off the lamp after calibration')
   end

    function gui_takerefimage(~,~)
        warning('Set the camera and turn on the lamp before taking refrence image')
        obj.takerefimage();
        warning('Set back the camera and turn off the lamp after taking refrence image')
    end

    function gui_saverefimage(~,~)
        obj.saverefimage();
    end

    function gui_save(~,~)
        obj.savealignment();
    end

end
