function gui=gui(obj)
%gui_NanoMax: is the graphical user interface (GUI) for mic,NanoMax.m

%Prevent opening more than one figure for same instrument
% if ishandle(obj.GuiFigureStage)
%     guiFig = obj.GuiFigureStage;
%     figure(obj.GuiFigureStage);
%     return
% end

%% Open figure
guiFig = figure();
guiFig.WindowScrollWheelFcn=@gui_Piezo; %Use mouse wheel for piezo focus
guiFig.MenuBar='none';
guiFig.NumberTitle='off';
obj.GuiFigureStage = guiFig;
obj.GuiFigureStage.Name = 'NanoMax Stage Control';
%Prevent closing after a 'close' or 'close all'
obj.GuiFigureStage.HandleVisibility='off';
%Save Propeties upon close
obj.GuiFigureStage.CloseRequestFcn = @closeFigure;
%Size Figure
W=750;
H=700;
X=400;
Y=400;
obj.GuiFigureStage.Position=[X Y W H];
% properties2gui();
 gui2properties();
P=75;
% Stepper Z
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','UP','Enable','on','Position', [P H-150 100 100],'FontSize',16,'Callback',@Up);
 handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','up','Enable','on','Position', [P+19 H-210 60 60],'FontSize',16,'Callback',@Down);
 handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','down','Enable','on','Position', [P+19 H-270 60 60],'FontSize',16,'Callback',@up);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','DOWN','Enable','on','Position', [P H-370 100 100],'FontSize',16,'Callback',@down);
% Stepper XY
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','Y-','Enable','on','Position', [P+550 H-210 80 80],'FontSize',16,'Callback',@YminusS);
 handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','y-','Enable','on','Position', [P+505 H-190 40 40],'FontSize',16,'Callback',@yminusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','Y+','Enable','on','Position', [P+335 H-210 80 80],'FontSize',16,'Callback',@YplusS);
 handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','y+','Enable','on','Position', [P+420 H-190 40 40],'FontSize',16,'Callback',@yplusS);
 handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','x+','Enable','on','Position', [P+463 H-230 40 40],'FontSize',16,'Callback',@xplusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','X+','Enable','on','Position', [P+440 H-315 80 80],'FontSize',16,'Callback',@XplusS);
 handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','x-','Enable','on','Position', [P+463 H-150 40 40],'FontSize',16,'Callback',@xminusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','X-','Enable','on','Position', [P+440 H-105 80 80],'FontSize',16,'Callback',@XminusS);
% Piezo XY
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','Y-','Enable','on','Position', [P+550 H-570 80 80],'FontSize',16,'Callback',@YminusS);
 handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','y-','Enable','on','Position', [P+505 H-540 40 40],'FontSize',16,'Callback',@yminusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','Y+','Enable','on','Position', [P+335 H-570 80 80],'FontSize',16,'Callback',@YplusS);
 handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','y+','Enable','on','Position', [P+420 H-540 40 40],'FontSize',16,'Callback',@yplusS);
 handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','x+','Enable','on','Position', [P+463 H-580 40 40],'FontSize',16,'Callback',@xplusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','X+','Enable','on','Position', [P+440 H-665 80 80],'FontSize',16,'Callback',@XplusS);
 handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','x-','Enable','on','Position', [P+463 H-500 40 40],'FontSize',16,'Callback',@xminusS);
 handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','X-','Enable','on','Position', [P+440 H-455 80 80],'FontSize',16,'Callback',@XminusS);
% uicontrol('Parent',guiFig,'Style', 'Text', 'String','Stepper (mm)','Enable','on','Position', [0 H-125 90 15],'FontSize',10);
% handles.Text_Step_X=uicontrol('Parent',guiFig,'Style', 'Text', 'String','X: 1.000','Enable','on','Position', [10 H-125-15 50 15],'FontSize',8);
% handles.Text_Step_Y=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Y: 1.000','Enable','on','Position', [10 H-125-30 50 15],'FontSize',8);
% handles.Text_Step_Z=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Z: 1.000','Enable','on','Position', [10 H-125-45 50 15],'FontSize',8);
% 
% uicontrol('Parent',guiFig,'Style', 'Text', 'String','Piezo (um)','Enable','on','Position', [150 H-125 90 15],'FontSize',10);
% handles.Text_Piezo_X=uicontrol('Parent',guiFig,'Style', 'Text', 'String','X: 10.00','Enable','on','Position', [150+10 H-125-15 60 15],'FontSize',8);
% handles.Text_Piezo_Y=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Y: 10.00','Enable','on','Position', [150+10 H-125-30 60 15],'FontSize',8);
% handles.Text_Piezo_Z=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Z: 10.00','Enable','on','Position', [150+10 H-125-45 60 15],'FontSize',8);

%Initialize GUI properties
% properties2gui();
% 
    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigureStage);
    end
% 
    function gui2properties()
        % Sets the object properties based on the GUI widgets
    end
% 
%     function properties2gui()
%         % Set the GUI widgets based on the object properties 
%         Pos_Step_Y=obj.Stage_Stepper.getPosition(1);
%         Pos_Step_X=obj.Stage_Stepper.getPosition(2);
%         Pos_Step_Z=obj.Stage_Stepper.getPosition(3);
%         handles.Text_Step_Y.String=sprintf('Y: %1.3g',Pos_Step_Y);
%         handles.Text_Step_X.String=sprintf('X: %1.3g',Pos_Step_X);
%         handles.Text_Step_Z.String=sprintf('Z: %1.3g',Pos_Step_Z);
%         
%         Pos_Piezo_Y=obj.Stage_Piezo_Y.getPosition;
%         Pos_Piezo_X=obj.Stage_Piezo_X.getPosition;
%         Pos_Piezo_Z=obj.Stage_Piezo_Z.getPosition;
%         handles.Text_Piezo_Y.String=sprintf('Y: %2.5f',Pos_Piezo_Y);
%         handles.Text_Piezo_X.String=sprintf('X: %2.5f',Pos_Piezo_X);
%         handles.Text_Piezo_Z.String=sprintf('Z: %2.5f',Pos_Piezo_Z);
%         
%     end
end
