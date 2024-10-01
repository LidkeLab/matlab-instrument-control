function gui(obj)
% GUI  gui for Camera class
%
% EXAMPLES:
%   CamObj = guiTest; %create empty test gui object
%   camObj.gui; %initialize gui
%
% See also CameraClass, guiTest
%
% Created by Peter Relich (November 2013)

% main GUI figure

h = findall(0,'tag','CameraClass.gui');
if ~(isempty(h))
    figure(h);
    return;
end

guiFig = figure('Units','pixels','Position',[100 100 700 600],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag','CameraClass.gui','HandleVisibility','off');
defaultBackground = get(0,'defaultUicontrolBackgroundColor');
set(guiFig,'Color',defaultBackground)

handles.output = guiFig;

% create toggle buttons
% top side

handles.DisplayButt = uicontrol('Parent',guiFig,'Style','pushbutton',...
    'String','Display','Units','normalized','Position',[.3 .92 .15 .05],...
    'Callback',@showDisp);
handles.CamParamsButt = uicontrol('Parent',guiFig,'Style','pushbutton',...
    'String','Camera Parameters','Units','normalized','Position',[.5 .92 .15 .05],...
    'Callback',@showCam);

% bottom side
handles.TempDisp = uicontrol('Parent',guiFig,'Style','text','String','Not Initialized yet!',...
    'Value',1,'FontSize',10,'FontWeight','Bold','Units','normalized','Position',[.05 .03 .15 .075]);
handles.AbortTab = uicontrol('Parent',guiFig,'Style','pushbutton','String','Abort',...
    'Value',1,'Units','normalized','Position',[.25 .05 .15 .05],'Callback',@abortAcquisition);
% handles.CoolerTab = uicontrol('Parent',guiFig,'Style','pushbutton','String','outParameters',...
%     'Value',1,'Units','normalized','Position',[.39 .05 .15 .05]);%,'Callback',@saveParams);
handles.ExitTab = uicontrol('Parent',guiFig,'Style','pushbutton','String','Exit',...
    'Value',1,'Units','normalized','Position',[.45 .05 .15 .05],'Callback',@shutDown);

% % Add a clock for the temperature displayed
%setup a timer for temperature monitoring
t = timer;
set(t,'ExecutionMode','fixedRate','BusyMode','drop','Period',5);
t.TimerFcn = [{@displayTemp,handles.TempDisp}]; %uncomment for working temp readout
%t.TimerFcn = 'disp([''gett temp'']);'
start(t)
handles.t=t;

% create panels
panelPosition = [.05 .12 .85 .74];
handles.actPan = uipanel('Parent',guiFig,'Units','normalized','fontweight','bold',...
    'Position',panelPosition,'Title','Action','Visible','off');


% create Action panel
handles.ExpTime_txt = uicontrol('Parent',handles.actPan,'Style','text','String',...
    'Exposure Times (s)','Units','Normalized','Position',[.075 .85 .2 .05]);
handles.OutVar_txt = uicontrol('Parent',handles.actPan,'Style','text','String',...
    'Output Variable','Units','Normalized','Position',[.5 .85 .2 .05]);

handles.focus_Input = uicontrol('Parent',handles.actPan,'Style','edit','String',num2str(obj.ExpTime_Focus),...
    'Units','Normalized','Position',[.1 .75 .15 .075],'BackgroundColor',[1 1 1],'CallBack',@focus_set);
handles.focus_Butt = uicontrol('Parent',handles.actPan,'Style','pushbutton','String','Focus',...
    'Units','Normalized','Position',[.3 .75 .15 .075],'CallBack',@focus_call);
handles.focus_Var = uicontrol('Parent',handles.actPan,'Style','edit','String','focus',...
    'Units','Normalized','Position',[.5 .75 .2 .075],'BackgroundColor',[1 1 1]);
 
handles.capture_Input = uicontrol('Parent',handles.actPan,'Style','edit','String',num2str(obj.ExpTime_Capture),...
    'Units','Normalized','Position',[.1 .60 .15 .075],'BackgroundColor',[1 1 1],'CallBack',@capture_set);
handles.capture_Butt = uicontrol('Parent',handles.actPan,'Style','pushbutton','String','Capture',...
    'Units','Normalized','Position',[.3 .60 .15 .075],'CallBack',@capture_call);
handles.capture_Var = uicontrol('Parent',handles.actPan,'Style','edit','String','capture',...
    'Units','Normalized','Position',[.5 .60 .2 .075],'BackgroundColor',[1 1 1]);
 
handles.sequence_Input = uicontrol('Parent',handles.actPan,'Style','edit','String',num2str(obj.ExpTime_Sequence),...
    'Units','Normalized','Position',[.1 .45 .15 .075],'BackgroundColor',[1 1 1],'CallBack',@sequence_set);
handles.sequence_Butt = uicontrol('Parent',handles.actPan,'Style','pushbutton','String','Sequence',...
    'Units','Normalized','Position',[.3 .45 .15 .075],'CallBack',@sequence_call);
handles.sequence_Var = uicontrol('Parent',handles.actPan,'Style','edit','String','sequence',...
    'Units','Normalized','Position',[.5 .45 .2 .075],'BackgroundColor',[1 1 1]);

handles.sequence_Length_txt = uicontrol('Parent',handles.actPan,'Style','text','String','Sequence Length',...
    'Units','Normalized','Position',[.1 .25 .2 .05]);
handles.sequence_Length_Butt = uicontrol('Parent',handles.actPan,'Style','edit','String',num2str(obj.SequenceLength),...
    'Units','Normalized','Position',[.3 .25 .15 .075],'BackgroundColor',[1 1 1],'CallBack',@sequence_len);
handles.sequence_Period_txt = uicontrol('Parent',handles.actPan,'Style','text','String','Sequence Period',...
    'Units','Normalized','Position',[.1 .15 .2 .05]);
handles.sequence_Period_Butt = uicontrol('Parent',handles.actPan,'Style','edit','String',num2str(obj.SequenceCycleTime),...
    'Units','Normalized','Position',[.3 .15 .15 .075],'BackgroundColor',[1 1 1],'CallBack',@setSequencePeriod);

handles.zoom_txt = uicontrol('Parent',handles.actPan,'Style','text','String','Zoom','Units','Normalized','Position',[.6 .25 .2 .05]);
handles.zoom_butt = uicontrol('Parent',handles.actPan,'Style','popupmenu','String',{'50%','100%','200%','400%','1000%'},...
    'Value',2,'Units','Normalized','Position',[.6 .2 .2 .05],'BackgroundColor',[1 1 1],'CallBack',@zoom_set);


guidata(guiFig,handles)

% create Display panel

objName = [];

obj.GuiFigure=guiFig;

initialize;


%updateButtonColor;

    function initialize(~,~)
        %initialize gui
        
        safefindme
               
        set(handles.actPan,'Visible','on');
        
        set(guiFig,'Name',sprintf('%s.gui(%s): %s',...
            class(obj),objName,objName))
                
    end

    function safefindme
        vars = evalin('base','whos');
        idx = strcmp(class(obj),{vars.class});
        for ii = find(idx)
            tmp = evalin('base',vars(ii).name);
            if tmp == obj
                objName = vars(ii).name;
                return
                %handle multiple references to 1 object
            end
        end
        objName = 'CamObj';
    end

    % update sequence period button
    function setSequencePeriod(fileTab,eventdata)
       set(handles.sequence_Period_Butt,'String',num2str(obj.SequenceCycleTime)); 
        
    end
    
    % Set focus parameter
    function focus_set(fileTab,eventdata)
        % shut off until things are set
        obj.ReadyForAcq=0;
        expTime_focus = get(handles.focus_Input,'String');
        obj.ExpTime_Focus = str2double(expTime_focus);
        
        obj.AcquisitionType = 'focus';
        obj.setup_acquisition;
        set(handles.focus_Input,'String',obj.ExpTime_Focus)
        % turn back on
        obj.ReadyForAcq=1;
    end

    % Call back to Focus
    function focus_call(fileTab,eventdata)
        data_param{1} = get(handles.focus_Var,'String');
        tempImg = obj.start_focus;
        assignin('caller',data_param{1},tempImg);
    end
    
    % Set capture parameter
    function capture_set(fileTab,eventdata)
        % shut off till things are set
        obj.ReadyForAcq=0;
        expTime_capture = get(handles.capture_Input,'String');
        obj.ExpTime_Capture = str2double(expTime_capture);
        
        obj.AcquisitionType = 'capture';
        obj.setup_acquisition;
        set(handles.capture_Input,'String',obj.ExpTime_Capture)
        % turn back on
        obj.ReadyForAcq=1;
    end

    % Call back to Capture
    function capture_call(fileTab,eventdata)
        data_param{2} = get(handles.capture_Var,'String');
        tempImg = obj.start_capture;
        assignin('caller',data_param{2},tempImg);
    end

    % Set sequence parameter
    function sequence_set(fileTab,eventdata)
        % shut off till things are set
        obj.ReadyForAcq=0;
        expTime_sequence = get(handles.sequence_Input,'String');
        obj.ExpTime_Sequence = str2double(expTime_sequence);
        
        obj.AcquisitionType = 'sequence';
        obj.setup_acquisition;
        set(handles.sequence_Input,'String',obj.ExpTime_Sequence)
        set(handles.sequence_Period_Butt,'String',num2str(obj.SequenceCycleTime));
        % turn back on
        obj.ReadyForAcq=1;       
    end

    % Call back to take a sequence
    function sequence_call(fileTab,eventdata)
        data_param{3} = get(handles.sequence_Var,'String');
        tempSeq = obj.start_sequence;
        assignin('caller',data_param{3},tempSeq);
    end

    % determine sequence length
    function sequence_len(fileTab,eventdata)
        % shut off till things are set
        obj.ReadyForAcq=0;
        seq_len = get(handles.sequence_Length_Butt,'String');
        obj.SequenceLength = str2double(seq_len);
        
    end

    % set the display zoom!
    function zoom_set(fileTab,eventdata)
        zoom_val = get(handles.zoom_butt,'Value');
        switch zoom_val
            case 1
                obj.DisplayZoom = 0.5;
            case 2
                obj.DisplayZoom = 1;
            case 3
                obj.DisplayZoom = 2;
            case 4
                obj.DisplayZoom = 4;
            case 5
                obj.DisplayZoom = 10;
        end
        
    end

    % Call back to show ROI selection GUI
    function showDisp(fileTab,eventdata)
        obj.guiDisp;
    end
    
    % Call back to show the gui Parameters
    function showCam(fileTab,eventdata)
%         obj.guiParams;
        obj.guiParams;
    end

    % get temperature
    function displayTemp(varargin)
        [temp, status] = obj.call_temperature;
        if isvalid(varargin{nargin})
            switch status
                case 0 %Acquiring Drive
                    set(varargin{nargin},'ForeGroundColor','black');
                    set(varargin{nargin},'String','not init');
                case 1 % Temperature Stabilized
                    set(varargin{nargin},'ForeGroundColor','green');
                    set(varargin{nargin},'String',num2str(temp));
                case 2 % Temperature Not Reached
                    set(varargin{nargin},'ForeGroundColor','red');
                    set(varargin{nargin},'String',num2str(temp));
                case 3 % Temperature Drift
                    set(varargin{nargin},'ForeGroundColor','blue');
                    set(varargin{nargin},'String',num2str(temp));
            end
        end
        
    end


    % Call back to Abort Acquisition
    function abortAcquisition(fileTab,eventdata)
       % function to abort the camera if its doing something (e.g. taking data) 
        obj.abortnow;
    end

    
    % Call back to Shut Down the Camera
    function shutDown(fileTab,eventdata)
       % call back to shut down the camera 
       handles.dgbox = dialog('Name','Shut Down Camera','Units','pixels','Position',[200 500 500 200]);
       % build the menu in the dialog box
       handles.ShutdownDisp = uicontrol('Parent',handles.dgbox,'Style','text','String',...
           'Are you sure you want to shut the camera down?','FontSize',12,...
           'Units','normalized','Position',[.10 .50 .75 .25]);
       handles.ConfirmShut = uicontrol('Parent',handles.dgbox,'Style','pushbutton','String','Confirm',...
           'Value',1,'Units','normalized','Position',[.25 .25 .20 .15],'Callback',@shutCamOff);
       handles.CancelShut = uicontrol('Parent',handles.dgbox,'Style','pushbutton','String','Cancel',...
           'Value',1,'Units','normalized','Position',[.5 .25 .20 .15],'Callback',@abortShutCam);       
    end

    function shutCamOff(fileTab,eventdata)
       % shuts down the camera
       close(handles.dgbox);
       
       if strcmp(obj.Manufacturer,'Andor')
           if obj.Capabilities.ulCameraType ~= 11 % Not for the Luca!
               [temp, obj.LastError] = call_temperature(obj);
               if temp<0                   
                   obj.change_temperature(20);
%                    while (temp<0)&&(temp~=-999)
%                        pause(5);
%                        fprintf('Current temp: %d  warming to 0 for safe shutdown\n',temp)
%                        [temp, obj.LastError]=obj.call_temperature;
%                    end
               end
           end
           obj.LastError = CoolerOFF;
           obj.errorcheck('CoolerOFF');

       end
       
       exist('handles.t','var');
       try exist('handles.t','var');
           ['deleting timer']
           stop(handles.t);
           delete(handles.t);
       catch ME
           error('timer deletion error');
       end
       
       close(guiFig);
       obj.shutdown;
       
       
       % I need to put a warning to count down on the temperature timer
    end

    function abortShutCam(fileTab,eventdata)
       % closes the dialog window
        close(handles.dgbox);
    end
    
end