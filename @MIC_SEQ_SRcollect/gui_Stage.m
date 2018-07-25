function gui_Stage = gui(obj)
%gui Graphical User Interface to ExampleInstrument
%   Must contain gui2properties() and properties2gui() functions

%% This will be the same for all gui functions

%Prevent opening more than one figure for same instrument
if ishandle(obj.GuiFigureStage)
    guiFig = obj.GuiFigureStage;
    figure(obj.GuiFigureStage);
    return
end

%% Open figure
guiFig = figure();
guiFig.WindowScrollWheelFcn=@gui_Piezo; %Use mouse wheel for piezo focus
guiFig.MenuBar='none';
guiFig.NumberTitle='off';
obj.GuiFigureStage = guiFig;
obj.GuiFigureStage.Name = 'Stage Control';

%Prevent closing after a 'close' or 'close all'
obj.GuiFigureStage.HandleVisibility='off';

%Save Propeties upon close
obj.GuiFigureStage.CloseRequestFcn = @closeFigure;

%Size Figure
W=250;
H=300;
X=400;
Y=400;
obj.GuiFigureStage.Position=[X Y W H];
properties2gui();
gui2properties();

%UI elements
P=75;
handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','UP','Enable','on','Position', [P H-100 100 100],'FontSize',16,'Callback',@gui_Stepper);
handles.Button_StepSUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','up','Enable','on','Position', [P+25 H-150 50 50],'FontSize',16,'Callback',@gui_Stepper);
handles.Button_StepSSown=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','down','Enable','on','Position', [P+25 H-200 50 50],'FontSize',16,'Callback',@gui_Stepper);
handles.Button_StepLUp=uicontrol('Parent',guiFig,'Style', 'PushButton', 'String','DOWN','Enable','on','Position', [P H-300 100 100],'FontSize',16,'Callback',@gui_Stepper);

uicontrol('Parent',guiFig,'Style', 'Text', 'String','Stepper (mm)','Enable','on','Position', [0 H-125 90 15],'FontSize',10);
handles.Text_Step_X=uicontrol('Parent',guiFig,'Style', 'Text', 'String','X: 1.000','Enable','on','Position', [10 H-125-15 50 15],'FontSize',8);
handles.Text_Step_Y=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Y: 1.000','Enable','on','Position', [10 H-125-30 50 15],'FontSize',8);
handles.Text_Step_Z=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Z: 1.000','Enable','on','Position', [10 H-125-45 50 15],'FontSize',8);

uicontrol('Parent',guiFig,'Style', 'Text', 'String','Piezo (um)','Enable','on','Position', [150 H-125 90 15],'FontSize',10);
handles.Text_Piezo_X=uicontrol('Parent',guiFig,'Style', 'Text', 'String','X: 10.00','Enable','on','Position', [150+10 H-125-15 60 15],'FontSize',8);
handles.Text_Piezo_Y=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Y: 10.00','Enable','on','Position', [150+10 H-125-30 60 15],'FontSize',8);
handles.Text_Piezo_Z=uicontrol('Parent',guiFig,'Style', 'Text', 'String','Z: 10.00','Enable','on','Position', [150+10 H-125-45 60 15],'FontSize',8);


%%
%Initialize GUI properties
properties2gui();


    function closeFigure(~,~)
        gui2properties();
        delete(obj.GuiFigureStage);
    end

%%  All figure have these functions but will be different contents

    function gui2properties()
        % Sets the object properties based on the GUI widgets
    end

    function properties2gui()
        % Set the GUI widgets based on the object properties 
        
        Pos_Step_Y=obj.StageStepper.getPosition(1);
        Pos_Step_X=obj.StageStepper.getPosition(2);
        Pos_Step_Z=obj.StageStepper.getPosition(3);
        handles.Text_Step_Y.String=sprintf('Y: %1.3g',Pos_Step_Y);
        handles.Text_Step_X.String=sprintf('X: %1.3g',Pos_Step_X);
        handles.Text_Step_Z.String=sprintf('Z: %1.3g',Pos_Step_Z);
        
        
        Pos_Piezo_Y=obj.StagePiezoY.getPosition;
        Pos_Piezo_X=obj.StagePiezoX.getPosition;
        Pos_Piezo_Z=obj.StagePiezoZ.getPosition;
        handles.Text_Piezo_Y.String=sprintf('Y: %2.5f',Pos_Piezo_Y);
        handles.Text_Piezo_X.String=sprintf('X: %2.5f',Pos_Piezo_X);
        handles.Text_Piezo_Z.String=sprintf('Z: %2.5f',Pos_Piezo_Z);
    end

    %function gui_Stepper(Source,Callbackdata)
        function gui_Stepper(Source,~)
        switch Source.String
            case 'UP'
                Pos_Step_Z=obj.StageStepper.getPosition(3); %new
                Pos_Z=Pos_Step_Z+obj.StepperLargeStep;
                obj.StageStepper.moveToPosition(3,Pos_Z); %new
            case 'up'
                Pos_Step_Z=obj.StageStepper.getPosition(3); %new
                Pos_Z=Pos_Step_Z+obj.StepperSmallStep;
                obj.StageStepper.moveToPosition(3,Pos_Z); %new
            case 'down'
                Pos_Step_Z=obj.StageStepper.getPosition(3); %new
                Pos_Z=Pos_Step_Z-obj.StepperSmallStep;
                obj.StageStepper.moveToPosition(3,Pos_Z); %new
            case 'DOWN'
                Pos_Step_Z=obj.StageStepper.getPosition(3); %new
                Pos_Z=Pos_Step_Z-obj.StepperLargeStep;
                obj.StageStepper.moveToPosition(3,Pos_Z); %new
        end
        
        
        properties2gui();  
    end

    function gui_Piezo(Source,Callbackdata)
       if Callbackdata.VerticalScrollCount>0 %Move Down
           obj.movePiezoDownSmall();
       else %Move up
           obj.movePiezoUpSmall();
       end
       properties2gui();
    end

end

