function guiMotor(obj)

xsz=400;
ysz=200;
xst=200;
yst=100;
pw=.06;
ph=0.12;
px=0.1;
py=0.70;
guiFig = figure('Units','pixels','Position',[xst yst xsz ysz],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag',...
    'SRcollect.guiMotor','HandleVisibility','off','name','SRcollect.guiMotor');%,'CloseRequestFcn',@FigureClose);

defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground);
handles.output = guiFig;
guidata(guiFig,handles);

handles.Button_Yplus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','+','Enable','on','BackgroundColor',[1 0.5 0],'Units','normalized','Position', [px py pw ph],'Callback',@Yplus);
handles.Button_Yminus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','-','Enable','on','BackgroundColor',[1 0.5 0],'Units','normalized','Position', [px py-2*ph pw ph],'Callback',@Yminus);
handles.Button_Xplus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','-','Enable','on','BackgroundColor',[1 0.5 0],'Units','normalized','Position', [px-pw py-ph pw ph],'Callback',@Xminus);
handles.Button_Xminus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','+','Enable','on','BackgroundColor',[1 0.5 0],'Units','normalized','Position', [px+pw py-ph pw ph],'Callback',@Xplus);
uicontrol('Parent',guiFig,'Style','text','String','coarse','Units','normalized','position',[px+2.2*pw py+0.7*ph 1.5*pw ph])
handles.Button_Zplus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','+','Enable','on','BackgroundColor',[0 1 1],'Units','normalized','Position', [px+2.5*pw py-0.5*ph pw 1.5*ph],'Callback',@Zplus);
handles.Button_Zminus=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','-','Enable','on','BackgroundColor',[0 1 1],'Units','normalized','Position', [px+2.5*pw py-2*ph pw 1.5*ph],'Callback',@Zminus);
uicontrol('Parent',guiFig,'Style','text','String','fine','Units','normalized','position',[px+3.7*pw py+0.7*ph 1.5*pw ph])
handles.Button_Zplus_fine=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','+','Enable','on','BackgroundColor',[0 0.7 1],'Units','normalized','Position', [px+4*pw py-0.5*ph pw 1.5*ph],'Callback',@Zplusfine);
handles.Button_Zminus_fine=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','-','Enable','on','BackgroundColor',[0 0.7 1],'Units','normalized','Position', [px+4*pw py-2*ph pw 1.5*ph],'Callback',@Zminusfine);



px=0.17;
uicontrol('Parent',guiFig,'Style','text','String','X','Units','normalized','position',[px+5*pw py-0.025 pw ph])
uicontrol('Parent',guiFig,'Style','text','String','Y','Units','normalized','position',[px+5*pw py-0.025-1.1*ph pw ph])
uicontrol('Parent',guiFig,'Style','text','String','Z','Units','normalized','position',[px+5*pw py-0.025-2.1*ph pw ph])
handles.Edit_XjogSz=uicontrol('Parent',guiFig,'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+6*pw py 3*pw 0.8*ph],'Callback',@XjogSize);
handles.Edit_YjogSz=uicontrol('Parent',guiFig,'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+6*pw py-ph 3*pw 0.8*ph],'Callback',@YjogSize);
handles.Edit_ZjogSz=uicontrol('Parent',guiFig,'Style', 'edit', 'String','0.01','Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+6*pw py-2*ph 3*pw 0.8*ph],'Callback',@ZjogSize);
handles.Text_XPos=uicontrol('Parent',guiFig,'Style', 'text', 'String','0','Enable','on','BackgroundColor',defaultBackground,'Units','normalized','Position', [px+9.5*pw py-0.01 3*pw 0.8*ph]);
handles.Text_YPos=uicontrol('Parent',guiFig,'Style', 'text', 'String','0','Enable','on','BackgroundColor',defaultBackground,'Units','normalized','Position', [px+9.5*pw py-0.01-ph 3*pw 0.8*ph]);
handles.Text_ZPos=uicontrol('Parent',guiFig,'Style', 'text', 'String','0','Enable','on','BackgroundColor',defaultBackground,'Units','normalized','Position', [px+9.5*pw py-0.01-2*ph 3*pw 0.8*ph]);

uicontrol('Parent',guiFig,'Style','text','String','Jog size (mm)','Units','normalized','position',[px+6*pw py+ph 3*pw ph])
uicontrol('Parent',guiFig,'Style','text','String','Current (mm)','Units','normalized','position',[px+9.5*pw py+ph 3*pw ph])

px=0.1;
handles.Button_FindCell=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','Find Cell','Enable','on','BackgroundColor',[0.5 1 0.5],'Units','normalized','Position', [px-1.3*pw py-5*ph 2.5*pw 1.3*ph],'Callback',@FindCell);
handles.Button_MoveTo=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','Move To','Enable','on','BackgroundColor',[1 0.5 1],'Units','normalized','Position', [px+1.6*pw py-5*ph 2.5*pw 1.3*ph],'Callback',@MoveTo);
handles.Button_UnLoad=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','Unload sample','Enable','on','BackgroundColor',[0.8 0.8 0.8],'Units','normalized','Position', [px+10.3*pw py-5*ph 4*pw 1.3*ph],'Callback',@UnLoad);
handles.Button_CenterPiezo=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','Center Piezo','Enable','on','BackgroundColor',[1 1 1],'Units','normalized','Position', [px+4.5*pw py-5*ph 2.7*pw 1.3*ph],'Callback',@Center);
handles.Button_SetZlimit=uicontrol('Parent',guiFig,'Style', 'toggle', 'String','Set Z limit','Enable','on','BackgroundColor',[1 1 0],'Units','normalized','Position', [px+7.5*pw py-5*ph 2.5*pw 1.3*ph],'Callback',@SetZlimit);

propertiesTogui();

    function propertiesTogui()
        set(handles.Edit_XjogSz,'String',num2str(obj.MotorObj.MotorX.JogStepsize));
        set(handles.Edit_YjogSz,'String',num2str(obj.MotorObj.MotorY.JogStepsize));
        set(handles.Edit_ZjogSz,'String',num2str(obj.MotorObj.MotorZ.JogStepsize));
        obj.MotorObj.get_position;
        set(handles.Text_XPos,'String',num2str(obj.MotorObj.Position(1),3));
        set(handles.Text_YPos,'String',num2str(obj.MotorObj.Position(2),3));
        set(handles.Text_ZPos,'String',num2str(obj.MotorObj.Position(3),3));
    end
    function XjogSize(~,~)
        stepsz=str2double(get(handles.Edit_XjogSz,'String'));
        obj.MotorObj.MotorX.JogStepsize=stepsz;
    end

    function YjogSize(~,~)
        stepsz=str2double(get(handles.Edit_YjogSz,'String'));
        obj.MotorObj.MotorY.JogStepsize=stepsz;
    end
    function ZjogSize(~,~)
        stepsz=str2double(get(handles.Edit_ZjogSz,'String'));
        obj.MotorObj.MotorZ.JogStepsize=stepsz;
    end

    function Yplus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        pos=obj.MotorObj.Position();
        pos(2)=pos(2)+str2double(get(handles.Edit_YjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[1 0.5 0]);
        set(h,'Value',0);
    end
    function Yminus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        pos=obj.MotorObj.Position();
        pos(2)=pos(2)-str2double(get(handles.Edit_YjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[1 0.5 0]);
        set(h,'Value',0);
    end
    function Xplus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        pos=obj.MotorObj.Position();
        pos(1)=pos(1)+str2double(get(handles.Edit_XjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[1 0.5 0]);
        set(h,'Value',0);
    end
    function Xminus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        pos=obj.MotorObj.Position();
        pos(1)=pos(1)-str2double(get(handles.Edit_XjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[1 0.5 0]);
        set(h,'Value',0);
    end
    function Zplus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.003);
        pos=obj.MotorObj.Position();
        pos(3)=pos(3)+str2double(get(handles.Edit_ZjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[0 1 1]);
        set(h,'Value',0);
    end
    function Zminus(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.003);
        pos=obj.MotorObj.Position();
        pos(3)=pos(3)-str2double(get(handles.Edit_ZjogSz,'String'));
        obj.MotorObj.set_position(pos)
        UpdatePos();
        set(h,'Backgroundcolor',[0 1 1]);
        set(h,'Value',0);
    end

    function Zplusfine(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.002);
        pos=obj.StageObj.Position;
        pos(3)=pos(3)+0.1; % um
        if pos(3) > 19.9
            error('Piezo will be at its working limit with the button you pushed! Adjust the problem using coarse and fine focus in other direction.')
        end
        obj.StageObj.set_position(pos);
        set(h,'Backgroundcolor',[0 0.7 1]);
        set(h,'Value',0);
    end
    function Zminusfine(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.002);
        pos=obj.StageObj.Position;
        pos(3)=pos(3)-0.1; % um
        if pos(3) < 0.1
            error('Piezo will be at its working limit with the button you pushed! Adjust the problem using coarse and fine focus in other direction.')
        end
        obj.StageObj.set_position(pos);
        set(h,'Backgroundcolor',[0 0.7 1]);
        set(h,'Value',0);
    end

    function FindCell(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        X=obj.MotorObj.Cellpos;
        obj.MotorObj.set_position(X);
        UpdatePos();
        set(h,'Backgroundcolor',[0.5 1 0.5]);
        set(h,'Value',0);
    end

    function MoveTo(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        
        obj.CameraObj.ROI=obj.getROI('R');
        obj.CameraObj.ExpTime_Capture=obj.ExpTime_Capture; %need to update when changing edit box
        obj.CameraObj.AcquisitionType = 'capture';
        obj.CameraObj.setup_acquisition();
        obj.LampObj660.SetPower(obj.LampPower);
        pause(obj.LampWait);
        out=obj.CameraObj.start_capture();
        close(gcf)
        obj.LampObj660.SetPower(0)
        hf=dipshow(permute(out,[2,1]));
        diptruesize(hf,100*obj.CameraObj.DisplayZoom);
        dipmapping(hf,'lin')
        disp('Click on bead in Master Channel to be used for calibration')
        clickPos = dipgetcoords(hf,1);
        
        roi=obj.getROI('R');
        dimx=roi(2)-roi(1)+1;
        dimy=roi(4)-roi(3)+1;
        centerPos=[dimx/2,dimy/2];
        clickPos(2)=dimy-clickPos(2);
        dist=-1.*(clickPos-centerPos).*obj.PixelSize.*1e-3;%mm
        obj.MotorObj.get_position;
        curPos=obj.MotorObj.Position;
        X=curPos;
        X(1)=curPos(1)+dist(1);
        X(2)=curPos(2)+dist(2);
        obj.MotorObj.set_position(X);
        UpdatePos;
        set(h,'Backgroundcolor',[1 0.5 1]);
        set(h,'Value',0);
        close(hf)
    end

    function Center(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(1);
        obj.StageObj.center();
        set(h,'Backgroundcolor',[0.5 1 0.5]);
        set(h,'Value',0);
    end

    function SetZlimit(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(.2);
        obj.MotorObj.Min_Z=obj.MotorObj.Position(3)-.05;
        set(h,'Backgroundcolor',[0.5 1 0.5]);
        set(h,'Value',0);
    end

    function UnLoad(h,~)
        set(h,'Backgroundcolor',[1,0,0]);
        pause(0.001);
        X=single([2,2,4]);
        obj.MotorObj.get_position;
        while sum(X~=obj.MotorObj.Position)
            obj.MotorObj.set_position(X);
            UpdatePos();
            pause(0.5);
            obj.MotorObj.get_position;
        end
        set(h,'Backgroundcolor',[0.8 0.8 0.8]);
        set(h,'Value',0);
    end
    function UpdatePos()
        obj.MotorObj.get_position;
        pos=obj.MotorObj.Position;
        obj.MotorObj.get_position;
        while sum(pos~=obj.MotorObj.Position)==1
            pos=obj.MotorObj.Position;
            obj.MotorObj.get_position;
            set(handles.Text_XPos,'String',num2str(obj.MotorObj.Position(1),3));
            set(handles.Text_YPos,'String',num2str(obj.MotorObj.Position(2),3));
            set(handles.Text_ZPos,'String',num2str(obj.MotorObj.Position(3),3));
            pause(0.003)
            if obj.MotorObj.MotorX.StopFlag==1 || obj.MotorObj.MotorY.StopFlag==1 || obj.MotorObj.MotorZ.StopFlag==1
                break;
            end
        end
        set(handles.Text_XPos,'String',num2str(obj.MotorObj.Position(1),3));
        set(handles.Text_YPos,'String',num2str(obj.MotorObj.Position(2),3));
        set(handles.Text_ZPos,'String',num2str(obj.MotorObj.Position(3),3));
    end

end