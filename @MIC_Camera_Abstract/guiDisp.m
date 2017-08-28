function guiDisp(obj)
%Display sub gui for Camera class
%   Dshould be called from the display button in the gui

% main camera param gui figure
dispFig = figure('Units','pixels','Position',[100 100 700 600],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag','ROISelector.gui');

defaultBackground = get(0,'defaultUicontrolBackgroundColor');


set(dispFig,'Color',defaultBackground)
handles.output1 = dispFig;
guidata(dispFig,handles)

% create panels
panelPosition = [.05 .12 .9 .85];
handles.dispPan = uipanel('Parent',dispFig,'Units','normalized','fontweight','bold',...
    'Position',panelPosition,'Title','ROI Selection Tool','Visible','on');

% put in a title
set(dispFig,'Name',sprintf('ROI Selection Tool'))

% buttons to OK, reset, or cancel changes
handles.commit_butt = uicontrol('Parent',dispFig,'Style','pushbutton','String','Commit','Value',1,'Units','normalized','Position',[.22 .05 .15 .05],'Callback',@commit);
handles.reset_butt = uicontrol('Parent',dispFig,'Style','pushbutton','String','Reset','Value',1,'Units','normalized','Position',[.39 .05 .15 .05],'Callback',@reset);
handles.cancel_butt = uicontrol('Parent',dispFig,'Style','pushbutton','String','Close','Value',1,'Units','normalized','Position',[.56 .05 .15 .05],'Callback',@cancel);

% Buttons to control ROI sizing
handles.dispMenu = uicontrol('Parent',handles.dispPan,'Style','popupmenu','String',{'Full CCD','Left Half','Right Half','Top Half','Bottom Half',...
    'Center Half Horizontal','Center Half Vertical','Quarter CCD Centered','Upper Left Quadrant','Upper Right Quadrant','Lower Left Quadrant',...
    'Lower Right Quadrant','Center Left','Center Right'},'Units','Normalized','Position',[.77 .87 .2 .075],'BackgroundColor',[1 1 1],'Callback',@ChangeRoi);

handles.ROITex = uicontrol('Parent',handles.dispPan,'Style','text','String','ROI (px) [xstart xend ystart yend]:','fontsize',10,'Units','Normalized','Position',[0.035 .1 .5 .075]);
handles.ROIBox = uicontrol('Parent',handles.dispPan,'Style','edit','String',['[1 ' num2str(obj.XPixels) ' 1 ' num2str(obj.YPixels) ']'],'Units','Normalized','Position',...
    [0.15 .05 .25 .075],'BackgroundColor',[1 1 1],'CallBack',@plotROI);


% create ROI figure
% display panel components
handles.imgAx = axes('Parent',handles.dispPan,'Units','Normalized','Position',[.055 .25 .7 .7],'Color',[1 1 1]);
setappdata(handles.imgAx,'imgs',[])
set(handles.imgAx,'Ydir','reverse');
set(handles.imgAx,'FontUnits','Normalized','FontSize',0.05);

% First Build the Original ROI
handles.OG_vertices = [obj.ROI(1) obj.ROI(3); obj.ROI(2) obj.ROI(3); obj.ROI(2) obj.ROI(4); obj.ROI(1) obj.ROI(4)];
handles.OG_patch = patch(handles.OG_vertices(:,1), handles.OG_vertices(:,2),'b','tag','OG_box');
set(handles.OG_patch,'FaceColor',[1 0.3 0.3],'FaceAlpha',1);
set(handles.OG_patch,'EdgeColor',[0 0 0],'LineWidth',3);
axis([1 obj.XPixels 1 obj.YPixels]);

% Overlay the potential ROI
ROIvec = str2num(get(handles.ROIBox,'String'));
handles.ROI_vertices = [ROIvec(1) ROIvec(3); ROIvec(2) ROIvec(3); ROIvec(2) ROIvec(4); ROIvec(1) ROIvec(4)];
handles.ROI_patch = patch(handles.ROI_vertices(:,1), handles.ROI_vertices(:,2),'b','tag','ROI_box');
set(handles.ROI_patch,'FaceColor',[0.7 0.7 1],'FaceAlpha',1);
set(handles.ROI_patch,'EdgeColor',[1 1 1],'LineWidth',3);
axis([1 obj.XPixels 1 obj.YPixels]);

% Display a legend
handles.ROIlegend = legend('Current ROI','Potential ROI');
set(handles.ROIlegend,'FontWeight','bold','FontSize',0.05)

% Build a duplicate of the original ROI to put an ROI outline
handles.top_patch = patch(handles.OG_vertices(:,1), handles.OG_vertices(:,2),'b','tag','top_box');
set(handles.top_patch,'FaceAlpha',0);
set(handles.top_patch,'EdgeColor',[0 0 0],'LineWidth',3,'LineStyle','--');

% set the original CCD image on top
uistack(handles.OG_patch,'top')

% plot ROI face
    function plotROI(filetab,eventdata)
        delete(findall(handles.imgAx,'tag','ROI_box'));
        ROIvec = str2num(get(handles.ROIBox,'String'));
        handles.ROI_vertices = [ROIvec(1) ROIvec(3); ROIvec(2) ROIvec(3); ROIvec(2) ROIvec(4); ROIvec(1) ROIvec(4)];
        handles.ROI_patch = patch(handles.ROI_vertices(:,1), handles.ROI_vertices(:,2),'b','tag','ROI_box');
        set(handles.ROI_patch,'FaceColor',[0.7 0.7 1],'FaceAlpha',1);
        set(handles.ROI_patch,'EdgeColor',[1 1 1],'LineWidth',3);
        axis([1 obj.XPixels 1 obj.YPixels]);
        
        uistack(handles.ROI_patch,'top'); % put the new ROI above the old one
        
        uistack(handles.top_patch,'top'); % put the outline of the set ROI on top
    end

% plot the original graph once things are committed
    function plotOG(filetab,eventdata)
        delete(findall(handles.imgAx,'tag','OG_box'));
        delete(findall(handles.imgAx,'tag','top_box'));
        OGvec = obj.ROI;
        handles.OG_vertices = [OGvec(1) OGvec(3); OGvec(2) OGvec(3); OGvec(2) OGvec(4); OGvec(1) OGvec(4)];
        handles.OG_patch = patch(handles.OG_vertices(:,1), handles.OG_vertices(:,2),'b','tag','OG_box');

        set(handles.OG_patch,'FaceColor',[1 0.3 0.3],'FaceAlpha',1);
        set(handles.OG_patch,'EdgeColor',[0 0 0],'LineWidth',3);
        axis([1 obj.XPixels 1 obj.YPixels]); 
        
        % Build a duplicate of the original ROI to put an ROI outline
        handles.top_patch = patch(handles.OG_vertices(:,1), handles.OG_vertices(:,2),'b','tag','top_box');
        set(handles.top_patch,'FaceAlpha',0);
        set(handles.top_patch,'EdgeColor',[0 0 0],'LineWidth',3,'LineStyle','--');
        uistack(handles.top_patch,'top'); % put the outline of the set ROI on top
    end

% reset and OK buttons
    % commit changes made on this gui
    function commit(eventdata,fileTab)
        newCCDval = str2num(get(handles.ROIBox,'String'));
        obj.ROI = newCCDval;
        plotOG;
    end

    % reset to defaults
    function reset(eventdata,fileTab)      
        obj.ROI = [1 obj.XPixels 1 obj.YPixels];
        plotOG;
    end

    % cancel any changes made in this window
    function cancel(eventdata,fileTab)
       close(dispFig);
    end

% call back functions
    function ChangeRoi(eventdata,fileTab)
        window_val = get(handles.dispMenu,'Value');
        switch window_val
            case 1
                % full CCD
                temp_variable = [1 obj.XPixels 1 obj.YPixels];
                temp_variable = num2str(temp_variable);                               
            case 2
                % left half
                temp_variable = [1 obj.XPixels/2 1 obj.YPixels];
                temp_variable = num2str(temp_variable);                  
            case 3
                % right half
                temp_variable = [obj.XPixels/2+1 obj.XPixels 1 obj.YPixels];
                temp_variable = num2str(temp_variable);                  
            case 4
                % top half
                temp_variable = [1 obj.XPixels 1 obj.YPixels/2];
                temp_variable = num2str(temp_variable);  
            case 5
                % bottom half
                temp_variable = [1 obj.XPixels obj.YPixels/2+1 obj.YPixels];
                temp_variable = num2str(temp_variable);                  
            case 6
                % center half horizontal
                temp_variable = [1 obj.XPixels obj.YPixels/4+1 3*obj.YPixels/4];
                temp_variable = num2str(temp_variable);  
            case 7
                % center half vertical
                temp_variable = [obj.XPixels/4+1 3*obj.XPixels/4 1 obj.YPixels];
                temp_variable = num2str(temp_variable);  
            case 8
                %quarter CCD centered
                temp_variable = [obj.XPixels/4+1 3*obj.XPixels/4 obj.YPixels/4+1 3*obj.YPixels/4];
                temp_variable = num2str(temp_variable);  
            case 9
                % upper left quadrant
                temp_variable = [1 obj.XPixels/2 1 obj.YPixels/2];
                temp_variable = num2str(temp_variable);  
            case 10
                % upper right quadrant
                temp_variable = [obj.XPixels/2+1 obj.XPixels 1 obj.YPixels/2];
                temp_variable = num2str(temp_variable);  
            case 11
                % lower left quadrant
                temp_variable = [1 obj.XPixels/2 obj.YPixels/2+1 obj.YPixels];
                temp_variable = num2str(temp_variable);  
            case 12
                % lower right quadrant
                temp_variable = [obj.XPixels/2+1 obj.XPixels obj.YPixels/2+1 obj.YPixels];
                temp_variable = num2str(temp_variable);  
            case 13
                % Center left
                temp_variable = [1 obj.XPixels/2 obj.YPixels/4+1 3*obj.YPixels/4];
                temp_variable = num2str(temp_variable);  
            case 14
                % Center right
                temp_variable = [obj.XPixels/2+1 obj.XPixels obj.YPixels/4+1 3*obj.YPixels/4];
                temp_variable = num2str(temp_variable);  

        end
        set(handles.ROIBox,'String',temp_variable);
        plotROI;        
        
    end

end
