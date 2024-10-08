classdef abstract < handle
    % MIC_Abstract Matlab Instrumentation Control Abstract Class
    % 
    % ## Description
    % This abstract class defines a set of Properties and methods that must
    % be implemented in all inheritting classes.  It also provides:
    % 1: A convienient auto-naming feature that will assign the object to a
    % variable name based on the InstrumentName property.  
    % 2: A method to save Attributes and Data to an HDF5 file. 
    %
    % ## Constructor
    % The constructor inheritting class requires 
    % 'obj = obj@mic.abstract(~nargout)'
    % as the first line in the constructor. 
    %
    % ## Note
    % All MATLAB classes for instrument control must inherit from this class.
    %
    % ## REQUIRES:
    %   MATLAB 2014b or higher.
    %
    % ### Citations: Lidkelab, 2015.
    
    properties (Abstract,SetAccess=protected)
        InstrumentName; %Descriptive name of instrument.  Must be a valid Matlab varible name. 
    end
    
    properties (Hidden)
        GuiFigure;      %This property will contain the GUI Figure object. 
        UniqueID;       %Reserved for future use.
    end
    
    properties (Abstract,Hidden)
        StartGUI;       %Defines GUI start mode.  'true' starts GUI on object creation. 
    end
    
    methods
        function obj = abstract(autoName) 
            %Constrcutor
            if nargin==0              %checks to see if there is any input
                autoName = false;
            end
            if autoName                %runs autoname function which assigns a name to your sub-class
                obj.autoName();
            end
            if obj.StartGUI            %starts gui
                obj.gui();
            end
            obj.UniqueID = num2str(cputime);
        end
        
        function delete(obj)
            %Destructor.  Deletes figure on object deletion. 
            delete(obj.GuiFigure); 
        end

        function autoName(obj) 
            % if you forget to name your object when you make an instance of a sub-class that inherits from mic.abstract,
            % this function will give it a name, so prevents MATLAB from assigning the object with the name "ans" that can be easily 
            % rewritten in the workspace and cause many problems. Technically speaking:  
            % Automatically names this object to a top-level workspace variable with a new unused name based on the
            % obects InstrumentName.
            curVars = evalin('base',sprintf('who(''%s*'');',obj.InstrumentName));
            varPattern = sprintf('%s%%i',obj.InstrumentName);
            varName = mic.abstract.nextUnusedName(curVars,varPattern);
            assignin('base',varName,obj);
            fprintf('Assigned new %s object as variable "%s"\n',obj.InstrumentName, varName);
        end
        
        function Err=save2hdf5(obj,File,Group)
            %This function save the Attributes and Data from exportState
            %directly into an HDF5 File as the Group.
            %
            %Example: obj.save2hdf5('Y:\Data\TestFile.h5','/Camera')
            
            try
                %Get Attributes and Data
                [Attributes,Data,Children]=obj.exportState();
                
                mic.abstract.saveAttAndData(File,Group,Attributes,Data,Children);

                Err=0;
            catch ME
                warning('%s:: Error writing to HDF5 file %s',obj.InstrumentName,File)
                ME
                Err=1;
            end   
        end
        
       
        
        
    end % public methods
    
    methods (Abstract)
        gui(obj);
        %All Classes must implement a gui() method that opens the main control GUI
        [Attributes, Data, Children]=exportState(obj);
            %Exports All Relevent Non-Transient Properties as Attributes
            %and Data. Both Attributes and Data must be a single-depth
            %structure (No structures of structures). Children is a structure that
            %contains Objects with the results of their export states. 
            %
            %The Children structure of a top level object would
            %then look like the following example:
            %
            %Children.LampObj.Attributes.Power 
            %Children.LampObj.Data
            %Children.LampObj.Children
            %Children.LaserObj.Attributes.Power
            %Children.LaserObj.Attributes.IsOn
            %Children.LaserObj.Data
            %Children.LaserObj.Children.ShutterObj.Attributes.IsOpen
            %Children.LaserObj.Children.ShutterObj.Data
            %Children.LaserObj.Children.ShutterObj.Children
            
          
            
    end %public abstract methods
    
    methods (Abstract,Access=protected)
    end
    
    methods (Abstract,Static)
        % each class that inherits from mic.abstract has it's own
        % funcTest function which is designed to make an object,
        % test all methods within the object and to make sure they work properly, and to delete the object.
        % if there is need for specific devices to be setup to test all
        % methods of the class, this should be done here.
        Success=funcTest() %force to have output variable for funcTest
    end
    
    methods (Static=true)
        function name=nextUnusedName(currNames,pattern, i) 
            % if you try to make the same object from a sub-class that inherits from mic.abstract multiple times,
            % this function makes sure that the name of this repetitive object is different each time by adding a number at the end 
            % of it.Technically speaking:
            % Returns a unique name using a '%i' pattern that uses the next integer i which would form a unique name
            % and not matching any in currNames.  This can be used to make a new variable name automatically.
            % [IN] currNames - Cell array of strings of existing names matching the pattern that should be avoided
            % [IN] pattern - the name to be used with a '%i' in the string pattern where an integer should be
            %               incrimented to make a unique name
            % [IN] i - [optional] integer to start trying to form unqiue names with
            %
            % [OUT] name - Unqiue name generated from pattern not matching any in currNames.
            if nargin==2
                i=1;
            end
            name=sprintf(pattern,i);
            while any(cellfun(@(s) strcmp(name,s),currNames))
                i=i+1;
                name=sprintf(pattern,i);
            end            
        end
        
        function saveAttAndData(File,Group,Attributes,Data,Children)
            %Save Attributes and data to an existing file in a group
            IsBusy=H5Write_Async();
            while IsBusy
                pause(0.05);
                IsBusy=H5Write_Async();
            end

            %Create group
            mic.H5.createGroup(File,Group)
          
            
            %Save Data
            if isempty(Data)
                %h5create(File,['/' Group],1);
            else
                Data_Names = fieldnames(Data)
                NData=length(Data_Names)
                
                for nn=1:NData
                    h5create(File,['/' Group '/' Data_Names{nn}],size(Data.(Data_Names{nn})));
                    h5write(File,['/' Group '/' Data_Names{nn}],Data.(Data_Names{nn}));
                end
            end
            
            %Save Attributes
            Att_Names = fieldnames(Attributes);
            NAtt=length(Att_Names);
            for nn=1:NAtt
                Att=Attributes.(Att_Names{nn});
                if islogical(Att);Att=single(Att);end
                h5writeatt(File,['/' Group],Att_Names{nn},Att);
            end
            
            %Save the Children!
            if ~isempty(Children)
                Child_Names = fieldnames(Children);
                NChild=length(Child_Names);
                for nn=1:NChild
                    Name=Child_Names{nn};
                    Child=Children.(Child_Names{nn});
                    ChildGroup=[Group '/' Name];
                    mic.abstract.saveAttAndData(File,ChildGroup,Child.Attributes,Child.Data,Child.Children);
                end
            end    
        end
        
         
    end % Publics static methods
    
end




