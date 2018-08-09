classdef MIC_H5 
    %MIC_H5 A collection of static methods for working with HDF5 files
    %   See individual methods for details.
    %   doc MIC_H5
    % EXAMPLE:  create a new file, and new group and write data
    %
    %File='TestFile.h5';
    %data=uint16(2^16*rand(256,512,10));
    %MIC_H5.createFile(File)
    %MIC_H5.createGroup(File,'Data')
    %MIC_H5.writeAsync_uint16(File,'Data','data1',data)
    %h5disp(File)
    %
    % REQUIRES:
    %   h5Write_Async.mex64
    %   MATLAB 2011a or newer
    
    properties
    end
    
    methods
    end
    
    methods (Static)
        
        function createFile(File)
            %Creates an empty H5 file. 
            if exist(File,'file')
                warning('File: %s Already Exists!',File);
            else
                fid=H5F.create(File);
                H5F.close(fid);
            end
        end
        
        function writeAsync_uint16(File,Group,DataName,Data)
            %Async write to an existing group in an existing H5 file. 
            %Returns immediately to MATLAB
            IsBusy=H5Write_Async(File,Group,DataName,Data);
            while IsBusy
                pause(0.05);
                IsBusy=H5Write_Async(File,Group,DataName,Data);
            end
        end
        
        function createGroup(File,Group)
            %Create a new group in an existing H5 file. 
            plist = 'H5P_DEFAULT';
            fid = H5F.open(File,'H5F_ACC_RDWR',plist);
            gid = H5G.open(fid,'/');
            try %try to open, if so it must exist
                H5G.open(gid,Group);
            catch
                H5G.create(gid,Group,plist,plist,plist);
            end
            
            H5G.close(gid);
            H5F.close(fid);
            fid = H5F.open(File,'H5F_ACC_RDWR',plist);
            gid = H5G.open(fid,Group);
            H5G.close(gid);
            H5F.close(fid);
        end
        
        function [H5Structure] = readH5File(FilePath, GroupName)
        %Extracts contents of an h5 file into H5Structure.
        % This method will extract the Data and Attributes from a group
        % named GroupName in the .h5 file specified by FilePath.  
        % Examples: 
        %   H5Structure = readH5File('C:\file.h5', 'Laser647') will extract
        %       contents of the group 'Laser647' from file.h5 given only the group
        %       name.
        %   H5Structure = readH5File('C:\file.h5', ...
        %       '/Channel01/Zposition001/Laser647') will extract contents of the
        %       group 'Laser647' from file.h5 given a full group path.

            % Ensure that FilePath points to a valid file.
            % NOTE: == 2 means a file indeed exists at FilePath
            if exist(FilePath, 'file') ~= 2
                error(['File specified by FilePath = ', ...
                    '''%s'' does not exist.'], FilePath)
            end

            % Read in all of the information available in the h5 file using 
            % MATLAB's built-in h5info() method.
            H5Info = h5info(FilePath); 

            % Iterate through the structure provided by h5info() to find 
            % the fields specified by GroupName.
            CurrentGroups = H5Info.Groups; % current groups to be explored
            CurrentGroupNames = {CurrentGroups.Name};
            GroupFound = 0; % boolean 0: group not found, 1: group found
            while ~GroupFound
                % Iterate through each of CurrentGroups to search for the 
                % desired group.
                for ii = 1:numel(CurrentGroupNames)
                    % If the GroupName isn't provided as a full path, simplify
                    % the current group name to remove group structure e.g. if 
                    % CurrentGroupNames{ii} = '/Channel01/Zposition001', 
                    % simplify it to 'ZPosition001' for comparison to 
                    % GroupName.
                    if GroupName(1) == '/'
                        % If the first character of the input GroupName is '/',
                        % assume that a full path was provided to the desired
                        % group.
                        CurrentGroupName = CurrentGroupNames{ii}; 
                    else
                        % The full path was not given, just a raw group name was
                        % given.
                        LastSlashIndex = find(CurrentGroupNames{ii}=='/', ...
                            1, 'last'); 
                        CurrentGroupName = ...
                            CurrentGroupNames{ii}(LastSlashIndex+1:end);
                    end

                    % Check if the current group is the desired group, 
                    % breaking out of the for loop if it is.
                    if strcmp(CurrentGroupName, GroupName)
                        GroupFound = 1;
                        break; % exit the current for loop immediately
                    end
                end

                % If the group has not been found yet, move one level 
                % deeper into the structure.
                if ~GroupFound
                    try
                        % Attempt to move one level deeper into the 
                        % structure.
                        CurrentGroups = CurrentGroups.Groups;
                        CurrentGroupNames = {CurrentGroups.Name};
                    catch
                        % We've reached the end of the structure, there are 
                        % no more groups to explore.
                        error(['No group named ''%s'' was found in ', ...
                            'the file specified by FilePath = ''%s'''], ...
                            GroupName, FilePath)
                    end
                end
            end

            % Now that we've found the desired group, store it's Attributes, 
            % Data, and Children in a more useable format.
            % NOTE: to reach this point in the code, we have found the 
            % desired group and it will have been found on the last 
            % iteration of the above for loop, thus the ii-th index will be
            % the index of the desired Group in the CurrentGroups cell 
            % array.
            DesiredGroup = CurrentGroups(ii);
            if ~isempty(DesiredGroup.Attributes)
                % If the desired group has attributes, store them in the output
                % structure.
                for ii = 1:numel(DesiredGroup.Attributes)
                    % Store each attribute as a field in the output structure
                    % accesible directly by that attributes name.
                    AttributeName = DesiredGroup.Attributes(ii).Name;
                    H5Structure.Attributes.(AttributeName) = ...
                        DesiredGroup.Attributes(ii).Value;
                end
            else
                % Create an empty field for the Attributes to prevent issues with
                % functions that may be using this method.
                H5Structure.Attributes = [];
            end
            if ~isempty(DesiredGroup.Datasets)
                for ii = 1:numel(DesiredGroup.Datasets)
                    % Read the ii-th dataset from the h5 file and store the 
                    % data in a field of the output structure, matching the 
                    % datasets name in the h5 file to the name of the field in 
                    % the output structure.
                    H5Structure.Data.(DesiredGroup.Datasets(ii).Name) = ...
                        h5read(FilePath, [DesiredGroup.Name, '/', ...
                            DesiredGroup.Datasets(ii).Name]);
                end
            else
                % Create an empty field for the Data to prevent issues with
                % functions that may be using this method.
                H5Structure.Data = [];
            end
            if ~isempty(DesiredGroup.Groups)
                % Create a cell array of subgroup names (if subgroups exist).
                % NOTE: If you are comparing the output structure to the Data,
                % Attributes, and Children format used in the exportState() method,
                % the subgroups are assumed to be the Children.
                SubgroupNames = {DesiredGroup.Groups.Name};
                for ii = 1:numel(SubgroupNames)
                    % Iteratively explore subgroups of the desired group to
                    % store their attributes and data.
                    SubgroupStructure = h5reader_test(FilePath, ...
                        SubgroupNames{ii});

                    % Remove the path information from the subgroup name, e.g. 
                    % /Channel01/Zposition001 will become Zposition001.
                    LastSlashIndex = find(SubgroupNames{ii}=='/', ...
                            1, 'last');
                    SubgroupName = SubgroupNames{ii}(LastSlashIndex+1:end); 

                    % Store the subgroup structure into the output H5Structure.
                    H5Structure.Children.(SubgroupName) = SubgroupStructure;
                end
            else
                % Create an empty field for the Children to prevent issues with
                % functions that may be using this method.
                H5Structure.Children = [];
            end
        end
    end
    
end

