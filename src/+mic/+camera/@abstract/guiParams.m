function guiParams(obj)
% general version, knows nothing about camera specifics
% requires obj.GuiDialog structure to generate options
% certain properties can trigger regeneration of options by calling
% obj.build_Guidialog via a callback


% main camera param gui figure
camFig = figure('Units','pixels','Position',[100 100 700 1000],...
    'MenuBar','none','ToolBar','none','Visible','on',...
    'NumberTitle','off','UserData',0,'Tag','ParamSelector.gui');

defaultBackground = get(0,'defaultUicontrolBackgroundColor');


set(camFig,'Color',defaultBackground)
handles.output2 = camFig;
guidata(camFig,handles)

% create panels
panelPosition = [.05 .12 .9 .85];
handles.camPan = uipanel('Parent',camFig,'Units','normalized','fontweight','bold',...
    'Position',panelPosition,'Title','Camera Parameters','Visible','on');

% put in a title
set(camFig,'Name',sprintf('Gui Camera Parameters'))

populate_guiDialog(obj.GuiDialog);

% buttons to OK, reset, or cancel changes
handles.commit_butt = uicontrol('Parent',camFig,'Style','pushbutton','String','Commit','Value',1,'Units','normalized','Position',[.22 .05 .15 .05],'Callback',@commit);
handles.reset_butt = uicontrol('Parent',camFig,'Style','pushbutton','String','Reset','Value',1,'Units','normalized','Position',[.39 .05 .15 .05],'Callback',@reset);
handles.cancel_butt = uicontrol('Parent',camFig,'Style','pushbutton','String','Cancel','Value',1,'Units','normalized','Position',[.56 .05 .15 .05],'Callback',@cancel);

% Call Backs

    % commit changes made on this gui
    function commit(eventdata,fileTab)
        % get user's current selection
        GuiCurSel = getGuiSel(handles.gui,fields(obj.GuiDialog));
        % update guiDialog's current selections
        obj.build_guiDialog(GuiCurSel);
        % transfer to obj.CamSetting
        obj.apply_camSetting;
        % debug
        assignin('base','CameraSetting',obj.CameraSetting);
        % call SDK to apply CameraSetting to camera
        obj.setCamProperties(obj.CameraSetting);
        
        obj.setup_acquisition;
        close(camFig);
    end

    % reset to defaults
    function reset(eventdata,fileTab)
        % use current camera settings
        GuiCurSel = obj.camSet2GuiSel(obj.CameraSetting);
        % rebuid GUI structure
        obj.build_guiDialog(GuiCurSel);
        populate_guiDialog(obj.GuiDialog);
    end

    % cancel any changes made in this window
    function cancel(eventdata,fileTab)
       close(camFig);
    end

    function populate_guiDialog(GuiDialog)
        % grab guiDialog values and populate the gui!
        % all it needs to know is the GuiDialog struct

        dialog_field = fields(GuiDialog);
        dialog_length = length(dialog_field);
        
        PosCounter = 1; % counter to position buttons!
        PosAdj = 0.031*PosCounter-0.025;
        for ii = 1:dialog_length
            dialog_ui{ii} = [dialog_field{ii} '_ui'];
            dialog_text{ii} = [dialog_field{ii} '_text'];
            dialog_Rtext{ii} = [dialog_field{ii} '_Rtext'];
            if ~isfield(GuiDialog.(dialog_field{ii}), 'uiType')
            else
%                 if GuiDialog.(dialog_field{ii}).enable
%                     enable = 'on';
%                 else
%                     enable = 'off';
%                 end
                enable = 'on';
                % build Gui based on type of uicontrol
                
                switch GuiDialog.(dialog_field{ii}).uiType
                    case 'select'
                        % bit
                        % desc
                        try
                            % drop down menu content
                            desc = GuiDialog.(dialog_field{ii}).Desc;
                            % current selection
                            val = GuiDialog.(dialog_field{ii}).curVal;
                            if (val > numel(desc))
                                val = 1;
                            end
                            handles.gui.(dialog_text{ii}) = uicontrol('Parent',handles.camPan,'Style','text','String',...
                                                    dialog_field{ii},'Units','normalized','Position',[0.05, PosAdj 0.35 0.03],'Enable',enable);
                            handles.gui.(dialog_ui{ii}) = uicontrol('Parent',handles.camPan,'Style','popupmenu','String',...
                                                     desc,'Value',val,'Units','normalized','BackgroundColor',[1 1 1],'Position',[0.4, PosAdj 0.25 0.03],'Enable',enable);
                            if isfield(GuiDialog.(dialog_field{ii}),'rebuild') && GuiDialog.(dialog_field{ii}).rebuild
                                set(handles.gui.(dialog_ui{ii}),'CallBack',@rebuildGuiOpt)
                            end
                        catch exception
                            throw(exception);
                        end
                    case 'input'
                        % range
                        % default value
                        % desc
                        try
                            range = GuiDialog.(dialog_field{ii}).Range;
                            val = GuiDialog.(dialog_field{ii}).curVal;
                            desc = GuiDialog.(dialog_field{ii}).Desc;
                            if GuiDialog.(dialog_field{ii}).enable
                                enable = 'on';
                            else
                                enable = 'off';
                            end
                            handles.gui.(dialog_text{ii}) = uicontrol('Parent',handles.camPan,'Style','text','String',...
                                                    [dialog_field{ii}],'Units','normalized','Position',[0.05, PosAdj 0.35 0.03],'Enable',enable);
                            handles.gui.(dialog_ui{ii}) = uicontrol('Parent',handles.camPan,'Style','edit','String',...
                                                    num2str(val),'Units','normalized','BackgroundColor',[1 1 1],'Position',[0.4, PosAdj 0.25 0.03],'Enable',enable);     
                            handles.gui.(dialog_Rtext{ii}) = uicontrol('Parent',handles.camPan,'Style','text','String',...
                                                    ['Range is ',regexprep(mat2str(range,4),'\s+','   ')],'Units','normalized','Position',[0.65, PosAdj 0.25 0.03],'Enable','off');                   
                        catch exception
                            throw(exception);
                        end
                    case 'binary'
                            val = GuiDialog.(dialog_field{ii}).curVal;
                            handles.gui.(dialog_text{ii}) = uicontrol('Parent',handles.camPan,'Style','text','String',...
                                                    dialog_field{ii},'Units','normalized','Position',[0.05, PosAdj 0.35 0.03]);
                            handles.gui.(dialog_ui{ii}) = uicontrol('Parent',handles.camPan,'Style','checkbox','Max',2,'Min',1,...
                                                    'Value',val,'Units','normalized','Position',[0.4, PosAdj 0.1 0.03]);
                    otherwise
                end
                
            
          
            PosCounter = PosCounter+1; % increment the position counter!
            PosAdj = 0.031*PosCounter-0.025;
            end
        end
    end

    function rebuildGuiOpt(hObject,event)
        disp('rebuiding GUI options...');
        % first get user's current selection
        GuiCurSel = getGuiSel(handles.gui,fields(obj.GuiDialog));
        % build options based on current selection
        obj.build_guiDialog(GuiCurSel);
        % refresh options
        populate_guiDialog(obj.GuiDialog);
    end

    function GuiCurSel = getGuiSel(uiStruct,guiFields)
        % grab current user selections
        nGuiFields = length(guiFields);
        for ii=1:nGuiFields
            ui_fields = [guiFields{ii},'_ui'];
            %disp(ui_fields);
            if isfield(uiStruct, ui_fields)
                ui_h = uiStruct.(ui_fields);
                switch get(ui_h,'Style')
                    case 'popupmenu'
                        GuiCurSel.(guiFields{ii}).Val = get(ui_h,'value');
                    case 'edit'
                        GuiCurSel.(guiFields{ii}).Val = str2num(get(ui_h,'string'));
                    otherwise % really just checkbox
                        GuiCurSel.(guiFields{ii}).Val = get(ui_h,'value');
                end
            end
            % get current selected parameters
        end

    end
end

