function guiFig=gui(obj)
% MIC_StepperMotor.gui: This gui is written for the Benchtop stepper motor.
%
% gui has three lines of uicontrols to control X, Y and Z axes (from top to
% the bottom). The Home button moves the stage to the origin. The jog
% buttons at each side of the slider makes the stage to jog with the size
% given in the jog-box. User can use the slider in three different ways.
% 1) They can simply drag the slider. 2) They can click at the buttons at
% the ends of the slider. 3) They can right click on the slider and then use
% the mouse wheel to move the stage. The user has two options for the mouse
% wheel steps, it can be determined using the toggle button at the bottom of
% the gui. The position box shows the current position of the stage and the
% Jog box shows the jog step size.
%
% Functions: properties2gui, homeX, jogXBackward, clickSliderX, wheelX,
%            jogXForward, posX, jogX, homeY, jogYBackward, sliderY,
%            clickSliderY, wheelY, jogYForward, posY, jogY, homeZ,
%            jogZBackward, sliderZ, clickSliderZ, wheelZ, jogZForward, posZ,
%            jogZ, toggSliderStep
%
% REQUIREMENTS:
%   MATLAB 2014 or higher
%   Kinesis software from thorlabs
%   MIC_Abstract class.
%   Access to the mexfunctions for this device. (kinesis_SBC_function).
%
% CITATION: Mohamadreza Fazel, Lidkelab, 2017.

%prevent opening more than one gui for an objext.
if ishandle(obj.GuiFigure)
    guiFig = obj.GuiFigure;
    figure(obj.GuiFigure);
    return
end

%making the figure
guiFig = figure('NumberTitle','off','Resize','off','Units','pixels','MenuBar','none',...
    'ToolBar','none','Visible','on', 'Position',[300 300 1135 550]);
obj.GuiFigure=guiFig;
obj.GuiFigure.Name = obj.InstrumentName;

%X-axis: The order of the uicontrols is from left to the right.
TextX1=uicontrol('Style','text','String','X-axis',...
    'Position',[20 420,60,40],'FontSize',15);

ButtonX1=uicontrol('Style','pushbutton',...
    'String','Home','Position',[90 420,50,50],...
    'BackgroundColor',[0.1  1  0],'Callback',@homeX);

TextX2=uicontrol('Style','text','String','Min X-position: -4 mm',...
    'Position',[180 422,100,40],'FontSize',11);

ButtonX2=uicontrol('Style','pushbutton',...
    'String','< Jog','FontSize',12,'Position',[285 420,50,50],...
    'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogXBackward);

SliderX=uicontrol('Parent',guiFig,'Style','slider','Min',-4,...
    'Max',4,'Value',0,'SliderStep',[0.025 0.025],...
    'Position', [345 420 300 50],'Callback',@sliderX,'ButtonDownFcn',@clickSliderX);

ButtonX3=uicontrol('Style','pushbutton',...
     'String','Jog >','FontSize',12,'Position',[655 420,50,50],...
     'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogXForward);

TextX3=uicontrol('Style','text','String','Max X-position: 4 mm',...
    'Position',[720 422,100,40],'FontSize',11);

TextX4=uicontrol('Style','text','String','X-Pos(mm)',...
    'Position',[850 424,45,40],'FontSize',11);

EditX1= uicontrol('Style','edit',...
    'Position',[900 424,60,40],'FontSize',11,'Callback',@posX);

TextX5=uicontrol('Style','text','String','X-jog(mm)',...
    'Position',[1000 424,38,40],'FontSize',11);

EditX2= uicontrol('Style','edit',...
    'Position',[1050 424,60,40],'FontSize',11,'Callback',@jogX);

%Y-axis: the orders of the uicontrols is from left to the right.
TextY1=uicontrol('Style','text','String','Y-axis',...
    'Position',[20 270,60,40],'FontSize',15);

ButtonY1=uicontrol('Style','pushbutton',...
    'String','Home','Position',[90 270,50,50],...
    'BackgroundColor',[0.1  1  0],'Callback',@homeY);

TextY2=uicontrol('Style','text','String','Min Y-position: -4 mm',...
    'Position',[180 272,100,40],'FontSize',11);

ButtonY2=uicontrol('Style','pushbutton',...
    'String','< Jog','FontSize',12,'Position',[285 270,50,50],...
    'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogYBackward);

SliderY=uicontrol('Parent',guiFig,'Style','slider','Min',-4,...
    'Max',4,'Value',0,'SliderStep',[0.025 0.025],...
    'Position', [345 270 300 50],'Tag','positionSlider',...
    'Callback',@sliderY,'ButtonDownFcn',@clickSliderY);

ButtonY3=uicontrol('Style','pushbutton',...
     'String','Jog >','FontSize',12,'Position',[655 270,50,50],...
     'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogYForward);

TextY3=uicontrol('Style','text','String','Max Y-position: 4 mm',...
    'Position',[720 272,100,40],'FontSize',11);

TextY4=uicontrol('Style','text','String','Y-Pos(mm)',...
    'Position',[850 274,45,40],'FontSize',11);

EditY1= uicontrol('Style','edit',...
    'Position',[900 274,60,40],'FontSize',11,'Callback',@posY);

TextY5=uicontrol('Style','text','String','Y-jog(mm)',...
    'Position',[1000 274,38,40],'FontSize',11);

EditY2= uicontrol('Style','edit',...
    'Position',[1050 274,60,40],'FontSize',11,'Callback',@jogY);

%Z-axis: The order of the uicontrols is from left to the right.
TextZ1=uicontrol('Style','text','String','Z-axis',...
    'Position',[20 120,60,40],'FontSize',15);

ButtonZ1=uicontrol('Style','pushbutton',...
    'String','Home','Position',[90 120,50,50],...
    'BackgroundColor',[0.1  1  0],'Callback',@homeZ);

TextZ2=uicontrol('Style','text','String','Min Z-position: -4 mm',...
    'Position',[180 122,100,40],'FontSize',11);

ButtonZ2=uicontrol('Style','pushbutton',...
    'String','< Jog','FontSize',12,'Position',[285 120,50,50],...
    'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogZBackward);

SliderZ=uicontrol('Parent',guiFig,'Style','slider','Min',-4,...
    'Max',4,'Value',0,'SliderStep',[0.025 0.025],...
    'Position', [345 120 300 50],'Tag','positionSlider',...
    'Callback',@sliderZ,'ButtonDownFcn',@clickSliderZ);

ButtonZ3=uicontrol('Style','pushbutton',...
     'String','Jog >','FontSize',12,'Position',[655 120,50,50],...
     'BackgroundColor',[0.8  0.8  0.8],'Callback',@jogZForward);

TextZ3=uicontrol('Style','text','String','Max Z-position: 4 mm',...
    'Position',[720 122,100,40],'FontSize',11);

TextZ4=uicontrol('Style','text','String','Z-Pos(mm)',...
    'Position',[850 124,45,40],'FontSize',11);

EditZ1= uicontrol('Style','edit',...
    'Position',[900 124,60,40],'FontSize',11,'Callback',@posZ);

TextZ5=uicontrol('Style','text','String','Z-jog(mm)',...
    'Position',[1000 124,38,40],'FontSize',11);

EditZ2= uicontrol('Style','edit',...
    'Position',[1050 124,60,40],'FontSize',11,'Callback',@jogZ);

%The toggle button at the button of the figure which gives the user to
%either choose a large or small step size for the mouse wheel.
Toggle = uicontrol('Style','togglebutton',...
    'String','Fine(0.2mm)','FontSize',10,'Position',[570 30,100,60],...
    'BackgroundColor',[0.8  0.8  0.8],'Tag','positionButton','Callback',@toggSliderStep);

Text = uicontrol('Style','text','String','Mouse Wheel Step',...
    'Position',[460 40,110,40],'FontSize',11);

%setting the sliders and editable texts to the initial values
properties2gui(obj);
%%
    function properties2gui(obj)
        %getting current values and updating the gui.
        %getting axes' positions
        Xpos=str2double(sprintf('%1.4f',obj.getPosition(2)));
        Ypos=str2double(sprintf('%1.4f',obj.getPosition(1)));
        Zpos=str2double(sprintf('%1.4f',obj.getPosition(3)));
        %getting jog step size for different axes.
        Xstep=str2double(sprintf('%1.4f',obj.getJogStep(2)));
        Ystep=str2double(sprintf('%1.4f',obj.getJogStep(1)));
        Zstep=str2double(sprintf('%1.4f',obj.getJogStep(3)));
        %setting for X-axis
        set(SliderX,'Value',Xpos);
        set(EditX1,'String',Xpos);
        set(EditX2,'String',Xstep);
        %setting for Y-axis
        set(SliderY,'Value',Ypos);
        set(EditY1,'String',Ypos);
        set(EditY2,'String',Ystep);
        %setting for Z-axis
        set(SliderZ,'Value',Zpos);
        set(EditZ1,'String',Zpos);
        set(EditZ2,'String',Zstep);
    end
    function homeX(~,~)
        %call back functions for X-axis
        obj.goHome(2);
        set(SliderX,'Value',0);
        set(EditX1,'String',0);
    end
    function jogXBackward(~,~)
        %call back function for X-jog backward.
        Xpos=str2double(sprintf('%1.4f',get(SliderX,'Value')));
        Xstep=str2double(sprintf('%1.4f',obj.getJogStep(2)));
        obj.moveJog(2,-1);
        set(SliderX,'Value',Xpos-Xstep);
        set(EditX1,'String',Xpos-Xstep);
    end
    function sliderX(~,~)
        %callback function for sliderX
        Xpos=str2double(sprintf('%1.4f',get(SliderX,'Value')));
        set(EditX1,'String',Xpos);
        obj.moveToPosition(2,Xpos);
    end
    function clickSliderX(~,~)
        %callback function when the user right click on SliderX.
        %The following line assign a function to the mouse wheel move.
        obj.GuiFigure.WindowScrollWheelFcn = @wheelX;
    end
    function wheelX(~,Event)
        %callback function when user right click on the SliderX and the
        %spin the mouse wheel.
           Step=get(SliderX,'SliderStep');
           Xpos=str2double(sprintf('%1.4f',get(SliderX,'Value')));
           Xpos = (Event.VerticalScrollCount)*Step(1)*8+Xpos;
           set(SliderX,'Value',Xpos);
           set(EditX1,'String',Xpos);
           obj.moveToPosition(2,Xpos);
    end
    function jogXForward(~,~)
        %callback function for the X-jog forward.
        Xpos=str2double(sprintf('%1.4f',obj.getPosition(2)));
        Xstep=str2double(sprintf('%1.4f',obj.getJogStep(2)));
        obj.moveJog(2,1);
        set(SliderX,'Value',Xpos+Xstep);
        set(EditX1,'String',Xpos+Xstep);
    end
    function posX(~,~)
        %call back function when user changes the value inside the prompt
        %for the X-position.
        Xpos=str2double(sprintf('%1.4f',str2double(get(EditX1,'String'))));
        set(SliderX,'Value',Xpos);
        obj.moveToPosition(2,Xpos);
    end
    function jogX(~,~)
        %callback function when user alters the value of jog step size.
        Xstep=str2double(get(EditX2,'String'));
        obj.setJogStep(2,Xstep);
    end
 %call back functions for Y-axis
    function homeY(~,~)
       %callback function for Y-home button.
        obj.goHome(1);
        set(SliderY,'Value',0);
        set(EditY1,'String',0);
    end
    function jogYBackward(~,~)
        %callback function for backward Y-jog
        Ypos=str2double(sprintf('%1.4f',obj.getPosition(1)));
        Ystep=str2double(sprintf('%1.4f',obj.getJogStep(1)));
        obj.moveJog(1,-1);
        set(SliderY,'Value',Ypos-Ystep);
        set(EditY1,'String',Ypos-Ystep);
    end
    function sliderY(~,~)
        %callback function for the SliderY.
        Ypos=str2double(sprintf('%1.4f',get(SliderY,'Value')));
        set(EditY1,'String',Ypos);
        obj.moveToPosition(1,Ypos);
    end
    function clickSliderY(~,~)
        %callback function when the user right clicks on the SliderY.
        %The following line assign a function to the mouse wheel move.
        obj.GuiFigure.WindowScrollWheelFcn = @wheelY;
    end
    function wheelY(~,Event)
        %callback function when user right click on the SliderX and the
        %spin the mouse wheel.
        Step=get(SliderY,'SliderStep');
        Ypos=str2double(sprintf('%1.4f',get(SliderY,'Value')));
        Ypos = (Event.VerticalScrollCount)*Step(1)*8+Ypos;
        set(SliderY,'Value',Ypos);
        set(EditY1,'String',Ypos);
        obj.moveToPosition(1,Ypos);
    end
    function jogYForward(~,~)
        %callback function for the forward Y-jog.
        Ypos=str2double(sprintf('%1.4f',obj.getPosition(1)));
        Ystep=str2double(sprintf('%1.4f',obj.getJogStep(1)));
        obj.moveJog(1,1);
        set(SliderY,'Value',Ypos+Ystep);
        set(EditY1,'String',Ypos+Ystep);
    end
    function posY(~,~)
        %callback function when user changes the value of the Y-Pos box.
        Ypos=str2double(sprintf('%1.4f',str2double(get(EditY1,'String'))));
        set(SliderY,'Value',Ypos);
        obj.moveToPosition(1,Ypos);
    end
    function jogY(~,~)
        %call back function when the user changes the value of the Y-Jog
        %box.
        Ystep=str2double(get(EditY2,'String'));
        obj.setJogStep(1,Ystep);
    end
%call back functions for Z-axis
    function homeZ(~,~)
        %callback function for Z-Homme button
        obj.goHome(3);
        set(SliderZ,'Value',0);
        set(EditZ1,'String',0);
    end
    function jogZBackward(~,~)
        %callback function for the backward Z-jog.
        Zpos=str2double(sprintf('%1.4f',obj.getPosition(3)));
        Zstep=str2double(sprintf('%1.4f',obj.getJogStep(3)));
        obj.moveJog(3,-1);
        set(SliderZ,'Value',Zpos-Zstep);
        set(EditZ1,'String',Zpos-Zstep);
    end
    function sliderZ(~,~)
        %callback function for the slider.
        Zpos=str2double(sprintf('%1.4f',get(SliderZ,'Value')));
        set(EditZ1,'String',Zpos);
        obj.moveToPosition(3,Zpos);
    end
    function clickSliderZ(~,~)
        %callback function when the user right clicks on the SliderY.
        %The following line assign a function to the mouse wheel move.
        obj.GuiFigure.WindowScrollWheelFcn = @wheelZ;
    end
    function wheelZ(~,Event)
        %callback function when user right click on the SliderX and the
        %spin the mouse wheel.
        Step=get(SliderZ,'SliderStep');
        Zpos=str2double(sprintf('%1.4f',get(SliderZ,'Value')));
        Zpos = (Event.VerticalScrollCount)*Step(1)*8+Zpos;
        set(SliderZ,'Value',Zpos);
        set(EditZ1,'String',Zpos);
        obj.moveToPosition(3,Zpos);
    end
   function jogZForward(~,~)
       %callback function for the foreard Z-jog.
        Zpos=str2double(sprintf('%1.4f',obj.getPosition(3)));
        Zstep=str2double(sprintf('%1.4f',obj.getJogStep(3)));
        obj.moveJog(3,1);
        set(SliderZ,'Value',Zpos+Zstep);
        set(EditZ1,'String',Zpos+Zstep);
    end
    function posZ(~,~)
        %callback function when user changes the value of the Z-Pos box.
        Zpos=str2double(sprintf('%1.4f',str2double(get(EditZ1,'String'))));
        set(SliderZ,'Value',Zpos);
        obj.moveToPosition(3,Zpos);
    end
    function jogZ(~,~)
        %callback function when the user changes the value inside the Z-jog
        %box.
        Zstep=str2double(get(EditZ2,'String'));
        obj.setJogStep(3,Zstep);
    end
    function toggSliderStep(~,~)
        %callback function for the togglebutton.
        S=get(Toggle,'String');
        if strcmp(S,'Fine(0.2mm)')==1
         SliderX.SliderStep= [0.0625 0.0625];
         SliderY.SliderStep= [0.0625 0.0625];
         SliderZ.SliderStep= [0.0625 0.0625];
         Toggle.String = 'Coarse(0.5mm)';
        else
         SliderX.SliderStep= [0.025 0.025];
         SliderY.SliderStep= [0.025 0.025];
         SliderZ.SliderStep= [0.025 0.025];
         Toggle.String = 'Fine(0.2mm)';
        end
   end
end
