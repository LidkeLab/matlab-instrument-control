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
        
        Pos_Step=obj.Stage_Stepper.Position;
        handles.Text_Step_X.String=sprintf('X: %1.4g',Pos_Step(1));
        handles.Text_Step_Y.String=sprintf('Y: %1.4g',Pos_Step(2));
        handles.Text_Step_Z.String=sprintf('Z: %1.4g',Pos_Step(3));
        
        
        Pos_Piezo=obj.Stage_Piezo.Position;
        handles.Text_Piezo_X.String=sprintf('X: %2.5g',Pos_Piezo(1));
        handles.Text_Piezo_Y.String=sprintf('Y: %2.5g',Pos_Piezo(2));
        handles.Text_Piezo_Z.String=sprintf('Z: %2.5g',Pos_Piezo(3));
    end

    %function gui_Stepper(Source,Callbackdata)
        function gui_Stepper(Source,~)
        switch Source.String
            case 'UP'
                obj.moveStepperUpLarge();
            case 'up'
                obj.moveStepperUpSmall();
            case 'down'
                obj.moveStepperDownSmall();
            case 'DOWN'
                obj.moveStepperDownLarge();
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

