classdef MIC_Joystick < handle
    % Matlab instrument class to control the TIRF stage with a joystick
    % ## Description
    % This class controls a microscope stage with a joystick, if said joystick
    % is turned ON through the GUI. You can change the speed/sensitivity in microns/second 
    % on your joystick with the two edit buttons on the GUI. When turning the
    % joystick ON, you pass in the Stage object and it will graph where you
    % are on the stage. When the Joystick is ON, a timer function is used
    % to check whether you are moving/using the joystick and graphs your position 
    % 10 times per second.   This code uses HebiJoystick to control an HID compliant 
    % joystick and uses JSaxes (analog joystick) to move in x and y.  The code uses
    % buttons(1,1) and buttons(1,3) to move in z ,buttons(1,7) is used to center the stage.
    % For example we used a USB N64 controller, you use the analog
    % joystick(JSaxes) to move in x and y.
    % You use the up and down yellow buttons (buttons(1,1) and buttons(1,3)) to 
    % move in z. Press the blue A button(buttons(1,7)) to center the Stage.
    %                Stg.gui
    %                JS=MIC_Joystick()
    %                JS.StageObj=Stg
    %                JS.gui
    % ## REQUIRES:
    % MIC_MCLNanoDrive
    % HebiJoystick: https://www.mathworks.com/matlabcentral/fileexchange/61306-hebirobotics-matlabinput
    % Citation: Sajjad Khan, Lidkelab, 2024.
    properties
        JS_activate=0  %used to control when Joystick is on
        FigGUI         %Figure for your GUI
        InstrumentName='Joystick'
        StageObj       %This gets passed in
        TimerObj       %needed for a timer which checks position/change in position
        JSObj          %used to pass in the HebiJoystick code
        MoveScale=[1,.05]  %Speed/scale of movement in each dimension
        AxesOrientation=[1,-1,1]  %Tell whether or not JS is inverted in each dimension
    end
    
    methods
        function gui(obj)
            Z=findall(0,'Tag','JSGUI'); 
            if~isempty(Z);return;end           %check if a figure is already opened
            F=figure('NumberTitle','off','Position',[100 100 500 300]); %set up a figure for GUI
            set(F, 'MenuBar', 'none'); %turn off the menubar
            set(F, 'ToolBar', 'none'); %turn off the toolbar
            F.Tag='JSGUI'; 
            obj.FigGUI=F;
            F.Name=obj.InstrumentName;
            OnButton=uicontrol('Style', 'pushbutton','String', 'On',... 
                'Position', [10 10 100 50], 'Callback', @startjoystick); % on/off button for joystick, when clicked on the timer begins
            xybutton=uicontrol('Style','edit','String',num2str(obj.MoveScale(1,1)*10),...
                'Position', [250 30 100 35],'Callback',{@changemovescale,1}); %changes how fast you move in y (sensitivity)
            zbutton=uicontrol('Style','edit', 'String',num2str(obj.MoveScale(1,2)*10),...
                'Position', [350 30 100 35],'Callback',{@changemovescale,2}); %changes how fast you move in z (sensitivity)
            xytext=uicontrol('Style','text', 'String', 'xy microns/second',...
                'Position',[250 5 100 20]);  %text box in GUI to explain your changeing sensitivity of x y
            ztext=uicontrol('Style','text', 'String', 'z microns/second',...
                'Position',[350 5 100 20]);  %text box in GUI to explain your changeing sensitivity of z
            ooaxistext=uicontrol('Style','text', 'String', '0,0',...
                'Position',[20 70 20 20]); %corner axis labels
            oymaxaxistext=uicontrol('Style','text', 'String', sprintf("%d,%d",0,obj.StageObj.Max_Y),...
                'Position',[10 260 30 20]); %corner axis labels
            xmaxymaxaxistext=uicontrol('Style','text', 'String', sprintf("%d,%d",obj.StageObj.Max_X,obj.StageObj.Max_Y),...
                'Position',[260 260 50 20]); %corner axis labels
            xmaxoaxistext=uicontrol('Style','text', 'String', sprintf("%d,%d",obj.StageObj.Max_X,0),...
                'Position',[260 75 30 20]); %corner axis labels
            ozaxistext=uicontrol('Style','text', 'String', '0',...
                'Position',[365 80 10 15]); %corner axis labels
            zmaxaxistext=uicontrol('Style','text', 'String', sprintf("%d",obj.StageObj.Max_Z),...
                'Position',[360 260 30 20]); %corner axis labels
            Ax1=axes();
            Ax1.Position=[.1 .3 .4 .6]; %specify the position of the axis
            Ax1.XTick=[]; %turn off the tick marks on axis
            Ax1.YTick=[];
            Ax2=axes();
            Ax2.Position=[.7 .3 .005 .6];
            Ax2.XTick=[];
            Ax2.YTick=[];
            obj.JS_activate=0;  % JS_activate is used to tell if the Joystick is on, if 1 it's on, if 0 it's off
            function changemovescale(source,~,num) %function which changes sensitivity 
                obj.MoveScale(1,num)=str2double(source.String)/10; %figures out which axis you want to change and converts your input to the property "MoveScale"
            end
            function startjoystick(~,~) % correlated to the on button 
                switch obj.JS_activate
                    case 1
                set(OnButton,'String', 'Not Running', 'BackgroundColor',[.5,.5,.5]) %when off sets the button to grey and says "not running"
                obj.JS_activate=0; % JS_activate set to 0 and the joystick is off
                stop(obj.TimerObj) % Stops the timer from running
                delete(obj.TimerObj) %deletes the timer object so that a new one can be created
                    case 0
                set(OnButton,'String', 'Running', 'BackgroundColor','g') % Joystick is on button says running and is green
                obj.JSObj = HebiJoystick(1); % Brings in the HebiJoystick code which allows you use the joystick in matlab
                obj.JS_activate=1; % JS_activate set to 1 and Joystick is on
                obj.TimerObj=timer('ExecutionMode','fixedRate','Period',.1,'TimerFcn',@movestage); %timer obj which calls movestage function every .1 second
                start(obj.TimerObj) %start the timer since button is on
                   
                end
            end
            function movestage(~,~)                  
                [JSAxes, buttons, povs] = read(obj.JSObj);  % check if any part of the joystick is being used
                 if any(JSAxes)  %plot if any part of the joystick is being used
                        figure(F) %Puts all plots into the same GUI
                        plot(Ax1,obj.StageObj.Position(1,1),obj.StageObj.Position(1,2),'o'); %plot where the stage is in x and y
                        Ax1.XLim=[0 obj.StageObj.Max_X]; %set axis limits
                        Ax1.YLim=[0 obj.StageObj.Max_Y];
                        Ax1.XTick=[]; %turn off the tick marks on axis once joystick is on
                        Ax1.YTick=[];
                        X=1; 
                        plot(Ax2,X,obj.StageObj.Position(1,3),'ro'); %plot where the stage is in z on a verticle line
                        Ax2.YLim=[0 obj.StageObj.Max_Z];
                        Ax2.XTick=[];
                        Ax2.YTick=[];
                        obj.StageObj.setPosition([obj.StageObj.Position(1,1)+obj.AxesOrientation(1,1)*obj.MoveScale(1,1)*JSAxes(1,1),...
                            obj.StageObj.Position(1,2)+obj.AxesOrientation(1,2)*JSAxes(1,2)*obj.MoveScale(1,1),...
                            obj.StageObj.Position(1,3)+buttons(1,1)*obj.MoveScale(1,2)-buttons(1,3)*obj.MoveScale(1,2)]); %change the position based on how you move the joystick taking into account microns/second and if your joystick is inverted
                        if buttons(1,7)==1 %blue A button on
                            obj.StageObj.center 
                        end
                 end
            end
        end
    end
end